import json
import unittest

from vending_machine.config import Settings
from vending_machine.database import Database
from vending_machine.models import ProcessingStatus
from vending_machine.push_parser import PushParser
from vending_machine.pushbullet import PushbulletApi, PushbulletError, PushbulletPage, PushbulletPoller, PushbulletStreamClient
from vending_machine.service import VendingService


class FakeResponse:
    status = 200

    def __init__(self, payload):
        self.payload = payload

    def read(self):
        return json.dumps(self.payload).encode("utf-8")

    def __enter__(self):
        return self

    def __exit__(self, *args):
        return False


class SizedResponse(FakeResponse):
    def __init__(self, payload, content_length=None):
        super().__init__(payload)
        self.headers = {}
        if content_length is not None:
            self.headers["Content-Length"] = str(content_length)


class PushbulletTests(unittest.TestCase):
    def test_poll_cursor_is_not_saved_when_processing_fails(self):
        database = Database(":memory:")
        database.set_setting("pushbullet.last_modified", "7")

        class FailingService:
            def __init__(self):
                self.calls = 0

            def handle_push(self, payload, *, now=None):
                self.calls += 1
                if self.calls == 2:
                    raise RuntimeError("processing failed")
                return None

        def opener(request, timeout):
            return FakeResponse(
                {
                    "pushes": [
                        {"iden": "p1", "modified": 8},
                        {"iden": "p2", "modified": 9},
                    ]
                }
            )

        try:
            poller = PushbulletPoller(PushbulletApi("token", opener=opener), database, FailingService())
            with self.assertRaises(RuntimeError):
                poller.poll_once()
            self.assertEqual(database.get_setting("pushbullet.last_modified"), "7")
        finally:
            database.close()

    def test_tickle_polls_and_advances_server_cursor(self):
        requests = []

        def opener(request, timeout):
            requests.append(request.full_url)
            return FakeResponse(
                {
                    "pushes": [
                        {
                            "iden": "p2",
                            "type": "mirror",
                            "package_name": "com.tossbank",
                            "application_name": "Toss",
                            "title": "입금 알림",
                            "body": "입금자: 홍길동\n금액: 20,000원",
                            "modified": 20,
                        },
                        {
                            "iden": "p1",
                            "type": "mirror",
                            "package_name": "com.tossbank",
                            "application_name": "Toss",
                            "title": "입금 알림",
                            "body": "입금자: 홍길동\n금액: 10,000원",
                            "modified": 10,
                        },
                    ]
                }
            )

        database = Database(":memory:")
        service = VendingService(
            database,
            Settings(
                bank_package_name="com.tossbank",
                bank_application_name="Toss",
                bank_title_prefix="입금",
            ),
        )
        try:
            api = PushbulletApi("token", opener=opener)
            poller = PushbulletPoller(api, database, service)
            result = poller.handle_stream_event({"type": "tickle", "subtype": "push"}, now=100)
            self.assertEqual([item.push_id for item in result], ["p1", "p2"])
            self.assertEqual(database.get_setting("pushbullet.last_modified"), "20")
            self.assertIn("modified_after=0", requests[0])
        finally:
            database.close()

    def test_poll_drains_cursor_pages_before_checkpoint(self):
        requests = []
        pages = {
            None: {"pushes": [{"iden": "p1", "modified": 10}], "cursor": "page-2"},
            "page-2": {"pushes": [{"iden": "p2", "modified": 20}]},
        }

        class RecordingService:
            def __init__(self):
                self.calls = []

            def handle_push(self, payload, *, now=None):
                self.calls.append(payload["push"]["iden"])
                return type("Result", (), {"push_id": payload["push"]["iden"]})()

        def opener(request, timeout):
            query = dict(item.split("=", 1) for item in request.full_url.split("?", 1)[1].split("&"))
            cursor = query.get("cursor")
            requests.append(request.full_url)
            return FakeResponse(pages[cursor])

        database = Database(":memory:")
        database.set_setting("pushbullet.last_modified", "0")
        service = RecordingService()
        try:
            poller = PushbulletPoller(PushbulletApi("token", opener=opener), database, service)
            results = poller.poll_once(now=100)
            self.assertEqual([result.push_id for result in results], ["p1", "p2"])
            self.assertEqual(service.calls, ["p1", "p2"])
            self.assertEqual(database.get_setting("pushbullet.last_modified"), "20")
            self.assertIn("cursor=page-2", requests[1])
        finally:
            database.close()

    def test_poll_rejects_repeated_cursor_without_checkpoint(self):
        database = Database(":memory:")
        database.set_setting("pushbullet.last_modified", "7")

        def opener(request, timeout):
            return FakeResponse({"pushes": [], "cursor": "same"})

        try:
            poller = PushbulletPoller(PushbulletApi("token", opener=opener), database, object())
            with self.assertRaises(PushbulletError):
                poller.poll_once()
            self.assertEqual(database.get_setting("pushbullet.last_modified"), "7")
        finally:
            database.close()

    def test_http_response_size_is_bounded(self):
        def opener(request, timeout):
            return SizedResponse({"pushes": []}, content_length=PushbulletApi.max_response_bytes + 1)

        with self.assertRaises(PushbulletError):
            PushbulletApi("token", opener=opener).list_pushes()

    def test_malformed_response_object_is_normalized_to_pushbullet_error(self):
        with self.assertRaises(PushbulletError):
            PushbulletApi("token", opener=lambda request, timeout: object()).list_pushes()

    def test_page_preserves_list_compatibility_and_cursor(self):
        page = PushbulletPage([{"iden": "p1"}], "next")
        self.assertIsInstance(page, list)
        self.assertEqual(page, [{"iden": "p1"}])
        page.sort()
        self.assertEqual(page.pushes[0]["iden"], "p1")
        self.assertEqual(page.cursor, "next")

    def test_modified_cursor_request_is_normalized_and_bounded(self):
        requests = []

        def opener(request, timeout):
            requests.append(request.full_url)
            return FakeResponse({"pushes": []})

        database = Database(":memory:")
        database.set_setting("pushbullet.last_modified", "not-a-number" + "x" * 200)
        try:
            poller = PushbulletPoller(PushbulletApi("token", opener=opener), database, object())
            poller.poll_once()
            self.assertIn("modified_after=0", requests[0])
            self.assertNotIn("not-a-number", requests[0])
        finally:
            database.close()

    def test_stream_event_shape_and_size_are_bounded(self):
        oversized = "{" + "\"body\":\"" + ("x" * PushbulletApi.max_response_bytes) + "\"}"
        with self.assertRaises(PushbulletError):
            PushbulletStreamClient._decode_event(oversized)
        with self.assertRaises(PushbulletError):
            PushbulletStreamClient._decode_event({"items": [None] * (PushbulletApi.max_pushes_per_page + 1)})
        with self.assertRaises(PushbulletError):
            PushbulletStreamClient._decode_event('{"type":"nop","value":NaN}')
        with self.assertRaises(PushbulletError):
            PushbulletStreamClient._decode_event(b"\xff")
        with self.assertRaises(PushbulletError):
            PushbulletStreamClient._decode_event({"value": float("nan")})

    def test_non_object_push_is_quarantined(self):
        database = Database(":memory:")
        service = VendingService(
            database,
            Settings(
                bank_package_name="com.tossbank",
                bank_application_name="Toss",
                bank_title_prefix="입금",
            ),
        )
        try:
            poller = PushbulletPoller(PushbulletApi("token", opener=lambda *args: FakeResponse({"pushes": []})), database, service)
            result = poller.handle_stream_event({"type": "push", "push": None}, now=100)
            self.assertEqual(result[0].status, ProcessingStatus.PARSE_FAILED)
            self.assertTrue(result[0].push_id.startswith("invalid-"))
            self.assertEqual(len(database.list_review_events()), 1)
        finally:
            database.close()

    def test_modified_cursor_is_validated_when_called_directly(self):
        for value in ("NaN", "Infinity", "1e10000", "x" * 65):
            with self.assertRaises(PushbulletError):
                PushbulletApi("token", opener=lambda *args: FakeResponse({"pushes": []})).list_pushes(value)

    def test_direct_mirror_event_is_processed_without_api_poll(self):
        requests = []

        def opener(request, timeout):
            requests.append(request.full_url)
            return FakeResponse({"pushes": []})

        database = Database(":memory:")
        service = VendingService(
            database,
            Settings(
                bank_package_name="com.tossbank",
                bank_application_name="Toss",
                bank_title_prefix="입금",
            ),
        )
        try:
            service.create_order("user-1", "홍길동", 10000, now=100)
            api = PushbulletApi("token", opener=opener)
            notified = []
            poller = PushbulletPoller(api, database, service, on_result=notified.append)
            event = {
                "type": "push",
                "push": {
                    "type": "mirror",
                    "application_name": "Toss",
                    "package_name": "com.tossbank",
                    "title": "입금 알림",
                    "body": "입금자: 홍길동\n금액: 10,000원",
                    "source_device_iden": "device-1",
                    "notification_id": "17",
                    "notification_tag": "deposit",
                },
            }
            result = poller.handle_stream_event(event, now=101)
            self.assertEqual(len(result), 1)
            self.assertEqual(result[0].status, ProcessingStatus.CONSUMED)
            self.assertTrue(result[0].push_id.startswith("mirror-"))
            self.assertEqual(notified, result)
            self.assertEqual(requests, [])
            self.assertEqual(database.get_support_total("user-1"), 10000)
            self.assertEqual(len(database.list_review_events()), 0)
        finally:
            database.close()

    def test_non_tickle_event_is_ignored(self):
        database = Database(":memory:")
        service = VendingService(database, Settings())
        try:
            api = PushbulletApi("token", opener=lambda *args: FakeResponse({"pushes": []}))
            poller = PushbulletPoller(api, database, service)
            self.assertEqual(poller.handle_stream_event({"type": "nop"}), [])
        finally:
            database.close()
