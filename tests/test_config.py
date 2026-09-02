import tempfile
import unittest
from pathlib import Path

from vending_machine.config import Settings, SettingsError


class ConfigTests(unittest.TestCase):
    def test_auto_credit_is_always_enabled(self):
        settings = Settings.from_mapping({})
        self.assertTrue(settings.auto_credit)

    def test_guild_tag_defaults_to_disabled_and_can_be_enabled(self):
        settings = Settings.from_mapping({})
        self.assertEqual(settings.discord_guild_tag_log_channel_id, "")
        self.assertEqual(settings.discord_guild_tag_status_channel_id, "")
        self.assertEqual(settings.discord_guild_tag_role_id, "")
        self.assertEqual(Settings.from_mapping({"DISCORD_GUILD_TAG_ROLE_ID": ""}).discord_guild_tag_role_id, "")

    def test_runtime_endpoints_require_approved_tls_hosts(self):
        Settings.from_mapping({}).validate_runtime_endpoints()
        with self.assertRaises(SettingsError):
            Settings.from_mapping({"DISCORD_GATEWAY_URL": "ws://gateway.discord.gg"}).validate_runtime_endpoints()
        with self.assertRaises(SettingsError):
            Settings.from_mapping({"PUSHBULLET_STREAM_URL": "wss://example.test"}).validate_runtime_endpoints()
        with self.assertRaises(SettingsError):
            Settings.from_mapping({"PUSHBULLET_STREAM_URL": "wss://stream.pushbullet.com/evil"}).validate_runtime_endpoints()
        with self.assertRaises(SettingsError):
            Settings.from_mapping({"PUSHBULLET_STREAM_URL": "wss://stream.pushbullet.com/websocket?debug=1"}).validate_runtime_endpoints()
        with self.assertRaises(SettingsError):
            Settings.from_mapping({"DISCORD_GATEWAY_URL": "wss://gateway.discord.gg/?debug=1"}).validate_runtime_endpoints()

    def test_direct_settings_still_validate_endpoint_syntax(self):
        with self.assertRaises(SettingsError):
            Settings(discord_gateway_url="not-a-url")

    def test_auto_credit_cannot_be_disabled(self):
        with self.assertRaises(SettingsError):
            Settings.from_mapping({"AUTO_CREDIT": "0"})
        with self.assertRaises(SettingsError):
            Settings(auto_credit=False)

    def test_environment_overrides_file(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "vending.ini"
            path.write_text(
                "AUTO_CREDIT=1\nORDER_TTL_SECONDS=10\nBANK_PACKAGE_NAME=com.tossbank\nBANK_APPLICATION_NAME=Toss\nBANK_TITLE_PREFIX=입금\n",
                encoding="utf-8",
            )
            settings = Settings.from_file(path, environ={"AUTO_CREDIT": "1"})
            self.assertTrue(settings.auto_credit)
            self.assertEqual(settings.order_ttl_seconds, 10)

    def test_unknown_key_is_rejected(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "vending.ini"
            path.write_text("NOT_ALLOWED=1\n", encoding="utf-8")
            with self.assertRaises(SettingsError):
                Settings.from_file(path, environ={})

    def test_title_pattern_can_be_used_as_auto_credit_source_filter(self):
        settings = Settings.from_mapping(
            {
                "AUTO_CREDIT": "1",
                "BANK_PACKAGE_NAME": "viva.republica.toss",
                "BANK_APPLICATION_NAME": "토스",
                "BANK_TITLE_PATTERN": r"^[0-9][0-9,]*원\s*입금$",
            }
        )
        self.assertEqual(settings.bank_title_pattern, r"^[0-9][0-9,]*원\s*입금$")

    def test_native_pattern_contract_rejects_unsupported_patterns(self):
        for key in ("BANK_TITLE_PATTERN", "BANK_AMOUNT_PATTERN", "BANK_NAME_PATTERN"):
            with self.subTest(key=key):
                with self.assertRaises(SettingsError):
                    Settings.from_mapping({key: "^anything$"})

    def test_native_pattern_contract_accepts_supported_body_patterns(self):
        settings = Settings.from_mapping(
            {
                "BANK_AMOUNT_PATTERN": r"(?:입금액|입금금액|금액|amount)\s*[:：]?\s*([0-9][0-9,]*)",
                "BANK_NAME_PATTERN": r"(?:입금자|보낸분|보낸 사람|sender|name)\s*[:：]?\s*([^\r\n,()]{1,100})",
            }
        )
        self.assertTrue(settings.bank_amount_pattern)
        self.assertTrue(settings.bank_name_pattern)

    def test_native_pattern_contract_accepts_supported_title_amount_pattern(self):
        settings = Settings.from_mapping(
            {
                "BANK_AMOUNT_PATTERN": r"([0-9][0-9,]*)원\s*입금",
            }
        )
        self.assertEqual(settings.bank_amount_pattern, r"([0-9][0-9,]*)원\s*입금")
