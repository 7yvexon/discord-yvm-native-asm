import base64
import hashlib
import unittest

from vending_machine.websocket import WebSocketConnection, WebSocketError


class MemorySocket:
    def __init__(self, *, status_line="HTTP/1.1 101 Switching Protocols", upgrade="websocket", connection="Upgrade"):
        self.incoming = bytearray()
        self.outgoing = bytearray()
        self.timeout = None
        self.handshake_done = False
        self.status_line = status_line
        self.upgrade = upgrade
        self.connection = connection

    def settimeout(self, value):
        self.timeout = value

    def gettimeout(self):
        return self.timeout

    def send(self, value):
        data = bytes(value)
        self.outgoing.extend(data)
        if not self.handshake_done and b"\r\n\r\n" in self.outgoing:
            request = bytes(self.outgoing)
            key_line = next(line for line in request.split(b"\r\n") if line.lower().startswith(b"sec-websocket-key:"))
            key = key_line.split(b":", 1)[1].strip().decode("ascii")
            accept = base64.b64encode(hashlib.sha1((key + "258EAFA5-E914-47DA-95CA-C5AB0DC85B11").encode("ascii")).digest()).decode("ascii")
            self.incoming.extend(
                (
                    f"{self.status_line}\r\n"
                    f"Upgrade: {self.upgrade}\r\n"
                    f"Connection: {self.connection}\r\n"
                    f"Sec-WebSocket-Accept: {accept}\r\n\r\n"
                ).encode("ascii")
            )
            self.incoming.extend(bytes((0x89, 0x03)) + b"abc")
            self.incoming.extend(bytes((0x81, 0x05)) + b"hello")
            self.handshake_done = True
        return len(data)

    def sendall(self, value):
        return self.send(value)

    def recv(self, size):
        if not self.incoming:
            return b""
        result = bytes(self.incoming[:size])
        del self.incoming[:size]
        return result

    def close(self):
        return None


class WebSocketTests(unittest.TestCase):
    def test_handshake_text_and_ping_pong(self):
        socket = MemorySocket()
        websocket = WebSocketConnection(
            "ws://example.test/socket",
            socket_factory=lambda host, port, timeout: socket,
        )
        websocket.connect()
        self.assertEqual(websocket.recv(), "hello")
        self.assertIn(b"\x8a\x83", bytes(socket.outgoing))
        self.assertIn(b"GET /socket HTTP/1.1", bytes(socket.outgoing))
        websocket.close()

    def test_handshake_rejects_non_exact_status(self):
        socket = MemorySocket(status_line="HTTP/1.1 101x")
        websocket = WebSocketConnection(
            "ws://example.test/socket",
            socket_factory=lambda host, port, timeout: socket,
        )
        with self.assertRaises(WebSocketError):
            websocket.connect()

    def test_handshake_requires_upgrade_connection_tokens(self):
        socket = MemorySocket(upgrade="websocketX", connection="Keep-Alive")
        websocket = WebSocketConnection(
            "ws://example.test/socket",
            socket_factory=lambda host, port, timeout: socket,
        )
        with self.assertRaises(WebSocketError):
            websocket.connect()


if __name__ == "__main__":
    unittest.main()
