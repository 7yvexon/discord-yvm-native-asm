import unittest
from unittest.mock import patch

from vending_machine.config import Settings
from vending_machine.database import Database
from vending_machine.models import DmStatus, OrderStatus, ProcessingStatus
from vending_machine.service import VendingService
from vending_machine.errors import ValidationError


def valid_push(push_id="p1", amount="10,000", name="홍길동", package="com.tossbank"):
    return {
        "type": "push",
        "subtype": "mirror",
        "push": {
            "iden": push_id,
            "type": "mirror",
            "application_name": "Toss",
            "package_name": package,
            "title": "입금 알림",
            "body": f"입금자: {name}\n금액: {amount}원",
            "created": 100,
            "modified": 101,
        },
    }


def direct_mirror_push(amount="10,000", name="홍길동", package="com.tossbank"):
    return {
        "type": "push",
        "push": {
            "type": "mirror",
            "application_name": "Toss",
            "package_name": package,
            "title": "입금 알림",
            "body": f"입금자: {name}\n금액: {amount}원",
            "source_device_iden": "device-1",
            "notification_id": "17",
            "notification_tag": "deposit",
        },
    }


class DatabaseTests(unittest.TestCase):
    def service(self):
        database = Database(":memory:")
        settings = Settings(
            bank_package_name="com.tossbank",
            bank_application_name="Toss",
            bank_title_prefix="입금",
        )
        return database, VendingService(database, settings)

    def test_unique_match_is_automatically_credited_atomically(self):
        database, service = self.service()
        try:
            receipt = service.create_order("user-1", "홍길동", "10000", now=100)
            result = service.handle_push(valid_push(), now=101)
            self.assertEqual(result.status, ProcessingStatus.CONSUMED)
            self.assertEqual(result.order_id, receipt.order.order_id)
            self.assertEqual(database.get_support_total("user-1"), 10000)
            order = database.get_order(receipt.order.order_id)
            self.assertEqual(order.status, OrderStatus.PAID)
            self.assertEqual(order.dm_status, DmStatus.PENDING)
            self.assertEqual(len(database.ledger_rows()), 1)
            duplicate = service.handle_push(valid_push(), now=103)
            self.assertEqual(duplicate.status, ProcessingStatus.DUPLICATE)
            self.assertEqual(database.get_support_total("user-1"), 10000)
        finally:
            database.close()

    def test_interaction_id_reuses_order_without_duplicate(self):
        database, service = self.service()
        try:
            first = service.create_order("user-1", "홍길동", 10000, interaction_id="interaction-1", now=100)
            second = service.create_order("user-1", "홍길동", 10000, interaction_id="interaction-1", now=101)
            self.assertEqual(first.order.order_id, second.order.order_id)
            self.assertEqual(database.connection.execute("SELECT COUNT(*) FROM deposit_orders").fetchone()[0], 1)
            with self.assertRaises(ValidationError):
                service.create_order("user-1", "홍길동", 20000, interaction_id="interaction-1", now=102)
        finally:
            database.close()

    def test_timestampless_direct_mirror_is_automatic_and_idempotent(self):
        database, service = self.service()
        try:
            receipt = service.create_order("user-1", "홍길동", 10000, now=100)
            parsed = service.push_parser.parse(direct_mirror_push())
            self.assertEqual(parsed.status, ProcessingStatus.RECEIVED)
            self.assertIsNone(parsed.event.push_created_at)
            self.assertIsNone(parsed.event.push_modified_at)
            result = service.handle_push(direct_mirror_push(), now=101)
            self.assertEqual(result.status, ProcessingStatus.CONSUMED)
            self.assertEqual(database.get_order(receipt.order.order_id).status, OrderStatus.PAID)
            self.assertEqual(database.get_support_total("user-1"), 10000)
            duplicate = service.handle_push(direct_mirror_push(), now=103)
            self.assertEqual(duplicate.status, ProcessingStatus.DUPLICATE)
            self.assertEqual(database.get_support_total("user-1"), 10000)
            row = database.connection.execute(
                "SELECT push_created_at,push_modified_at,processing_status FROM push_events"
            ).fetchone()
            self.assertEqual(tuple(row), (None, None, ProcessingStatus.CONSUMED.value))
        finally:
            database.close()

    def test_auto_credit_commits_order_ledger_and_total(self):
        database, service = self.service()
        try:
            receipt = service.create_order("user-1", "홍길동", 10000, now=100)
            result = service.handle_push(valid_push(), now=101)
            self.assertEqual(result.status, ProcessingStatus.CONSUMED)
            self.assertEqual(result.order_id, receipt.order.order_id)
            self.assertEqual(database.get_support_total("user-1"), 10000)
            self.assertEqual(len(database.ledger_rows(discord_id="user-1")), 1)
        finally:
            database.close()

    def test_multiple_credits_use_native_total_without_double_counting(self):
        database, service = self.service()
        try:
            service.create_order("user-1", "홍길동", 10000, now=100)
            service.handle_push(valid_push(push_id="p1"), now=101)
            service.create_order("user-1", "김철수", 5000, now=102)
            second_push = valid_push(push_id="p2", amount="5,000", name="김철수")
            second_push["push"]["created"] = 102
            second_push["push"]["modified"] = 103
            result = service.handle_push(second_push, now=103)
            self.assertEqual(result.status, ProcessingStatus.CONSUMED)
            self.assertEqual(database.get_support_total("user-1"), 15000)
        finally:
            database.close()

    def test_two_equal_orders_are_ambiguous(self):
        database, service = self.service()
        try:
            service.create_order("user-1", "홍길동", 10000, now=100)
            service.create_order("user-2", "홍길동", 10000, now=100)
            result = service.handle_push(valid_push(), now=101)
            self.assertEqual(result.status, ProcessingStatus.MATCH_AMBIGUOUS)
            self.assertEqual(database.get_support_total("user-1"), 0)
            self.assertEqual(database.get_support_total("user-2"), 0)
        finally:
            database.close()

    def test_expired_order_is_not_paid(self):
        database = Database(":memory:")
        service = VendingService(
            database,
            Settings(
                bank_package_name="com.tossbank",
                bank_application_name="Toss",
                bank_title_prefix="입금",
                order_ttl_seconds=10,
            ),
        )
        try:
            receipt = service.create_order("user-1", "홍길동", 10000, now=100)
            result = service.handle_push(valid_push(), now=111)
            self.assertEqual(result.status, ProcessingStatus.EXPIRED)
            self.assertEqual(database.get_order(receipt.order.order_id).status, OrderStatus.EXPIRED)
            self.assertEqual(database.get_support_total("user-1"), 0)
        finally:
            database.close()

    def test_stale_push_cannot_match_a_new_order(self):
        database, service = self.service()
        try:
            receipt = service.create_order("user-1", "홍길동", 10000, now=100)
            delayed = valid_push(push_id="delayed")
            delayed["push"]["created"] = 90
            delayed["push"]["modified"] = 91
            result = service.handle_push(delayed, now=101)
            self.assertEqual(result.status, ProcessingStatus.REVIEW)
            self.assertEqual(database.get_order(receipt.order.order_id).status, OrderStatus.PENDING)
            self.assertEqual(database.get_support_total("user-1"), 0)
            row = database.connection.execute(
                "SELECT processing_status FROM push_events WHERE push_id = ?",
                ("delayed",),
            ).fetchone()
            self.assertEqual(row[0], ProcessingStatus.REVIEW.value)
        finally:
            database.close()

    def test_unmatched_amount_does_not_pay(self):
        database, service = self.service()
        try:
            service.create_order("user-1", "홍길동", 10000, now=100)
            result = service.handle_push(valid_push(amount="11,000"), now=101)
            self.assertEqual(result.status, ProcessingStatus.MATCH_NOT_FOUND)
            self.assertEqual(database.get_support_total("user-1"), 0)
        finally:
            database.close()

    def test_unsupported_push_is_recorded_without_matching(self):
        database, service = self.service()
        try:
            service.create_order("user-1", "홍길동", 10000, now=100)
            result = service.handle_push(valid_push(push_id="unsupported", package="com.other"), now=101)
            self.assertEqual(result.status, ProcessingStatus.UNSUPPORTED)
            self.assertEqual(database.get_support_total("user-1"), 0)
        finally:
            database.close()

    def test_credit_failure_rolls_back_everything(self):
        database, service = self.service()
        try:
            receipt = service.create_order("user-1", "홍길동", 10000, now=100)
            with patch.object(database, "_credit_locked", side_effect=RuntimeError("forced")):
                with self.assertRaises(RuntimeError):
                    service.handle_push(valid_push(), now=101)
            self.assertEqual(database.get_support_total("user-1"), 0)
            self.assertEqual(database.get_order(receipt.order.order_id).status, OrderStatus.PENDING)
            self.assertEqual(database.connection.execute("SELECT COUNT(*) FROM push_events").fetchone()[0], 0)
        finally:
            database.close()
