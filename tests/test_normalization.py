import unittest

from vending_machine.errors import ValidationError
from vending_machine.normalization import normalize_depositor_name, parse_amount_input, parse_notification_amount


class NormalizationTests(unittest.TestCase):
    def test_name_trims_and_collapses_whitespace(self):
        self.assertEqual(normalize_depositor_name("  Alice   Kim "), "Alice Kim")

    def test_name_rejects_control_characters(self):
        with self.assertRaises(ValidationError):
            normalize_depositor_name("Alice\nKim")

    def test_name_rejects_surrogate(self):
        with self.assertRaises(ValidationError):
            normalize_depositor_name("Alice\ud800")

    def test_latin_case_policy_only_changes_ascii(self):
        self.assertEqual(normalize_depositor_name("Alice", case_insensitive_latin=True), "alice")
        self.assertEqual(normalize_depositor_name("홍길동", case_insensitive_latin=True), "홍길동")

    def test_modal_amount_accepts_display_formatting(self):
        self.assertEqual(parse_amount_input("10000"), 10000)
        self.assertEqual(parse_amount_input("10,000"), 10000)
        self.assertEqual(parse_amount_input("10,000원"), 10000)
        self.assertEqual(parse_amount_input(" 10,000 원 "), 10000)
        for value in ("₩10000", "1.5", "-1", "0", "", "원10000"):
            with self.subTest(value=value):
                with self.assertRaises(ValidationError):
                    parse_amount_input(value)

    def test_notification_amount_allows_comma(self):
        self.assertEqual(parse_notification_amount("10,000"), 10000)
