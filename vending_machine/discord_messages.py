from __future__ import annotations

from collections.abc import Iterable, Mapping
from typing import Any


COLOR_PRIMARY = 0x5865F2
COLOR_SUCCESS = 0x57F287
COLOR_WARNING = 0xFEE75C
COLOR_ERROR = 0xED4245
COLOR_NEUTRAL = 0x2B2D31


def _clean(
    value: Any,
    *,
    limit: int = 1024,
    preserve_newlines: bool = False,
    escape_backticks: bool = True,
) -> str:
    text = str(value).replace("\r", " ")
    if not preserve_newlines:
        text = text.replace("\n", " ")
    text = text.strip()
    if escape_backticks:
        text = text.replace("`", "ˋ")
    if len(text) > limit:
        return text[: max(0, limit - 1)] + "…"
    return text


def inline_code(value: Any) -> str:
    return f"`{_clean(value, limit=256)}`"


def amount_text(value: Any) -> str:
    if value is None or value == "":
        return "확인 필요"
    try:
        return f"{int(value):,}원"
    except (TypeError, ValueError):
        return f"{_clean(value)}원"


def _field(name: str, value: str, *, inline: bool = False) -> dict[str, Any]:
    return {"name": name, "value": value, "inline": inline}


def make_embed(
    title: str,
    *,
    description: str | None = None,
    color: int = COLOR_PRIMARY,
    fields: Iterable[Mapping[str, Any]] = (),
) -> dict[str, Any]:
    embed: dict[str, Any] = {"title": title, "color": color}
    if description:
        embed["description"] = _clean(description, limit=4096, preserve_newlines=True, escape_backticks=False)
    normalized_fields: list[dict[str, Any]] = []
    for item in fields:
        name = item.get("name")
        value = item.get("value")
        if not name or value is None:
            continue
        normalized_fields.append(
            {
                "name": _clean(name, limit=256),
                "value": _clean(value, limit=1024, preserve_newlines=True, escape_backticks=False),
                "inline": bool(item.get("inline", False)),
            }
        )
    if normalized_fields:
        embed["fields"] = normalized_fields[:25]
    return embed


def panel_embed() -> dict[str, Any]:
    return make_embed(
        "💳 입금 후원 안내",
        description="후원할 금액과 입금자명을 등록하면 입금 알림을 확인해 자동으로 반영합니다.",
        color=COLOR_PRIMARY,
        fields=(
            _field(
                "📝 신청 방법",
                "1. **입금 신청** 버튼을 눌러요.\n2. 입금자명과 금액을 입력해요.\n3. 안내된 계좌로 정확히 입금해요.",
            ),
            _field("⏱️ 처리 안내", "입금 알림 반영까지 잠시 걸릴 수 있어요.", inline=True),
            _field("🔐 자동 확인 조건", "입금자명과 금액이 신청 정보와 모두 일치해야 해요.", inline=False),
        ),
    )


def order_message(receipt: Any) -> tuple[str, dict[str, Any]]:
    order = receipt.order
    expires_at = int(order.expires_at)
    embed = make_embed(
        "📥 입금 신청이 접수되었습니다",
        description="아래 정보대로 입금해 주세요. 입금자명과 금액이 모두 일치하면 자동으로 확인됩니다.",
        color=COLOR_PRIMARY,
        fields=(
            _field("💰 입금 금액", f"**{amount_text(order.requested_amount_krw)}**", inline=True),
            _field(
                "🏦 입금 계좌",
                f"{_clean(receipt.bank_name or '은행 정보 미설정')}\n{inline_code(receipt.account_number or '계좌번호 미설정')}",
                inline=False,
            ),
            _field("👤 예금주", _clean(receipt.account_holder or "예금주 정보 미설정"), inline=True),
            _field("✍️ 입금자명", inline_code(order.depositor_name_input), inline=True),
            _field("⏳ 만료 시각", f"<t:{expires_at}:F>\n(<t:{expires_at}:R>)", inline=False),
        ),
    )
    content = "✅ **입금 신청이 접수되었습니다.**"
    return content, embed


def payment_message(receipt: Any, cumulative_total: int) -> tuple[str, dict[str, Any]]:
    order = receipt.order
    embed = make_embed(
        "🎉 입금 확인 완료",
        description="입금이 정상적으로 확인되어 후원 금액에 반영되었습니다. 감사합니다! 🙌",
        color=COLOR_SUCCESS,
        fields=(
            _field("✅ 반영 금액", f"**{amount_text(order.requested_amount_krw)}**", inline=True),
            _field("💰 누적 후원 금액", f"**{amount_text(cumulative_total)}**", inline=False),
        ),
    )
    content = f"🎉 **입금이 확인되었습니다!**\n반영 금액: **{amount_text(order.requested_amount_krw)}**"
    return content, embed


def support_total_message(total: int) -> tuple[str, dict[str, Any]]:
    formatted = amount_text(total)
    embed = make_embed(
        "💰 누적 후원 금액",
        description="지금까지 확인된 누적 후원 금액입니다.",
        color=COLOR_SUCCESS,
        fields=(_field("현재 누적액", f"# **{formatted}**", inline=False),),
    )
    return f"💰 **누적 후원 금액**\n현재까지 {inline_code(formatted)} 입니다.", embed


def review_list_message(rows: list[Any]) -> tuple[str, dict[str, Any]]:
    fields = []
    for row in rows:
        push_id = _clean(row["push_id"])
        status = _clean(row["processing_status"])
        name = row["parsed_depositor_name"] or "-"
        amount = amount_text(row["parsed_amount_krw"]) if row["parsed_amount_krw"] is not None else "-"
        fields.append(
            _field(
                f"🧾 {_clean(push_id[:16])} · {status}",
                f"입금자명: {inline_code(name)}\n금액: **{amount}**\nPush ID: {inline_code(push_id)}",
            )
        )
    embed = make_embed(
        "🕵️ 검토 대기 입금",
        description="자동 처리되지 않은 입금 알림입니다. 매칭 정보와 원장을 확인해 주세요.",
        color=COLOR_WARNING,
        fields=fields,
    )
    return f"🕵️ **검토 대기 입금 · {len(rows)}건**\n아래 항목을 확인해 주세요.", embed


def ledger_message(rows: list[Any]) -> tuple[str, dict[str, Any]]:
    fields = []
    for row in rows:
        ledger_id = _clean(row["ledger_id"])
        amount = amount_text(row["amount_krw"])
        fields.append(
            _field(
                f"📒 {_clean(ledger_id[:16])} · {amount}",
                f"사용자: {inline_code(row['discord_id'])}\n주문: {inline_code(row['order_id'])}\n사유: {_clean(row['reason'])}",
            )
        )
    embed = make_embed(
        "📒 지급 원장",
        description="자동 확인으로 반영된 지급 내역입니다.",
        color=COLOR_NEUTRAL,
        fields=fields,
    )
    return f"📒 **지급 원장 · {len(rows)}건**\n아래에서 지급 내역을 확인해 주세요.", embed


def status_embed(
    title: str,
    description: str,
    *,
    color: int = COLOR_PRIMARY,
    fields: Iterable[Mapping[str, Any]] = (),
) -> dict[str, Any]:
    return make_embed(title, description=description, color=color, fields=fields)


def guild_tag_log_message(user_id: str, display_name: str, tag: str, *, enabled: bool, guild_id: str) -> tuple[str, dict[str, Any]]:
    action = "착용" if enabled else "해제"
    color = COLOR_SUCCESS if enabled else COLOR_WARNING
    embed = make_embed(
        f"🏷️ `뀨?` 길드 태그 {action}",
        description=f"<@{_clean(user_id, limit=32)}> 님이 `뀨?` 길드 태그를 {action}했습니다.",
        color=color,
        fields=(
            _field("사용자", f"<@{_clean(user_id, limit=32)}> ({_clean(display_name, limit=100)})"),
            _field("태그", inline_code(tag), inline=True),
            _field("길드 ID", inline_code(guild_id), inline=True),
        ),
    )
    return f"🏷️ **`뀨?` 길드 태그 {action}** · <@{_clean(user_id, limit=32)}>", embed


def guild_tag_status_embed(members: Mapping[str, str]) -> dict[str, Any]:
    ordered = sorted(
        ((str(user_id), str(display_name)) for user_id, display_name in members.items()),
        key=lambda item: (item[1].casefold(), item[0]),
    )
    count = len(ordered)
    description = f"현재 `뀨?` 길드 태그를 착용 중인 사람: **{count}명**"
    if not ordered:
        description += "\n\n현재 착용 중인 사람이 없습니다."
    else:
        lines: list[str] = []
        for index, (user_id, display_name) in enumerate(ordered):
            line = f"• <@{_clean(user_id, limit=32)}> · {_clean(display_name, limit=100)}"
            remaining = len(ordered) - index - 1
            suffix = f"\n… 외 {remaining}명" if remaining else ""
            candidate_lines = lines + [line]
            candidate = description + "\n\n" + "\n".join(candidate_lines) + suffix
            if len(candidate) > 4096:
                if remaining:
                    lines.append(f"… 외 {remaining + 1}명")
                break
            lines.append(line)
        description += "\n\n" + "\n".join(lines)
    return make_embed(
        "🏷️ `뀨?` 현재 착용자",
        description=description,
        color=COLOR_SUCCESS if count else COLOR_NEUTRAL,
    )
