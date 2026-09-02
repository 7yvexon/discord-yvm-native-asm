from __future__ import annotations

import os
from dataclasses import dataclass
from pathlib import Path
from typing import Mapping
from urllib.parse import parse_qsl, urlsplit

from .errors import SettingsError
from .normalization import MAX_INT64


_KNOWN_KEYS = {
    "DISCORD_BOT_TOKEN",
    "DISCORD_APPLICATION_ID",
    "DISCORD_GUILD_ID",
    "DISCORD_PANEL_CHANNEL_ID",
    "DISCORD_GUILD_TAG_LOG_CHANNEL_ID",
    "DISCORD_GUILD_TAG_STATUS_CHANNEL_ID",
    "DISCORD_GUILD_TAG_ROLE_ID",
    "DISCORD_ADMIN_USER_ID",
    "DISCORD_GATEWAY_URL",
    "DISCORD_INTENTS",
    "PUSHBULLET_ACCESS_TOKEN",
    "PUSHBULLET_STREAM_URL",
    "BANK_NAME",
    "BANK_ACCOUNT_NUMBER",
    "BANK_ACCOUNT_HOLDER",
    "BANK_PACKAGE_NAME",
    "BANK_APPLICATION_NAME",
    "BANK_TITLE_PREFIX",
    "BANK_TITLE_PATTERN",
    "BANK_AMOUNT_PATTERN",
    "BANK_NAME_PATTERN",
    "ORDER_TTL_SECONDS",
    "MIN_AMOUNT_KRW",
    "MAX_AMOUNT_KRW",
    "AUTO_CREDIT",
    "CASE_INSENSITIVE_LATIN",
    "DATABASE_PATH",
}

_DEFAULT_DISCORD_GATEWAY_URL = "wss://gateway.discord.gg/?v=10&encoding=json"
_DEFAULT_PUSHBULLET_STREAM_URL = "wss://stream.pushbullet.com/websocket"
_DEFAULT_BANK_AMOUNT_PATTERN = r"(?:입금액|입금금액|금액|amount)\s*[:：]?\s*([0-9][0-9,]*)"
_DEFAULT_BANK_NAME_PATTERN = r"(?:입금자|보낸분|보낸 사람|sender|name)\s*[:：]?\s*([^\r\n,()]{1,100})"
_SUPPORTED_BANK_TITLE_PATTERN = r"^[0-9][0-9,]*원\s*입금$"
_SUPPORTED_BANK_AMOUNT_PATTERNS = frozenset(
    {
        r"([0-9][0-9,]*)원\s*입금",
        _DEFAULT_BANK_AMOUNT_PATTERN,
    }
)
_SUPPORTED_BANK_NAME_PATTERNS = frozenset(
    {
        r"^([^\r\n→,()]{1,100}?)\s*→\s*내 토스뱅크 통장$",
        _DEFAULT_BANK_NAME_PATTERN,
    }
)


def _validate_pattern_contract(name: str, value: str, supported: frozenset[str], *, optional: bool = False) -> None:
    if optional and value == "":
        return
    if value not in supported:
        raise SettingsError(f"{name} is not supported by native runtime")


def _validate_websocket_url(name: str, value: str) -> None:
    if len(value.encode("utf-8", "strict")) > 2048:
        raise SettingsError(f"{name} is too long")
    try:
        parsed = urlsplit(value)
        hostname = parsed.hostname
        port = parsed.port
    except (TypeError, ValueError, UnicodeError) as exc:
        raise SettingsError(f"{name} is invalid") from exc
    if parsed.scheme not in {"ws", "wss"} or not hostname or parsed.username or parsed.password or parsed.fragment:
        raise SettingsError(f"{name} must use a host-only ws:// or wss:// URL")
    if port is not None and not 1 <= port <= 65535:
        raise SettingsError(f"{name} has an invalid port")


def _host_matches(host: str, *, exact: frozenset[str], suffixes: frozenset[str]) -> bool:
    host = host.lower().rstrip(".")
    return host in exact or any(host.endswith("." + suffix) for suffix in suffixes)


def validate_runtime_endpoint(
    name: str,
    value: str,
    *,
    exact: frozenset[str],
    suffixes: frozenset[str],
    allowed_paths: frozenset[str] | None = None,
    allowed_query_keys: frozenset[str] | None = None,
) -> None:
    _validate_websocket_url(name, value)
    parsed = urlsplit(value)
    if allowed_paths is not None and parsed.path not in allowed_paths:
        raise SettingsError(f"{name} must use an approved endpoint path")
    if allowed_query_keys is not None:
        try:
            query_items = parse_qsl(parsed.query, keep_blank_values=True, strict_parsing=True)
        except ValueError as exc:
            raise SettingsError(f"{name} has an invalid query") from exc
        query_names = [key for key, _ in query_items]
        if len(query_names) != len(set(query_names)) or any(key not in allowed_query_keys for key in query_names):
            raise SettingsError(f"{name} has an invalid query")
    if (
        parsed.scheme != "wss"
        or not parsed.hostname
        or parsed.username
        or parsed.password
        or parsed.fragment
        or (parsed.port is not None and parsed.port != 443)
        or not _host_matches(parsed.hostname, exact=exact, suffixes=suffixes)
    ):
        raise SettingsError(f"{name} must use an approved wss endpoint")


def _parse_bool(value: str, key: str) -> bool:
    if value in {"1", "true", "TRUE", "yes", "YES"}:
        return True
    if value in {"0", "false", "FALSE", "no", "NO"}:
        return False
    raise SettingsError(f"{key} must be 0 or 1")


def _parse_optional_int(value: str | None, key: str) -> int | None:
    if value is None or value == "":
        return None
    try:
        parsed = int(value, 10)
    except ValueError as exc:
        raise SettingsError(f"{key} must be an integer") from exc
    if parsed < 0:
        raise SettingsError(f"{key} must not be negative")
    return parsed


def read_key_value_file(path: str | Path) -> dict[str, str]:
    values: dict[str, str] = {}
    try:
        lines = Path(path).read_text(encoding="utf-8").splitlines()
    except OSError as exc:
        raise SettingsError(f"unable to read settings: {path}") from exc
    for line_number, raw_line in enumerate(lines, 1):
        line = raw_line.strip()
        if not line or line.startswith("#"):
            continue
        if "=" not in line:
            raise SettingsError(f"invalid settings line {line_number}")
        key, value = line.split("=", 1)
        key = key.strip()
        if key not in _KNOWN_KEYS:
            raise SettingsError(f"unknown setting: {key}")
        values[key] = value.strip()
    return values


@dataclass(frozen=True, slots=True)
class Settings:
    discord_bot_token: str = ""
    discord_application_id: str = ""
    discord_guild_id: str = ""
    discord_panel_channel_id: str = ""
    discord_guild_tag_log_channel_id: str = ""
    discord_guild_tag_status_channel_id: str = ""
    discord_guild_tag_role_id: str = ""
    discord_admin_user_id: str = ""
    discord_gateway_url: str = _DEFAULT_DISCORD_GATEWAY_URL
    discord_intents: int = 1
    pushbullet_access_token: str = ""
    pushbullet_stream_url: str = _DEFAULT_PUSHBULLET_STREAM_URL
    bank_name: str = ""
    bank_account_number: str = ""
    bank_account_holder: str = ""
    bank_package_name: str = ""
    bank_application_name: str = ""
    bank_title_prefix: str = ""
    bank_title_pattern: str = ""
    bank_amount_pattern: str = _DEFAULT_BANK_AMOUNT_PATTERN
    bank_name_pattern: str = _DEFAULT_BANK_NAME_PATTERN
    order_ttl_seconds: int = 1800
    min_amount_krw: int | None = None
    max_amount_krw: int | None = None
    auto_credit: bool = True
    case_insensitive_latin: bool = False
    database_path: str = "vending.db"

    def __post_init__(self) -> None:
        if not self.auto_credit:
            raise SettingsError("AUTO_CREDIT is always enabled")
        _validate_pattern_contract("BANK_TITLE_PATTERN", self.bank_title_pattern, frozenset({_SUPPORTED_BANK_TITLE_PATTERN}), optional=True)
        _validate_pattern_contract("BANK_AMOUNT_PATTERN", self.bank_amount_pattern, _SUPPORTED_BANK_AMOUNT_PATTERNS)
        _validate_pattern_contract("BANK_NAME_PATTERN", self.bank_name_pattern, _SUPPORTED_BANK_NAME_PATTERNS)
        _validate_websocket_url("DISCORD_GATEWAY_URL", self.discord_gateway_url)
        _validate_websocket_url("PUSHBULLET_STREAM_URL", self.pushbullet_stream_url)

    @classmethod
    def from_mapping(cls, values: Mapping[str, str]) -> "Settings":
        unknown = set(values) - _KNOWN_KEYS
        if unknown:
            raise SettingsError(f"unknown setting: {sorted(unknown)[0]}")
        try:
            settings = cls(
                discord_bot_token=values.get("DISCORD_BOT_TOKEN", ""),
                discord_application_id=values.get("DISCORD_APPLICATION_ID", ""),
                discord_guild_id=values.get("DISCORD_GUILD_ID", ""),
                discord_panel_channel_id=values.get("DISCORD_PANEL_CHANNEL_ID", ""),
                discord_guild_tag_log_channel_id=values.get("DISCORD_GUILD_TAG_LOG_CHANNEL_ID", ""),
                discord_guild_tag_status_channel_id=values.get("DISCORD_GUILD_TAG_STATUS_CHANNEL_ID", ""),
                discord_guild_tag_role_id=values.get("DISCORD_GUILD_TAG_ROLE_ID", ""),
                discord_admin_user_id=values.get("DISCORD_ADMIN_USER_ID", ""),
                discord_gateway_url=values.get("DISCORD_GATEWAY_URL", _DEFAULT_DISCORD_GATEWAY_URL),
                discord_intents=int(values.get("DISCORD_INTENTS", "1"), 10),
                pushbullet_access_token=values.get("PUSHBULLET_ACCESS_TOKEN", ""),
                pushbullet_stream_url=values.get("PUSHBULLET_STREAM_URL", _DEFAULT_PUSHBULLET_STREAM_URL),
                bank_name=values.get("BANK_NAME", ""),
                bank_account_number=values.get("BANK_ACCOUNT_NUMBER", ""),
                bank_account_holder=values.get("BANK_ACCOUNT_HOLDER", ""),
                bank_package_name=values.get("BANK_PACKAGE_NAME", ""),
                bank_application_name=values.get("BANK_APPLICATION_NAME", ""),
                bank_title_prefix=values.get("BANK_TITLE_PREFIX", ""),
                bank_title_pattern=values.get("BANK_TITLE_PATTERN", ""),
                bank_amount_pattern=values.get("BANK_AMOUNT_PATTERN", _DEFAULT_BANK_AMOUNT_PATTERN),
                bank_name_pattern=values.get("BANK_NAME_PATTERN", _DEFAULT_BANK_NAME_PATTERN),
                order_ttl_seconds=int(values.get("ORDER_TTL_SECONDS", "1800"), 10),
                min_amount_krw=_parse_optional_int(values.get("MIN_AMOUNT_KRW"), "MIN_AMOUNT_KRW"),
                max_amount_krw=_parse_optional_int(values.get("MAX_AMOUNT_KRW"), "MAX_AMOUNT_KRW"),
                auto_credit=_parse_bool(values.get("AUTO_CREDIT", "1"), "AUTO_CREDIT"),
                case_insensitive_latin=_parse_bool(values.get("CASE_INSENSITIVE_LATIN", "0"), "CASE_INSENSITIVE_LATIN"),
                database_path=values.get("DATABASE_PATH", "vending.db"),
            )
        except ValueError as exc:
            raise SettingsError("invalid numeric setting") from exc
        if settings.order_ttl_seconds <= 0:
            raise SettingsError("ORDER_TTL_SECONDS must be positive")
        if settings.discord_intents < 0:
            raise SettingsError("DISCORD_INTENTS must not be negative")
        _validate_websocket_url("DISCORD_GATEWAY_URL", settings.discord_gateway_url)
        _validate_websocket_url("PUSHBULLET_STREAM_URL", settings.pushbullet_stream_url)
        if settings.min_amount_krw is not None and settings.min_amount_krw <= 0:
            raise SettingsError("MIN_AMOUNT_KRW must be positive")
        if settings.max_amount_krw is not None and settings.max_amount_krw <= 0:
            raise SettingsError("MAX_AMOUNT_KRW must be positive")
        if settings.min_amount_krw is not None and settings.min_amount_krw > MAX_INT64:
            raise SettingsError("MIN_AMOUNT_KRW is outside the valid range")
        if settings.max_amount_krw is not None and settings.max_amount_krw > MAX_INT64:
            raise SettingsError("MAX_AMOUNT_KRW is outside the valid range")
        if settings.min_amount_krw and settings.max_amount_krw and settings.min_amount_krw > settings.max_amount_krw:
            raise SettingsError("MIN_AMOUNT_KRW must not exceed MAX_AMOUNT_KRW")
        if not settings.database_path:
            raise SettingsError("DATABASE_PATH must not be empty")
        if not settings.auto_credit:
            raise SettingsError("AUTO_CREDIT is always enabled")
        return settings

    def validate_runtime_endpoints(self) -> None:
        endpoints = (
            (
                "DISCORD_GATEWAY_URL",
                self.discord_gateway_url,
                frozenset({"gateway.discord.gg"}),
                frozenset({"discord.gg", "discord.com"}),
                frozenset({"", "/"}),
                frozenset({"v", "encoding"}),
            ),
            (
                "PUSHBULLET_STREAM_URL",
                self.pushbullet_stream_url,
                frozenset({"stream.pushbullet.com"}),
                frozenset(),
                frozenset({"/websocket"}),
                frozenset(),
            ),
        )
        for name, value, exact, suffixes, allowed_paths, allowed_query_keys in endpoints:
            validate_runtime_endpoint(
                name,
                value,
                exact=exact,
                suffixes=suffixes,
                allowed_paths=allowed_paths,
                allowed_query_keys=allowed_query_keys,
            )

    @classmethod
    def from_file(cls, path: str | Path, *, environ: Mapping[str, str] | None = None) -> "Settings":
        values = read_key_value_file(path)
        source = os.environ if environ is None else environ
        for key in _KNOWN_KEYS:
            if key in source:
                values[key] = source[key]
        return cls.from_mapping(values)
