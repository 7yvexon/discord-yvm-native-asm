from __future__ import annotations

from dataclasses import dataclass
from enum import StrEnum
from typing import Any


class OrderStatus(StrEnum):
    PENDING = "PENDING"
    PAID = "PAID"
    REVIEW = "REVIEW"
    EXPIRED = "EXPIRED"


class DmStatus(StrEnum):
    PENDING = "PENDING"
    SENT = "SENT"
    FAILED = "FAILED"


class ProcessingStatus(StrEnum):
    RECEIVED = "RECEIVED"
    CONSUMED = "CONSUMED"
    REVIEW = "REVIEW"
    DUPLICATE = "DUPLICATE"
    UNSUPPORTED = "UNSUPPORTED"
    PARSE_FAILED = "PARSE_FAILED"
    MATCH_NOT_FOUND = "MATCH_NOT_FOUND"
    MATCH_AMBIGUOUS = "MATCH_AMBIGUOUS"
    EXPIRED = "EXPIRED"


@dataclass(frozen=True, slots=True)
class Order:
    order_id: str
    discord_id: str
    depositor_name_input: str
    depositor_name_normalized: str
    requested_amount_krw: int
    status: OrderStatus
    created_at: int
    expires_at: int
    matched_push_id: str | None
    matched_amount_krw: int | None
    matched_at: int | None
    dm_status: DmStatus
    payment_dm_status: DmStatus = DmStatus.PENDING


@dataclass(frozen=True, slots=True)
class ParsedPush:
    push_id: str
    push_created_at: int | None
    push_modified_at: int | None
    package_name: str | None
    application_name: str | None
    title: str
    body_hash: str
    parsed_depositor_name: str | None
    parsed_depositor_name_normalized: str | None
    parsed_amount_krw: int | None
    source: dict[str, Any]


@dataclass(frozen=True, slots=True)
class PushParseResult:
    status: ProcessingStatus
    event: ParsedPush
    detail: str | None = None


@dataclass(frozen=True, slots=True)
class MatchResult:
    status: ProcessingStatus
    push_id: str
    order_id: str | None = None
    amount_krw: int | None = None
    detail: str | None = None
