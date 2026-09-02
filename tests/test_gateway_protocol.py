import unittest

from vending_machine.gateway_protocol import GatewayOpcode, GatewaySession


class GatewayProtocolTests(unittest.TestCase):
    def test_hello_identify_and_ready_resume(self):
        session = GatewaySession("token", 513)
        identify = session.handle_hello({"d": {"heartbeat_interval": 41250}})
        self.assertEqual(identify["op"], GatewayOpcode.IDENTIFY)
        session.handle_dispatch({"s": 4, "t": "READY", "d": {"session_id": "s1", "resume_gateway_url": "wss://resume"}})
        heartbeat = session.heartbeat_payload()
        self.assertEqual(heartbeat, {"op": GatewayOpcode.HEARTBEAT, "d": 4})
        self.assertEqual(session.resume_payload()["op"], GatewayOpcode.RESUME)
