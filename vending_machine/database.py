from __future__ import annotations

import hashlib
import secrets
import threading
import time
from contextlib import contextmanager
from pathlib import Path
from typing import Iterator

from .sqlite_runtime import prepare_sqlite_runtime

prepare_sqlite_runtime()
import sqlite3

from .errors import DatabaseError, ValidationError
from .models import DmStatus, MatchResult, Order, OrderStatus, ParsedPush, ProcessingStatus
from .native_core import NativeCoreError, load_native_core
from .normalization import MAX_INT64, normalize_depositor_name, parse_amount_input, validate_utf8_text


_SCHEMA_PATH = Path(__file__).resolve().parent.parent / "db" / "schema.sql"
_MIGRATIONS_PATH = Path(__file__).resolve().parent.parent / "db" / "migrations"


class Database:
    def __init__(self, path: str | Path = "vending.db", *, case_insensitive_latin: bool = False, timeout: float = 5.0):
        self.path = str(path)
        self.case_insensitive_latin = case_insensitive_latin
        self._lock = threading.RLock()
        if self.path != ":memory:":
            Path(self.path).parent.mkdir(parents=True, exist_ok=True)
        try:
            self.connection = sqlite3.connect(self.path, timeout=timeout, isolation_level=None, check_same_thread=False)
            self.connection.row_factory = sqlite3.Row
            self.connection.execute("PRAGMA busy_timeout=5000")
            self.connection.execute("PRAGMA foreign_keys=ON")
            self.connection.execute("PRAGMA synchronous=FULL")
            self.connection.execute("PRAGMA journal_mode=WAL")
            self.connection.executescript(_SCHEMA_PATH.read_text(encoding="utf-8"))
            columns = {row[1] for row in self.connection.execute("PRAGMA table_info(deposit_orders)").fetchall()}
            if "interaction_id" not in columns:
                self.connection.execute("ALTER TABLE deposit_orders ADD COLUMN interaction_id TEXT")
            if "payment_dm_status" not in columns:
                self.connection.execute(
                    "ALTER TABLE deposit_orders ADD COLUMN payment_dm_status TEXT NOT NULL DEFAULT 'PENDING' CHECK(payment_dm_status IN ('PENDING', 'SENT', 'FAILED'))"
                )
            for migration in sorted(_MIGRATIONS_PATH.glob("*.sql")):
                self.connection.executescript(migration.read_text(encoding="utf-8"))
        except (OSError, sqlite3.Error) as exc:
            raise DatabaseError("unable to initialize database") from exc

    def close(self) -> None:
        with self._lock:
            self.connection.close()

    def __enter__(self) -> "Database":
        return self

    def __exit__(self, exc_type, exc_value, traceback) -> None:
        self.close()

    @contextmanager
    def _transaction(self) -> Iterator[sqlite3.Cursor]:
        with self._lock:
            cursor = self.connection.cursor()
            try:
                started = False
                for attempt in range(3):
                    try:
                        cursor.execute("BEGIN IMMEDIATE")
                        started = True
                        break
                    except sqlite3.OperationalError as exc:
                        message = str(exc).lower()
                        if "busy" not in message and "locked" not in message:
                            raise
                        if attempt == 2:
                            raise
                        time.sleep(0.05 * (attempt + 1))
                if not started:
                    raise DatabaseError("unable to start transaction")
                yield cursor
                self.connection.commit()
            except Exception:
                self.connection.rollback()
                raise
            finally:
                cursor.close()

    @staticmethod
    def _now(value: int | None) -> int:
        return int(time.time()) if value is None else int(value)

    @staticmethod
    def _validate_discord_id(value: str) -> str:
        value = validate_utf8_text(value, field="discord_id", max_bytes=64)
        if not value or any(character.isspace() for character in value):
            raise ValidationError("discord_id is invalid")
        return value

    def _new_order_id(self) -> str:
        return secrets.token_urlsafe(16).rstrip("=")

    def create_order(
        self,
        discord_id: str,
        depositor_name_input: str,
        amount_krw: int | str,
        *,
        interaction_id: str | None = None,
        ttl_seconds: int = 1800,
        minimum: int | None = None,
        maximum: int | None = None,
        now: int | None = None,
    ) -> Order:
        discord_id = self._validate_discord_id(discord_id)
        if interaction_id is not None:
            interaction_id = validate_utf8_text(interaction_id, field="interaction_id", max_bytes=128)
            if not interaction_id or any(character.isspace() for character in interaction_id):
                raise ValidationError("interaction_id is invalid")
        normalized_name = normalize_depositor_name(
            depositor_name_input,
            case_insensitive_latin=self.case_insensitive_latin,
        )
        if isinstance(amount_krw, bool):
            raise ValidationError("amount_krw is invalid")
        if isinstance(amount_krw, int):
            if amount_krw <= 0 or amount_krw > MAX_INT64:
                raise ValidationError("amount_krw is outside the valid range")
            if minimum is not None and amount_krw < minimum:
                raise ValidationError("amount_krw is below the configured minimum")
            if maximum is not None and amount_krw > maximum:
                raise ValidationError("amount_krw is above the configured maximum")
            parsed_amount = amount_krw
        else:
            parsed_amount = parse_amount_input(amount_krw, minimum=minimum, maximum=maximum)
        if ttl_seconds <= 0:
            raise ValidationError("ttl_seconds must be positive")
        created_at = self._now(now)
        expires_at = created_at + int(ttl_seconds)
        for _ in range(5):
            order_id = self._new_order_id()
            try:
                with self._transaction() as cursor:
                    cursor.execute(
                        """
                        INSERT INTO deposit_orders(
                            order_id, interaction_id, discord_id, depositor_name_input,
                            depositor_name_normalized, requested_amount_krw,
                            status, created_at, expires_at, dm_status
                        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                        """,
                        (
                            order_id,
                            interaction_id,
                            discord_id,
                            depositor_name_input,
                            normalized_name,
                            parsed_amount,
                            OrderStatus.PENDING.value,
                            created_at,
                            expires_at,
                            DmStatus.PENDING.value,
                        ),
                    )
                return self.get_order(order_id)
            except sqlite3.IntegrityError as exc:
                if interaction_id is not None and "interaction_id" in str(exc):
                    with self._lock:
                        existing = self.connection.execute(
                            "SELECT order_id, discord_id, depositor_name_normalized, requested_amount_krw FROM deposit_orders WHERE interaction_id = ?",
                            (interaction_id,),
                        ).fetchone()
                    if existing is None:
                        continue
                    if (
                        existing["discord_id"] != discord_id
                        or existing["depositor_name_normalized"] != normalized_name
                        or int(existing["requested_amount_krw"]) != parsed_amount
                    ):
                        raise ValidationError("interaction id is already bound to another order")
                    return self.get_order(existing["order_id"])
                if "deposit_orders.order_id" not in str(exc):
                    raise DatabaseError("unable to create order") from exc
        raise DatabaseError("unable to allocate order id")

    def get_order(self, order_id: str) -> Order:
        with self._lock:
            row = self.connection.execute("SELECT * FROM deposit_orders WHERE order_id = ?", (order_id,)).fetchone()
        if row is None:
            raise DatabaseError("order not found")
        return Order(
            order_id=row["order_id"],
            discord_id=row["discord_id"],
            depositor_name_input=row["depositor_name_input"],
            depositor_name_normalized=row["depositor_name_normalized"],
            requested_amount_krw=row["requested_amount_krw"],
            status=OrderStatus(row["status"]),
            created_at=row["created_at"],
            expires_at=row["expires_at"],
            matched_push_id=row["matched_push_id"],
            matched_amount_krw=row["matched_amount_krw"],
            matched_at=row["matched_at"],
            dm_status=DmStatus(row["dm_status"]),
            payment_dm_status=DmStatus(row["payment_dm_status"]),
        )

    def set_dm_status(self, order_id: str, status: DmStatus) -> None:
        with self._transaction() as cursor:
            cursor.execute("UPDATE deposit_orders SET dm_status = ? WHERE order_id = ?", (status.value, order_id))
            if cursor.rowcount != 1:
                raise DatabaseError("order not found")

    def set_payment_dm_status(self, order_id: str, status: DmStatus) -> None:
        with self._transaction() as cursor:
            cursor.execute("UPDATE deposit_orders SET payment_dm_status = ? WHERE order_id = ?", (status.value, order_id))
            if cursor.rowcount != 1:
                raise DatabaseError("order not found")

    def get_support_total(self, discord_id: str) -> int:
        discord_id = self._validate_discord_id(discord_id)
        with self._lock:
            row = self.connection.execute(
                "SELECT cumulative_support_krw FROM support_totals WHERE discord_id = ?",
                (discord_id,),
            ).fetchone()
        return 0 if row is None else int(row[0])

    def set_setting(self, key: str, value: str) -> None:
        validate_utf8_text(key, field="setting key", max_bytes=128)
        validate_utf8_text(value, field="setting value", max_bytes=4096)
        with self._transaction() as cursor:
            cursor.execute(
                "INSERT INTO settings(key, value) VALUES (?, ?) ON CONFLICT(key) DO UPDATE SET value=excluded.value",
                (key, value),
            )

    def get_setting(self, key: str) -> str | None:
        with self._lock:
            row = self.connection.execute("SELECT value FROM settings WHERE key = ?", (key,)).fetchone()
        return None if row is None else str(row[0])

    @staticmethod
    def _body_hash(body: str | None) -> str | None:
        if body is None:
            return None
        return hashlib.sha256(body.encode("utf-8", "strict")).hexdigest()

    def _insert_push_event(self, cursor: sqlite3.Cursor, event: ParsedPush, status: ProcessingStatus, received_at: int) -> bool:
        cursor.execute(
            """
            INSERT OR IGNORE INTO push_events(
                push_id, push_created_at, push_modified_at, package_name,
                application_name, title, body_hash, parsed_depositor_name,
                parsed_depositor_name_normalized, parsed_amount_krw,
                processing_status, received_at
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            (
                event.push_id,
                event.push_created_at,
                event.push_modified_at,
                event.package_name,
                event.application_name,
                event.title,
                event.body_hash,
                event.parsed_depositor_name,
                event.parsed_depositor_name_normalized,
                event.parsed_amount_krw,
                status.value,
                received_at,
            ),
        )
        return cursor.rowcount == 1

    def _update_push_status(
        self,
        cursor: sqlite3.Cursor,
        push_id: str,
        status: ProcessingStatus,
        order_id: str | None = None,
    ) -> None:
        cursor.execute(
            "UPDATE push_events SET processing_status = ?, consumed_order_id = ? WHERE push_id = ?",
            (status.value, order_id, push_id),
        )

    def _credit_locked(self, cursor: sqlite3.Cursor, order: sqlite3.Row, event: ParsedPush, now: int) -> None:
        amount = int(order["requested_amount_krw"])
        current = cursor.execute(
            "SELECT cumulative_support_krw FROM support_totals WHERE discord_id = ?",
            (order["discord_id"],),
        ).fetchone()
        current_total = 0 if current is None else int(current[0])
        native_core = load_native_core()
        if native_core is None:
            if current_total > MAX_INT64 - amount:
                raise DatabaseError("support total exceeds int64 range")
            next_total = current_total + amount
        else:
            try:
                next_total = native_core.add_support_total(current_total, amount)
            except NativeCoreError as exc:
                raise DatabaseError("support total exceeds int64 range") from exc
        cursor.execute(
            """
            UPDATE deposit_orders
            SET status = ?, matched_push_id = ?, matched_amount_krw = ?, matched_at = ?
            WHERE order_id = ? AND status = ?
            """,
            (OrderStatus.PAID.value, event.push_id, amount, now, order["order_id"], OrderStatus.PENDING.value),
        )
        if cursor.rowcount != 1:
            raise DatabaseError("order is no longer pending")
        cursor.execute(
            "INSERT INTO ledger(order_id, discord_id, amount_krw, reason, created_at) VALUES (?, ?, ?, ?, ?)",
            (order["order_id"], order["discord_id"], amount, "deposit", now),
        )
        cursor.execute(
            """
            INSERT INTO support_totals(discord_id, cumulative_support_krw, created_at, updated_at)
            VALUES (?, ?, ?, ?)
            ON CONFLICT(discord_id) DO UPDATE SET
                cumulative_support_krw = excluded.cumulative_support_krw,
                updated_at = excluded.updated_at
            """,
            (order["discord_id"], next_total, now, now),
        )
        self._update_push_status(cursor, event.push_id, ProcessingStatus.CONSUMED, order["order_id"])

    def process_push(
        self,
        event: ParsedPush,
        *,
        preliminary_status: ProcessingStatus = ProcessingStatus.RECEIVED,
        now: int | None = None,
    ) -> MatchResult:
        if not event.push_id:
            raise ValidationError("push_id must not be empty")
        received_at = self._now(now)
        try:
            with self._transaction() as cursor:
                inserted = self._insert_push_event(cursor, event, preliminary_status, received_at)
                if not inserted:
                    return MatchResult(ProcessingStatus.DUPLICATE, event.push_id, detail="push id already processed")
                if preliminary_status != ProcessingStatus.RECEIVED:
                    return MatchResult(preliminary_status, event.push_id)
                if event.parsed_depositor_name_normalized is None or event.parsed_amount_krw is None:
                    self._update_push_status(cursor, event.push_id, ProcessingStatus.PARSE_FAILED)
                    return MatchResult(ProcessingStatus.PARSE_FAILED, event.push_id, detail="required fields are missing")
                cursor.execute(
                    """
                    UPDATE deposit_orders
                    SET status = ?
                    WHERE status = ? AND expires_at <= ?
                    """,
                    (OrderStatus.EXPIRED.value, OrderStatus.PENDING.value, received_at),
                )
                matching_orders = cursor.execute(
                    """
                    SELECT * FROM deposit_orders
                    WHERE depositor_name_normalized = ?
                      AND requested_amount_krw = ?
                      AND status = ?
                    ORDER BY created_at ASC, order_id ASC
                    """,
                    (
                        event.parsed_depositor_name_normalized,
                        event.parsed_amount_krw,
                        OrderStatus.PENDING.value,
                    ),
                ).fetchall()
                event_time = event.push_created_at if event.push_created_at is not None else event.push_modified_at
                candidates = [
                    order
                    for order in matching_orders
                    if int(order["expires_at"]) > received_at
                    and (
                        event_time is None
                        or int(order["created_at"]) <= event_time < int(order["expires_at"])
                    )
                ]
                stale_candidates = [
                    order
                    for order in matching_orders
                    if int(order["expires_at"]) > received_at
                    and event_time is not None
                    and not (int(order["created_at"]) <= event_time < int(order["expires_at"]))
                ]
                if stale_candidates:
                    self._update_push_status(cursor, event.push_id, ProcessingStatus.REVIEW)
                    return MatchResult(
                        ProcessingStatus.REVIEW,
                        event.push_id,
                        amount_krw=event.parsed_amount_krw,
                        detail="push timestamp is outside the pending order lifetime",
                    )
                if len(candidates) != 1:
                    expired_match = cursor.execute(
                        """
                        SELECT 1 FROM deposit_orders
                        WHERE depositor_name_normalized = ?
                          AND requested_amount_krw = ?
                          AND status = ?
                          AND expires_at <= ?
                        LIMIT 1
                        """,
                        (
                            event.parsed_depositor_name_normalized,
                            event.parsed_amount_krw,
                            OrderStatus.EXPIRED.value,
                            received_at,
                        ),
                    ).fetchone()
                    if expired_match is not None:
                        status = ProcessingStatus.EXPIRED
                        detail = "matching order expired"
                    elif len(candidates) == 0:
                        status = ProcessingStatus.MATCH_NOT_FOUND
                        detail = "no unique pending order"
                    else:
                        status = ProcessingStatus.MATCH_AMBIGUOUS
                        detail = "more than one pending order"
                    stored_status = ProcessingStatus.REVIEW if status == ProcessingStatus.MATCH_AMBIGUOUS else status
                    self._update_push_status(cursor, event.push_id, stored_status)
                    return MatchResult(status, event.push_id, amount_krw=event.parsed_amount_krw, detail=detail)
                order = candidates[0]
                self._credit_locked(cursor, order, event, received_at)
                return MatchResult(
                    ProcessingStatus.CONSUMED,
                    event.push_id,
                    order_id=order["order_id"],
                    amount_krw=event.parsed_amount_krw,
                )
        except sqlite3.IntegrityError as exc:
            raise DatabaseError("unable to process push") from exc
        except sqlite3.Error as exc:
            raise DatabaseError("database error while processing push") from exc

    def list_review_events(self, *, limit: int = 100) -> list[sqlite3.Row]:
        if limit <= 0 or limit > 1000:
            raise ValidationError("limit is outside the valid range")
        with self._lock:
            return list(
                self.connection.execute(
                    """
                    SELECT * FROM push_events
                    WHERE processing_status IN (?, ?, ?, ?, ?, ?)
                    ORDER BY received_at ASC LIMIT ?
                    """,
                    (
                        ProcessingStatus.REVIEW.value,
                        ProcessingStatus.MATCH_AMBIGUOUS.value,
                        ProcessingStatus.MATCH_NOT_FOUND.value,
                        ProcessingStatus.EXPIRED.value,
                        ProcessingStatus.PARSE_FAILED.value,
                        ProcessingStatus.UNSUPPORTED.value,
                        limit,
                    ),
                ).fetchall()
            )

    def list_pending_dm_orders(self, *, limit: int = 100) -> list[Order]:
        if limit <= 0 or limit > 1000:
            raise ValidationError("limit is outside the valid range")
        with self._lock:
            rows = self.connection.execute(
                "SELECT order_id FROM deposit_orders WHERE dm_status IN (?, ?) ORDER BY created_at ASC LIMIT ?",
                (DmStatus.PENDING.value, DmStatus.FAILED.value, limit),
            ).fetchall()
        return [self.get_order(row[0]) for row in rows]

    def list_pending_payment_dm_orders(self, *, limit: int = 100) -> list[Order]:
        if limit <= 0 or limit > 1000:
            raise ValidationError("limit is outside the valid range")
        with self._lock:
            rows = self.connection.execute(
                "SELECT order_id FROM deposit_orders WHERE status = ? AND payment_dm_status IN (?, ?) ORDER BY matched_at ASC LIMIT ?",
                (OrderStatus.PAID.value, DmStatus.PENDING.value, DmStatus.FAILED.value, limit),
            ).fetchall()
        return [self.get_order(row[0]) for row in rows]

    def ledger_rows(self, *, discord_id: str | None = None, limit: int = 100) -> list[sqlite3.Row]:
        if limit <= 0 or limit > 1000:
            raise ValidationError("limit is outside the valid range")
        with self._lock:
            if discord_id is None:
                return list(self.connection.execute("SELECT * FROM ledger ORDER BY ledger_id DESC LIMIT ?", (limit,)).fetchall())
            discord_id = self._validate_discord_id(discord_id)
            return list(
                self.connection.execute(
                    "SELECT * FROM ledger WHERE discord_id = ? ORDER BY ledger_id DESC LIMIT ?",
                    (discord_id, limit),
                ).fetchall()
            )
