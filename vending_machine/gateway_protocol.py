from __future__ import annotations

from dataclasses import dataclass
import platform
from enum import IntEnum
from typing import Any


class GatewayOpcode(IntEnum):
    DISPATCH = 0
    HEARTBEAT = 1
    IDENTIFY = 2
    RESUME = 6
    RECONNECT = 7
    INVALID_SESSION = 9
    HELLO = 10
    HEARTBEAT_ACK = 11


@dataclass(slots=True)
class GatewaySession:
    token: str
    intents: int
    os_name: str | None = None
    heartbeat_interval_ms: int | None = None
    sequence: int | None = None
    session_id: str | None = None
    resume_gateway_url: str | None = None

    def restore(self, *, sequence: int | None, session_id: str | None, resume_gateway_url: str | None) -> None:
        self.sequence = sequence
        self.session_id = session_id
        self.resume_gateway_url = resume_gateway_url

    def clear_session(self) -> None:
        self.sequence = None
        self.session_id = None
        self.resume_gateway_url = None

    @property
    def resumable(self) -> bool:
        return bool(self.session_id) and self.sequence is not None

    def handle_hello(self, payload: dict[str, Any]) -> dict[str, Any]:
        data = payload.get("d")
        if not isinstance(data, dict) or not isinstance(data.get("heartbeat_interval"), (int, float)):
            raise ValueError("invalid Discord hello payload")
        self.heartbeat_interval_ms = int(data["heartbeat_interval"])
        return self.resume_payload()

    def identify_payload(self) -> dict[str, Any]:
        return {
            "op": GatewayOpcode.IDENTIFY.value,
            "d": {
                "token": self.token,
                "intents": self.intents,
                "properties": {"os": self.os_name or platform.system().lower(), "browser": "yul-vending-machine", "device": "yul-vending-machine"},
            },
        }

    def resume_payload(self) -> dict[str, Any]:
        if not self.session_id or self.sequence is None:
            return self.identify_payload()
        return {
            "op": GatewayOpcode.RESUME.value,
            "d": {"token": self.token, "session_id": self.session_id, "seq": self.sequence},
        }

    def heartbeat_payload(self) -> dict[str, Any]:
        return {"op": GatewayOpcode.HEARTBEAT.value, "d": self.sequence}

    def handle_dispatch(self, payload: dict[str, Any]) -> str | None:
        sequence = payload.get("s")
        if sequence is not None:
            try:
                self.sequence = int(sequence)
            except (TypeError, ValueError) as exc:
                raise ValueError("invalid Discord sequence") from exc
        event_name = payload.get("t")
        data = payload.get("d")
        if event_name == "READY" and isinstance(data, dict):
            self.session_id = str(data.get("session_id")) if data.get("session_id") else None
            resume_url = data.get("resume_gateway_url")
            self.resume_gateway_url = str(resume_url) if resume_url else None
        return event_name if isinstance(event_name, str) else None

    def handle_invalid_session(self, resumable: bool) -> dict[str, Any]:
        if not resumable:
            self.clear_session()
        return self.resume_payload() if resumable else self.identify_payload()
