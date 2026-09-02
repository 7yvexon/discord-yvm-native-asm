from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime, timezone

from .config import Settings
from .database import Database
from .errors import SettingsError, ValidationError
from .models import MatchResult, Order
from .push_parser import PushParser


@dataclass(frozen=True, slots=True)
class OrderReceipt:
    order: Order
    bank_name: str
    account_number: str
    account_holder: str

    def message(self) -> str:
        expires = datetime.fromtimestamp(self.order.expires_at, tz=timezone.utc).astimezone().strftime("%Y-%m-%d %H:%M:%S %Z")
        return "\n".join(
            (
                f"은행: {self.bank_name}",
                f"계좌번호: {self.account_number}",
                f"예금주: {self.account_holder}",
                f"입금 금액: {self.order.requested_amount_krw:,}원",
                f"입금자명: {self.order.depositor_name_input}",
                f"만료 시각: {expires}",
                "입금자명과 금액이 모두 일치해야 자동 확인됩니다.",
            )
        )

    def payment_message(self, cumulative_total: int) -> str:
        return "\n".join(
            (
                "입금 확인 완료",
                f"반영 금액: {self.order.requested_amount_krw:,}원",
                f"누적 후원 금액: {cumulative_total:,}원",
            )
        )


class VendingService:
    def __init__(self, database: Database, settings: Settings):
        self.database = database
        self.settings = settings
        self.push_parser = PushParser.from_settings(settings)

    def create_order(
        self,
        discord_id: str,
        depositor_name: str,
        amount_krw: int | str,
        *,
        interaction_id: str | None = None,
        now: int | None = None,
    ) -> OrderReceipt:
        order = self.database.create_order(
            discord_id,
            depositor_name,
            amount_krw,
            interaction_id=interaction_id,
            ttl_seconds=self.settings.order_ttl_seconds,
            minimum=self.settings.min_amount_krw,
            maximum=self.settings.max_amount_krw,
            now=now,
        )
        return OrderReceipt(
            order=order,
            bank_name=self.settings.bank_name,
            account_number=self.settings.bank_account_number,
            account_holder=self.settings.bank_account_holder,
        )

    def handle_push(self, payload: dict, *, now: int | None = None) -> MatchResult:
        if not (
            self.settings.bank_package_name
            and self.settings.bank_application_name
            and (self.settings.bank_title_prefix or self.settings.bank_title_pattern)
        ):
            raise SettingsError("automatic credit requires bank source filters")
        result = self.push_parser.parse(payload)
        return self.database.process_push(
            result.event,
            preliminary_status=result.status,
            now=now,
        )

    def support_total(self, discord_id: str) -> int:
        return self.database.get_support_total(discord_id)

    def list_review_events(self, *, actor_id: str | None = None, limit: int = 100):
        if not self.validate_admin_id(actor_id or ""):
            raise ValidationError("administrator permission is required")
        return self.database.list_review_events(limit=limit)

    def ledger_rows(self, *, actor_id: str | None = None, discord_id: str | None = None, limit: int = 100):
        if not self.validate_admin_id(actor_id or ""):
            raise ValidationError("administrator permission is required")
        return self.database.ledger_rows(discord_id=discord_id, limit=limit)

    def panel_text(self) -> str:
        return "\n".join(
            (
                "입금 후원 패널",
                f"입금자명은 신청할 때 입력한 값과 같아야 합니다.",
                "입금 알림 반영까지 시간이 걸릴 수 있습니다.",
                "같은 이름과 금액의 주문이 여러 개면 자동 매칭하지 않습니다.",
            )
        )

    def validate_admin_id(self, discord_id: str) -> bool:
        return bool(self.settings.discord_admin_user_id) and discord_id == self.settings.discord_admin_user_id
