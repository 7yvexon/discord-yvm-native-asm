CREATE TABLE IF NOT EXISTS support_totals (
    discord_id TEXT PRIMARY KEY,
    cumulative_support_krw INTEGER NOT NULL DEFAULT 0 CHECK(cumulative_support_krw >= 0),
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS deposit_orders (
    order_id TEXT PRIMARY KEY,
    interaction_id TEXT,
    discord_id TEXT NOT NULL,
    depositor_name_input TEXT NOT NULL,
    depositor_name_normalized TEXT NOT NULL,
    requested_amount_krw INTEGER NOT NULL CHECK(requested_amount_krw > 0),
    status TEXT NOT NULL CHECK(status IN ('PENDING', 'PAID', 'REVIEW', 'EXPIRED')),
    created_at INTEGER NOT NULL,
    expires_at INTEGER NOT NULL,
    matched_push_id TEXT UNIQUE,
    matched_amount_krw INTEGER,
    matched_at INTEGER,
    dm_status TEXT NOT NULL CHECK(dm_status IN ('PENDING', 'SENT', 'FAILED')),
    payment_dm_status TEXT NOT NULL DEFAULT 'PENDING' CHECK(payment_dm_status IN ('PENDING', 'SENT', 'FAILED'))
);

CREATE INDEX IF NOT EXISTS idx_deposit_orders_match
ON deposit_orders(depositor_name_normalized, requested_amount_krw, status, expires_at);

CREATE TABLE IF NOT EXISTS push_events (
    push_id TEXT PRIMARY KEY,
    push_created_at INTEGER,
    push_modified_at INTEGER,
    package_name TEXT,
    application_name TEXT,
    title TEXT,
    body_hash TEXT,
    parsed_depositor_name TEXT,
    parsed_depositor_name_normalized TEXT,
    parsed_amount_krw INTEGER,
    processing_status TEXT NOT NULL,
    consumed_order_id TEXT,
    received_at INTEGER NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_push_events_status
ON push_events(processing_status, received_at);

CREATE TABLE IF NOT EXISTS ledger (
    ledger_id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id TEXT NOT NULL UNIQUE,
    discord_id TEXT NOT NULL,
    amount_krw INTEGER NOT NULL CHECK(amount_krw > 0),
    reason TEXT NOT NULL,
    created_at INTEGER NOT NULL,
    FOREIGN KEY(order_id) REFERENCES deposit_orders(order_id)
);

CREATE TABLE IF NOT EXISTS settings (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL
);
