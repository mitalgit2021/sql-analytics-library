-- =============================================================
-- top_accounts_by_volume.sql
-- Top N accounts by transaction volume and amount
--
-- Interview relevance: Goldman Sachs, JPMorgan, Capital One
-- Concepts: RANK, GROUP BY, multiple aggregations
-- =============================================================

-- ── TOP 10 ACCOUNTS BY TRANSACTION COUNT ──────────────────────

WITH account_stats AS (
    SELECT
        account_id,
        COUNT(*)                    AS transaction_count,
        SUM(amount)                 AS total_amount,
        AVG(amount)                 AS avg_amount,
        MIN(amount)                 AS min_amount,
        MAX(amount)                 AS max_amount,
        MIN(transaction_date)       AS first_transaction,
        MAX(transaction_date)       AS last_transaction,
        COUNT(DISTINCT
            merchant_category)      AS unique_categories,
        RANK() OVER (
            ORDER BY COUNT(*) DESC
        )                           AS volume_rank,
        RANK() OVER (
            ORDER BY SUM(amount) DESC
        )                           AS amount_rank
    FROM transactions
    WHERE status = 'completed'
    GROUP BY account_id
)
SELECT
    account_id,
    transaction_count,
    ROUND(total_amount, 2)      AS total_amount,
    ROUND(avg_amount, 2)        AS avg_amount,
    volume_rank,
    amount_rank
FROM account_stats
WHERE volume_rank <= 10
ORDER BY volume_rank;

-- ── TOP ACCOUNTS PER MERCHANT CATEGORY ────────────────────────
-- Highest spending account in each merchant category

WITH category_rankings AS (
    SELECT
        account_id,
        merchant_category,
        SUM(amount)                 AS category_spend,
        RANK() OVER (
            PARTITION BY merchant_category
            ORDER BY SUM(amount) DESC
        )                           AS category_rank
    FROM transactions
    WHERE status = 'completed'
    GROUP BY account_id, merchant_category
)
SELECT
    merchant_category,
    account_id,
    ROUND(category_spend, 2)    AS category_spend,
    category_rank
FROM category_rankings
WHERE category_rank <= 3
ORDER BY merchant_category, category_rank;
