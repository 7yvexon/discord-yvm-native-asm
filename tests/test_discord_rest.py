import json
import unittest

from vending_machine.discord_messages import panel_embed
from vending_machine.discord_rest import DiscordRestClient


class FakeResponse:
    def __init__(self, payload):
        self.status = 200
        self.headers = {}
        self.payload = payload

    def read(self):
        return json.dumps(self.payload).encode("utf-8")

    def __enter__(self):
        return self

    def __exit__(self, *args):
        return False


class DiscordRestFormattingTests(unittest.TestCase):
    def test_application_commands_are_korean_and_have_no_manual_approval(self):
        commands = DiscordRestClient.application_commands()
        self.assertEqual(
            [command["name"] for command in commands],
            ["후원금액", "입금패널", "검토목록", "지급원장"],
        )
        self.assertNotIn("review-approve", {command["name"] for command in commands})

    def test_panel_and_dm_send_embeds(self):
        requests = []

        def opener(request, timeout):
            requests.append((request.method, json.loads(request.data.decode("utf-8"))))
            if len(requests) == 1:
                return FakeResponse({"id": "panel-message"})
            if len(requests) == 2:
                return FakeResponse({"id": "dm-channel"})
            return FakeResponse({"id": "dm-message"})

        client = DiscordRestClient("token", "application", opener=opener)
        client.publish_panel("channel", embeds=[panel_embed()])
        client.send_dm("user", "✅ **확인**", embeds=[{"title": "🎉 완료", "color": 0x57F287}])

        self.assertEqual(requests[0][1]["components"][0]["components"][0]["emoji"], {"name": "💳"})
        self.assertNotIn("content", requests[0][1])
        self.assertIn("embeds", requests[0][1])
        self.assertEqual(requests[1][0], "POST")
        self.assertEqual(requests[2][1]["embeds"][0]["title"], "🎉 완료")

    def test_guild_member_list_and_message_edit_use_expected_endpoints(self):
        requests = []

        def opener(request, timeout):
            requests.append((request.method, request.full_url, json.loads(request.data.decode("utf-8")) if request.data else None))
            if request.method == "GET":
                return FakeResponse([{"user": {"id": "member"}}])
            return FakeResponse({"id": "status-message"})

        client = DiscordRestClient("token", "application", opener=opener, api_base="https://discord.test/api/v10")
        self.assertEqual(client.list_guild_members("guild"), [{"user": {"id": "member"}}])
        client.edit_channel_message("channel", "message", embeds=[{"title": "상태"}], allowed_mentions={"parse": []})

        self.assertEqual(requests[0][0], "GET")
        self.assertIn("/guilds/guild/members?limit=1000", requests[0][1])
        self.assertEqual(requests[1][0], "PATCH")
        self.assertEqual(requests[1][2]["embeds"][0]["title"], "상태")
        self.assertEqual(requests[1][2]["allowed_mentions"], {"parse": []})

    def test_guild_member_role_requests_use_expected_endpoints(self):
        requests = []

        def opener(request, timeout):
            requests.append((request.method, request.full_url, request.data))
            return FakeResponse(None)

        client = DiscordRestClient("token", "application", opener=opener, api_base="https://discord.test/api/v10")
        client.add_guild_member_role("guild", "member", "role")
        client.remove_guild_member_role("guild", "member", "role")

        self.assertEqual(requests[0][0], "PUT")
        self.assertEqual(requests[0][1], "https://discord.test/api/v10/guilds/guild/members/member/roles/role")
        self.assertIsNone(requests[0][2])
        self.assertEqual(requests[1][0], "DELETE")
        self.assertEqual(requests[1][1], "https://discord.test/api/v10/guilds/guild/members/member/roles/role")
        self.assertIsNone(requests[1][2])


if __name__ == "__main__":
    unittest.main()
