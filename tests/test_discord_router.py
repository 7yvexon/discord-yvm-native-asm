import unittest

from vending_machine.config import Settings
from vending_machine.database import Database
from vending_machine.discord_gateway import DEPOSIT_BUTTON_ID, DEPOSIT_MODAL_ID, DiscordInteractionProcessor, DiscordInteractionRouter
from vending_machine.discord_rest import DiscordResponse
from vending_machine.models import DmStatus
from vending_machine.panel import PanelManager
from vending_machine.service import VendingService


class DiscordRouterTests(unittest.TestCase):
    def setUp(self):
        self.database = Database(":memory:")
        self.service = VendingService(self.database, Settings())
        self.router = DiscordInteractionRouter(self.service)

    def tearDown(self):
        self.database.close()

    def test_button_opens_modal(self):
        result = self.router.handle({"type": 3, "data": {"custom_id": DEPOSIT_BUTTON_ID}})
        self.assertEqual(result.response["type"], 9)
        self.assertEqual(result.response["data"]["custom_id"], DEPOSIT_MODAL_ID)

    def test_panel_publish_persists_message_scope(self):
        class FakeDiscord:
            def publish_panel(self, channel_id, content, *, embeds=None):
                self.request = (channel_id, content, embeds)
                return DiscordResponse(200, {"id": "message"})

        discord = FakeDiscord()
        service = VendingService(
            self.database,
            Settings(discord_admin_user_id="admin", discord_panel_channel_id="panel"),
        )
        message_id = PanelManager(service, discord).publish("admin")
        self.assertEqual(message_id, "message")
        self.assertEqual(discord.request[0], "panel")
        self.assertEqual(self.database.get_setting("discord.panel_channel_id"), "panel")
        self.assertEqual(self.database.get_setting("discord.panel_message_id"), "message")

    def test_modal_uses_interaction_actor_id(self):
        result = self.router.handle(
            {
                "type": 5,
                "member": {"user": {"id": "actor"}},
                "data": {
                    "custom_id": DEPOSIT_MODAL_ID,
                    "components": [
                        {"components": [{"custom_id": "depositor_name", "value": "홍길동"}]},
                        {"components": [{"custom_id": "amount_krw", "value": "10000"}]},
                    ],
                },
            },
            now=100,
        )
        self.assertIsNotNone(result.order_receipt)
        self.assertEqual(result.order_receipt.order.discord_id, "actor")
        self.assertEqual(result.response["data"]["flags"], 64)

    def test_modal_accepts_commas_and_won_suffix_in_amount(self):
        result = self.router.handle(
            {
                "type": 5,
                "member": {"user": {"id": "actor"}},
                "data": {
                    "custom_id": DEPOSIT_MODAL_ID,
                    "components": [
                        {"components": [{"custom_id": "depositor_name", "value": "홍길동"}]},
                        {"components": [{"custom_id": "amount_krw", "value": "10,000원"}]},
                    ],
                },
            },
            now=100,
        )
        self.assertIsNotNone(result.order_receipt)
        self.assertEqual(result.order_receipt.order.requested_amount_krw, 10000)

    def test_invalid_modal_returns_ephemeral_result(self):
        result = self.router.handle(
            {
                "type": 5,
                "member": {"user": {"id": "actor"}},
                "data": {"custom_id": DEPOSIT_MODAL_ID, "components": []},
            }
        )
        self.assertEqual(result.response["type"], 4)
        self.assertEqual(result.response["data"]["flags"], 64)

    def test_payment_result_sends_separate_completion_dm(self):
        class FakeDiscord:
            def __init__(self):
                self.messages = []

            def send_dm(self, user_id, content):
                self.messages.append((user_id, content))
                return DiscordResponse(200, {})

        database = Database(":memory:")
        try:
            settings = Settings(
                bank_package_name="com.tossbank",
                bank_application_name="Toss",
                bank_title_prefix="입금",
                bank_name="은행",
                bank_account_number="123",
                bank_account_holder="예금주",
            )
            service = VendingService(database, settings)
            receipt = service.create_order("actor", "홍길동", 10000, now=100)
            result = service.handle_push(
                {
                    "type": "push",
                    "push": {
                        "iden": "payment",
                        "type": "mirror",
                        "package_name": "com.tossbank",
                        "application_name": "Toss",
                        "title": "입금 알림",
                        "body": "입금자: 홍길동\n금액: 10,000원",
                    },
                },
                now=101,
            )
            discord = FakeDiscord()
            processor = DiscordInteractionProcessor(DiscordInteractionRouter(service), discord)
            self.assertTrue(processor.handle_payment_result(result))
            self.assertEqual(database.get_order(receipt.order.order_id).payment_dm_status, DmStatus.SENT)
            self.assertEqual(len(discord.messages), 1)
        finally:
            database.close()

    def test_processor_rejects_invalid_scope_before_any_side_effect(self):
        class FakeDiscord:
            def __init__(self):
                self.deferred = []
                self.edited = []
                self.responded = []

            def defer_interaction(self, interaction_id, interaction_token):
                self.deferred.append((interaction_id, interaction_token))

            def edit_original_response(self, interaction_token, payload):
                self.edited.append((interaction_token, payload))

            def respond_to_interaction(self, interaction_id, interaction_token, payload):
                self.responded.append((interaction_id, interaction_token, payload))

        discord = FakeDiscord()
        processor = DiscordInteractionProcessor(
            self.router,
            discord,
            application_id="application",
            guild_id="guild",
            panel_channel_id="panel",
        )
        self.database.set_setting("discord.panel_message_id", "message")
        modal = {
            "type": 5,
            "application_id": "application",
            "guild_id": "guild",
            "channel_id": "panel",
            "member": {"user": {"id": "actor"}},
            "data": {
                "custom_id": DEPOSIT_MODAL_ID,
                "components": [
                    {"components": [{"custom_id": "depositor_name", "value": "홍길동"}]},
                    {"components": [{"custom_id": "amount_krw", "value": "10000"}]},
                ],
            },
        }
        button = {
            "type": 3,
            "application_id": "application",
            "guild_id": "guild",
            "channel_id": "panel",
            "message": {"id": "message"},
            "data": {"custom_id": DEPOSIT_BUTTON_ID},
        }
        invalid_interactions = (
            {key: value for key, value in modal.items() if key != "application_id"},
            {**modal, "application_id": ""},
            {**modal, "application_id": 123},
            {**modal, "application_id": "other"},
            {**modal, "guild_id": "other"},
            {**modal, "channel_id": "other"},
            {key: value for key, value in button.items() if key != "message"},
            {**button, "message": {"id": ""}},
            {**button, "message": {"id": 123}},
            {**button, "message": {"id": "other"}},
        )
        for index, interaction in enumerate(invalid_interactions):
            with self.subTest(index=index):
                processor.process(interaction, interaction_id=f"interaction-{index}", interaction_token="token")
        self.assertEqual(discord.deferred, [])
        self.assertEqual(discord.edited, [])
        self.assertEqual(discord.responded, [])
        self.assertEqual(self.database.connection.execute("SELECT COUNT(*) FROM deposit_orders").fetchone()[0], 0)

        processor.process(button, interaction_id="button", interaction_token="button-token")
        self.assertEqual(len(discord.responded), 1)
        self.assertEqual(discord.responded[0][2]["type"], 9)

    def test_modal_replay_reuses_order_after_response_failure(self):
        class FakeDiscord:
            def __init__(self):
                self.edits = 0
                self.dms = []

            def defer_interaction(self, interaction_id, interaction_token):
                return DiscordResponse(200, {})

            def edit_original_response(self, interaction_token, payload):
                self.edits += 1
                if self.edits == 1:
                    raise RuntimeError("response unavailable")
                return DiscordResponse(200, {})

            def send_dm(self, user_id, content, **kwargs):
                self.dms.append((user_id, content))
                return DiscordResponse(200, {})

        interaction = {
            "type": 5,
            "application_id": "application",
            "guild_id": "guild",
            "channel_id": "panel",
            "member": {"user": {"id": "actor"}},
            "data": {
                "custom_id": DEPOSIT_MODAL_ID,
                "components": [
                    {"components": [{"custom_id": "depositor_name", "value": "홍길동"}]},
                    {"components": [{"custom_id": "amount_krw", "value": "10000"}]},
                ],
            },
        }
        discord = FakeDiscord()
        processor = DiscordInteractionProcessor(
            self.router,
            discord,
            application_id="application",
            guild_id="guild",
            panel_channel_id="panel",
            guild_tag_log_channel_id="log",
        )
        with self.assertRaises(RuntimeError):
            processor.process(interaction, interaction_id="interaction-replay", interaction_token="token")
        result = processor.process(interaction, interaction_id="interaction-replay", interaction_token="token")
        self.assertIsNotNone(result.order_receipt)
        self.assertEqual(self.database.connection.execute("SELECT COUNT(*) FROM deposit_orders").fetchone()[0], 1)
        self.assertEqual(len(discord.dms), 1)

    def test_guild_tag_update_logs_only_on_state_change(self):
        class FakeDiscord:
            def __init__(self):
                self.messages = []

            def send_channel_message(self, channel_id, content=None, *, embeds=None):
                self.messages.append((channel_id, content, embeds))

        discord = FakeDiscord()
        processor = DiscordInteractionProcessor(self.router, discord, guild_id="guild", guild_tag_log_channel_id="log")
        base = {
            "guild_id": "guild",
            "user": {
                "id": "user",
                "username": "tester",
                "primary_guild": {
                    "identity_guild_id": "guild",
                    "identity_enabled": True,
                    "tag": "뀨?",
                },
            },
        }
        self.assertFalse(processor.handle_guild_tag_update(base, guild_id="guild", channel_id="log"))
        self.assertEqual(discord.messages, [])
        self.assertFalse(processor.handle_guild_tag_update(base, guild_id="guild", channel_id="log"))
        disabled = {**base, "user": {**base["user"], "primary_guild": {**base["user"]["primary_guild"], "identity_enabled": False}}}
        self.assertTrue(processor.handle_guild_tag_update(disabled, guild_id="guild", channel_id="log"))
        self.assertEqual(len(discord.messages), 1)
        self.assertEqual(discord.messages[0][0], "log")
        self.assertIn("해제", discord.messages[0][1])

    def test_guild_tag_update_syncs_configured_role(self):
        class FakeDiscord:
            def __init__(self):
                self.added = []
                self.removed = []

            def add_guild_member_role(self, guild_id, user_id, role_id):
                self.added.append((guild_id, user_id, role_id))

            def remove_guild_member_role(self, guild_id, user_id, role_id):
                self.removed.append((guild_id, user_id, role_id))

        discord = FakeDiscord()
        processor = DiscordInteractionProcessor(self.router, discord, guild_id="guild", guild_tag_role_id="role")
        enabled = {
            "guild_id": "guild",
            "roles": [],
            "user": {
                "id": "user",
                "username": "tester",
                "primary_guild": {"identity_guild_id": "guild", "identity_enabled": True},
            },
        }
        disabled = {
            **enabled,
            "roles": ["role"],
            "user": {**enabled["user"], "primary_guild": {"identity_enabled": False}},
        }

        self.assertFalse(processor.handle_guild_tag_update(enabled, guild_id="guild", channel_id=""))
        self.assertEqual(discord.added, [("guild", "user", "role")])
        self.assertFalse(processor.handle_guild_tag_update({**enabled, "roles": ["role"]}, guild_id="guild", channel_id=""))
        self.assertEqual(discord.added, [("guild", "user", "role")])
        self.assertFalse(processor.handle_guild_tag_update(enabled, guild_id="guild", channel_id=""))
        self.assertEqual(discord.added, [("guild", "user", "role"), ("guild", "user", "role")])
        self.assertFalse(processor.handle_guild_tag_update(disabled, guild_id="guild", channel_id=""))
        self.assertEqual(discord.removed, [("guild", "user", "role")])

    def test_guild_tag_status_sync_updates_configured_roles_without_status_channel(self):
        class FakeDiscord:
            def __init__(self):
                self.added = []
                self.removed = []

            def list_guild_members(self, guild_id, *, limit=1000, after=None):
                if after is not None:
                    raise AssertionError("unexpected pagination cursor")
                return [
                    {
                        "roles": [],
                        "user": {
                            "id": "active",
                            "primary_guild": {"identity_guild_id": "guild", "identity_enabled": True},
                        },
                    },
                    {
                        "roles": ["role"],
                        "user": {
                            "id": "inactive",
                            "primary_guild": {"identity_enabled": False},
                        },
                    },
                ]

            def add_guild_member_role(self, guild_id, user_id, role_id):
                self.added.append((guild_id, user_id, role_id))

            def remove_guild_member_role(self, guild_id, user_id, role_id):
                self.removed.append((guild_id, user_id, role_id))

        discord = FakeDiscord()
        processor = DiscordInteractionProcessor(self.router, discord, guild_id="guild", guild_tag_role_id="role")

        self.assertTrue(processor.sync_guild_tag_status(guild_id="guild"))
        self.assertEqual(discord.added, [("guild", "active", "role")])
        self.assertEqual(discord.removed, [("guild", "inactive", "role")])

    def test_guild_tag_update_ignores_other_guild(self):
        class FakeDiscord:
            def send_channel_message(self, *args, **kwargs):
                raise AssertionError("must not send")

        processor = DiscordInteractionProcessor(self.router, FakeDiscord(), guild_id="guild")
        event = {
            "guild_id": "other",
            "user": {
                "id": "user",
                "primary_guild": {"identity_guild_id": "guild", "identity_enabled": True, "tag": "뀨?"},
            },
        }
        self.assertFalse(processor.handle_guild_tag_update(event, guild_id="guild", channel_id="log"))

    def test_guild_tag_status_uses_one_message_and_updates_only_active_members(self):
        class FakeDiscord:
            def __init__(self):
                self.created = []
                self.edited = []

            def send_channel_message(self, channel_id, content=None, *, embeds=None, allowed_mentions=None):
                self.created.append((channel_id, content, embeds, allowed_mentions))
                return DiscordResponse(200, {"id": "status-message"})

            def edit_channel_message(self, channel_id, message_id, content=None, *, embeds=None, allowed_mentions=None):
                self.edited.append((channel_id, message_id, content, embeds, allowed_mentions))
                return DiscordResponse(200, {})

        discord = FakeDiscord()
        processor = DiscordInteractionProcessor(
            self.router,
            discord,
            guild_id="guild",
            guild_tag_log_channel_id="log",
            guild_tag_status_channel_id="status",
        )
        enabled = {
            "guild_id": "guild",
            "user": {
                "id": "user",
                "username": "tester",
                "primary_guild": {"identity_guild_id": "guild", "identity_enabled": True, "tag": "뀨?"},
            },
        }
        disabled = {**enabled, "user": {**enabled["user"], "primary_guild": {"identity_enabled": False}}}

        self.assertFalse(processor.handle_guild_tag_update(enabled, guild_id="guild", channel_id="log"))
        self.assertEqual(len(discord.created), 1)
        self.assertEqual(len(discord.edited), 0)
        self.assertIn("<@user>", discord.created[0][2][0]["description"])
        self.assertFalse(processor.handle_guild_tag_update(enabled, guild_id="guild", channel_id="log"))
        self.assertEqual(len(discord.created), 1)
        self.assertTrue(processor.handle_guild_tag_update(disabled, guild_id="guild", channel_id="log"))
        self.assertEqual(len(discord.edited), 1)
        self.assertIn("0명", discord.edited[0][3][0]["description"])

    def test_guild_tag_status_sync_reuses_persisted_message(self):
        class FakeDiscord:
            def __init__(self):
                self.edited = []

            def list_guild_members(self, guild_id, *, limit=1000, after=None):
                self.assertions.append((guild_id, limit, after))
                return []

            def edit_channel_message(self, channel_id, message_id, content=None, *, embeds=None, allowed_mentions=None):
                self.edited.append((channel_id, message_id, embeds, allowed_mentions))
                return DiscordResponse(200, {})

            def send_channel_message(self, *args, **kwargs):
                raise AssertionError("must edit the persisted message")

        discord = FakeDiscord()
        discord.assertions = []
        self.database.set_setting("discord.guild_tag_status_channel_id", "status")
        self.database.set_setting("discord.guild_tag_status_message_id", "message")
        self.database.set_setting("discord.guild_tag_status_members", '{"user":"tester"}')
        processor = DiscordInteractionProcessor(self.router, discord, guild_id="guild", guild_tag_status_channel_id="status")
        self.assertTrue(processor.sync_guild_tag_status(guild_id="guild"))
        self.assertEqual(discord.assertions, [("guild", 1000, None)])
        self.assertEqual(discord.edited[0][1], "message")
        self.assertIn("0명", discord.edited[0][2][0]["description"])

    def test_guild_tag_status_sync_indexes_all_paginated_members(self):
        class FakeDiscord:
            def __init__(self):
                self.assertions = []
                self.edited = []
                self.first_page = []
                for index in range(1, 1001):
                    active = index == 1
                    self.first_page.append(
                        {
                            "user": {
                                "id": str(index),
                                "username": f"user-{index}",
                                "primary_guild": {
                                    "identity_guild_id": "guild",
                                    "identity_enabled": active,
                                },
                            }
                        }
                    )
                self.second_page = [
                    {
                        "user": {
                            "id": "2000",
                            "username": "user-2000",
                            "primary_guild": {
                                "identity_guild_id": "guild",
                                "identity_enabled": True,
                            },
                        }
                    }
                ]

            def list_guild_members(self, guild_id, *, limit=1000, after=None):
                self.assertions.append((guild_id, limit, after))
                if after is None:
                    return self.first_page
                if after == "1000":
                    return self.second_page
                raise AssertionError(f"unexpected pagination cursor: {after}")

            def edit_channel_message(self, channel_id, message_id, content=None, *, embeds=None, allowed_mentions=None):
                self.edited.append((channel_id, message_id, embeds, allowed_mentions))
                return DiscordResponse(200, {})

            def send_channel_message(self, *args, **kwargs):
                raise AssertionError("must edit the persisted message")

        discord = FakeDiscord()
        self.database.set_setting("discord.guild_tag_status_channel_id", "status")
        self.database.set_setting("discord.guild_tag_status_message_id", "message")
        processor = DiscordInteractionProcessor(self.router, discord, guild_id="guild", guild_tag_status_channel_id="status")
        self.assertTrue(processor.sync_guild_tag_status(guild_id="guild"))
        self.assertEqual(discord.assertions, [("guild", 1000, None), ("guild", 1000, "1000")])
        description = discord.edited[0][2][0]["description"]
        self.assertIn("2명", description)
        self.assertIn("<@1>", description)
        self.assertIn("<@2000>", description)
        self.assertNotIn("<@2>", description)
