from __future__ import annotations

import base64
import hashlib
import os
import socket
import ssl
import struct
from dataclasses import dataclass
from typing import Callable
from urllib.parse import urlsplit


class WebSocketError(Exception):
    pass


class WebSocketClosed(WebSocketError):
    pass


SocketFactory = Callable[[str, int, float | None], socket.socket]


@dataclass(frozen=True, slots=True)
class WebSocketAddress:
    scheme: str
    host: str
    port: int
    path: str


def parse_websocket_url(url: str) -> WebSocketAddress:
    parsed = urlsplit(url)
    if parsed.scheme not in {"ws", "wss"} or not parsed.hostname:
        raise WebSocketError("websocket URL must use ws:// or wss://")
    default_port = 443 if parsed.scheme == "wss" else 80
    path = parsed.path or "/"
    if parsed.query:
        path += "?" + parsed.query
    return WebSocketAddress(parsed.scheme, parsed.hostname, parsed.port or default_port, path)


class WebSocketConnection:
    def __init__(
        self,
        url: str,
        *,
        timeout: float = 20.0,
        max_message_bytes: int = 16 * 1024 * 1024,
        socket_factory: SocketFactory | None = None,
        ssl_context: ssl.SSLContext | None = None,
    ):
        self.url = url
        self.timeout = timeout
        if max_message_bytes <= 0:
            raise ValueError("max websocket message size must be positive")
        self.max_message_bytes = max_message_bytes
        self.socket_factory = socket_factory or self._default_socket_factory
        self.ssl_context = ssl_context or ssl.create_default_context()
        self.address = parse_websocket_url(url)
        self.socket: socket.socket | None = None
        self._buffer = bytearray()
        self._closed = False
        self._fragment_opcode: int | None = None
        self._fragment_parts: list[bytes] = []
        self._fragment_size = 0

    @staticmethod
    def _default_socket_factory(host: str, port: int, timeout: float | None) -> socket.socket:
        return socket.create_connection((host, port), timeout=timeout)

    def connect(self) -> "WebSocketConnection":
        if self.socket is not None:
            return self
        raw_socket = self.socket_factory(self.address.host, self.address.port, self.timeout)
        try:
            raw_socket.settimeout(self.timeout)
            if self.address.scheme == "wss":
                server_hostname = self.address.host
                raw_socket = self.ssl_context.wrap_socket(raw_socket, server_hostname=server_hostname)
            self.socket = raw_socket
            self._handshake()
            return self
        except Exception:
            try:
                raw_socket.close()
            finally:
                self.socket = None
            raise

    def _send_raw(self, data: bytes) -> None:
        if self.socket is None:
            raise WebSocketClosed("websocket is not connected")
        view = memoryview(data)
        while view:
            count = self.socket.send(view)
            if count <= 0:
                raise WebSocketClosed("websocket send failed")
            view = view[count:]

    def _recv_raw(self, size: int) -> bytes:
        if self.socket is None:
            raise WebSocketClosed("websocket is not connected")
        while len(self._buffer) < size:
            chunk = self.socket.recv(max(4096, size - len(self._buffer)))
            if not chunk:
                raise WebSocketClosed("websocket peer closed the connection")
            self._buffer.extend(chunk)
        result = bytes(self._buffer[:size])
        del self._buffer[:size]
        return result

    def _read_http_headers(self) -> bytes:
        marker = b"\r\n\r\n"
        while marker not in self._buffer:
            if len(self._buffer) > 65536:
                raise WebSocketError("websocket handshake is too large")
            if self.socket is None:
                raise WebSocketClosed("websocket is not connected")
            chunk = self.socket.recv(4096)
            if not chunk:
                raise WebSocketClosed("websocket closed during handshake")
            self._buffer.extend(chunk)
        end = self._buffer.index(marker) + len(marker)
        headers = bytes(self._buffer[:end])
        del self._buffer[:end]
        return headers

    def _handshake(self) -> None:
        key = base64.b64encode(os.urandom(16)).decode("ascii")
        host = self.address.host
        if ":" in host and not host.startswith("["):
            host = f"[{host}]"
        if (self.address.scheme == "ws" and self.address.port != 80) or (self.address.scheme == "wss" and self.address.port != 443):
            host = f"{host}:{self.address.port}"
        request = (
            f"GET {self.address.path} HTTP/1.1\r\n"
            f"Host: {host}\r\n"
            "Upgrade: websocket\r\n"
            "Connection: Upgrade\r\n"
            f"Sec-WebSocket-Key: {key}\r\n"
            "Sec-WebSocket-Version: 13\r\n"
            "User-Agent: yul-vending-machine/1\r\n"
            "\r\n"
        ).encode("ascii")
        self._send_raw(request)
        raw_headers = self._read_http_headers()
        lines = raw_headers.decode("iso-8859-1").split("\r\n")
        status_line = lines[0] if lines else ""
        if (
            len(status_line) < 12
            or status_line[:9] != "HTTP/1.1 "
            or status_line[9:12] != "101"
            or (len(status_line) > 12 and status_line[12] not in " \t")
        ):
            raise WebSocketError("websocket handshake was rejected")
        values: dict[str, str] = {}
        for line in lines[1:]:
            if ":" not in line:
                continue
            name, value = line.split(":", 1)
            values[name.strip().lower()] = value.strip()
        expected = base64.b64encode(hashlib.sha1((key + "258EAFA5-E914-47DA-95CA-C5AB0DC85B11").encode("ascii")).digest()).decode("ascii")
        connection_tokens = {token.strip().lower() for token in values.get("connection", "").split(",")}
        if values.get("upgrade", "").lower() != "websocket" or "upgrade" not in connection_tokens:
            raise WebSocketError("invalid websocket handshake headers")
        if values.get("sec-websocket-accept") != expected:
            raise WebSocketError("invalid websocket handshake response")

    @staticmethod
    def _mask_payload(payload: bytes, mask: bytes) -> bytes:
        return bytes(value ^ mask[index % 4] for index, value in enumerate(payload))

    def _send_frame(self, opcode: int, payload: bytes, *, fin: bool = True) -> None:
        if len(payload) >= 2**63:
            raise WebSocketError("websocket payload is too large")
        first = (0x80 if fin else 0) | (opcode & 0x0F)
        mask = os.urandom(4)
        length = len(payload)
        if length < 126:
            header = bytes((first, 0x80 | length))
        elif length < 2**16:
            header = bytes((first, 0x80 | 126)) + struct.pack("!H", length)
        else:
            header = bytes((first, 0x80 | 127)) + struct.pack("!Q", length)
        self._send_raw(header + mask + self._mask_payload(payload, mask))

    def send_text(self, value: str) -> None:
        self._send_frame(0x1, value.encode("utf-8", "strict"))

    def send_binary(self, value: bytes) -> None:
        self._send_frame(0x2, bytes(value))

    def send_ping(self, payload: bytes = b"") -> None:
        if len(payload) > 125:
            raise WebSocketError("websocket control payload is too large")
        self._send_frame(0x9, payload)

    def send_pong(self, payload: bytes = b"") -> None:
        if len(payload) > 125:
            raise WebSocketError("websocket control payload is too large")
        self._send_frame(0xA, payload)

    def _recv_frame(self) -> tuple[int, bytes, bool]:
        first, second = self._recv_raw(2)
        fin = bool(first & 0x80)
        rsv = first & 0x70
        opcode = first & 0x0F
        if rsv:
            raise WebSocketError("websocket extensions are not supported")
        masked = bool(second & 0x80)
        length = second & 0x7F
        if length == 126:
            length = struct.unpack("!H", self._recv_raw(2))[0]
        elif length == 127:
            length = struct.unpack("!Q", self._recv_raw(8))[0]
            if length & (1 << 63):
                raise WebSocketError("invalid websocket payload length")
        if opcode >= 0x8 and (not fin or length > 125):
            raise WebSocketError("invalid websocket control frame")
        if length > self.max_message_bytes:
            raise WebSocketError("websocket payload is too large")
        mask = self._recv_raw(4) if masked else None
        payload = self._recv_raw(length)
        if mask is not None:
            payload = self._mask_payload(payload, mask)
        return opcode, payload, fin

    def recv(self, *, timeout: float | None = None) -> str | bytes:
        if self.socket is None:
            raise WebSocketClosed("websocket is not connected")
        previous_timeout = self.socket.gettimeout()
        if timeout is not None:
            self.socket.settimeout(timeout)
        try:
            while True:
                opcode, payload, fin = self._recv_frame()
                if opcode == 0x8:
                    if self.socket is not None:
                        try:
                            self._send_frame(0x8, payload[:125])
                        except (OSError, WebSocketError):
                            pass
                    self._closed = True
                    raise WebSocketClosed("websocket close frame received")
                if opcode == 0x9:
                    self.send_pong(payload)
                    continue
                if opcode == 0xA:
                    continue
                if opcode in {0x1, 0x2}:
                    if self._fragment_opcode is not None:
                        raise WebSocketError("new websocket message before continuation")
                    self._fragment_opcode = opcode
                    self._fragment_parts = [payload]
                    self._fragment_size = len(payload)
                elif opcode == 0x0:
                    if self._fragment_opcode is None:
                        raise WebSocketError("unexpected websocket continuation")
                    self._fragment_parts.append(payload)
                    self._fragment_size += len(payload)
                    if self._fragment_size > self.max_message_bytes:
                        raise WebSocketError("websocket payload is too large")
                else:
                    raise WebSocketError("unsupported websocket opcode")
                if fin:
                    message_opcode = self._fragment_opcode
                    complete = b"".join(self._fragment_parts)
                    self._fragment_opcode = None
                    self._fragment_parts = []
                    self._fragment_size = 0
                    if message_opcode == 0x1:
                        return complete.decode("utf-8", "strict")
                    return complete
        finally:
            if self.socket is not None and timeout is not None:
                self.socket.settimeout(previous_timeout)

    def close(self) -> None:
        sock, self.socket = self.socket, None
        self._closed = True
        if sock is None:
            return
        try:
            try:
                mask = os.urandom(4)
                payload = struct.pack("!H", 1000)
                frame = bytes((0x88, 0x82)) + mask + self._mask_payload(payload, mask)
                sock.sendall(frame)
            except OSError:
                pass
        finally:
            sock.close()

    def __enter__(self) -> "WebSocketConnection":
        return self.connect()

    def __exit__(self, exc_type, exc_value, traceback) -> None:
        self.close()
