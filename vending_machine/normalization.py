from __future__ import annotations

import unicodedata

from .errors import ValidationError
from .native_core import NativeCoreError, load_native_core

MAX_INT64 = (1 << 63) - 1


def validate_utf8_text(value: str, *, field: str, max_bytes: int = 256) -> str:
    if not isinstance(value, str):
        raise ValidationError(f"{field} must be text")
    try:
        encoded = value.encode("utf-8", "strict")
    except UnicodeEncodeError as exc:
        raise ValidationError(f"{field} is not valid UTF-8") from exc
    if len(encoded) > max_bytes:
        raise ValidationError(f"{field} is too long")
    if any(unicodedata.category(character) == "Cc" for character in value):
        raise ValidationError(f"{field} contains a control character")
    if "\x00" in value:
        raise ValidationError(f"{field} contains a null byte")
    return value


def _ascii_lower(value: str) -> str:
    return "".join(chr(ord(character) + 32) if "A" <= character <= "Z" else character for character in value)


def normalize_depositor_name(value: str, *, case_insensitive_latin: bool = False) -> str:
    value = validate_utf8_text(value, field="depositor_name", max_bytes=256)
    normalized: str
    native_core = load_native_core()
    if native_core is None:
        normalized = " ".join(value.split())
    else:
        try:
            normalized = native_core.normalize_name(value.encode("utf-8", "strict")).decode("utf-8", "strict")
        except (NativeCoreError, UnicodeDecodeError) as exc:
            raise ValidationError("depositor_name is invalid") from exc
    if not normalized:
        raise ValidationError("depositor_name must not be empty")
    if case_insensitive_latin:
        normalized = _ascii_lower(normalized)
    return normalized


def parse_amount_input(value: str, *, minimum: int | None = None, maximum: int | None = None) -> int:
    if not isinstance(value, str) or not value:
        raise ValidationError("amount_krw must contain ASCII digits")
    compact = value.strip()
    if compact.endswith("원"):
        compact = compact[:-1].rstrip()
    compact = compact.replace(",", "").replace(" ", "")
    if not compact or any(character < "0" or character > "9" for character in compact):
        raise ValidationError("amount_krw must contain ASCII digits only")
    native_core = load_native_core()
    if native_core is None:
        try:
            amount = int(compact, 10)
        except ValueError as exc:
            raise ValidationError("amount_krw is invalid") from exc
    else:
        try:
            amount = native_core.parse_amount(compact.encode("ascii", "strict"))
        except (NativeCoreError, UnicodeEncodeError) as exc:
            raise ValidationError("amount_krw is outside the valid range") from exc
    if amount <= 0 or amount > MAX_INT64:
        raise ValidationError("amount_krw is outside the valid range")
    if minimum is not None and amount < minimum:
        raise ValidationError("amount_krw is below the configured minimum")
    if maximum is not None and amount > maximum:
        raise ValidationError("amount_krw is above the configured maximum")
    return amount


def parse_notification_amount(value: str) -> int:
    value = validate_utf8_text(value, field="amount", max_bytes=64)
    compact = value.replace(",", "").replace(" ", "")
    if not compact or any(character < "0" or character > "9" for character in compact):
        raise ValidationError("notification amount is invalid")
    return parse_amount_input(compact)
