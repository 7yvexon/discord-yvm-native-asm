import json
import threading
import unittest

from vending_machine.config import Settings
from vending_machine.database import Database
from vending_machine.pushbullet import PushbulletApi, PushbulletPoller, PushbulletStreamClient
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


class FakeStreamSocket:
    def __init__(self, stop_event):
        self.stop_event = stop_event
        self.sent = []
        self.done = False

    def connect(self):
        return self

    def recv(self, *, timeout=None):
        if self.done:
            self.stop_event.set()
            raise TimeoutError
        self.done = True
        return json.dumps({"type": "tickle", "subtype": "push"})

    def send_text(self, value):
        self.sent.append(value)

    def close(self):
        return None


class PushbulletStreamTests(unittest.TestCase):
    def test_stream_tickle_uses_poller_and_encoded_token(self):
        database = Database(":memory:")
        try:
            service = VendingService(
                database,
                Settings(bank_package_name="p", bank_application_name="a", bank_title_prefix="입금"),
            )
            requests = []

            def opener(request, timeout):
                requests.append(request.full_url)
                return FakeResponse({"pushes": []})

            poller = PushbulletPoller(PushbulletApi("token/value", opener=opener), database, service)
            stop_event = threading.Event()
            websocket = FakeStreamSocket(stop_event)
            stream = PushbulletStreamClient(
                "token/value",
                poller,
                websocket_factory=lambda url: websocket,
                fallback_interval=60,
            )
            stream.run_forever(stop_event)
            self.assertTrue(websocket.done)
            self.assertIn("token%2Fvalue", stream.stream_url)
            self.assertIn("modified_after=0", requests[0])
        finally:
            database.close()


if __name__ == "__main__":
    unittest.main()
