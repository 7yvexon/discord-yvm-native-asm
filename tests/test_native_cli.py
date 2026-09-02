import json
import os
import sqlite3
import subprocess
import tempfile
import time
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
NATIVE_BINARY = Path(
    os.environ.get(
        "YUL_NATIVE_BINARY",
        str(ROOT / "build" / "windows-x64" / "yul-vending-machine.exe"),
    )
)
NATIVE_AVAILABLE = NATIVE_BINARY.exists() and (os.name == "nt" or "YUL_NATIVE_BINARY" in os.environ)


def native_config(
    database_path,
    *,
    package,
    application,
    title_prefix,
    push_token="",
    title_pattern="",
    amount_pattern=r"(?:입금액|입금금액|금액|amount)\s*[:：]?\s*([0-9][0-9,]*)",
    name_pattern=r"(?:입금자|보낸분|보낸 사람|sender|name)\s*[:：]?\s*([^\r\n,()]{1,100})",
):
    return "\n".join(
        [
            "DISCORD_BOT_TOKEN=native-test-discord-token",
            "DISCORD_APPLICATION_ID=123456789012345678",
            "DISCORD_GUILD_ID=223456789012345678",
            "DISCORD_PANEL_CHANNEL_ID=323456789012345678",
            "DISCORD_ADMIN_USER_ID=423456789012345678",
            "DISCORD_GATEWAY_URL=wss://gateway.discord.gg/?v=10&encoding=json",
            "DISCORD_INTENTS=1",
            "PUSHBULLET_ACCESS_TOKEN=" + push_token,
            "PUSHBULLET_STREAM_URL=wss://stream.pushbullet.com/websocket",
            "BANK_NAME=테스트은행",
            "BANK_ACCOUNT_NUMBER=1234567890",
            "BANK_ACCOUNT_HOLDER=테스트",
            "BANK_PACKAGE_NAME=" + package,
            "BANK_APPLICATION_NAME=" + application,
            "BANK_TITLE_PREFIX=" + title_prefix,
            "BANK_TITLE_PATTERN=" + title_pattern,
            "BANK_AMOUNT_PATTERN=" + amount_pattern,
            "BANK_NAME_PATTERN=" + name_pattern,
            "ORDER_TTL_SECONDS=1800",
            "MIN_AMOUNT_KRW=",
            "MAX_AMOUNT_KRW=",
            "AUTO_CREDIT=1",
            "CASE_INSENSITIVE_LATIN=0",
            "DATABASE_PATH=" + str(database_path),
            "",
        ]
    )


@unittest.skipUnless(NATIVE_AVAILABLE, "native binary is not built")
class NativeCliTests(unittest.TestCase):
    def setUp(self):
        self.temp_dir = tempfile.TemporaryDirectory(prefix="yul-native-cli-")
        self.workdir = Path(self.temp_dir.name)
        self.database_path = self.workdir / "data" / "vending.db"
        self.database_path.parent.mkdir(parents=True, exist_ok=True)
        self.config_path = self.workdir / "native.ini"
        self.config_path.write_text(
            native_config(
                self.database_path,
                package="com.tossbank",
                application="Toss",
                title_prefix="입금",
            ),
            encoding="utf-8",
        )

    def tearDown(self):
        self.temp_dir.cleanup()

    def run_native(self, *arguments, timeout=15, check=True):
        result = subprocess.run(
            [str(NATIVE_BINARY), "--config", str(self.config_path), *arguments],
            cwd=self.workdir,
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="replace",
            timeout=timeout,
        )
        if check:
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        return result

    def initialize_database(self):
        self.run_native("init-db")

    def test_validate_config_accepts_complete_operational_config(self):
        self.config_path.write_text(
            native_config(
                self.database_path,
                package="com.tossbank",
                application="Toss",
                title_prefix="입금",
                push_token="native-test-push-token",
            ),
            encoding="utf-8",
        )
        result = self.run_native("validate-config")
        self.assertIn("native config valid", result.stdout)

    def test_validate_config_accepts_python_boolean_spellings(self):
        for value in ("true", "TRUE", "yes", "YES", "false", "FALSE", "no", "NO"):
            with self.subTest(value=value):
                config = native_config(
                    self.database_path,
                    package="com.tossbank",
                    application="Toss",
                    title_prefix="입금",
                    push_token="native-test-push-token",
                ).replace("AUTO_CREDIT=1", "AUTO_CREDIT=true")
                config = config.replace("CASE_INSENSITIVE_LATIN=0", f"CASE_INSENSITIVE_LATIN={value}")
                self.config_path.write_text(config, encoding="utf-8")
                result = self.run_native("validate-config")
                self.assertIn("native config valid", result.stdout)

    def test_validate_config_rejects_empty_required_value(self):
        self.config_path.write_text(
            native_config(
                self.database_path,
                package="com.tossbank",
                application="Toss",
                title_prefix="입금",
                push_token="native-test-push-token",
            ).replace("DISCORD_BOT_TOKEN=native-test-discord-token", "DISCORD_BOT_TOKEN="),
            encoding="utf-8",
        )
        result = self.run_native("validate-config", check=False)
        self.assertEqual(result.returncode, 1)
        self.assertIn("native config invalid", result.stdout)

    def test_validate_config_rejects_missing_required_key(self):
        self.config_path.write_text(
            native_config(
                self.database_path,
                package="com.tossbank",
                application="Toss",
                title_prefix="입금",
                push_token="native-test-push-token",
            ).replace("DISCORD_BOT_TOKEN=native-test-discord-token\n", ""),
            encoding="utf-8",
        )
        result = self.run_native("validate-config", check=False)
        self.assertEqual(result.returncode, 1)
        self.assertIn("native config invalid", result.stdout)

    def test_validate_config_rejects_invalid_numeric_value(self):
        self.config_path.write_text(
            native_config(
                self.database_path,
                package="com.tossbank",
                application="Toss",
                title_prefix="입금",
                push_token="native-test-push-token",
            ).replace("ORDER_TTL_SECONDS=1800", "ORDER_TTL_SECONDS=not-a-number"),
            encoding="utf-8",
        )
        result = self.run_native("validate-config", check=False)
        self.assertEqual(result.returncode, 1)
        self.assertIn("native config invalid", result.stdout)

    def test_validate_config_rejects_embedded_key_value(self):
        self.config_path.write_text(
            native_config(
                self.database_path,
                package="com.tossbank",
                application="Toss",
                title_prefix="입금",
                push_token="native-test-push-token",
            )
            .replace("DISCORD_BOT_TOKEN=native-test-discord-token\n", "")
            .replace("BANK_NAME=테스트은행", "BANK_NAME=DISCORD_BOT_TOKEN=spoofed"),
            encoding="utf-8",
        )
        result = self.run_native("validate-config", check=False)
        self.assertEqual(result.returncode, 1)
        self.assertIn("native config invalid", result.stdout)

    def test_validate_config_rejects_unknown_or_malformed_line(self):
        for line in ("UNKNOWN_SETTING=value", "BROKEN_SETTING"):
            with self.subTest(line=line):
                self.config_path.write_text(
                    native_config(
                        self.database_path,
                        package="com.tossbank",
                        application="Toss",
                        title_prefix="입금",
                        push_token="native-test-push-token",
                    )
                    + line
                    + "\n",
                    encoding="utf-8",
                )
                result = self.run_native("validate-config", check=False)
                self.assertEqual(result.returncode, 1)
                self.assertIn("native config invalid", result.stdout)

    @unittest.skipUnless("YUL_NATIVE_BINARY" in os.environ, "Linux AArch64 native binary is required")
    def test_validate_config_rejects_oversized_value_without_truncation(self):
        self.config_path.write_text(
            native_config(
                self.database_path,
                package="com.tossbank",
                application="Toss",
                title_prefix="입금",
            ).replace("BANK_NAME=테스트은행", "BANK_NAME=" + ("B" * 512)),
            encoding="utf-8",
        )
        result = self.run_native("validate-config", check=False)
        self.assertEqual(result.returncode, 1)
        self.assertIn("native config invalid", result.stdout)

    @unittest.skipUnless("YUL_NATIVE_BINARY" in os.environ, "Linux AArch64 native binary is required")
    def test_validate_config_rejects_oversized_file_without_truncation(self):
        self.config_path.write_text(
            native_config(
                self.database_path,
                package="com.tossbank",
                application="Toss",
                title_prefix="입금",
            )
            + ("X" * 33000),
            encoding="utf-8",
        )
        result = self.run_native("validate-config", check=False)
        self.assertEqual(result.returncode, 1)
        self.assertIn("native config invalid", result.stdout)

    def test_validate_config_accepts_whitespace_and_missing_trailing_newline(self):
        config = native_config(
            self.database_path,
            package="com.tossbank",
            application="Toss",
            title_prefix="입금",
            push_token="native-test-push-token",
        ).replace(
            "DATABASE_PATH=" + str(self.database_path),
            "  DATABASE_PATH \t= \t" + str(self.database_path) + " \t",
        )
        self.config_path.write_text(config.rstrip("\n"), encoding="utf-8")
        result = self.run_native("validate-config")
        self.assertIn("native config valid", result.stdout)

    def test_validate_config_rejects_invalid_optional_amount_range(self):
        for replacement in (
            ("MIN_AMOUNT_KRW=", "MIN_AMOUNT_KRW=0"),
            ("MAX_AMOUNT_KRW=", "MAX_AMOUNT_KRW=-1"),
            ("MIN_AMOUNT_KRW=\nMAX_AMOUNT_KRW=", "MIN_AMOUNT_KRW=200\nMAX_AMOUNT_KRW=100"),
        ):
            with self.subTest(replacement=replacement):
                self.config_path.write_text(
                    native_config(
                        self.database_path,
                        package="com.tossbank",
                        application="Toss",
                        title_prefix="입금",
                        push_token="native-test-push-token",
                    ).replace(*replacement),
                    encoding="utf-8",
                )
                result = self.run_native("validate-config", check=False)
                self.assertEqual(result.returncode, 1)
                self.assertIn("native config invalid", result.stdout)

    def test_validate_config_rejects_invalid_url_and_intents(self):
        for replacement in (
            (
                "DISCORD_GATEWAY_URL=wss://gateway.discord.gg/?v=10&encoding=json",
                "DISCORD_GATEWAY_URL=http://gateway.discord.gg/?v=10&encoding=json",
            ),
            (
                "DISCORD_GATEWAY_URL=wss://gateway.discord.gg/?v=10&encoding=json",
                "DISCORD_GATEWAY_URL=wss://127.0.0.1/?v=10&encoding=json",
            ),
            (
                "DISCORD_GATEWAY_URL=wss://gateway.discord.gg/?v=10&encoding=json",
                "DISCORD_GATEWAY_URL=wss://gateway.discord.gg/api/?v=10&encoding=json",
            ),
            (
                "DISCORD_GATEWAY_URL=wss://gateway.discord.gg/?v=10&encoding=json",
                "DISCORD_GATEWAY_URL=wss://gateway.discord.gg/?v=10&v=11",
            ),
            (
                "PUSHBULLET_STREAM_URL=wss://stream.pushbullet.com/websocket",
                "PUSHBULLET_STREAM_URL=https://stream.pushbullet.com/websocket",
            ),
            (
                "PUSHBULLET_STREAM_URL=wss://stream.pushbullet.com/websocket",
                "PUSHBULLET_STREAM_URL=wss://example.test/websocket",
            ),
            (
                "PUSHBULLET_STREAM_URL=wss://stream.pushbullet.com/websocket",
                "PUSHBULLET_STREAM_URL=wss://stream.pushbullet.com/evil",
            ),
            (
                "PUSHBULLET_STREAM_URL=wss://stream.pushbullet.com/websocket",
                "PUSHBULLET_STREAM_URL=wss://stream.pushbullet.com/websocket?debug=1",
            ),
            ("DISCORD_INTENTS=1", "DISCORD_INTENTS=-1"),
        ):
            with self.subTest(replacement=replacement):
                self.config_path.write_text(
                    native_config(
                        self.database_path,
                        package="com.tossbank",
                        application="Toss",
                        title_prefix="입금",
                        push_token="native-test-push-token",
                    ).replace(*replacement),
                    encoding="utf-8",
                )
                result = self.run_native("validate-config", check=False)
                self.assertEqual(result.returncode, 1)
                self.assertIn("native config invalid", result.stdout)

    def test_validate_config_rejects_plain_ws_urls(self):
        config = native_config(
            self.database_path,
            package="com.tossbank",
            application="Toss",
            title_prefix="입금",
            push_token="native-test-push-token",
        ).replace(
            "wss://gateway.discord.gg/?v=10&encoding=json",
            "ws://gateway.discord.gg/?v=10&encoding=json",
        ).replace(
            "wss://stream.pushbullet.com/websocket",
            "ws://stream.pushbullet.com/websocket",
        )
        self.config_path.write_text(config, encoding="utf-8")
        result = self.run_native("validate-config", check=False)
        self.assertEqual(result.returncode, 1)
        self.assertIn("native config invalid", result.stdout)

    def test_case_insensitive_latin_normalizes_order_and_push_names(self):
        self.config_path.write_text(
            native_config(
                self.database_path,
                package="com.tossbank",
                application="Toss",
                title_prefix="입금",
                push_token="native-test-push-token",
            ).replace("CASE_INSENSITIVE_LATIN=0", "CASE_INSENSITIVE_LATIN=1"),
            encoding="utf-8",
        )
        self.initialize_database()
        self.create_order(name="Alice")
        payload = {
            "type": "push",
            "subtype": "mirror",
            "push": {
                "iden": "native-case-001",
                "type": "mirror",
                "application_name": "Toss",
                "package_name": "com.tossbank",
                "title": "입금 알림",
                "body": "입금자: alice\n금액: 10,000원",
            },
        }
        path = self.workdir / "case-insensitive.json"
        path.write_text(json.dumps(payload, ensure_ascii=False), encoding="utf-8")
        result = self.run_native("process-push", str(path))
        self.assert_status(result, "CONSUMED")
        total = self.run_native("support-total", "native-user")
        self.assertIn("10000", total.stdout)

    def test_native_sqlite_migration_adds_native_columns_and_interaction_index(self):
        self.database_path.parent.mkdir(parents=True, exist_ok=True)
        connection = sqlite3.connect(self.database_path)
        connection.executescript(
            """
            PRAGMA user_version=1;
            CREATE TABLE deposit_orders(
                order_id TEXT PRIMARY KEY,
                discord_id TEXT NOT NULL,
                depositor_name_input TEXT NOT NULL,
                depositor_name_normalized TEXT NOT NULL,
                requested_amount_krw INTEGER NOT NULL,
                status TEXT NOT NULL,
                created_at INTEGER NOT NULL,
                expires_at INTEGER NOT NULL,
                matched_push_id TEXT UNIQUE,
                matched_amount_krw INTEGER,
                matched_at INTEGER,
                dm_status TEXT NOT NULL
            );
            """
        )
        connection.commit()
        connection.close()

        self.initialize_database()

        connection = sqlite3.connect(self.database_path)
        columns = {row[1] for row in connection.execute("PRAGMA table_info(deposit_orders)")}
        version = connection.execute("PRAGMA user_version").fetchone()[0]
        indexes = {row[1] for row in connection.execute("PRAGMA index_list(deposit_orders)")}
        connection.close()
        self.assertIn("payment_dm_status", columns)
        self.assertIn("interaction_id", columns)
        self.assertIn("idx_deposit_orders_interaction_id", indexes)
        self.assertEqual(version, 3)

    def test_native_cli_orders_keep_null_interaction_ids(self):
        self.initialize_database()
        self.create_order()

        connection = sqlite3.connect(self.database_path)
        interaction_id = connection.execute("SELECT interaction_id FROM deposit_orders").fetchone()[0]
        connection.close()

        self.assertIsNone(interaction_id)

    def test_native_sqlite_migration_accepts_existing_python_order_schema(self):
        self.database_path.parent.mkdir(parents=True, exist_ok=True)
        connection = sqlite3.connect(self.database_path)
        connection.executescript(
            """
            CREATE TABLE deposit_orders(
                order_id TEXT PRIMARY KEY,
                interaction_id TEXT,
                discord_id TEXT NOT NULL,
                depositor_name_input TEXT NOT NULL,
                depositor_name_normalized TEXT NOT NULL,
                requested_amount_krw INTEGER NOT NULL,
                status TEXT NOT NULL,
                created_at INTEGER NOT NULL,
                expires_at INTEGER NOT NULL,
                matched_push_id TEXT UNIQUE,
                matched_amount_krw INTEGER,
                matched_at INTEGER,
                dm_status TEXT NOT NULL,
                payment_dm_status TEXT NOT NULL DEFAULT 'PENDING'
            );
            CREATE UNIQUE INDEX idx_deposit_orders_interaction_id
            ON deposit_orders(interaction_id) WHERE interaction_id IS NOT NULL;
            """
        )
        connection.commit()
        connection.close()

        self.initialize_database()

        connection = sqlite3.connect(self.database_path)
        columns = {row[1] for row in connection.execute("PRAGMA table_info(deposit_orders)")}
        version = connection.execute("PRAGMA user_version").fetchone()[0]
        connection.close()
        self.assertIn("interaction_id", columns)
        self.assertIn("payment_dm_status", columns)
        self.assertEqual(version, 3)

    def test_native_interaction_index_rejects_duplicate_modal_receipts(self):
        self.initialize_database()
        connection = sqlite3.connect(self.database_path)
        columns = [row[1] for row in connection.execute("PRAGMA table_info(deposit_orders)")]
        values = {
            "order_id": "native-modal-1",
            "interaction_id": "interaction-replay-1",
            "discord_id": "native-user",
            "depositor_name_input": "홍길동",
            "depositor_name_normalized": "홍길동",
            "requested_amount_krw": 10000,
            "status": "PENDING",
            "created_at": 100,
            "expires_at": 1900,
            "dm_status": "PENDING",
            "payment_dm_status": "PENDING",
        }
        selected = [column for column in columns if column in values]
        placeholders = ",".join("?" for _ in selected)
        connection.execute(
            f"INSERT INTO deposit_orders({','.join(selected)}) VALUES({placeholders})",
            [values[column] for column in selected],
        )
        connection.commit()
        with self.assertRaises(sqlite3.IntegrityError):
            connection.execute(
                f"INSERT INTO deposit_orders({','.join(selected)}) VALUES({placeholders})",
                ["native-modal-2" if column == "order_id" else values[column] for column in selected],
            )
        count = connection.execute(
            "SELECT COUNT(*) FROM deposit_orders WHERE interaction_id='interaction-replay-1'"
        ).fetchone()[0]
        ledger_count = connection.execute("SELECT COUNT(*) FROM ledger").fetchone()[0]
        connection.close()
        self.assertEqual(count, 1)
        self.assertEqual(ledger_count, 0)

    def create_order(self, user="native-user", name="홍길동", amount="10000"):
        result = self.run_native("create-order", user, name, amount)
        self.assertIn("order-created:", result.stdout)

    def copy_fixture(self, fixture_name, *, fresh_timestamps=False):
        fixture_path = ROOT / "fixtures" / "pushbullet" / fixture_name
        destination = self.workdir / fixture_name
        if fresh_timestamps:
            payload = json.loads(fixture_path.read_text(encoding="utf-8"))
            current = int(time.time())
            payload["push"]["created"] = current
            payload["push"]["modified"] = current
            destination.write_text(json.dumps(payload, ensure_ascii=False), encoding="utf-8")
        else:
            destination.write_bytes(fixture_path.read_bytes())
        return destination

    def assert_status(self, result, status):
        self.assertTrue(
            f'"status":"{status}"' in result.stdout or f"status: {status}" in result.stdout,
            result.stdout + result.stderr,
        )

    def test_malformed_json_is_recorded_as_parse_failure(self):
        self.initialize_database()
        malformed = self.workdir / "malformed.json"
        malformed.write_text('{"type":"push","push":', encoding="utf-8")

        result = self.run_native("process-push", str(malformed))

        self.assert_status(result, "PARSE_FAILED")
        review = self.run_native("review-list")
        self.assertIn("PARSE_FAILED", review.stdout)

    def test_malformed_json_replay_is_idempotent(self):
        self.initialize_database()
        malformed = self.workdir / "malformed-replay.json"
        malformed.write_text('{"type":"push","push":', encoding="utf-8")

        first = self.run_native("process-push", str(malformed))
        second = self.run_native("process-push", str(malformed), check=False)

        self.assert_status(first, "PARSE_FAILED")
        self.assert_status(second, "DUPLICATE")
        self.assertEqual(second.returncode, 0, second.stdout + second.stderr)
        connection = sqlite3.connect(self.database_path)
        self.assertEqual(connection.execute("SELECT COUNT(*) FROM push_events").fetchone()[0], 1)
        connection.close()

    def test_unsupported_push_replay_is_idempotent(self):
        self.initialize_database()
        payload = {
            "type": "mirror",
            "iden": "native-unsupported-replay",
            "package_name": "com.tossbank.evil",
            "application_name": "Toss",
            "title": "입금 알림",
            "body": "입금자: 홍길동\n금액: 10,000원",
        }
        path = self.workdir / "unsupported-replay.json"
        path.write_text(json.dumps(payload, ensure_ascii=False), encoding="utf-8")

        first = self.run_native("process-push", str(path))
        second = self.run_native("process-push", str(path), check=False)

        self.assert_status(first, "UNSUPPORTED")
        self.assert_status(second, "DUPLICATE")
        self.assertEqual(second.returncode, 0, second.stdout + second.stderr)
        connection = sqlite3.connect(self.database_path)
        self.assertEqual(connection.execute("SELECT COUNT(*) FROM push_events").fetchone()[0], 1)
        connection.close()

    def test_long_json_string_is_bounded_without_crashing(self):
        self.initialize_database()
        long_payload = {
            "type": "push",
            "subtype": "mirror",
            "push": {
                "iden": "native-long-001",
                "type": "mirror",
                "application_name": "Toss",
                "package_name": "com.tossbank",
                "title": "입금 알림",
                "body": "A" * 17000,
            },
        }
        long_json = self.workdir / "long.json"
        long_json.write_text(json.dumps(long_payload, ensure_ascii=False), encoding="utf-8")

        result = self.run_native("process-push", str(long_json))

        self.assert_status(result, "PARSE_FAILED")
        self.assertLess(result.stdout.count("A"), 10)

    def test_complete_json_with_trailing_garbage_is_parse_failed(self):
        self.initialize_database()
        payload = {
            "type": "mirror",
            "iden": "native-trailing-001",
            "package_name": "com.tossbank",
            "application_name": "Toss",
            "title": "입금 알림",
            "body": "입금자: 홍길동\n금액: 10,000원",
        }
        path = self.workdir / "trailing.json"
        path.write_text(json.dumps(payload, ensure_ascii=False) + "garbage", encoding="utf-8")

        result = self.run_native("process-push", str(path))

        self.assert_status(result, "PARSE_FAILED")

    def test_structurally_invalid_json_is_parse_failed(self):
        self.initialize_database()
        invalid_payloads = (
            '{"iden":"native-invalid-001","package_name":"com.tossbank","application_name":"Toss","title":"입금 알림","body":"입금자: 홍길동\\n금액: 10,000원",}',
            '{"iden":"native-invalid-002","package_name":"com.tossbank" "application_name":"Toss","title":"입금 알림","body":"입금자: 홍길동\\n금액: 10,000원"}',
        )
        for index, value in enumerate(invalid_payloads):
            with self.subTest(index=index):
                path = self.workdir / f"invalid-{index}.json"
                path.write_text(value, encoding="utf-8")
                result = self.run_native("process-push", str(path))
                self.assert_status(result, "PARSE_FAILED")

    def test_source_filters_require_exact_package_and_application(self):
        self.initialize_database()
        for field, value in (("package_name", "com.tossbank.evil"), ("application_name", "Toss.evil")):
            with self.subTest(field=field):
                payload = {
                    "type": "mirror",
                    "iden": "native-source-" + field,
                    "package_name": "com.tossbank",
                    "application_name": "Toss",
                    "title": "입금 알림",
                    "body": "입금자: 홍길동\n금액: 10,000원",
                }
                payload[field] = value
                path = self.workdir / (field + ".json")
                path.write_text(json.dumps(payload, ensure_ascii=False), encoding="utf-8")

                result = self.run_native("process-push", str(path))

                self.assert_status(result, "UNSUPPORTED")

    def test_unsupported_missing_push_id_is_fingerprinted(self):
        self.initialize_database()
        payload = {
            "type": "mirror",
            "package_name": "com.tossbank.evil",
            "application_name": "Toss",
            "title": "입금 알림",
            "body": "입금자: 홍길동\n금액: 10,000원",
        }
        first_path = self.workdir / "unsupported-missing-id-first.json"
        first_path.write_text(json.dumps(payload, ensure_ascii=False), encoding="utf-8")

        first = self.run_native("process-push", str(first_path))

        self.assert_status(first, "UNSUPPORTED")
        connection = sqlite3.connect(self.database_path)
        first_row = connection.execute(
            "SELECT push_id,processing_status FROM push_events"
        ).fetchone()
        connection.close()
        self.assertIsNotNone(first_row)
        self.assertTrue(first_row[0].startswith("mirror-"))
        self.assertEqual(len(first_row[0]), len("mirror-") + 16)
        self.assertEqual(first_row[1], "UNSUPPORTED")

        second_database_path = self.workdir / "data" / "second-vending.db"
        self.config_path.write_text(
            native_config(
                second_database_path,
                package="com.tossbank",
                application="Toss",
                title_prefix="입금",
            ),
            encoding="utf-8",
        )
        self.run_native("init-db")
        second = self.run_native("process-push", str(first_path))

        self.assert_status(second, "UNSUPPORTED")
        connection = sqlite3.connect(second_database_path)
        second_id = connection.execute("SELECT push_id FROM push_events").fetchone()[0]
        connection.close()
        self.assertEqual(second_id, first_row[0])

    def test_json_string_content_cannot_spoof_structural_fields(self):
        self.initialize_database()
        self.create_order()
        payload = {
            "type": "mirror",
            "iden": "native-structural-001",
            "title": "입금 알림",
            "body": "입금자: 홍길동\n금액: 10,000원 \"package_name\":\"evil\"",
            "application_name": "Toss",
            "package_name": "com.tossbank",
        }
        path = self.workdir / "structural.json"
        path.write_text(json.dumps(payload, ensure_ascii=False), encoding="utf-8")

        result = self.run_native("process-push", str(path))

        self.assert_status(result, "CONSUMED")

    def test_nested_json_members_cannot_spoof_root_fields(self):
        self.initialize_database()
        payload = {
            "type": "mirror",
            "metadata": {
                "package_name": "com.tossbank",
                "application_name": "Toss",
                "title": "입금 알림",
                "body": "입금자: 홍길동\n금액: 10,000원",
            },
            "iden": "native-nested-member-001",
            "package_name": "com.tossbank.evil",
            "application_name": "Toss",
            "title": "입금 알림",
            "body": "입금자: 홍길동\n금액: 10,000원",
        }
        path = self.workdir / "nested-member.json"
        path.write_text(json.dumps(payload, ensure_ascii=False), encoding="utf-8")

        result = self.run_native("process-push", str(path))

        self.assert_status(result, "UNSUPPORTED")

    def test_nested_push_object_controls_source_fields(self):
        self.initialize_database()
        payload = {
            "type": "push",
            "package_name": "com.tossbank",
            "application_name": "Toss",
            "title": "입금 알림",
            "body": "입금자: 홍길동\n금액: 10,000원",
            "push": {
                "iden": "native-nested-source-001",
                "type": "mirror",
                "package_name": "com.tossbank.evil",
                "application_name": "Toss",
                "title": "입금 알림",
                "body": "입금자: 홍길동\n금액: 10,000원",
            },
        }
        path = self.workdir / "nested-source.json"
        path.write_text(json.dumps(payload, ensure_ascii=False), encoding="utf-8")

        result = self.run_native("process-push", str(path))

        self.assert_status(result, "UNSUPPORTED")

    def test_native_rejects_unsupported_pattern_contract(self):
        self.config_path.write_text(
            self.config_path.read_text(encoding="utf-8").replace(
                "BANK_AMOUNT_PATTERN=(?:입금액|입금금액|금액|amount)\\s*[:：]?\\s*([0-9][0-9,]*)",
                "BANK_AMOUNT_PATTERN=.*",
            ),
            encoding="utf-8",
        )

        result = self.run_native("validate-config", check=False)

        self.assertEqual(result.returncode, 1)
        self.assertIn("native config invalid", result.stdout)

    def test_native_accepts_title_amount_pattern_contract(self):
        self.config_path.write_text(
            self.config_path.read_text(encoding="utf-8").replace(
                "BANK_AMOUNT_PATTERN=(?:입금액|입금금액|금액|amount)\\s*[:：]?\\s*([0-9][0-9,]*)",
                "BANK_AMOUNT_PATTERN=([0-9][0-9,]*)원\\s*입금",
            ).replace(
                "PUSHBULLET_ACCESS_TOKEN=\n",
                "PUSHBULLET_ACCESS_TOKEN=native-test-push-token\n",
            ),
            encoding="utf-8",
        )

        result = self.run_native("validate-config")

        self.assertIn("native config valid", result.stdout)

    def test_native_title_pattern_is_applied_to_event_title(self):
        self.config_path.write_text(
            self.config_path.read_text(encoding="utf-8").replace(
                "BANK_TITLE_PREFIX=입금\nBANK_TITLE_PATTERN=\n",
                "BANK_TITLE_PREFIX=\nBANK_TITLE_PATTERN=^[0-9][0-9,]*원\\s*입금$\n",
            ),
            encoding="utf-8",
        )
        self.initialize_database()
        payload = {
            "type": "mirror",
            "iden": "native-title-pattern-001",
            "package_name": "com.tossbank",
            "application_name": "Toss",
            "title": "출금 알림",
            "body": "입금자: 홍길동\n금액: 10,000원",
        }
        path = self.workdir / "title-pattern.json"
        path.write_text(json.dumps(payload, ensure_ascii=False), encoding="utf-8")

        result = self.run_native("process-push", str(path))

        self.assert_status(result, "UNSUPPORTED")

    def test_push_fixture_replay_is_idempotent(self):
        self.initialize_database()
        self.create_order()
        fixture = self.copy_fixture("toss-mirror-001.json", fresh_timestamps=True)

        first = self.run_native("process-push", str(fixture))
        second = self.run_native("process-push", str(fixture))
        total = self.run_native("support-total", "native-user")

        self.assert_status(first, "CONSUMED")
        self.assert_status(second, "DUPLICATE")

    @unittest.skipUnless("YUL_NATIVE_BINARY" in os.environ, "Linux AArch64 native binary is required")
    def test_push_fixture_decodes_unicode_escapes(self):
        self.initialize_database()
        self.create_order()
        fixture = self.copy_fixture("toss-unicode-escaped-001.json", fresh_timestamps=True)

        result = self.run_native("process-push", str(fixture))
        total = self.run_native("support-total", "native-user")

        self.assert_status(result, "CONSUMED")
        self.assertEqual(total.stdout.strip(), "10000")

    def test_timestampless_direct_mirror_is_automatic_and_idempotent(self):
        self.config_path.write_text(
            native_config(
                self.database_path,
                package="viva.republica.toss",
                application="토스",
                title_prefix="10원",
                title_pattern=r"^[0-9][0-9,]*원\s*입금$",
                amount_pattern=r"([0-9][0-9,]*)원\s*입금",
                name_pattern=r"^([^\r\n→,()]{1,100}?)\s*→\s*내 토스뱅크 통장$",
            ),
            encoding="utf-8",
        )
        self.initialize_database()
        self.create_order(name="홍길동", amount="10")
        fixture = self.copy_fixture("toss-mirror-direct-001.json")

        first = self.run_native("process-push", str(fixture))
        second = self.run_native("process-push", str(fixture))
        total = self.run_native("support-total", "native-user")

        self.assert_status(first, "CONSUMED")
        self.assert_status(second, "DUPLICATE")
        self.assertEqual(total.stdout.strip(), "10")
        connection = sqlite3.connect(self.database_path)
        timestamp_row = connection.execute(
            "SELECT push_created_at,push_modified_at,processing_status FROM push_events"
        ).fetchone()
        push_id = connection.execute("SELECT push_id FROM push_events").fetchone()[0]
        connection.close()
        self.assertEqual(timestamp_row, (None, None, "CONSUMED"))
        self.assertTrue(push_id.startswith("mirror-"))

    def test_direct_mirror_fingerprint_matches_native_golden(self):
        self.config_path.write_text(
            native_config(
                self.database_path,
                package="viva.republica.toss",
                application="토스",
                title_prefix="10원",
                title_pattern=r"^[0-9][0-9,]*원\s*입금$",
                amount_pattern=r"([0-9][0-9,]*)원\s*입금",
                name_pattern=r"^([^\r\n→,()]{1,100}?)\s*→\s*내 토스뱅크 통장$",
            ),
            encoding="utf-8",
        )
        self.initialize_database()
        self.create_order(name="홍길동", amount="10")
        fixture = self.copy_fixture("toss-mirror-direct-001.json")

        result = self.run_native("process-push", str(fixture))

        self.assert_status(result, "CONSUMED")
        connection = sqlite3.connect(self.database_path)
        push_id = connection.execute("SELECT push_id FROM push_events").fetchone()[0]
        connection.close()
        self.assertEqual(push_id, "mirror-ff8a5fc45669a404")

    def test_direct_mirror_fingerprint_ignores_lifecycle_metadata(self):
        self.config_path.write_text(
            native_config(
                self.database_path,
                package="viva.republica.toss",
                application="토스",
                title_prefix="10원",
                title_pattern=r"^[0-9][0-9,]*원\s*입금$",
                amount_pattern=r"([0-9][0-9,]*)원\s*입금",
                name_pattern=r"^([^\r\n→,()]{1,100}?)\s*→\s*내 토스뱅크 통장$",
            ),
            encoding="utf-8",
        )
        self.initialize_database()
        self.create_order(name="홍길동", amount="10")
        payload = json.loads((ROOT / "fixtures" / "pushbullet" / "toss-mirror-direct-001.json").read_text(encoding="utf-8"))
        first_path = self.workdir / "mirror-lifecycle-first.json"
        second_path = self.workdir / "mirror-lifecycle-second.json"
        payload["push"].update({"created": int(time.time()), "modified": int(time.time()), "active": True, "dismissed": False})
        first_path.write_text(json.dumps(payload, ensure_ascii=False), encoding="utf-8")
        payload["push"].update({"created": int(time.time()) + 1, "modified": int(time.time()) + 2, "active": False, "dismissed": True})
        second_path.write_text(json.dumps(payload, ensure_ascii=False), encoding="utf-8")

        first = self.run_native("process-push", str(first_path))
        second = self.run_native("process-push", str(second_path))

        self.assert_status(first, "CONSUMED")
        self.assert_status(second, "DUPLICATE")
        connection = sqlite3.connect(self.database_path)
        self.assertEqual(connection.execute("SELECT COUNT(*) FROM push_events").fetchone()[0], 1)
        connection.close()

    def test_direct_mirror_fingerprint_includes_broad_payload_fields(self):
        self.config_path.write_text(
            native_config(
                self.database_path,
                package="viva.republica.toss.expected",
                application="토스",
                title_prefix="10원",
                title_pattern=r"^[0-9][0-9,]*원\s*입금$",
                amount_pattern=r"([0-9][0-9,]*)원\s*입금",
                name_pattern=r"^([^\r\n→,()]{1,100}?)\s*→\s*내 토스뱅크 통장$",
            ),
            encoding="utf-8",
        )
        self.initialize_database()
        base = {
            "type": "mirror",
            "package_name": "viva.republica.toss",
            "application_name": "토스",
            "title": "10원 입금",
            "body": "홍길동 → 내 토스뱅크 통장",
        }
        variants = []
        for field, value in (
            ("client_version", 2),
            ("dismissible", False),
            ("unknown_scalar", "changed"),
            ("unknown_nested", {"provider": "bank", "flags": ["a", 2, {"ok": True}]}),
            ("unknown_list", ["first", {"second": [1, 2, 3]}]),
        ):
            payload = {**base, field: value}
            path = self.workdir / f"broad-{field}.json"
            path.write_text(json.dumps(payload, ensure_ascii=False), encoding="utf-8")
            variants.append(path)

        for path in variants:
            with self.subTest(path=path.name):
                result = self.run_native("process-push", str(path))
                self.assert_status(result, "UNSUPPORTED")

        connection = sqlite3.connect(self.database_path)
        rows = connection.execute("SELECT push_id FROM push_events ORDER BY received_at, push_id").fetchall()
        connection.close()
        self.assertEqual(len(rows), len(variants))
        self.assertEqual(len({row[0] for row in rows}), len(variants))
        self.assertTrue(all(row[0].startswith("mirror-") for row in rows))

    def test_direct_mirror_fingerprint_lifecycle_add_remove_is_ignored(self):
        self.config_path.write_text(
            native_config(
                self.database_path,
                package="viva.republica.toss",
                application="토스",
                title_prefix="10원",
                title_pattern=r"^[0-9][0-9,]*원\s*입금$",
                amount_pattern=r"([0-9][0-9,]*)원\s*입금",
                name_pattern=r"^([^\r\n→,()]{1,100}?)\s*→\s*내 토스뱅크 통장$",
            ),
            encoding="utf-8",
        )
        self.initialize_database()
        first_payload = {
            "type": "push",
            "push": {
                "type": "mirror",
                "package_name": "viva.republica.toss",
                "application_name": "토스",
                "title": "10원 입금",
                "body": "홍길동 → 내 토스뱅크 통장",
            },
        }
        second_payload = {
            **first_payload,
            "push": {
                **first_payload["push"],
                "created": int(time.time()),
                "modified": int(time.time()),
                "active": True,
                "dismissed": False,
            },
        }
        first_path = self.workdir / "lifecycle-absent.json"
        second_path = self.workdir / "lifecycle-present.json"
        first_path.write_text(json.dumps(first_payload, ensure_ascii=False), encoding="utf-8")
        second_path.write_text(json.dumps(second_payload, ensure_ascii=False), encoding="utf-8")

        first = self.run_native("process-push", str(first_path))
        second = self.run_native("process-push", str(second_path))

        self.assert_status(first, "REVIEW")
        self.assert_status(second, "DUPLICATE")
        connection = sqlite3.connect(self.database_path)
        self.assertEqual(connection.execute("SELECT COUNT(*) FROM push_events").fetchone()[0], 1)
        connection.close()

    def test_stale_push_timestamp_is_stored_and_reviewed(self):
        self.initialize_database()
        self.create_order()
        payload = {
            "type": "mirror",
            "iden": "native-stale-timestamp",
            "created": 100,
            "modified": 101.125,
            "package_name": "com.tossbank",
            "application_name": "Toss",
            "title": "입금 알림",
            "body": "입금자: 홍길동\n금액: 10,000원",
        }
        path = self.workdir / "stale-timestamp.json"
        path.write_text(json.dumps(payload, ensure_ascii=False), encoding="utf-8")

        result = self.run_native("process-push", str(path))

        self.assert_status(result, "REVIEW")
        connection = sqlite3.connect(self.database_path)
        row = connection.execute(
            "SELECT push_created_at,push_modified_at,processing_status FROM push_events WHERE push_id=?",
            ("native-stale-timestamp",),
        ).fetchone()
        ledger_count = connection.execute("SELECT COUNT(*) FROM ledger").fetchone()[0]
        connection.close()
        self.assertEqual(row, (100, 101, "REVIEW"))
        self.assertEqual(ledger_count, 0)

    def test_missing_or_invalid_mirror_type_is_parse_failed(self):
        self.initialize_database()
        base = {
            "iden": "native-type-invalid",
            "package_name": "com.tossbank",
            "application_name": "Toss",
            "title": "입금 알림",
            "body": "입금자: 홍길동\n금액: 10,000원",
        }
        payloads = (
            base,
            {**base, "iden": "native-type-number", "type": 1},
            {"type": "noop", "push": {**base, "iden": "native-root-type-invalid", "type": "mirror"}},
            {"type": "push", "push": {**base, "iden": "native-nested-type-missing"}},
            {"type": "push", "push": {**base, "iden": "native-nested-type-number", "type": 1}},
        )
        for index, payload in enumerate(payloads):
            with self.subTest(index=index):
                path = self.workdir / f"invalid-type-{index}.json"
                path.write_text(json.dumps(payload, ensure_ascii=False), encoding="utf-8")
                result = self.run_native("process-push", str(path))
                self.assert_status(result, "PARSE_FAILED")
        connection = sqlite3.connect(self.database_path)
        push_ids = [row[0] for row in connection.execute("SELECT push_id FROM push_events ORDER BY push_id")]
        connection.close()
        self.assertEqual(len(push_ids), len(payloads))
        self.assertTrue(all(value.startswith("invalid-") for value in push_ids))

    def test_invalid_explicit_push_ids_are_fingerprinted_as_parse_failures(self):
        self.initialize_database()
        for index, invalid_id in enumerate(("", " \t\r\n", 42)):
            with self.subTest(index=index):
                payload = {
                    "type": "mirror",
                    "iden": invalid_id,
                    "package_name": "com.tossbank",
                    "application_name": "Toss",
                    "title": "입금 알림",
                    "body": "입금자: 홍길동\n금액: 10,000원",
                }
                path = self.workdir / f"invalid-id-{index}.json"
                path.write_text(json.dumps(payload, ensure_ascii=False), encoding="utf-8")
                result = self.run_native("process-push", str(path))
                self.assert_status(result, "PARSE_FAILED")
        connection = sqlite3.connect(self.database_path)
        push_ids = [row[0] for row in connection.execute("SELECT push_id FROM push_events ORDER BY push_id")]
        connection.close()
        self.assertEqual(len(push_ids), 3)
        self.assertEqual(len(set(push_ids)), 3)
        self.assertTrue(all(value.startswith("invalid-") for value in push_ids))

    def test_native_amount_parser_does_not_join_later_numbers(self):
        self.initialize_database()
        self.create_order(amount="1020")
        payload = {
            "type": "mirror",
            "iden": "native-first-amount-token",
            "package_name": "com.tossbank",
            "application_name": "Toss",
            "title": "입금 알림",
            "body": "입금자: 홍길동\n금액: 10원 승인번호 20",
        }
        path = self.workdir / "first-amount-token.json"
        path.write_text(json.dumps(payload, ensure_ascii=False), encoding="utf-8")

        result = self.run_native("process-push", str(path))

        self.assert_status(result, "REVIEW")
        connection = sqlite3.connect(self.database_path)
        parsed_amount = connection.execute(
            "SELECT parsed_amount_krw FROM push_events WHERE push_id=?",
            ("native-first-amount-token",),
        ).fetchone()[0]
        ledger_count = connection.execute("SELECT COUNT(*) FROM ledger").fetchone()[0]
        connection.close()
        self.assertEqual(parsed_amount, 10)
        self.assertEqual(ledger_count, 0)

    def test_native_sender_space_label_is_matchable(self):
        self.initialize_database()
        self.create_order(name="홍길동", amount="10")
        payload = {
            "type": "mirror",
            "iden": "native-sender-space",
            "package_name": "com.tossbank",
            "application_name": "Toss",
            "title": "입금 알림",
            "body": "보낸 사람: 홍길동\n금액: 10원",
        }
        path = self.workdir / "sender-space.json"
        path.write_text(json.dumps(payload, ensure_ascii=False), encoding="utf-8")

        result = self.run_native("process-push", str(path))
        total = self.run_native("support-total", "native-user")

        self.assert_status(result, "CONSUMED")
        self.assertEqual(total.stdout.strip(), "10")

    def test_native_name_ambiguity_is_not_auto_credited(self):
        self.initialize_database()
        self.create_order(amount="10")
        payload = {
            "type": "mirror",
            "iden": "native-ambiguous-name",
            "package_name": "com.tossbank",
            "application_name": "Toss",
            "title": "입금 알림",
            "body": "입금자: 홍길동\n입금자: 홍길동\n금액: 10원",
        }
        path = self.workdir / "ambiguous-name.json"
        path.write_text(json.dumps(payload, ensure_ascii=False), encoding="utf-8")

        result = self.run_native("process-push", str(path))

        self.assert_status(result, "PARSE_FAILED")
        connection = sqlite3.connect(self.database_path)
        ledger_count = connection.execute("SELECT COUNT(*) FROM ledger").fetchone()[0]
        order_status = connection.execute("SELECT status FROM deposit_orders").fetchone()[0]
        connection.close()
        self.assertEqual(ledger_count, 0)
        self.assertEqual(order_status, "PENDING")

    def test_native_amount_ambiguity_is_not_auto_credited(self):
        self.initialize_database()
        self.create_order(amount="10")
        payload = {
            "type": "mirror",
            "iden": "native-ambiguous-amount",
            "package_name": "com.tossbank",
            "application_name": "Toss",
            "title": "입금 알림",
            "body": "입금자: 홍길동\n금액: 10원\n금액: 10원",
        }
        path = self.workdir / "ambiguous-amount.json"
        path.write_text(json.dumps(payload, ensure_ascii=False), encoding="utf-8")

        result = self.run_native("process-push", str(path))

        self.assert_status(result, "PARSE_FAILED")
        connection = sqlite3.connect(self.database_path)
        ledger_count = connection.execute("SELECT COUNT(*) FROM ledger").fetchone()[0]
        order_status = connection.execute("SELECT status FROM deposit_orders").fetchone()[0]
        connection.close()
        self.assertEqual(ledger_count, 0)
        self.assertEqual(order_status, "PENDING")

    def test_native_label_ambiguity_spans_body_and_title(self):
        self.initialize_database()
        self.create_order(amount="10")
        payload = {
            "type": "mirror",
            "iden": "native-mixed-name-ambiguity",
            "package_name": "com.tossbank",
            "application_name": "Toss",
            "title": "입금자: 홍길동 입금 알림",
            "body": "입금자: 홍길동\n금액: 10원",
        }
        path = self.workdir / "mixed-name-ambiguity.json"
        path.write_text(json.dumps(payload, ensure_ascii=False), encoding="utf-8")

        result = self.run_native("process-push", str(path))

        self.assert_status(result, "PARSE_FAILED")
        connection = sqlite3.connect(self.database_path)
        ledger_count = connection.execute("SELECT COUNT(*) FROM ledger").fetchone()[0]
        connection.close()
        self.assertEqual(ledger_count, 0)

    def test_native_arrow_name_ambiguity_spans_body_and_title(self):
        self.config_path.write_text(
            native_config(
                self.database_path,
                package="viva.republica.toss",
                application="토스",
                title_prefix="10원",
                name_pattern=r"^([^\r\n→,()]{1,100}?)\s*→\s*내 토스뱅크 통장$",
            ),
            encoding="utf-8",
        )
        self.initialize_database()
        self.create_order(name="홍길동", amount="10")
        payload = {
            "type": "mirror",
            "iden": "native-mixed-arrow-ambiguity",
            "package_name": "viva.republica.toss",
            "application_name": "토스",
            "title": "10원 입금\n홍길동 → 내 토스뱅크 통장",
            "body": "홍길동 → 내 토스뱅크 통장\n금액: 10원",
        }
        path = self.workdir / "mixed-arrow-ambiguity.json"
        path.write_text(json.dumps(payload, ensure_ascii=False), encoding="utf-8")

        result = self.run_native("process-push", str(path))

        self.assert_status(result, "PARSE_FAILED")
        connection = sqlite3.connect(self.database_path)
        ledger_count = connection.execute("SELECT COUNT(*) FROM ledger").fetchone()[0]
        connection.close()
        self.assertEqual(ledger_count, 0)

    def test_native_title_amount_ambiguity_spans_body_and_title(self):
        self.config_path.write_text(
            native_config(
                self.database_path,
                package="viva.republica.toss",
                application="토스",
                title_prefix="10원",
                amount_pattern=r"([0-9][0-9,]*)원\s*입금",
                name_pattern=r"^([^\r\n→,()]{1,100}?)\s*→\s*내 토스뱅크 통장$",
            ),
            encoding="utf-8",
        )
        self.initialize_database()
        self.create_order(name="홍길동", amount="10")
        payload = {
            "type": "mirror",
            "iden": "native-mixed-title-amount-ambiguity",
            "package_name": "viva.republica.toss",
            "application_name": "토스",
            "title": "10원 입금",
            "body": "홍길동 → 내 토스뱅크 통장\n10원 입금",
        }
        path = self.workdir / "mixed-title-amount-ambiguity.json"
        path.write_text(json.dumps(payload, ensure_ascii=False), encoding="utf-8")

        result = self.run_native("process-push", str(path))

        self.assert_status(result, "PARSE_FAILED")
        connection = sqlite3.connect(self.database_path)
        ledger_count = connection.execute("SELECT COUNT(*) FROM ledger").fetchone()[0]
        connection.close()
        self.assertEqual(ledger_count, 0)

    def test_native_title_amount_duplicate_in_title_fails_closed(self):
        self.config_path.write_text(
            native_config(
                self.database_path,
                package="viva.republica.toss",
                application="토스",
                title_prefix="10원",
                amount_pattern=r"([0-9][0-9,]*)원\s*입금",
                name_pattern=r"^([^\r\n→,()]{1,100}?)\s*→\s*내 토스뱅크 통장$",
            ),
            encoding="utf-8",
        )
        self.initialize_database()
        self.create_order(name="홍길동", amount="10")
        payload = {
            "type": "mirror",
            "iden": "native-title-amount-duplicate",
            "package_name": "viva.republica.toss",
            "application_name": "토스",
            "title": "10원 입금 10원 입금",
            "body": "홍길동 → 내 토스뱅크 통장",
        }
        path = self.workdir / "title-amount-duplicate.json"
        path.write_text(json.dumps(payload, ensure_ascii=False), encoding="utf-8")

        result = self.run_native("process-push", str(path))

        self.assert_status(result, "PARSE_FAILED")
        connection = sqlite3.connect(self.database_path)
        ledger_count = connection.execute("SELECT COUNT(*) FROM ledger").fetchone()[0]
        connection.close()
        self.assertEqual(ledger_count, 0)

    def test_native_label_boundaries_ignore_identifier_suffixes(self):
        self.initialize_database()
        self.create_order(amount="10")
        payload = {
            "type": "mirror",
            "iden": "native-label-boundaries",
            "package_name": "com.tossbank",
            "application_name": "Toss",
            "title": "입금 알림",
            "body": "입금자: 홍길동\nusername: evil\namounting: 20\n금액10원",
        }
        path = self.workdir / "label-boundaries.json"
        path.write_text(json.dumps(payload, ensure_ascii=False), encoding="utf-8")

        result = self.run_native("process-push", str(path))
        total = self.run_native("support-total", "native-user")

        self.assert_status(result, "CONSUMED")
        self.assertEqual(total.stdout.strip(), "10")

    def test_native_malformed_second_label_candidate_fails_closed(self):
        self.initialize_database()
        self.create_order(amount="10")
        payload = {
            "type": "mirror",
            "iden": "native-malformed-second-label",
            "package_name": "com.tossbank",
            "application_name": "Toss",
            "title": "입금 알림",
            "body": "입금자: 홍길동\n보낸분:\n금액: 10원",
        }
        path = self.workdir / "malformed-second-label.json"
        path.write_text(json.dumps(payload, ensure_ascii=False), encoding="utf-8")

        result = self.run_native("process-push", str(path))

        self.assert_status(result, "PARSE_FAILED")
        connection = sqlite3.connect(self.database_path)
        ledger_count = connection.execute("SELECT COUNT(*) FROM ledger").fetchone()[0]
        connection.close()
        self.assertEqual(ledger_count, 0)

    def test_run_fails_closed_when_operational_config_is_incomplete(self):
        self.config_path.write_text(
            native_config(
                self.database_path,
                package="com.tossbank",
                application="Toss",
                title_prefix="입금",
                push_token="native-test-token",
            ).replace("DISCORD_BOT_TOKEN=native-test-discord-token", "DISCORD_BOT_TOKEN="),
            encoding="utf-8",
        )
        result = self.run_native("run", check=False)
        self.assertEqual(result.returncode, 1)
        self.assertIn("native config invalid", result.stdout)


if __name__ == "__main__":
    unittest.main()
