from __future__ import annotations

import json
from typing import Any


def _first_object_pairs(pairs: list[tuple[str, Any]]) -> dict[str, Any]:
    result: dict[str, Any] = {}
    for key, value in pairs:
        if key not in result:
            result[key] = value
    return result


def _reject_nonstandard_number(value: str) -> Any:
    raise ValueError(f"non-standard JSON number: {value}")


def loads_native(value: str | bytes | bytearray) -> Any:
    return json.loads(
        value,
        object_pairs_hook=_first_object_pairs,
        parse_constant=_reject_nonstandard_number,
    )
