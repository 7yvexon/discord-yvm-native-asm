import unittest

from vending_machine.native_core import NativeCoreError, load_native_core, native_core_available


@unittest.skipUnless(native_core_available(), "native core is not built for this host")
class NativeCoreTests(unittest.TestCase):
    def setUp(self):
        self.core = load_native_core()
        self.assertIsNotNone(self.core)

    def test_amount_parser_accepts_int64_max(self):
        self.assertEqual(self.core.parse_amount(b"9223372036854775807"), 9223372036854775807)

    def test_amount_parser_rejects_invalid_and_overflow(self):
        with self.assertRaises(NativeCoreError):
            self.core.parse_amount(b"10,000")
        with self.assertRaises(NativeCoreError):
            self.core.parse_amount(b"9223372036854775808")

    def test_support_total_arithmetic_checks_int64_overflow(self):
        self.assertEqual(self.core.add_support_total(10000, 5000), 15000)
        self.assertEqual(self.core.add_support_total(9223372036854775806, 1), 9223372036854775807)
        with self.assertRaises(NativeCoreError):
            self.core.add_support_total(9223372036854775807, 1)

    def test_name_normalizer_validates_utf8_and_unicode_whitespace(self):
        self.assertEqual(self.core.normalize_name("\u3000홍\u2003길동\u3000".encode()), "홍 길동".encode())
        with self.assertRaises(NativeCoreError):
            self.core.normalize_name(b"bad\xff")


if __name__ == "__main__":
    unittest.main()
