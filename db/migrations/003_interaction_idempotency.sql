CREATE UNIQUE INDEX IF NOT EXISTS idx_deposit_orders_interaction_id
ON deposit_orders(interaction_id)
WHERE interaction_id IS NOT NULL;

PRAGMA user_version = 3;
