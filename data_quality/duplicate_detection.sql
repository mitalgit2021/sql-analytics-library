-- =============================================================
-- duplicate_detection.sql
-- Find and handle duplicate records
--
-- Interview relevance: DTCC, Citi, Meta, all companies
-- Concepts: ROW_NUMBER, COUNT+HAVING, GROUP BY, deduplication
-- =============================================================

-- ── METHOD 1: Find duplicate transaction IDs ──────────────────

SELECT
    transaction_id,
    COUNT(*)    AS occurrence_count
FROM transactions
GROUP BY transaction_id
HAVING COUNT(*) > 1
ORDER BY occurrence_count DESC;

-- ── METHOD 2: Find exact duplicate rows ───────────────────────
-- All columns match — true duplicates

SELECT
    transaction_id,
    account_id,
    amount,
    transaction_date,
    COUNT(*)    AS duplicate_count
FROM transactions
GROUP BY
    transaction_id,
    account_id,
    amount,
    transaction_date
HAVING COUNT(*) > 1;

-- ── METHOD 3: ROW_NUMBER deduplication ────────────────────────
-- Keep only the LATEST record per transaction_id
-- This is the production pattern for loading dimension tables

WITH ranked_transactions AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY transaction_id          -- group by natural key
            ORDER BY transaction_date DESC       -- keep most recent
        ) AS row_num
    FROM transactions
)
SELECT *
FROM ranked_transactions
WHERE row_num = 1;              -- only keep first (latest) record

-- ── METHOD 4: Business-key deduplication ──────────────────────
-- Same account, amount, date = likely duplicate
-- Even if transaction_id differs

WITH business_key_dupes AS (
    SELECT
        account_id,
        amount,
        transaction_date,
        transaction_type,
        COUNT(*)                    AS dupe_count,
        MIN(transaction_id)         AS keep_id,
        MAX(transaction_id)         AS remove_id
    FROM transactions
    GROUP BY account_id, amount, transaction_date, transaction_type
    HAVING COUNT(*) > 1
)
SELECT
    t.*,
    'BUSINESS_KEY_DUPLICATE'    AS issue_type
FROM transactions t
JOIN business_key_dupes d
  ON t.account_id       = d.account_id
 AND t.amount           = d.amount
 AND t.transaction_date = d.transaction_date
 AND t.transaction_id   = d.remove_id;   -- the one to remove

-- =============================================================
-- PRODUCTION USE CASE:
-- In FDIC regulatory pipelines, I use ROW_NUMBER() to
-- deduplicate staging tables before loading to Snowflake
-- Fact tables. The PARTITION BY is the natural/business key,
-- ORDER BY is the pipeline load timestamp DESC.
-- This ensures idempotent pipeline runs.
-- =============================================================
