from __future__ import annotations

import json
from dataclasses import dataclass
from typing import Any

from .discord_messages import (
    COLOR_ERROR,
    COLOR_NEUTRAL,
    COLOR_SUCCESS,
    COLOR_WARNING,
    ledger_message,
    order_message,
    payment_message,
    review_list_message,
    status_embed,
    support_total_message,
    guild_tag_log_message,
    guild_tag_status_embed,
)
from .errors import ValidationError
from .discord_rest import DiscordHttpError, DiscordRestClient
from .models import DmStatus, MatchResult, ProcessingStatus
from .panel import PanelManager
from .service import OrderReceipt, VendingService


DEPOSIT_BUTTON_ID = "vending:deposit:v1"
DEPOSIT_MODAL_ID = "vending:deposit:modal:v1"


@dataclass(frozen=True, slots=True)
class InteractionResult:
    response: dict[str, Any]
    dm_content: str | None = None
    order_receipt: OrderReceipt | None = None
    payment_result: MatchResult | None = None
    dm_embeds: list[dict[str, Any]] | None = None


class DiscordInteractionRouter:
    def __init__(self, service: VendingService):
        self.service = service

    @staticmethod
    def _user_id(interaction: dict[str, Any]) -> str:
        member = interaction.get("member")
        if isinstance(member, dict) and isinstance(member.get("user"), dict):
            value = member["user"].get("id")
            if value:
                return str(value)
        user = interaction.get("user")
        if isinstance(user, dict) and user.get("id"):
            return str(user["id"])
        raise ValidationError("interaction user is missing")

    @staticmethod
    def modal_response() -> dict[str, Any]:
        return {
            "type": 9,
            "data": {
                "custom_id": DEPOSIT_MODAL_ID,
                "title": "💳 입금 신청",
                "components": [
                    {
                        "type": 1,
                        "components": [
                            {
                                "type": 4,
                                "custom_id": "depositor_name",
                                "label": "입금자명",
                                "style": 1,
                                "required": True,
                                "max_length": 100,
                                "placeholder": "실제 입금자명을 입력해 주세요",
                            }
                        ],
                    },
                    {
                        "type": 1,
                        "components": [
                            {
                                "type": 4,
                                "custom_id": "amount_krw",
                                "label": "입금 금액(원)",
                                "style": 1,
                                "required": True,
                                "max_length": 19,
                                "placeholder": "예: 10000",
                            }
                        ],
                    },
                ],
            },
        }

    @staticmethod
    def _modal_values(data: dict[str, Any]) -> dict[str, str]:
        values: dict[str, str] = {}
        for row in data.get("components", []):
            if not isinstance(row, dict):
                continue
            for component in row.get("components", []):
                if not isinstance(component, dict):
                    continue
                custom_id = component.get("custom_id")
                value = component.get("value")
                if isinstance(custom_id, str) and isinstance(value, str):
                    values[custom_id] = value
        return values

    @staticmethod
    def _ephemeral_payload(content: str, *, embed: dict[str, Any] | None = None) -> dict[str, Any]:
        data: dict[str, Any] = {"content": content, "flags": 64}
        if embed is not None:
            data["embeds"] = [embed]
        return {"type": 4, "data": data}

    @classmethod
    def _ephemeral(
        cls,
        content: str,
        *,
        embed: dict[str, Any] | None = None,
        title: str = "🔔 알림",
        description: str | None = None,
        color: int = COLOR_NEUTRAL,
    ) -> InteractionResult:
        if embed is None:
            embed = status_embed(title, description or content, color=color)
        return InteractionResult(cls._ephemeral_payload(content, embed=embed))

    def handle(
        self,
        interaction: dict[str, Any],
        *,
        interaction_id: str | None = None,
        now: int | None = None,
    ) -> InteractionResult:
        interaction_type = interaction.get("type")
        data = interaction.get("data")
        if not isinstance(data, dict):
            return self._ephemeral(
                "⚠️ **요청 형식이 올바르지 않습니다.**",
                title="⚠️ 요청 형식 오류",
                color=COLOR_ERROR,
            )
        if interaction_type == 2 and data.get("name") in {"후원금액", "support-total"}:
            try:
                user_id = self._user_id(interaction)
                total = self.service.support_total(user_id)
            except ValidationError:
                return self._ephemeral(
                    "⚠️ **사용자 정보를 확인할 수 없습니다.**",
                    title="⚠️ 사용자 정보 확인 실패",
                    color=COLOR_ERROR,
                )
            content, embed = support_total_message(total)
            return self._ephemeral(content, embed=embed)
        if interaction_type == 2 and data.get("name") in {"검토목록", "review-list"}:
            try:
                actor_id = self._user_id(interaction)
                rows = self.service.list_review_events(actor_id=actor_id, limit=25)
                if not rows:
                    return self._ephemeral(
                        "📭 **검토 대기 입금이 없습니다.**",
                        title="📭 검토 대기 없음",
                        description="현재 자동 확인을 기다리는 입금 알림이 없습니다.",
                    )
                content, embed = review_list_message(rows)
                return self._ephemeral(content, embed=embed)
            except ValidationError:
                return self._ephemeral(
                    "⛔ **관리자 권한을 확인해 주세요.**",
                    title="⛔ 권한이 필요합니다",
                    color=COLOR_ERROR,
                )
            except Exception:
                return self._ephemeral(
                    "⚠️ **검토 목록을 조회하지 못했습니다.**",
                    title="⚠️ 검토 목록 조회 실패",
                    color=COLOR_ERROR,
                )
        if interaction_type == 2 and data.get("name") in {"지급원장", "ledger"}:
            try:
                actor_id = self._user_id(interaction)
                rows = self.service.ledger_rows(actor_id=actor_id, limit=25)
                if not rows:
                    return self._ephemeral(
                        "📭 **지급 원장이 없습니다.**",
                        title="📭 지급 원장 없음",
                        description="아직 반영된 지급 내역이 없습니다.",
                    )
                content, embed = ledger_message(rows)
                return self._ephemeral(content, embed=embed)
            except ValidationError:
                return self._ephemeral(
                    "⛔ **관리자 권한을 확인해 주세요.**",
                    title="⛔ 권한이 필요합니다",
                    color=COLOR_ERROR,
                )
            except Exception:
                return self._ephemeral(
                    "⚠️ **지급 원장을 조회하지 못했습니다.**",
                    title="⚠️ 지급 원장 조회 실패",
                    color=COLOR_ERROR,
                )
        if interaction_type == 3 and data.get("custom_id") == DEPOSIT_BUTTON_ID:
            return InteractionResult(self.modal_response())
        if interaction_type != 5 or data.get("custom_id") != DEPOSIT_MODAL_ID:
            return self._ephemeral(
                "⚠️ **지원하지 않는 요청입니다.**",
                title="⚠️ 지원하지 않는 요청",
                color=COLOR_WARNING,
            )
        try:
            values = self._modal_values(data)
            user_id = self._user_id(interaction)
            receipt = self.service.create_order(
                user_id,
                values.get("depositor_name", ""),
                values.get("amount_krw", ""),
                interaction_id=interaction_id,
                now=now,
            )
        except ValidationError:
            return self._ephemeral(
                "⚠️ **입금자명 또는 금액을 확인해 주세요.**",
                title="⚠️ 입력값을 확인해 주세요",
                color=COLOR_WARNING,
            )
        except Exception:
            return self._ephemeral(
                "⚠️ **입금 신청을 처리하지 못했습니다.**",
                title="⚠️ 입금 신청 실패",
                color=COLOR_ERROR,
            )
        content, embed = order_message(receipt)
        return InteractionResult(
            self._ephemeral_payload(content, embed=embed),
            dm_content=content,
            dm_embeds=[embed],
            order_receipt=receipt,
        )


class DiscordInteractionProcessor:
    def __init__(
        self,
        router: DiscordInteractionRouter,
        discord: DiscordRestClient,
        panel_manager: PanelManager | None = None,
        *,
        application_id: str = "",
        guild_id: str = "",
        panel_channel_id: str = "",
        guild_tag_log_channel_id: str = "",
        guild_tag_status_channel_id: str = "",
        guild_tag_role_id: str = "",
    ):
        self.router = router
        self.discord = discord
        self.panel_manager = panel_manager
        self.application_id = str(application_id or "")
        self.guild_id = str(guild_id or "")
        self.panel_channel_id = str(panel_channel_id or "")
        self.guild_tag_log_channel_id = str(guild_tag_log_channel_id or "")
        self.guild_tag_status_channel_id = guild_tag_status_channel_id
        self.guild_tag_role_id = str(guild_tag_role_id or "")
        self._guild_tag_states: dict[str, bool] = {}
        self._guild_tag_members: dict[str, str] = {}
        self._guild_tag_status_dirty = False
        self._restore_guild_tag_status()

    def _restore_guild_tag_status(self) -> None:
        database = self.router.service.database
        stored_channel_id = database.get_setting("discord.guild_tag_status_channel_id")
        if stored_channel_id and stored_channel_id != self.guild_tag_status_channel_id:
            return
        raw_members = database.get_setting("discord.guild_tag_status_members")
        if raw_members:
            try:
                members = json.loads(raw_members)
            except (TypeError, ValueError):
                members = None
            if isinstance(members, dict):
                self._guild_tag_members = {
                    str(user_id): str(display_name)
                    for user_id, display_name in members.items()
                    if str(user_id) and str(display_name)
                }
                self._guild_tag_states = {user_id: True for user_id in self._guild_tag_members}

    def _persist_guild_tag_status(self) -> None:
        database = self.router.service.database
        try:
            database.set_setting(
                "discord.guild_tag_status_members",
                json.dumps(self._guild_tag_members, ensure_ascii=False, separators=(",", ":")),
            )
        except ValidationError:
            return

    def _update_guild_tag_status(self, channel_id: str) -> bool:
        if not channel_id:
            return False
        embed = guild_tag_status_embed(self._guild_tag_members)
        database = self.router.service.database
        stored_channel_id = database.get_setting("discord.guild_tag_status_channel_id")
        message_id = database.get_setting("discord.guild_tag_status_message_id")
        if stored_channel_id != channel_id:
            message_id = None
        if message_id:
            try:
                self.discord.edit_channel_message(
                    channel_id,
                    message_id,
                    embeds=[embed],
                    allowed_mentions={"parse": []},
                )
            except DiscordHttpError as exc:
                if exc.status != 404:
                    raise
                message_id = None
        if not message_id:
            response = self.discord.send_channel_message(
                channel_id,
                embeds=[embed],
                allowed_mentions={"parse": []},
            )
            payload = response.payload
            if not isinstance(payload, dict) or not payload.get("id"):
                raise ValueError("Discord did not return a guild tag status message")
            message_id = str(payload["id"])
            database.set_setting("discord.guild_tag_status_message_id", message_id)
        database.set_setting("discord.guild_tag_status_channel_id", channel_id)
        self._persist_guild_tag_status()
        self._guild_tag_status_dirty = False
        return True

    def retry_guild_tag_status(self) -> bool:
        if not self.guild_tag_status_channel_id or not self._guild_tag_status_dirty:
            return False
        return self._update_guild_tag_status(self.guild_tag_status_channel_id)

    @staticmethod
    def _guild_tag_enabled(data: dict[str, Any], guild_id: str) -> tuple[bool, str] | None:
        user = data.get("user")
        if not isinstance(user, dict) or not user.get("id"):
            return None
        primary = user.get("primary_guild")
        if not isinstance(primary, dict):
            return False, str(user["id"])
        identity_guild_id = primary.get("identity_guild_id")
        enabled = primary.get("identity_enabled")
        if not isinstance(enabled, (bool, type(None))):
            return None
        active = bool(enabled) and str(identity_guild_id or "") == guild_id
        return active, str(user["id"])

    @staticmethod
    def _guild_tag_display_name(data: dict[str, Any], user_id: str) -> str:
        user = data.get("user") or {}
        return str(data.get("nick") or user.get("global_name") or user.get("username") or user_id)

    def sync_guild_tag_status(self, *, guild_id: str) -> bool:
        if not self.guild_id or str(guild_id) != self.guild_id:
            return False
        if not guild_id or not (self.guild_tag_status_channel_id or self.guild_tag_role_id):
            return False
        members: dict[str, str] = {}
        self._guild_tag_states = {}
        after: str | None = None
        while True:
            batch = self.discord.list_guild_members(guild_id, limit=1000, after=after)
            if not batch:
                break
            for member in batch:
                if not isinstance(member, dict):
                    continue
                user = member.get("user")
                if not isinstance(user, dict):
                    continue
                parsed = self._guild_tag_enabled({"user": user}, guild_id)
                if parsed is None:
                    continue
                enabled, user_id = parsed
                self._guild_tag_states[user_id] = enabled
                self._sync_guild_tag_role(guild_id, user_id, enabled, member=member)
                if enabled:
                    members[user_id] = self._guild_tag_display_name({"user": user, "nick": member.get("nick")}, user_id)
            if len(batch) < 1000:
                break
            last_user = batch[-1].get("user")
            last_id = last_user.get("id") if isinstance(last_user, dict) else None
            if not last_id or str(last_id) == after:
                raise ValueError("Discord guild member pagination did not advance")
            after = str(last_id)
        self._guild_tag_members = members
        self._persist_guild_tag_status()
        if not self.guild_tag_status_channel_id:
            return True
        self._guild_tag_status_dirty = True
        return self._update_guild_tag_status(self.guild_tag_status_channel_id)

    def _sync_guild_tag_role(
        self,
        guild_id: str,
        user_id: str,
        enabled: bool,
        *,
        member: dict[str, Any] | None = None,
        state_changed: bool = True,
    ) -> bool:
        if not self.guild_tag_role_id:
            return False
        roles = member.get("roles") if isinstance(member, dict) else None
        role_ids = {str(role) for role in roles} if isinstance(roles, list) else None
        if role_ids is None and not state_changed:
            return False
        role_already_synced = role_ids is not None and (
            (enabled and self.guild_tag_role_id in role_ids)
            or (not enabled and self.guild_tag_role_id not in role_ids)
        )
        if role_already_synced:
            return False
        if enabled:
            self.discord.add_guild_member_role(guild_id, user_id, self.guild_tag_role_id)
        else:
            self.discord.remove_guild_member_role(guild_id, user_id, self.guild_tag_role_id)
        return True

    def handle_guild_tag_update(
        self,
        data: dict[str, Any],
        *,
        guild_id: str,
        channel_id: str,
        status_channel_id: str | None = None,
    ) -> bool:
        if not self.guild_id or str(guild_id) != self.guild_id:
            return False
        if self.guild_tag_log_channel_id:
            if str(channel_id) != self.guild_tag_log_channel_id:
                return False
        elif channel_id:
            channel_id = ""
        if self.guild_tag_status_channel_id:
            if status_channel_id is not None and str(status_channel_id) != self.guild_tag_status_channel_id:
                return False
        elif status_channel_id:
            return False
        if str(data.get("guild_id") or "") != guild_id:
            return False
        parsed = self._guild_tag_enabled(data, guild_id)
        if parsed is None:
            return False
        enabled, user_id = parsed
        previous = self._guild_tag_states.get(user_id)
        self._guild_tag_states[user_id] = enabled
        self._sync_guild_tag_role(
            guild_id,
            user_id,
            enabled,
            member=data,
            state_changed=previous is None or previous != enabled,
        )
        display_name = self._guild_tag_display_name(data, user_id)
        previous_display_name = self._guild_tag_members.get(user_id)
        if enabled:
            self._guild_tag_members[user_id] = display_name
        else:
            self._guild_tag_members.pop(user_id, None)
        status_channel = self.guild_tag_status_channel_id if status_channel_id is None else status_channel_id
        status_changed = (previous != enabled) or (enabled and previous_display_name != display_name)
        if status_channel and (status_changed or self._guild_tag_status_dirty):
            self._guild_tag_status_dirty = True
            self._update_guild_tag_status(status_channel)
        if previous is None or previous == enabled or not channel_id:
            return False
        user = data.get("user") or {}
        tag = ((user.get("primary_guild") or {}).get("tag") or "뀨?")
        content, embed = guild_tag_log_message(user_id, display_name, str(tag), enabled=enabled, guild_id=guild_id)
        self.discord.send_channel_message(channel_id, content, embeds=[embed])
        return True

    def _send_dm(self, user_id: str, content: str, embeds: list[dict[str, Any]] | None = None):
        if not embeds:
            return self.discord.send_dm(user_id, content)
        try:
            return self.discord.send_dm(user_id, content, embeds=embeds)
        except TypeError as exc:
            if "embed" not in str(exc).lower():
                raise
            return self.discord.send_dm(user_id, content)

    def _interaction_allowed(self, interaction: dict[str, Any]) -> bool:
        interaction_type = interaction.get("type")
        if interaction_type not in {2, 3, 5}:
            return True
        scopes = (
            (self.application_id, interaction.get("application_id")),
            (self.guild_id, interaction.get("guild_id")),
            (self.panel_channel_id, interaction.get("channel_id")),
        )
        if any(
            not expected or not isinstance(actual, str) or not actual or actual != expected
            for expected, actual in scopes
        ):
            return False
        if interaction_type == 3:
            panel_message_id = self.router.service.database.get_setting("discord.panel_message_id")
            message = interaction.get("message")
            if not panel_message_id or not isinstance(message, dict):
                return False
            message_id = message.get("id")
            if not isinstance(message_id, str) or not message_id or message_id != panel_message_id:
                return False
        return True

    def process(self, interaction: dict[str, Any], *, interaction_id: str, interaction_token: str, now: int | None = None) -> InteractionResult:
        if not self._interaction_allowed(interaction):
            return self.router._ephemeral(
                "⚠️ **이 애플리케이션, 서버 또는 패널에서는 사용할 수 없는 요청입니다.**",
                title="⚠️ 요청 범위 확인",
                color=COLOR_WARNING,
            )
        deferred = interaction.get("type") in {2, 5}
        if deferred:
            self.discord.defer_interaction(interaction_id, interaction_token)
        if interaction.get("type") == 2 and isinstance(interaction.get("data"), dict) and interaction["data"].get("name") in {"입금패널", "vending-panel"}:
            try:
                if self.panel_manager is None:
                    raise ValidationError("panel manager is not configured")
                actor_id = self.router._user_id(interaction)
                message_id = self.panel_manager.publish(actor_id)
                result = self.router._ephemeral(
                    f"✅ **입금 패널을 게시했습니다.**\n메시지 ID: `{message_id}`",
                    title="✅ 패널 게시 완료",
                    description="지정된 채널에 입금 후원 패널을 게시했습니다.",
                    color=COLOR_SUCCESS,
                )
            except ValidationError:
                result = self.router._ephemeral(
                    "⚠️ **관리자 권한 또는 패널 설정을 확인해 주세요.**",
                    title="⚠️ 패널 설정 확인",
                    color=COLOR_ERROR,
                )
            except Exception:
                result = self.router._ephemeral(
                    "⚠️ **입금 패널을 게시하지 못했습니다.**",
                    title="⚠️ 패널 게시 실패",
                    color=COLOR_ERROR,
                )
        else:
            result = self.router.handle(interaction, interaction_id=interaction_id, now=now)
        if deferred:
            data = dict(result.response.get("data", {}))
            data.pop("flags", None)
            self.discord.edit_original_response(interaction_token, data)
        else:
            self.discord.respond_to_interaction(interaction_id, interaction_token, result.response)
        if result.order_receipt is not None and result.dm_content is not None:
            order = result.order_receipt.order
            current_order = self.router.service.database.get_order(order.order_id)
            if current_order.dm_status != DmStatus.SENT:
                try:
                    self._send_dm(order.discord_id, result.dm_content, result.dm_embeds)
                    self.router.service.database.set_dm_status(order.order_id, DmStatus.SENT)
                except Exception:
                    self.router.service.database.set_dm_status(order.order_id, DmStatus.FAILED)
        if result.payment_result is not None:
            self.handle_payment_result(result.payment_result)
        return result

    def handle_payment_result(self, result: MatchResult) -> bool:
        if result.status != ProcessingStatus.CONSUMED or not result.order_id:
            return False
        service = self.router.service
        order = service.database.get_order(result.order_id)
        if order.payment_dm_status == DmStatus.SENT:
            return True
        receipt = OrderReceipt(
            order=order,
            bank_name=service.settings.bank_name,
            account_number=service.settings.bank_account_number,
            account_holder=service.settings.bank_account_holder,
        )
        try:
            content, embed = payment_message(receipt, service.support_total(order.discord_id))
            self._send_dm(order.discord_id, content, [embed])
            service.database.set_payment_dm_status(order.order_id, DmStatus.SENT)
            return True
        except Exception:
            service.database.set_payment_dm_status(order.order_id, DmStatus.FAILED)
            return False

    def retry_pending_dms(self, *, limit: int = 100) -> int:
        service = self.router.service
        sent = 0
        for order in service.database.list_pending_dm_orders(limit=limit):
            receipt = OrderReceipt(
                order=order,
                bank_name=service.settings.bank_name,
                account_number=service.settings.bank_account_number,
                account_holder=service.settings.bank_account_holder,
            )
            try:
                content, embed = order_message(receipt)
                self._send_dm(order.discord_id, content, [embed])
                service.database.set_dm_status(order.order_id, DmStatus.SENT)
                sent += 1
            except Exception:
                service.database.set_dm_status(order.order_id, DmStatus.FAILED)
        return sent

    def retry_pending_payment_dms(self, *, limit: int = 100) -> int:
        service = self.router.service
        sent = 0
        for order in service.database.list_pending_payment_dm_orders(limit=limit):
            result = MatchResult(ProcessingStatus.CONSUMED, order.matched_push_id or "", order_id=order.order_id, amount_krw=order.matched_amount_krw)
            if self.handle_payment_result(result):
                sent += 1
        return sent
