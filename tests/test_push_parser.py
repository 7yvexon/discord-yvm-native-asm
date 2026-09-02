import unittest

from vending_machine.config import Settings
from vending_machine.models import ProcessingStatus
from vending_machine.push_parser import PushParser


def payload(push_id="p1", package="com.tossbank", title="입금 알림", body="입금자: 홍길동\n금액: 10,000원"):
    return {
        "type": "push",
        "subtype": "mirror",
        "push": {
            "iden": push_id,
            "type": "mirror",
            "application_name": "Toss",
            "package_name": package,
            "title": title,
            "body": body,
            "created": 100,
            "modified": 101,
        },
    }


def direct_mirror_payload(package="com.tossbank", title="입금 알림", body="입금자: 홍길동\n금액: 10,000원"):
    return {
        "type": "push",
        "push": {
            "type": "mirror",
            "application_name": "Toss",
            "package_name": package,
            "title": title,
            "body": body,
            "source_device_iden": "device-1",
            "notification_id": "17",
            "notification_tag": "deposit",
        },
    }


def toss_masked_one_won_payload():
    return {
        "type": "push",
        "push": {
            "type": "mirror",
            "application_name": "토스",
            "package_name": "viva.republica.toss",
            "title": "1원 입금",
            "body": "**** → 내 토스뱅크 통장",
            "notification_id": "masked-notification",
            "source_device_iden": "device-1",
            "source_user_iden": "user-1",
        },
    }


def toss_deposit_payload(name="홍길동", amount="10"):
    return {
        "type": "push",
        "push": {
            "type": "mirror",
            "application_name": "토스",
            "package_name": "viva.republica.toss",
            "title": f"{amount}원 입금",
            "body": f"{name} → 내 토스뱅크 통장",
            "notification_id": "masked-notification",
            "source_device_iden": "masked-device",
            "source_user_iden": "masked-user",
        },
    }


class PushParserTests(unittest.TestCase):
    def setUp(self):
        self.parser = PushParser.from_settings(
            Settings(
                bank_package_name="com.tossbank",
                bank_application_name="Toss",
                bank_title_prefix="입금",
            )
        )

    def test_valid_mirror(self):
        result = self.parser.parse(payload())
        self.assertEqual(result.status, ProcessingStatus.RECEIVED)
        self.assertEqual(result.event.parsed_depositor_name_normalized, "홍길동")
        self.assertEqual(result.event.parsed_amount_krw, 10000)

    def test_timestampless_direct_mirror_without_push_id_is_received(self):
        result = self.parser.parse(direct_mirror_payload())
        self.assertEqual(result.status, ProcessingStatus.RECEIVED)
        self.assertTrue(result.event.push_id.startswith("mirror-"))
        self.assertIsNone(result.event.push_created_at)
        self.assertIsNone(result.event.push_modified_at)
        self.assertEqual(result.event.parsed_depositor_name_normalized, "홍길동")
        self.assertEqual(result.event.parsed_amount_krw, 10000)
        self.assertEqual(result.event.source["id_source"], "fingerprint")

    def test_direct_mirror_fingerprint_is_repeatable(self):
        first = self.parser.parse(direct_mirror_payload())
        second = self.parser.parse(direct_mirror_payload())
        self.assertEqual(first.event.push_id, second.event.push_id)

    def test_direct_mirror_fingerprint_ignores_transport_metadata(self):
        first = direct_mirror_payload()
        second = direct_mirror_payload()
        second["subtype"] = "mirror"
        second["push"]["modified"] = 999
        second["push"]["created"] = 998
        second["push"]["active"] = False
        second["push"]["dismissed"] = True
        self.assertEqual(self.parser.parse(first).event.push_id, self.parser.parse(second).event.push_id)

    def test_masked_toss_one_won_notification_is_not_payment(self):
        parser = PushParser.from_settings(
            Settings(
                bank_package_name="viva.republica.toss",
                bank_application_name="토스",
            )
        )
        result = parser.parse(toss_masked_one_won_payload())
        self.assertEqual(result.status, ProcessingStatus.PARSE_FAILED)
        self.assertIn("depositor name", result.detail or "")
        self.assertIn("amount", result.detail or "")
        self.assertTrue(result.event.push_id.startswith("mirror-"))

    def test_toss_deposit_shape_is_parsed_with_configured_patterns(self):
        parser = PushParser.from_settings(
            Settings(
                bank_package_name="viva.republica.toss",
                bank_application_name="토스",
                bank_title_pattern=r"^[0-9][0-9,]*원\s*입금$",
                bank_amount_pattern=r"([0-9][0-9,]*)원\s*입금",
                bank_name_pattern=r"^([^\r\n→,()]{1,100}?)\s*→\s*내 토스뱅크 통장$",
            )
        )
        result = parser.parse(toss_deposit_payload())
        self.assertEqual(result.status, ProcessingStatus.RECEIVED)
        self.assertEqual(result.event.parsed_depositor_name_normalized, "홍길동")
        self.assertEqual(result.event.parsed_amount_krw, 10)
        self.assertTrue(result.event.push_id.startswith("mirror-"))
        withdrawal = toss_deposit_payload()
        withdrawal["push"]["title"] = "10원 출금"
        rejected = parser.parse(withdrawal)
        self.assertEqual(rejected.status, ProcessingStatus.UNSUPPORTED)

    def test_unsupported_source_is_not_payment(self):
        result = self.parser.parse(payload(package="com.example.other"))
        self.assertEqual(result.status, ProcessingStatus.UNSUPPORTED)
        self.assertIsNone(result.event.parsed_amount_krw)

    def test_ambiguous_values_are_rejected(self):
        result = self.parser.parse(payload(body="입금자: 홍길동\n금액: 10,000원\n금액: 20,000원"))
        self.assertEqual(result.status, ProcessingStatus.PARSE_FAILED)

    def test_repeated_same_value_is_rejected_as_ambiguous(self):
        result = self.parser.parse(payload(body="입금자: 홍길동\n금액: 10,000원\n금액: 10,000원"))
        self.assertEqual(result.status, ProcessingStatus.PARSE_FAILED)

    def test_non_deposit_title_is_rejected_before_parsing(self):
        result = self.parser.parse(payload(title="출금 알림", body="입금자: 홍길동\n금액: 10,000원"))
        self.assertEqual(result.status, ProcessingStatus.UNSUPPORTED)

    def test_invalid_push_id_becomes_non_payment_event(self):
        value = payload()
        value["push"]["iden"] = "bad\x00id"
        result = self.parser.parse(value)
        self.assertEqual(result.status, ProcessingStatus.PARSE_FAILED)
        self.assertTrue(result.event.push_id.startswith("invalid-"))

    def test_whitespace_push_id_becomes_non_payment_event(self):
        value = payload()
        value["push"]["iden"] = "  "
        result = self.parser.parse(value)
        self.assertEqual(result.status, ProcessingStatus.PARSE_FAILED)
        self.assertTrue(result.event.push_id.startswith("invalid-"))

    def test_non_object_payload_is_quarantinable(self):
        result = self.parser.parse(["malformed"])
        self.assertEqual(result.status, ProcessingStatus.PARSE_FAILED)
        self.assertTrue(result.event.push_id.startswith("invalid-"))

    def test_non_finite_or_out_of_range_timestamp_is_parse_failed(self):
        for value in ("inf", "-inf", "Infinity", "1e10000", "1e999999999", str(1 << 80)):
            value_payload = payload()
            value_payload["push"]["created"] = value
            result = self.parser.parse(value_payload)
            self.assertEqual(result.status, ProcessingStatus.PARSE_FAILED)
            self.assertIn("timestamp", result.detail or "")

    def test_non_mirror_envelope_is_rejected(self):
        value_payload = payload()
        value_payload["push"]["type"] = "note"
        result = self.parser.parse(value_payload)
        self.assertEqual(result.status, ProcessingStatus.PARSE_FAILED)

    def test_missing_id_malformed_mirror_has_quarantine_key(self):
        value_payload = direct_mirror_payload(body="x" * 20000)
        result = self.parser.parse(value_payload)
        self.assertEqual(result.status, ProcessingStatus.PARSE_FAILED)
        self.assertTrue(result.event.push_id.startswith("mirror-"))

    def test_truncated_fingerprint_keeps_distinct_suffixes(self):
        first = direct_mirror_payload(body="x" * 1024 + "금액: 10원")
        second = direct_mirror_payload(body="x" * 1024 + "금액: 20원")
        self.assertNotEqual(self.parser.parse(first).event.push_id, self.parser.parse(second).event.push_id)

    def test_fingerprint_overflow_is_independent_of_mapping_order(self):
        first = direct_mirror_payload()
        second = direct_mirror_payload()
        common = {f"common-{index}": index for index in range(70)}
        first["push"].update(common)
        second["push"].update(common)
        first["push"].update({f"extra-{index}": index for index in range(70)})
        second["push"].update({f"extra-{index}": index for index in reversed(range(70))})
        self.assertEqual(self.parser.parse(first).event.push_id, self.parser.parse(second).event.push_id)

    def test_fingerprint_first_items_are_independent_of_mapping_order(self):
        first = direct_mirror_payload()
        second = direct_mirror_payload()
        fields = {f"extra-{index}": index for index in range(100)}
        first["push"].update(fields)
        second["push"].update(reversed(list(fields.items())))
        self.assertEqual(self.parser.parse(first).event.push_id, self.parser.parse(second).event.push_id)
