import json
import threading
import unittest

from vending_machine.discord_client import DiscordGatewayClient


class FakeProcessor:
    def __init__(self):
        self.calls = []

    def process(self, interaction, *, interaction_id, interaction_token):
        self.calls.append((interaction, interaction_id, interaction_token))


class SyncProcessor(FakeProcessor):
    def __init__(self):
        super().__init__()
        self.sync_calls = []

    def sync_guild_tag_status(self, *, guild_id):
        self.sync_calls.append(guild_id)
        return True


class FakeGatewaySocket:
    def __init__(self, stop_event):
        self.stop_event = stop_event
        self.messages = [
            {"op": 10, "d": {"heartbeat_interval": 1000}},
            {"op": 0, "s": 1, "t": "READY", "d": {"session_id": "session", "resume_gateway_url": "wss://resume"}},
            {
                "op": 0,
                "s": 2,
                "t": "INTERACTION_CREATE",
                "d": {"id": "interaction", "token": "token", "type": 2, "data": {"name": "support-total"}},
            },
        ]
        self.sent = []
        self.connected = False

    def connect(self):
        self.connected = True
        return self

    def send_text(self, value):
        self.sent.append(json.loads(value))

    def recv(self, *, timeout=None):
        value = self.messages.pop(0)
        if not self.messages:
            self.stop_event.set()
        return json.dumps(value)

    def close(self):
        return None


class DiscordClientTests(unittest.TestCase):
    def test_gateway_url_uses_resume_endpoint_only_for_resumable_session(self):
        processor = FakeProcessor()
        client = DiscordGatewayClient(
            "token",
            processor,
            gateway_url="wss://gateway.discord.gg/?v=10&encoding=json",
        )

        client.session.resume_gateway_url = "wss://gateway.discord.gg"
        self.assertEqual(client._gateway_url(), "wss://gateway.discord.gg/?v=10&encoding=json")

        client.session.session_id = "session"
        client.session.sequence = 3
        self.assertEqual(client._gateway_url(), "wss://gateway.discord.gg?v=10&encoding=json")

        client.session.resume_gateway_url = "wss://attacker.example"
        self.assertEqual(client._gateway_url(), "wss://gateway.discord.gg/?v=10&encoding=json")
        self.assertFalse(client.session.resumable)

    def test_interaction_failure_does_not_checkpoint_sequence(self):
        stop_event = threading.Event()

        class FailingProcessor(FakeProcessor):
            def process(self, interaction, *, interaction_id, interaction_token):
                stop_event.set()
                raise RuntimeError("interaction failed")

        class InteractionSocket(FakeGatewaySocket):
            def __init__(self, stop_event):
                super().__init__(stop_event)
                self.messages = [
                    {"op": 10, "d": {"heartbeat_interval": 1000}},
                    {"op": 0, "s": 1, "t": "READY", "d": {"session_id": "session", "resume_gateway_url": "wss://gateway.discord.gg"}},
                    {"op": 0, "s": 2, "t": "INTERACTION_CREATE", "d": {"id": "interaction", "token": "token", "type": 2, "data": {"name": "support-total"}}},
                ]

        websocket = InteractionSocket(stop_event)
        client = DiscordGatewayClient(
            "token",
            FailingProcessor(),
            gateway_url="wss://gateway.discord.gg",
            websocket_factory=lambda url: websocket,
        )
        client.run_forever(stop_event)
        self.assertEqual(client.session.sequence, 1)

    def test_gateway_identifies_persists_dispatch_and_routes_interaction(self):
        stop_event = threading.Event()
        processor = FakeProcessor()
        websocket = FakeGatewaySocket(stop_event)
        client = DiscordGatewayClient(
            "token",
            processor,
            gateway_url="wss://gateway.discord.gg",
            websocket_factory=lambda url: websocket,
        )
        client.run_forever(stop_event)
        self.assertTrue(websocket.connected)
        self.assertEqual(websocket.sent[0]["op"], 2)
        self.assertEqual(len(processor.calls), 1)
        self.assertEqual(processor.calls[0][1:], ("interaction", "token"))

    def test_gateway_reindexes_guild_tag_status_after_resume(self):
        stop_event = threading.Event()
        processor = SyncProcessor()

        class ResumeSocket(FakeGatewaySocket):
            def __init__(self, stop_event):
                super().__init__(stop_event)
                self.messages = [
                    {"op": 10, "d": {"heartbeat_interval": 1000}},
                    {"op": 0, "s": 2, "t": "RESUMED", "d": {}},
                ]

        websocket = ResumeSocket(stop_event)
        client = DiscordGatewayClient(
            "token",
            processor,
            gateway_url="wss://gateway.discord.gg",
            websocket_factory=lambda url: websocket,
            guild_id="guild",
            guild_tag_status_channel_id="status",
        )
        client.run_forever(stop_event)
        self.assertEqual(processor.sync_calls, ["guild"])

    def test_gateway_reindexes_guild_tag_roles_when_only_role_is_configured(self):
        stop_event = threading.Event()
        processor = SyncProcessor()

        class ReadySocket(FakeGatewaySocket):
            def __init__(self, stop_event):
                super().__init__(stop_event)
                self.messages = [
                    {"op": 10, "d": {"heartbeat_interval": 1000}},
                    {"op": 0, "s": 1, "t": "READY", "d": {"session_id": "session", "resume_gateway_url": "wss://resume"}},
                ]

        websocket = ReadySocket(stop_event)
        client = DiscordGatewayClient(
            "token",
            processor,
            gateway_url="wss://gateway.discord.gg",
            websocket_factory=lambda url: websocket,
            guild_id="guild",
            guild_tag_role_id="role",
        )
        self.assertEqual(client.session.intents & 2, 2)
        client.run_forever(stop_event)
        self.assertEqual(processor.sync_calls, ["guild"])


if __name__ == "__main__":
    unittest.main()
