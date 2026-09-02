from __future__ import annotations

import json
import socket
import threading
import time
from collections.abc import Callable
from typing import Any

from .database import Database
from .config import validate_runtime_endpoint
from .discord_gateway import DiscordInteractionProcessor
from .discord_rest import DiscordRestClient
from .errors import SettingsError
from .gateway_protocol import GatewayOpcode, GatewaySession
from .json_utils import loads_native
from .websocket import WebSocketClosed, WebSocketConnection, WebSocketError


class DiscordGatewayError(Exception):
    pass


class DiscordGatewayClient:
    def __init__(
        self,
        token: str,
        processor: DiscordInteractionProcessor,
        *,
        database: Database | None = None,
        rest: DiscordRestClient | None = None,
        guild_id: str = "",
        guild_tag_log_channel_id: str = "",
        guild_tag_status_channel_id: str = "",
        guild_tag_role_id: str = "",
        intents: int = 1,
        gateway_url: str = "wss://gateway.discord.gg/?v=10&encoding=json",
        websocket_factory: Callable[[str], WebSocketConnection] | None = None,
        on_error: Callable[[Exception], None] | None = None,
        reconnect_min_seconds: float = 1.0,
        reconnect_max_seconds: float = 60.0,
    ):
        if not token:
            raise ValueError("Discord bot token is required")
        if intents < 0:
            raise ValueError("Discord intents must not be negative")
        validate_runtime_endpoint(
            "DISCORD_GATEWAY_URL",
            gateway_url,
            exact=frozenset({"gateway.discord.gg"}),
            suffixes=frozenset({"discord.gg", "discord.com"}),
            allowed_paths=frozenset({"", "/"}),
            allowed_query_keys=frozenset({"v", "encoding"}),
        )
        self.processor = processor
        self.database = database
        self.rest = rest
        self.guild_id = guild_id
        self.guild_tag_log_channel_id = guild_tag_log_channel_id
        self.guild_tag_status_channel_id = guild_tag_status_channel_id
        self.guild_tag_role_id = str(guild_tag_role_id or "")
        self.gateway_url = gateway_url
        self.websocket_factory = websocket_factory or (lambda url: WebSocketConnection(url))
        self.on_error = on_error
        self.reconnect_min_seconds = max(0.1, reconnect_min_seconds)
        self.reconnect_max_seconds = max(self.reconnect_min_seconds, reconnect_max_seconds)
        effective_intents = intents | (1 << 1) if guild_tag_log_channel_id or guild_tag_status_channel_id or guild_tag_role_id else intents
        self.session = GatewaySession(token, effective_intents)
        self._socket: WebSocketConnection | None = None
        self._stop = threading.Event()
        self._commands_registered = False
        self._restore_session()

    def _restore_session(self) -> None:
        if self.database is None:
            return
        sequence_value = self.database.get_setting("discord.gateway_sequence")
        sequence: int | None
        try:
            sequence = None if sequence_value is None else int(sequence_value)
        except ValueError:
            sequence = None
        self.session.restore(
            sequence=sequence,
            session_id=self.database.get_setting("discord.gateway_session_id"),
            resume_gateway_url=self.database.get_setting("discord.gateway_resume_url"),
        )

    def _save_session(self) -> None:
        if self.database is None:
            return
        if self.session.sequence is None:
            self.database.set_setting("discord.gateway_sequence", "")
        else:
            self.database.set_setting("discord.gateway_sequence", str(self.session.sequence))
        self.database.set_setting("discord.gateway_session_id", self.session.session_id or "")
        self.database.set_setting("discord.gateway_resume_url", self.session.resume_gateway_url or "")

    def stop(self) -> None:
        self._stop.set()
        websocket = self._socket
        if websocket is not None:
            websocket.close()

    def _notify_error(self, error: Exception) -> None:
        if self.on_error is not None:
            try:
                self.on_error(error)
            except Exception:
                return

    @staticmethod
    def _json_message(value: str | bytes | dict[str, Any]) -> dict[str, Any]:
        if isinstance(value, dict):
            return value
        if isinstance(value, bytes):
            value = value.decode("utf-8", "strict")
        payload = loads_native(value)
        if not isinstance(payload, dict):
            raise DiscordGatewayError("Discord Gateway message is not an object")
        return payload

    @staticmethod
    def _send(websocket: WebSocketConnection, payload: dict[str, Any]) -> None:
        websocket.send_text(json.dumps(payload, ensure_ascii=False, separators=(",", ":")))

    def _gateway_url(self) -> str:
        if self.session.resumable and self.session.resume_gateway_url:
            url = self.session.resume_gateway_url
            try:
                validate_runtime_endpoint(
                    "DISCORD_RESUME_GATEWAY_URL",
                    url,
                    exact=frozenset({"gateway.discord.gg"}),
                    suffixes=frozenset({"discord.gg", "discord.com"}),
                    allowed_paths=frozenset({"", "/"}),
                    allowed_query_keys=frozenset({"v", "encoding"}),
                )
            except (TypeError, ValueError, SettingsError):
                valid = False
            else:
                valid = True
            if valid:
                if "?" not in url:
                    return url + "?v=10&encoding=json"
                return url
            self.session.clear_session()
            self._save_session()
        return self.gateway_url

    def _register_commands(self) -> None:
        if self._commands_registered or self.rest is None or not self.guild_id:
            return
        self.rest.upsert_guild_commands(self.guild_id)
        self._commands_registered = True

    def register_commands(self) -> None:
        self._register_commands()

    def _dispatch_interaction(self, data: dict[str, Any]) -> None:
        interaction_id = data.get("id")
        interaction_token = data.get("token")
        if not interaction_id or not interaction_token:
            raise DiscordGatewayError("Discord interaction is missing id or token")
        self.processor.process(
            data,
            interaction_id=str(interaction_id),
            interaction_token=str(interaction_token),
        )

    def _run_connection(self, websocket: WebSocketConnection, stop_event: threading.Event | None = None) -> None:
        self._socket = websocket
        websocket.connect()
        heartbeat_interval = 30.0
        next_heartbeat = time.monotonic() + heartbeat_interval
        heartbeat_ack = True
        try:
            while not self._stop.is_set() and not (stop_event is not None and stop_event.is_set()):
                now = time.monotonic()
                timeout = max(0.05, min(1.0, next_heartbeat - now))
                try:
                    raw = websocket.recv(timeout=timeout)
                except (socket.timeout, TimeoutError):
                    raw = None
                if raw is not None:
                    payload = self._json_message(raw)
                    opcode_value = payload.get("op")
                    try:
                        opcode = GatewayOpcode(int(opcode_value))
                    except (TypeError, ValueError):
                        raise DiscordGatewayError("unknown Discord Gateway opcode")
                    if opcode == GatewayOpcode.HELLO:
                        identify_or_resume = self.session.handle_hello(payload)
                        heartbeat_interval = max(1.0, (self.session.heartbeat_interval_ms or 30000) / 1000.0)
                        next_heartbeat = time.monotonic() + heartbeat_interval
                        heartbeat_ack = True
                        self._send(websocket, identify_or_resume)
                    elif opcode == GatewayOpcode.DISPATCH:
                        previous_sequence = self.session.sequence
                        event_name = self.session.handle_dispatch(payload)
                        data = payload.get("d")
                        if event_name == "INTERACTION_CREATE" and isinstance(data, dict):
                            try:
                                self._dispatch_interaction(data)
                            except Exception:
                                self.session.sequence = previous_sequence
                                raise
                        elif event_name in {"READY", "RESUMED"} and (
                            self.guild_tag_log_channel_id or self.guild_tag_status_channel_id or self.guild_tag_role_id
                        ):
                            sync = getattr(self.processor, "sync_guild_tag_status", None)
                            if sync is not None:
                                try:
                                    sync(guild_id=self.guild_id)
                                except Exception as exc:
                                    self._notify_error(exc)
                        elif event_name == "GUILD_MEMBER_UPDATE" and isinstance(data, dict) and (
                            self.guild_tag_log_channel_id or self.guild_tag_status_channel_id or self.guild_tag_role_id
                        ):
                            try:
                                self.processor.handle_guild_tag_update(
                                    data,
                                    guild_id=self.guild_id,
                                    channel_id=self.guild_tag_log_channel_id,
                                    status_channel_id=self.guild_tag_status_channel_id,
                                )
                            except Exception as exc:
                                self._notify_error(exc)
                        self._save_session()
                    elif opcode == GatewayOpcode.HEARTBEAT:
                        self._send(websocket, self.session.heartbeat_payload())
                    elif opcode == GatewayOpcode.HEARTBEAT_ACK:
                        heartbeat_ack = True
                    elif opcode == GatewayOpcode.RECONNECT:
                        raise DiscordGatewayError("Discord requested Gateway reconnect")
                    elif opcode == GatewayOpcode.INVALID_SESSION:
                        resumable = bool(payload.get("d"))
                        self._send(websocket, self.session.handle_invalid_session(resumable))
                        self._save_session()
                now = time.monotonic()
                if now >= next_heartbeat:
                    if not heartbeat_ack:
                        raise DiscordGatewayError("Discord heartbeat was not acknowledged")
                    self._send(websocket, self.session.heartbeat_payload())
                    heartbeat_ack = False
                    next_heartbeat = now + heartbeat_interval
        finally:
            if self._socket is websocket:
                self._socket = None
            websocket.close()

    def run_forever(self, stop_event: threading.Event | None = None) -> None:
        external_stop = stop_event or self._stop
        delay = self.reconnect_min_seconds
        while not external_stop.is_set() and not self._stop.is_set():
            if not self._commands_registered:
                try:
                    self._register_commands()
                except Exception as exc:
                    self._notify_error(exc)
                    external_stop.wait(delay)
                    delay = min(self.reconnect_max_seconds, delay * 2)
                    continue
            websocket: WebSocketConnection | None = None
            try:
                websocket = self.websocket_factory(self._gateway_url())
                self._run_connection(websocket, external_stop)
                delay = self.reconnect_min_seconds
            except (WebSocketClosed, WebSocketError, DiscordGatewayError, OSError, socket.timeout) as exc:
                if not external_stop.is_set() and not self._stop.is_set():
                    self._notify_error(exc)
                    external_stop.wait(delay)
                    delay = min(self.reconnect_max_seconds, delay * 2)
            except Exception as exc:
                if not external_stop.is_set() and not self._stop.is_set():
                    self._notify_error(exc)
                    external_stop.wait(delay)
                    delay = min(self.reconnect_max_seconds, delay * 2)
            finally:
                if websocket is not None and self._socket is websocket:
                    self._socket = None
                    websocket.close()
