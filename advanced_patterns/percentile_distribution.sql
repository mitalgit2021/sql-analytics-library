-- =============================================================
-- percentile_distribution.sql
-- P50, P75, P90, P95, P99 distributions
--
-- Interview relevance: Netflix, Capital One, Meta
-- Concepts: PERCENTILE_CONT, NTILE, histogram buckets
-- =============================================================

-- ── TRANSACTION AMOUNT PERCENTILES ────────────────────────────

SELECT
    COUNT(*)                                    AS total_transactions,
    MIN(amount)                                 AS min_amount,
    PERCENTILE_CONT(0.25) WITHIN GROUP
        (ORDER BY amount)                       AS p25_amount,
    PERCENTILE_CONT(0.50) WITHIN GROUP
        (ORDER BY amount)                       AS p50_median,
    ROUND(AVG(amount), 2)                       AS mean_amount,
    PERCENTILE_CONT(0.75) WITHIN GROUP
        (ORDER BY amount)                       AS p75_amount,
    PERCENTILE_CONT(0.90) WITHIN GROUP
        (ORDER BY amount)                       AS p90_amount,
    PERCENTILE_CONT(0.95) WITHIN GROUP
        (ORDER BY amount)                       AS p95_amount,
    PERCENTILE_CONT(0.99) WITHIN GROUP
        (ORDER BY amount)                       AS p99_amount,
    MAX(amount)                                 AS max_amount
FROM transactions
WHERE status = 'completed'
  AND amount > 0;

-- ── NTILE — Divide into buckets ───────────────────────────────
-- Split transactions into 4 quartiles

SELECT
    transaction_id,
    account_id,
    amount,
    NTILE(4) OVER (ORDER BY amount)             AS quartile,
    NTILE(10) OVER (ORDER BY amount)            AS decile,
    NTILE(100) OVER (ORDER BY amount)           AS percentile_rank
FROM transactions
WHERE status = 'completed'
ORDER BY amount;

-- ── HISTOGRAM — Distribution of amounts ──────────────────────

SELECT
    CASE
        WHEN amount < 100           THEN '0-100'
        WHEN amount < 500           THEN '100-500'
        WHEN amount < 1000          THEN '500-1000'
        WHEN amount < 5000          THEN '1000-5000'
        WHEN amount < 10000         THEN '5000-10000'
        ELSE                             '10000+'
    END                             AS amount_bucket,
    COUNT(*)                        AS transaction_count,
    ROUND(AVG(amount), 2)           AS avg_in_bucket,
    ROUND(COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (), 2)   AS pct_of_total
FROM transactions
WHERE status = 'completed'
GROUP BY
    CASE
        WHEN amount < 100    THEN '0-100'
        WHEN amount < 500    THEN '100-500'
        WHEN amount < 1000   THEN '500-1000'
        WHEN amount < 5000   THEN '1000-5000'
        WHEN amount < 10000  THEN '5000-10000'
        ELSE                      '10000+'
    END
ORDER BY MIN(amount);
