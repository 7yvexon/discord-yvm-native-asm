from __future__ import annotations

import hashlib
import json
import math
import re
from dataclasses import dataclass
from decimal import Decimal, InvalidOperation
from typing import Any, Mapping

from .errors import ValidationError
from .models import ParsedPush, ProcessingStatus, PushParseResult
from .normalization import normalize_depositor_name, parse_notification_amount, validate_utf8_text


@dataclass(frozen=True, slots=True)
class PushParserConfig:
    package_name: str = ""
    application_name: str = ""
    title_prefix: str = ""
    title_pattern: str = ""
    amount_pattern: str = r"(?:입금액|입금금액|금액|amount)\s*[:：]?\s*([0-9][0-9,]*)"
    name_pattern: str = r"(?:입금자|보낸분|보낸 사람|sender|name)\s*[:：]?\s*([^\r\n,()]{1,100})"
    case_insensitive_latin: bool = False


class PushParser:
    max_fingerprint_depth = 4
    max_fingerprint_items = 64
    max_fingerprint_text_bytes = 1024
    fingerprint_ignored_fields = frozenset({"iden", "created", "modified", "active", "dismissed"})
    min_timestamp = -(1 << 63)
    max_timestamp = (1 << 63) - 1

    def __init__(self, config: PushParserConfig | None = None):
        self.config = config or PushParserConfig()
        try:
            self._amount_re = re.compile(self.config.amount_pattern, re.IGNORECASE)
            self._name_re = re.compile(self.config.name_pattern, re.IGNORECASE)
            self._title_re = re.compile(self.config.title_pattern, re.IGNORECASE) if self.config.title_pattern else None
        except re.error as exc:
            raise ValueError("invalid push parser pattern") from exc

    @staticmethod
    def from_settings(settings: Any) -> "PushParser":
        return PushParser(
            PushParserConfig(
                package_name=settings.bank_package_name,
                application_name=settings.bank_application_name,
                title_prefix=settings.bank_title_prefix,
                title_pattern=settings.bank_title_pattern,
                amount_pattern=settings.bank_amount_pattern,
                name_pattern=settings.bank_name_pattern,
                case_insensitive_latin=settings.case_insensitive_latin,
            )
        )

    @staticmethod
    def _as_mapping(value: Any) -> Mapping[str, Any] | None:
        return value if isinstance(value, Mapping) else None

    @staticmethod
    def _text(value: Any, *, field: str, max_bytes: int) -> str:
        if value is None:
            return ""
        return validate_utf8_text(value, field=field, max_bytes=max_bytes)

    @staticmethod
    def _body_text(value: Any) -> str:
        if value is None:
            return ""
        if not isinstance(value, str):
            raise ValidationError("body must be text")
        text = value
        try:
            encoded = text.encode("utf-8", "strict")
        except UnicodeEncodeError as exc:
            raise ValidationError("body is not valid UTF-8") from exc
        if len(encoded) > 16384:
            raise ValidationError("body is too long")
        if any(ord(character) == 0 or (ord(character) < 32 and character not in "\r\n\t") for character in text):
            raise ValidationError("body contains a control character")
        return text

    @staticmethod
    def _timestamp(value: Any) -> int | None:
        if value is None:
            return None
        try:
            if isinstance(value, bool):
                return None
            text = str(value)
            if len(text.encode("utf-8", "strict")) > 64:
                return None
            parsed = Decimal(text)
            if not parsed.is_finite() or parsed.as_tuple().exponent < -6:
                return None
            if parsed < PushParser.min_timestamp or parsed > PushParser.max_timestamp:
                return None
            result = int(parsed)
            return result
        except (TypeError, ValueError, InvalidOperation, UnicodeEncodeError, OverflowError):
            return None

    @staticmethod
    def _field_value(match: re.Match[str]) -> str:
        if match.lastindex:
            return match.group(1)
        return match.group(0)

    def _extract_name(self, texts: list[str]) -> tuple[str | None, str | None, str | None]:
        normalized: dict[str, str] = {}
        original: dict[str, str] = {}
        invalid = False
        match_count = 0
        for text in texts:
            for match in self._name_re.finditer(text):
                match_count += 1
                candidate = self._field_value(match).strip()
                try:
                    candidate_normalized = normalize_depositor_name(
                        candidate,
                        case_insensitive_latin=self.config.case_insensitive_latin,
                    )
                except ValidationError:
                    invalid = True
                    continue
                normalized[candidate_normalized] = candidate_normalized
                original.setdefault(candidate_normalized, candidate)
        if invalid:
            return None, None, "invalid depositor name"
        if len(normalized) == 0:
            return None, None, "depositor name was not found"
        if match_count != 1 or len(normalized) > 1:
            return None, None, "multiple depositor names were found"
        key = next(iter(normalized))
        return original[key], key, None

    def _extract_amount(self, texts: list[str]) -> tuple[int | None, str | None]:
        values: set[int] = set()
        invalid = False
        match_count = 0
        for text in texts:
            for match in self._amount_re.finditer(text):
                match_count += 1
                candidate = self._field_value(match)
                try:
                    values.add(parse_notification_amount(candidate))
                except ValidationError:
                    invalid = True
        if invalid:
            return None, "invalid amount"
        if len(values) == 0:
            return None, "amount was not found"
        if match_count != 1 or len(values) > 1:
            return None, "multiple amounts were found"
        return next(iter(values)), None

    @staticmethod
    def _is_direct_mirror(payload: Mapping[str, Any], push: Mapping[str, Any]) -> bool:
        return payload.get("type") == "push" and push.get("type") == "mirror"

    @classmethod
    def _fingerprint_value(cls, value: Any, *, depth: int = 0) -> Any:
        if depth > cls.max_fingerprint_depth:
            return "<depth>"
        if value is None or isinstance(value, (bool, int, float)):
            if isinstance(value, float) and not math.isfinite(value):
                return "<non-finite>"
            return value
        if isinstance(value, str):
            encoded = value.encode("utf-8", "replace")
            if len(encoded) <= cls.max_fingerprint_text_bytes:
                return value
            return {
                "length": len(encoded),
                "sha256": hashlib.sha256(encoded).hexdigest(),
            }
        if isinstance(value, Mapping):
            result: dict[str, Any] = {}
            overflow_items: list[bytes] = []
            canonical_items = [
                (
                    str(key),
                    item,
                    cls._fingerprint_value(item, depth=depth + 1),
                )
                for key, item in value.items()
            ]
            canonical_items.sort(
                key=lambda entry: (
                    entry[0],
                    json.dumps(entry[2], ensure_ascii=False, sort_keys=True, separators=(",", ":")),
                )
            )
            count = 0
            for key_text, _item, canonical_item in canonical_items:
                if count < cls.max_fingerprint_items:
                    result[key_text] = canonical_item
                else:
                    item_text = json.dumps(
                        canonical_item,
                        ensure_ascii=False,
                        sort_keys=True,
                        separators=(",", ":"),
                    )
                    overflow_items.append(
                        hashlib.sha256(
                            key_text.encode("utf-8", "replace")
                            + b"="
                            + item_text.encode("utf-8", "replace")
                        ).digest()
                    )
                count += 1
            if count > cls.max_fingerprint_items:
                overflow = hashlib.sha256()
                for item_digest in sorted(overflow_items):
                    overflow.update(item_digest)
                result["<items>"] = {"count": count, "sha256": overflow.hexdigest()}
            return result
        if isinstance(value, (list, tuple)):
            result = [cls._fingerprint_value(item, depth=depth + 1) for item in value[: cls.max_fingerprint_items]]
            if len(value) > cls.max_fingerprint_items:
                overflow = hashlib.sha256()
                for item in value[cls.max_fingerprint_items:]:
                    overflow.update(json.dumps(cls._fingerprint_value(item, depth=depth + 1), ensure_ascii=False, sort_keys=True, separators=(",", ":")).encode("utf-8", "replace"))
                    overflow.update(b"\0")
                result.append({"<items>": {"count": len(value), "sha256": overflow.hexdigest()}})
            return result
        return f"<{type(value).__name__}>"

    @classmethod
    def _fingerprint_id(cls, payload: Any, *, prefix: str) -> str:
        canonical = cls._fingerprint_value(payload)
        try:
            encoded = json.dumps(canonical, ensure_ascii=False, sort_keys=True, separators=(",", ":")).encode("utf-8", "strict")
        except (TypeError, UnicodeEncodeError, ValueError):
            encoded = repr(canonical).encode("utf-8", "replace")
        return prefix + hashlib.sha256(encoded).hexdigest()

    def parse(self, payload: Mapping[str, Any] | Any) -> PushParseResult:
        if not isinstance(payload, Mapping):
            event = ParsedPush(
                push_id=self._fingerprint_id(payload, prefix="invalid-"),
                push_created_at=None,
                push_modified_at=None,
                package_name=None,
                application_name=None,
                title="",
                body_hash=hashlib.sha256(b"").hexdigest(),
                parsed_depositor_name=None,
                parsed_depositor_name_normalized=None,
                parsed_amount_krw=None,
                source={"type": None, "subtype": None},
            )
            return PushParseResult(ProcessingStatus.PARSE_FAILED, event, "push payload must be an object")
        push = self._as_mapping(payload.get("push"))
        if payload.get("type") != "push" or push is None or push.get("type") != "mirror":
            event = ParsedPush(
                push_id=self._fingerprint_id(payload, prefix="invalid-"),
                push_created_at=None,
                push_modified_at=None,
                package_name=None,
                application_name=None,
                title="",
                body_hash=hashlib.sha256(b"").hexdigest(),
                parsed_depositor_name=None,
                parsed_depositor_name_normalized=None,
                parsed_amount_krw=None,
                source={"type": payload.get("type"), "subtype": payload.get("subtype")},
            )
            return PushParseResult(ProcessingStatus.PARSE_FAILED, event, "push envelope is not a mirror event")
        direct_mirror = self._is_direct_mirror(payload, push)
        invalid_id = False
        try:
            push_id = self._text(push.get("iden"), field="push_id", max_bytes=256)
        except ValidationError:
            push_id = ""
            invalid_id = True
        if push_id and not push_id.strip():
            push_id = ""
            invalid_id = True
        missing_id = not push_id
        if missing_id:
            if direct_mirror:
                fingerprint_source = {
                    key: value
                    for key, value in push.items()
                    if key not in self.fingerprint_ignored_fields
                }
            else:
                fingerprint_source = payload
            push_id = self._fingerprint_id(fingerprint_source, prefix="mirror-" if direct_mirror and not invalid_id else "invalid-")
        created_present = push.get("created") is not None
        modified_present = push.get("modified") is not None
        push_created_at = self._timestamp(push.get("created"))
        push_modified_at = self._timestamp(push.get("modified"))
        timestamp_invalid = (created_present and push_created_at is None) or (modified_present and push_modified_at is None)
        try:
            package_name = self._text(push.get("package_name"), field="package_name", max_bytes=256) or None
            application_name = self._text(push.get("application_name"), field="application_name", max_bytes=256) or None
            title = self._text(push.get("title"), field="title", max_bytes=1024)
            body = self._body_text(push.get("body"))
        except ValidationError as exc:
            event = ParsedPush(
                push_id=push_id,
                push_created_at=push_created_at,
                push_modified_at=push_modified_at,
                package_name=None,
                application_name=None,
                title="",
                body_hash=hashlib.sha256(b"").hexdigest(),
                parsed_depositor_name=None,
                parsed_depositor_name_normalized=None,
                parsed_amount_krw=None,
                source={"type": payload.get("type"), "subtype": payload.get("subtype")},
            )
            return PushParseResult(ProcessingStatus.PARSE_FAILED, event, str(exc))
        event_base = dict(
            push_id=push_id,
            push_created_at=push_created_at,
            push_modified_at=push_modified_at,
            package_name=package_name,
            application_name=application_name,
            title=title,
            body_hash=hashlib.sha256(body.encode("utf-8", "strict")).hexdigest(),
            parsed_depositor_name=None,
            parsed_depositor_name_normalized=None,
            parsed_amount_krw=None,
            source={
                "type": payload.get("type"),
                "subtype": payload.get("subtype"),
                "push_type": push.get("type"),
                "id_source": "fingerprint" if missing_id else "push_id",
            },
        )
        event = ParsedPush(**event_base)
        if invalid_id:
            return PushParseResult(ProcessingStatus.PARSE_FAILED, event, "push id is missing")
        if timestamp_invalid:
            return PushParseResult(ProcessingStatus.PARSE_FAILED, event, "push timestamp is invalid")
        if self.config.package_name and package_name != self.config.package_name:
            return PushParseResult(ProcessingStatus.UNSUPPORTED, event, "package name is not allowed")
        if self.config.application_name and application_name != self.config.application_name:
            return PushParseResult(ProcessingStatus.UNSUPPORTED, event, "application name is not allowed")
        if self.config.title_prefix and not title.startswith(self.config.title_prefix):
            return PushParseResult(ProcessingStatus.UNSUPPORTED, event, "title is not allowed")
        if self._title_re is not None and self._title_re.search(title) is None:
            return PushParseResult(ProcessingStatus.UNSUPPORTED, event, "title is not allowed")
        texts = [body, title]
        parsed_name, normalized_name, name_error = self._extract_name(texts)
        parsed_amount, amount_error = self._extract_amount(texts)
        if name_error or amount_error:
            detail = "; ".join(value for value in (name_error, amount_error) if value)
            return PushParseResult(ProcessingStatus.PARSE_FAILED, event, detail)
        event = ParsedPush(
            **{
                **event_base,
                "parsed_depositor_name": parsed_name,
                "parsed_depositor_name_normalized": normalized_name,
                "parsed_amount_krw": parsed_amount,
            }
        )
        if missing_id:
            if direct_mirror:
                return PushParseResult(ProcessingStatus.RECEIVED, event)
            return PushParseResult(ProcessingStatus.PARSE_FAILED, event, "push id is missing")
        return PushParseResult(ProcessingStatus.RECEIVED, event)
