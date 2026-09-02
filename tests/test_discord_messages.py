import unittest

from vending_machine.config import Settings
from vending_machine.database import Database
from vending_machine.discord_gateway import DEPOSIT_MODAL_ID, DiscordInteractionRouter
from vending_machine.discord_messages import COLOR_PRIMARY, COLOR_SUCCESS, guild_tag_status_embed, panel_embed
from vending_machine.service import VendingService


class DiscordMessageFormattingTests(unittest.TestCase):
    def setUp(self):
        self.database = Database(":memory:")
        self.service = VendingService(self.database, Settings())
        self.router = DiscordInteractionRouter(self.service)

    def tearDown(self):
        self.database.close()

    def test_panel_embed_contains_guidance_fields_and_primary_color(self):
        embed = panel_embed()
        self.assertEqual(embed["color"], COLOR_PRIMARY)
        self.assertEqual(embed["title"], "💳 입금 후원 안내")
        self.assertGreaterEqual(len(embed["fields"]), 2)
        self.assertNotIn("금액 범위", {field["name"] for field in embed["fields"]})
        self.assertNotIn("footer", embed)

    def test_support_total_response_contains_embed_and_markdown(self):
        result = self.router.handle(
            {
                "type": 2,
                "member": {"user": {"id": "actor"}},
                "data": {"name": "support-total"},
            }
        )
        data = result.response["data"]
        self.assertIn("**", data["content"])
        self.assertEqual(data["embeds"][0]["color"], COLOR_SUCCESS)
        self.assertEqual(data["embeds"][0]["title"], "💰 누적 후원 금액")

    def test_order_response_and_dm_share_rich_embed(self):
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
        self.assertIsNotNone(result.dm_embeds)
        self.assertEqual(result.response["data"]["embeds"], result.dm_embeds)
        self.assertNotIn("신청 번호", result.response["data"]["content"])
        field_names = {field["name"] for field in result.dm_embeds[0]["fields"]}
        self.assertIn("💰 입금 금액", field_names)
        self.assertNotIn("🧾 신청 번호", field_names)
        self.assertNotIn("footer", result.dm_embeds[0])

    def test_guild_tag_status_embed_lists_only_active_members(self):
        embed = guild_tag_status_embed({"2": "베타", "1": "알파"})
        self.assertEqual(embed["title"], "🏷️ `뀨?` 현재 착용자")
        self.assertEqual(embed["color"], COLOR_SUCCESS)
        self.assertIn("<@1> · 알파", embed["description"])
        self.assertIn("<@2> · 베타", embed["description"])

    def test_guild_tag_status_embed_handles_empty_state(self):
        embed = guild_tag_status_embed({})
        self.assertIn("0명", embed["description"])
        self.assertIn("현재 착용 중인 사람이 없습니다.", embed["description"])


if __name__ == "__main__":
    unittest.main()
