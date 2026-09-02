from __future__ import annotations

import json
import time
import urllib.error
import urllib.parse
import urllib.request
from dataclasses import dataclass
from typing import Any, Callable

from .json_utils import loads_native


class DiscordHttpError(Exception):
    def __init__(self, message: str, *, status: int | None = None):
        super().__init__(message)
        self.status = status


@dataclass(frozen=True, slots=True)
class DiscordResponse:
    status: int
    payload: Any


class DiscordRestClient:
    def __init__(self, bot_token: str, application_id: str, *, opener: Callable[..., Any] | None = None, api_base: str = "https://discord.com/api/v10"):
        if not bot_token or not application_id:
            raise ValueError("Discord credentials are required")
        self.bot_token = bot_token
        self.application_id = application_id
        self.opener = opener or urllib.request.urlopen
        self.api_base = api_base.rstrip("/")

    def _request(self, method: str, path: str, payload: Any = None) -> DiscordResponse:
        body = None if payload is None else json.dumps(payload, ensure_ascii=False, separators=(",", ":")).encode("utf-8")
        headers = {
            "Authorization": f"Bot {self.bot_token}",
            "Accept": "application/json",
            "User-Agent": "yul-vending-machine/1",
        }
        if body is not None:
            headers["Content-Type"] = "application/json"
        for attempt in range(3):
            request = urllib.request.Request(
                f"{self.api_base}/{path.lstrip('/')}",
                data=body,
                headers=headers,
                method=method,
            )
            try:
                with self.opener(request, timeout=20) as response:
                    raw = response.read()
                    status = int(response.status)
                    retry_after_header = getattr(getattr(response, "headers", None), "get", lambda *_: None)("Retry-After")
            except (OSError, urllib.error.URLError) as exc:
                raise DiscordHttpError("unable to contact Discord") from exc
            if not raw:
                result: Any = None
            else:
                try:
                    result = loads_native(raw.decode("utf-8"))
                except (UnicodeDecodeError, json.JSONDecodeError) as exc:
                    raise DiscordHttpError("Discord returned invalid JSON") from exc
            if status == 429 and method in {"GET", "PUT", "PATCH", "DELETE"} and attempt < 2:
                retry_after = retry_after_header
                if isinstance(result, dict):
                    retry_after = result.get("retry_after", retry_after)
                try:
                    delay = min(5.0, max(0.0, float(retry_after)))
                except (TypeError, ValueError):
                    delay = 1.0
                time.sleep(delay)
                continue
            if status < 200 or status >= 300:
                raise DiscordHttpError(f"Discord request failed with status {status}", status=status)
            return DiscordResponse(status, result)
        raise DiscordHttpError("Discord request rate limit was not cleared")

    @staticmethod
    def panel_components() -> list[dict[str, Any]]:
        return [
            {
                "type": 1,
                "components": [
                    {
                        "type": 2,
                        "style": 1,
                        "label": "입금 신청",
                        "custom_id": "vending:deposit:v1",
                        "emoji": {"name": "💳"},
                    }
                ],
            }
        ]

    @staticmethod
    def application_commands() -> list[dict[str, Any]]:
        return [
            {
                "name": "후원금액",
                "description": "내 누적 후원 금액을 확인합니다.",
                "type": 1,
            },
            {
                "name": "입금패널",
                "description": "입금 패널을 게시합니다.",
                "type": 1,
            },
            {
                "name": "검토목록",
                "description": "자동 처리되지 않은 입금 알림을 조회합니다.",
                "type": 1,
            },
            {
                "name": "지급원장",
                "description": "지급 원장을 조회합니다.",
                "type": 1,
            },
        ]

    def upsert_guild_commands(self, guild_id: str) -> DiscordResponse:
        path = f"applications/{urllib.parse.quote(self.application_id, safe='')}/guilds/{urllib.parse.quote(guild_id, safe='')}/commands"
        return self._request("PUT", path, self.application_commands())

    def publish_panel(
        self,
        channel_id: str,
        content: str | None = None,
        *,
        embeds: list[dict[str, Any]] | None = None,
    ) -> DiscordResponse:
        path = f"channels/{urllib.parse.quote(channel_id, safe='')}/messages"
        payload: dict[str, Any] = {"components": self.panel_components()}
        if content:
            payload["content"] = content
        if embeds:
            payload["embeds"] = embeds
        return self._request("POST", path, payload)

    def send_channel_message(
        self,
        channel_id: str,
        content: str | None = None,
        *,
        embeds: list[dict[str, Any]] | None = None,
        allowed_mentions: dict[str, Any] | None = None,
    ) -> DiscordResponse:
        path = f"channels/{urllib.parse.quote(channel_id, safe='')}/messages"
        payload: dict[str, Any] = {}
        if content:
            payload["content"] = content
        if embeds:
            payload["embeds"] = embeds
        if allowed_mentions is not None:
            payload["allowed_mentions"] = allowed_mentions
        if not payload:
            raise DiscordHttpError("Discord message must contain content or embeds")
        return self._request("POST", path, payload)

    def edit_channel_message(
        self,
        channel_id: str,
        message_id: str,
        content: str | None = None,
        *,
        embeds: list[dict[str, Any]] | None = None,
        allowed_mentions: dict[str, Any] | None = None,
    ) -> DiscordResponse:
        path = (
            f"channels/{urllib.parse.quote(channel_id, safe='')}/messages/"
            f"{urllib.parse.quote(message_id, safe='')}"
        )
        payload: dict[str, Any] = {}
        if content is not None:
            payload["content"] = content
        if embeds is not None:
            payload["embeds"] = embeds
        if allowed_mentions is not None:
            payload["allowed_mentions"] = allowed_mentions
        if not payload:
            raise DiscordHttpError("Discord message edit must contain content or embeds")
        return self._request("PATCH", path, payload)

    def list_guild_members(self, guild_id: str, *, limit: int = 1000, after: str | None = None) -> list[dict[str, Any]]:
        if limit <= 0 or limit > 1000:
            raise ValueError("guild member limit must be between 1 and 1000")
        query = urllib.parse.urlencode({"limit": str(limit), **({"after": after} if after else {})})
        path = f"guilds/{urllib.parse.quote(guild_id, safe='')}/members?{query}"
        payload = self._request("GET", path).payload
        if not isinstance(payload, list) or any(not isinstance(member, dict) for member in payload):
            raise DiscordHttpError("Discord returned an invalid guild member list")
        return payload

    def add_guild_member_role(self, guild_id: str, user_id: str, role_id: str) -> DiscordResponse:
        path = (
            f"guilds/{urllib.parse.quote(guild_id, safe='')}/members/"
            f"{urllib.parse.quote(user_id, safe='')}/roles/{urllib.parse.quote(role_id, safe='')}"
        )
        return self._request("PUT", path)

    def remove_guild_member_role(self, guild_id: str, user_id: str, role_id: str) -> DiscordResponse:
        path = (
            f"guilds/{urllib.parse.quote(guild_id, safe='')}/members/"
            f"{urllib.parse.quote(user_id, safe='')}/roles/{urllib.parse.quote(role_id, safe='')}"
        )
        return self._request("DELETE", path)

    def create_dm_channel(self, user_id: str) -> DiscordResponse:
        return self._request("POST", "users/@me/channels", {"recipient_id": user_id})

    def send_dm(
        self,
        user_id: str,
        content: str | None = None,
        *,
        embeds: list[dict[str, Any]] | None = None,
    ) -> DiscordResponse:
        channel = self.create_dm_channel(user_id).payload
        if not isinstance(channel, dict) or not channel.get("id"):
            raise DiscordHttpError("Discord did not return a DM channel")
        channel_id = urllib.parse.quote(str(channel["id"]), safe="")
        payload: dict[str, Any] = {}
        if content:
            payload["content"] = content
        if embeds:
            payload["embeds"] = embeds
        if not payload:
            raise DiscordHttpError("Discord message must contain content or embeds")
        return self._request("POST", f"channels/{channel_id}/messages", payload)

    def respond_to_interaction(self, interaction_id: str, interaction_token: str, payload: dict[str, Any]) -> DiscordResponse:
        path = f"interactions/{urllib.parse.quote(interaction_id, safe='')}/{urllib.parse.quote(interaction_token, safe='')}/callback"
        return self._request("POST", path, payload)

    def defer_interaction(self, interaction_id: str, interaction_token: str, *, ephemeral: bool = True) -> DiscordResponse:
        data: dict[str, Any] = {}
        if ephemeral:
            data["flags"] = 64
        return self.respond_to_interaction(interaction_id, interaction_token, {"type": 5, "data": data})

    def edit_original_response(self, interaction_token: str, payload: dict[str, Any]) -> DiscordResponse:
        path = f"webhooks/{urllib.parse.quote(self.application_id, safe='')}/{urllib.parse.quote(interaction_token, safe='')}/messages/@original"
        return self._request("PATCH", path, payload)
