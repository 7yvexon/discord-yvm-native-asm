from __future__ import annotations

import json
import math
import socket
import threading
import time
import urllib.error
import urllib.parse
import urllib.request
from dataclasses import dataclass
from decimal import Decimal, InvalidOperation
from typing import Any, Callable, Iterable

from .database import Database
from .config import validate_runtime_endpoint
from .errors import DatabaseError
from .json_utils import loads_native
from .models import MatchResult
from .service import VendingService
from .websocket import WebSocketClosed, WebSocketConnection, WebSocketError


class PushbulletError(Exception):
    pass


@dataclass(frozen=True, slots=True)
class PushbulletResponse:
    status: int
    payload: dict[str, Any]


class PushbulletPage(list[Any]):
    __slots__ = ("cursor",)

    def __init__(self, pushes: Iterable[Any], cursor: str | None = None):
        super().__init__(pushes)
        self.cursor = cursor

    @property
    def pushes(self) -> list[Any]:
        return self


class PushbulletApi:
    max_response_bytes = 1024 * 1024
    max_pushes_per_page = 100
    max_cursor_bytes = 256
    max_modified_bytes = 64
    max_modified_value = Decimal((1 << 63) - 1)

    def __init__(self, access_token: str, *, opener: Callable[..., Any] | None = None, base_url: str = "https://api.pushbullet.com/v2"):
        if not access_token:
            raise ValueError("Pushbullet access token is required")
        self.access_token = access_token
        self.opener = opener or urllib.request.urlopen
        self.base_url = base_url.rstrip("/")

    @classmethod
    def _read_response(cls, response: Any) -> bytes:
        headers = getattr(response, "headers", None)
        content_length = None
        if headers is not None:
            try:
                content_length = headers.get("Content-Length")
            except AttributeError:
                content_length = None
        if content_length:
            try:
                if int(content_length) > cls.max_response_bytes:
                    raise PushbulletError("Pushbullet response is too large")
            except (TypeError, ValueError, OverflowError) as exc:
                raise PushbulletError("Pushbullet response has an invalid content length") from exc
        chunks = bytearray()
        while True:
            single_read = False
            try:
                chunk = response.read(min(65536, cls.max_response_bytes - len(chunks) + 1))
            except TypeError:
                chunk = response.read()
                single_read = True
            if not chunk:
                break
            if not isinstance(chunk, (bytes, bytearray)):
                raise PushbulletError("Pushbullet response body is invalid")
            chunks.extend(chunk)
            if len(chunks) > cls.max_response_bytes:
                raise PushbulletError("Pushbullet response is too large")
            if single_read:
                break
        return bytes(chunks)

    @classmethod
    def _validate_json_shape(cls, value: Any, *, depth: int = 0, budget: list[int] | None = None) -> None:
        if budget is None:
            budget = [10000]
        budget[0] -= 1
        if budget[0] < 0 or depth > 32:
            raise PushbulletError("Pushbullet response is too deeply nested")
        if isinstance(value, str):
            if len(value.encode("utf-8", "replace")) > 65536:
                raise PushbulletError("Pushbullet response contains an oversized string")
        elif isinstance(value, float):
            if not math.isfinite(value):
                raise PushbulletError("Pushbullet response contains a non-finite number")
        elif isinstance(value, dict):
            if len(value) > 256:
                raise PushbulletError("Pushbullet response contains too many object fields")
            for key, item in value.items():
                if not isinstance(key, str) or len(key.encode("utf-8", "replace")) > 256:
                    raise PushbulletError("Pushbullet response contains an invalid key")
                cls._validate_json_shape(item, depth=depth + 1, budget=budget)
        elif isinstance(value, list):
            if len(value) > cls.max_pushes_per_page:
                raise PushbulletError("Pushbullet response contains too many pushes")
            for item in value:
                cls._validate_json_shape(item, depth=depth + 1, budget=budget)

    def list_pushes(
        self,
        modified_after: str | None = None,
        *,
        cursor: str | None = None,
        limit: int = 50,
    ) -> PushbulletPage:
        if limit <= 0 or limit > self.max_pushes_per_page:
            raise ValueError("Pushbullet limit is outside the valid range")
        if cursor is not None and not isinstance(cursor, str):
            raise PushbulletError("Pushbullet cursor must be text")
        if modified_after is not None and not isinstance(modified_after, str):
            raise PushbulletError("Pushbullet modified cursor must be text")
        normalized_modified_after = None
        if modified_after:
            try:
                if len(modified_after.encode("utf-8", "strict")) > self.max_modified_bytes:
                    raise PushbulletError("Pushbullet modified cursor is too long")
                parsed_modified_after = Decimal(modified_after)
                if (
                    not parsed_modified_after.is_finite()
                    or parsed_modified_after.copy_abs() > self.max_modified_value
                    or parsed_modified_after.as_tuple().exponent < -6
                ):
                    raise PushbulletError("Pushbullet modified cursor is invalid")
                normalized_modified_after = format(parsed_modified_after, "f")
                if "." in normalized_modified_after:
                    normalized_modified_after = normalized_modified_after.rstrip("0").rstrip(".")
                normalized_modified_after = normalized_modified_after or "0"
            except (InvalidOperation, ValueError, UnicodeEncodeError, OverflowError) as exc:
                raise PushbulletError("Pushbullet modified cursor is invalid") from exc
        query = {"limit": str(limit)}
        if cursor:
            if len(cursor.encode("utf-8", "strict")) > self.max_cursor_bytes:
                raise PushbulletError("Pushbullet cursor is too long")
            query["cursor"] = cursor
        elif normalized_modified_after:
            query["modified_after"] = normalized_modified_after
        url = f"{self.base_url}/pushes?{urllib.parse.urlencode(query)}"
        request = urllib.request.Request(
            url,
            headers={"Access-Token": self.access_token, "Accept": "application/json"},
            method="GET",
        )
        try:
            with self.opener(request, timeout=20) as response:
                status = int(response.status)
                raw = self._read_response(response)
                payload = loads_native(raw.decode("utf-8", "strict"))
        except PushbulletError:
            raise
        except (AttributeError, OSError, TypeError, urllib.error.URLError, json.JSONDecodeError, UnicodeDecodeError, RecursionError, ValueError) as exc:
            raise PushbulletError("unable to query Pushbullet") from exc
        if status < 200 or status >= 300 or not isinstance(payload, dict):
            raise PushbulletError("Pushbullet returned an invalid response")
        self._validate_json_shape(payload)
        pushes = payload.get("pushes", [])
        if not isinstance(pushes, list):
            raise PushbulletError("Pushbullet response has invalid pushes")
        next_cursor = payload.get("cursor")
        if next_cursor is not None:
            if not isinstance(next_cursor, str) or not next_cursor:
                raise PushbulletError("Pushbullet response has an invalid cursor")
            if len(next_cursor.encode("utf-8", "strict")) > self.max_cursor_bytes:
                raise PushbulletError("Pushbullet cursor is too long")
        return PushbulletPage(pushes, next_cursor)


class PushbulletPoller:
    cursor_key = "pushbullet.last_modified"
    max_pages = 100
    max_modified_bytes = 64
    max_modified_value = Decimal((1 << 63) - 1)

    def __init__(
        self,
        api: PushbulletApi,
        database: Database,
        service: VendingService,
        *,
        on_result: Callable[[MatchResult], None] | None = None,
    ):
        self.api = api
        self.database = database
        self.service = service
        self.on_result = on_result

    def _cursor(self) -> str:
        return self.database.get_setting(self.cursor_key) or "0"

    @staticmethod
    def _modified(push: Any) -> Decimal | None:
        if not isinstance(push, dict):
            return None
        value = push.get("modified")
        try:
            if isinstance(value, bool) or value is None:
                return None
            text = str(value)
            if len(text.encode("utf-8", "strict")) > PushbulletPoller.max_modified_bytes:
                return None
            parsed = Decimal(text)
            if not parsed.is_finite() or parsed.copy_abs() > PushbulletPoller.max_modified_value:
                return None
            if parsed.as_tuple().exponent < -6:
                return None
            return parsed
        except (InvalidOperation, TypeError, ValueError, UnicodeEncodeError, OverflowError):
            return None

    @classmethod
    def _cursor_decimal(cls, value: str | None) -> Decimal:
        if value is None:
            return Decimal(0)
        try:
            parsed = Decimal(value)
            if not parsed.is_finite() or parsed.copy_abs() > cls.max_modified_value:
                return Decimal(0)
            if parsed.as_tuple().exponent < -6:
                return Decimal(0)
            return parsed
        except (InvalidOperation, TypeError, ValueError, OverflowError):
            return Decimal(0)

    @classmethod
    def _format_cursor(cls, value: Decimal) -> str:
        formatted = format(value, "f")
        if len(formatted.encode("ascii", "strict")) > cls.max_modified_bytes:
            raise PushbulletError("Pushbullet modified cursor is too long")
        if "." in formatted:
            formatted = formatted.rstrip("0").rstrip(".")
        return formatted or "0"

    def _notify_result(self, result: MatchResult) -> None:
        if self.on_result is not None:
            try:
                self.on_result(result)
            except Exception:
                pass

    def poll_once(self, *, now: int | None = None) -> list[MatchResult]:
        cursor = self._cursor()
        cursor_decimal = self._cursor_decimal(cursor)
        request_cursor = self._format_cursor(cursor_decimal)
        results: list[MatchResult] = []
        seen: set[str] = set()
        next_cursor: Decimal | None = None
        page_cursor: str | None = None
        seen_page_cursors: set[str] = set()
        for _ in range(self.max_pages):
            page = self.api.list_pushes(cursor=page_cursor, modified_after=None if page_cursor else request_cursor)
            if not isinstance(page, PushbulletPage):
                page = PushbulletPage(list(page), None)
            if page.cursor and page.cursor in seen_page_cursors:
                raise PushbulletError("Pushbullet cursor did not advance")
            pushes = list(page.pushes)
            pushes.sort(key=lambda item: (self._modified(item) is None, self._modified(item) or Decimal(0)))
            for push in pushes:
                raw_push_id = push.get("iden") if isinstance(push, dict) else None
                push_id = raw_push_id if isinstance(raw_push_id, str) and raw_push_id.strip() else ""
                if push_id and push_id in seen:
                    continue
                if push_id:
                    seen.add(push_id)
                result = self.service.handle_push({"push": push, "type": "push"}, now=now)
                results.append(result)
                self._notify_result(result)
                modified = self._modified(push)
                if modified is not None and (next_cursor is None or modified > next_cursor):
                    next_cursor = modified
            if not page.cursor:
                break
            seen_page_cursors.add(page.cursor)
            page_cursor = page.cursor
        else:
            raise PushbulletError("Pushbullet pagination limit exceeded")
        if next_cursor is not None and next_cursor > cursor_decimal:
            self.database.set_setting(self.cursor_key, self._format_cursor(next_cursor))
        return results

    def handle_stream_event(self, event: dict[str, Any], *, now: int | None = None) -> list[MatchResult]:
        if not isinstance(event, dict):
            return []
        PushbulletApi._validate_json_shape(event)
        event_type = event.get("type")
        if event_type == "push":
            result = self.service.handle_push(event, now=now)
            self._notify_result(result)
            return [result]
        if event_type == "tickle" and event.get("subtype") == "push":
            return self.poll_once(now=now)
        return []


class PushbulletStreamClient:
    def __init__(
        self,
        access_token: str,
        poller: PushbulletPoller,
        *,
        stream_url: str = "wss://stream.pushbullet.com/websocket",
        websocket_factory: Callable[[str], WebSocketConnection] | None = None,
        fallback_interval: float = 30.0,
        reconnect_min_seconds: float = 1.0,
        reconnect_max_seconds: float = 60.0,
        on_error: Callable[[Exception], None] | None = None,
    ):
        if not access_token:
            raise ValueError("Pushbullet access token is required")
        if fallback_interval <= 0:
            raise ValueError("fallback interval must be positive")
        validate_runtime_endpoint(
            "PUSHBULLET_STREAM_URL",
            stream_url,
            exact=frozenset({"stream.pushbullet.com"}),
            suffixes=frozenset(),
            allowed_paths=frozenset({"/websocket"}),
            allowed_query_keys=frozenset(),
        )
        self.access_token = access_token
        self.poller = poller
        self.stream_url = stream_url.rstrip("/") + "/" + urllib.parse.quote(access_token, safe="")
        self.websocket_factory = websocket_factory or (
            lambda url: WebSocketConnection(url, max_message_bytes=PushbulletApi.max_response_bytes)
        )
        self.fallback_interval = fallback_interval
        self.reconnect_min_seconds = max(0.1, reconnect_min_seconds)
        self.reconnect_max_seconds = max(self.reconnect_min_seconds, reconnect_max_seconds)
        self.on_error = on_error
        self._stop = threading.Event()
        self._socket: WebSocketConnection | None = None

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
    def _decode_event(raw: str | bytes | dict[str, Any]) -> dict[str, Any]:
        if isinstance(raw, dict):
            PushbulletApi._validate_json_shape(raw)
            return raw
        if isinstance(raw, bytes):
            if len(raw) > PushbulletApi.max_response_bytes:
                raise PushbulletError("Pushbullet stream event is too large")
            try:
                raw = raw.decode("utf-8", "strict")
            except UnicodeDecodeError as exc:
                raise PushbulletError("Pushbullet stream event is not valid UTF-8") from exc
        elif isinstance(raw, str) and len(raw.encode("utf-8", "strict")) > PushbulletApi.max_response_bytes:
            raise PushbulletError("Pushbullet stream event is too large")
        try:
            event = loads_native(raw)
        except (ValueError, TypeError, UnicodeDecodeError, RecursionError) as exc:
            raise PushbulletError("Pushbullet stream event is invalid JSON") from exc
        if not isinstance(event, dict):
            raise PushbulletError("Pushbullet stream event is not an object")
        PushbulletApi._validate_json_shape(event)
        return event

    def _run_connection(self, websocket: WebSocketConnection, stop_event: threading.Event) -> None:
        self._socket = websocket
        websocket.connect()
        last_poll = time.monotonic()
        try:
            while not self._stop.is_set() and not stop_event.is_set():
                try:
                    raw = websocket.recv(timeout=1.0)
                except (socket.timeout, TimeoutError):
                    raw = None
                if raw is not None:
                    event = self._decode_event(raw)
                    self.poller.handle_stream_event(event)
                    if event.get("type") == "tickle" and event.get("subtype") == "push":
                        last_poll = time.monotonic()
                if time.monotonic() - last_poll >= self.fallback_interval:
                    self.poller.poll_once()
                    last_poll = time.monotonic()
        finally:
            if self._socket is websocket:
                self._socket = None
            websocket.close()

    def run_forever(self, stop_event: threading.Event | None = None) -> None:
        external_stop = stop_event or self._stop
        delay = self.reconnect_min_seconds
        last_fallback = 0.0
        while not external_stop.is_set() and not self._stop.is_set():
            websocket: WebSocketConnection | None = None
            try:
                websocket = self.websocket_factory(self.stream_url)
                self._run_connection(websocket, external_stop)
                delay = self.reconnect_min_seconds
            except (WebSocketClosed, WebSocketError, PushbulletError, OSError, socket.timeout) as exc:
                if not external_stop.is_set() and not self._stop.is_set():
                    self._notify_error(exc)
                    if time.monotonic() - last_fallback >= self.fallback_interval:
                        try:
                            self.poller.poll_once()
                        except Exception as polling_error:
                            self._notify_error(polling_error)
                        last_fallback = time.monotonic()
                    external_stop.wait(delay)
                    delay = min(self.reconnect_max_seconds, delay * 2)
            except Exception as exc:
                if not external_stop.is_set() and not self._stop.is_set():
                    self._notify_error(exc)
                    if time.monotonic() - last_fallback >= self.fallback_interval:
                        try:
                            self.poller.poll_once()
                        except Exception as polling_error:
                            self._notify_error(polling_error)
                        last_fallback = time.monotonic()
                    external_stop.wait(delay)
                    delay = min(self.reconnect_max_seconds, delay * 2)
            finally:
                if websocket is not None and self._socket is websocket:
                    self._socket = None
                    websocket.close()
