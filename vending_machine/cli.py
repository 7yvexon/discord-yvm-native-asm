from __future__ import annotations

import argparse
import json
import signal
import sys
import threading
import time
from pathlib import Path

from .config import Settings
from .database import Database
from .discord_client import DiscordGatewayClient
from .discord_gateway import DiscordInteractionProcessor, DiscordInteractionRouter
from .discord_rest import DiscordRestClient
from .json_utils import loads_native
from .panel import PanelManager
from .pushbullet import PushbulletApi, PushbulletPoller, PushbulletStreamClient
from .service import VendingService


def _settings(path: str | None) -> Settings:
    if path is None:
        return Settings()
    return Settings.from_file(path)


def _database(settings: Settings) -> Database:
    return Database(settings.database_path, case_insensitive_latin=settings.case_insensitive_latin)


def _result_json(result) -> str:
    return json.dumps(
        {
            "status": result.status.value,
            "push_id": result.push_id,
            "order_id": result.order_id,
            "amount_krw": result.amount_krw,
            "detail": result.detail,
        },
        ensure_ascii=False,
    )


def _review_json(rows) -> str:
    return json.dumps(
        [
            {
                "push_id": row["push_id"],
                "status": row["processing_status"],
                "parsed_depositor_name": row["parsed_depositor_name"],
                "parsed_amount_krw": row["parsed_amount_krw"],
                "received_at": row["received_at"],
            }
            for row in rows
        ],
        ensure_ascii=False,
    )


def _ledger_json(rows) -> str:
    return json.dumps(
        [
            {
                "ledger_id": row["ledger_id"],
                "order_id": row["order_id"],
                "discord_id": row["discord_id"],
                "amount_krw": row["amount_krw"],
                "reason": row["reason"],
                "created_at": row["created_at"],
            }
            for row in rows
        ],
        ensure_ascii=False,
    )


def _order_created_message(receipt) -> str:
    return "\n".join(
        (
            "order-created:",
            f"order_id: {receipt.order.order_id}",
            f"amount_krw: {receipt.order.requested_amount_krw}",
            f"expires_at: {receipt.order.expires_at}",
        )
    )


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="yul-vending-machine")
    parser.add_argument("--config", default=None)
    subparsers = parser.add_subparsers(dest="command", required=True)

    subparsers.add_parser("init-db")

    create = subparsers.add_parser("create-order")
    create.add_argument("discord_id")
    create.add_argument("depositor_name")
    create.add_argument("amount_krw")
    create.add_argument("--now", type=int)

    process = subparsers.add_parser("process-push")
    process.add_argument("json_file", type=Path)
    process.add_argument("--now", type=int)

    review = subparsers.add_parser("review-list")
    review.add_argument("--actor-id")
    review.add_argument("--limit", type=int, default=100)

    ledger = subparsers.add_parser("ledger")
    ledger.add_argument("--actor-id")
    ledger.add_argument("--discord-id")
    ledger.add_argument("--limit", type=int, default=100)

    total = subparsers.add_parser("support-total")
    total.add_argument("discord_id")

    subparsers.add_parser("panel-text")
    panel = subparsers.add_parser("panel")
    panel.add_argument("--actor-id")
    run = subparsers.add_parser("run")
    run.add_argument("--poll-interval", type=int, default=30)
    return parser


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    try:
        settings = _settings(args.config)
        with _database(settings) as database:
            service = VendingService(database, settings)
            if args.command == "init-db":
                return 0
            if args.command == "create-order":
                receipt = service.create_order(args.discord_id, args.depositor_name, args.amount_krw, now=args.now)
                print(_order_created_message(receipt))
                return 0
            if args.command == "process-push":
                payload = loads_native(args.json_file.read_text(encoding="utf-8"))
                print(_result_json(service.handle_push(payload, now=args.now)))
                return 0
            if args.command == "support-total":
                print(service.support_total(args.discord_id))
                return 0
            if args.command == "review-list":
                actor_id = args.actor_id or settings.discord_admin_user_id
                print(_review_json(service.list_review_events(actor_id=actor_id, limit=args.limit)))
                return 0
            if args.command == "ledger":
                actor_id = args.actor_id or settings.discord_admin_user_id
                print(_ledger_json(service.ledger_rows(actor_id=actor_id, discord_id=args.discord_id, limit=args.limit)))
                return 0
            if args.command == "panel-text":
                print(service.panel_text())
                return 0
            if args.command == "panel":
                actor_id = args.actor_id or settings.discord_admin_user_id
                discord = DiscordRestClient(settings.discord_bot_token, settings.discord_application_id)
                manager = PanelManager(service, discord)
                print(manager.publish(actor_id))
                return 0
            if args.command == "run":
                if args.poll_interval <= 0:
                    raise ValueError("poll interval must be positive")
                settings.validate_runtime_endpoints()
                required_settings = {
                    "DISCORD_BOT_TOKEN": settings.discord_bot_token,
                    "DISCORD_APPLICATION_ID": settings.discord_application_id,
                    "DISCORD_GUILD_ID": settings.discord_guild_id,
                    "DISCORD_PANEL_CHANNEL_ID": settings.discord_panel_channel_id,
                    "DISCORD_ADMIN_USER_ID": settings.discord_admin_user_id,
                    "PUSHBULLET_ACCESS_TOKEN": settings.pushbullet_access_token,
                    "BANK_NAME": settings.bank_name,
                    "BANK_ACCOUNT_NUMBER": settings.bank_account_number,
                    "BANK_ACCOUNT_HOLDER": settings.bank_account_holder,
                    "BANK_PACKAGE_NAME": settings.bank_package_name,
                    "BANK_APPLICATION_NAME": settings.bank_application_name,
                    "BANK_TITLE_FILTER": settings.bank_title_prefix or settings.bank_title_pattern,
                }
                missing = [key for key, value in required_settings.items() if not value]
                if missing:
                    raise ValueError("required settings are missing: " + ", ".join(missing))
                discord = DiscordRestClient(settings.discord_bot_token, settings.discord_application_id)
                router = DiscordInteractionRouter(service)
                panel_manager = PanelManager(service, discord)
                processor = DiscordInteractionProcessor(
                    router,
                    discord,
                    panel_manager,
                    application_id=settings.discord_application_id,
                    guild_id=settings.discord_guild_id,
                    panel_channel_id=settings.discord_panel_channel_id,
                    guild_tag_log_channel_id=settings.discord_guild_tag_log_channel_id,
                    guild_tag_status_channel_id=settings.discord_guild_tag_status_channel_id,
                    guild_tag_role_id=settings.discord_guild_tag_role_id,
                )
                gateway = DiscordGatewayClient(
                    settings.discord_bot_token,
                    processor,
                    database=database,
                    rest=discord,
                    guild_id=settings.discord_guild_id,
                    guild_tag_log_channel_id=settings.discord_guild_tag_log_channel_id,
                    guild_tag_status_channel_id=settings.discord_guild_tag_status_channel_id,
                    guild_tag_role_id=settings.discord_guild_tag_role_id,
                    intents=settings.discord_intents,
                    gateway_url=settings.discord_gateway_url,
                    on_error=lambda error: print(f"Discord Gateway: {error}", file=sys.stderr),
                )
                api = PushbulletApi(settings.pushbullet_access_token)
                poller = PushbulletPoller(api, database, service, on_result=processor.handle_payment_result)
                stream = PushbulletStreamClient(
                    settings.pushbullet_access_token,
                    poller,
                    stream_url=settings.pushbullet_stream_url,
                    fallback_interval=args.poll_interval,
                    on_error=lambda error: print(f"Pushbullet stream: {error}", file=sys.stderr),
                )
                stopping = threading.Event()

                def stop(*_):
                    stopping.set()
                    gateway.stop()
                    stream.stop()

                signal.signal(signal.SIGINT, stop)
                signal.signal(signal.SIGTERM, stop)
                gateway_thread = threading.Thread(target=gateway.run_forever, args=(stopping,), name="discord-gateway", daemon=True)
                stream_thread = threading.Thread(target=stream.run_forever, args=(stopping,), name="pushbullet-stream", daemon=True)
                gateway_thread.start()
                stream_thread.start()
                try:
                    last_dm_retry = 0.0
                    while not stopping.wait(1.0):
                        if time.monotonic() - last_dm_retry >= 30.0:
                            try:
                                processor.retry_pending_dms()
                                processor.retry_pending_payment_dms()
                                processor.retry_guild_tag_status()
                            except Exception as error:
                                print(f"DM retry: {error}", file=sys.stderr)
                            last_dm_retry = time.monotonic()
                finally:
                    gateway.stop()
                    stream.stop()
                    gateway_thread.join(timeout=5.0)
                    stream_thread.join(timeout=5.0)
                return 0
    except Exception as exc:
        print(str(exc), file=sys.stderr)
        return 1
    return 1
