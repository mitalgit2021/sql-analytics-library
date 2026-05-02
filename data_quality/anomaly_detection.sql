-- =============================================================
-- anomaly_detection.sql
-- Statistical outlier detection using standard deviation
-- Flag transactions that are statistically unusual
--
-- Interview relevance: Capital One, DTCC, Citi, Meta
-- Concepts: STDDEV, Z-score, statistical outliers
-- =============================================================

-- ── Z-SCORE BASED ANOMALY DETECTION ──────────────────────────
-- Flag transactions more than 2 standard deviations from mean
-- This is the statistical definition of an outlier

WITH transaction_stats AS (
    SELECT
        account_id,
        AVG(amount)     AS mean_amount,
        STDDEV(amount)  AS stddev_amount
    FROM transactions
    WHERE status = 'completed'
    GROUP BY account_id
),
transaction_zscores AS (
    SELECT
        t.transaction_id,
        t.account_id,
        t.amount,
        t.transaction_date,
        t.merchant_name,
        s.mean_amount,
        s.stddev_amount,
        -- Z-score = (value - mean) / stddev
        CASE
            WHEN s.stddev_amount = 0 THEN 0
            ELSE (t.amount - s.mean_amount) / s.stddev_amount
        END             AS z_score
    FROM transactions t
    JOIN transaction_stats s ON t.account_id = s.account_id
    WHERE t.status = 'completed'
)
SELECT
    transaction_id,
    account_id,
    amount,
    ROUND(mean_amount, 2)       AS account_avg,
    ROUND(stddev_amount, 2)     AS account_stddev,
    ROUND(z_score, 2)           AS z_score,
    CASE
        WHEN ABS(z_score) > 3   THEN 'EXTREME OUTLIER'
        WHEN ABS(z_score) > 2   THEN 'OUTLIER'
        WHEN ABS(z_score) > 1.5 THEN 'UNUSUAL'
        ELSE                         'NORMAL'
    END                         AS anomaly_level,
    transaction_date,
    merchant_name
FROM transaction_zscores
WHERE ABS(z_score) > 2          -- Only show outliers
ORDER BY ABS(z_score) DESC;

-- ── DATA FRESHNESS CHECK ──────────────────────────────────────
-- How stale is our data? Critical for SLA monitoring

SELECT
    'transactions'              AS table_name,
    MAX(transaction_date)       AS latest_record,
    CURRENT_DATE                AS today,
    DATEDIFF('day',
        MAX(transaction_date),
        CURRENT_DATE)           AS days_since_update,
    CASE
        WHEN DATEDIFF('day', MAX(transaction_date), CURRENT_DATE) = 0
                                THEN '✅ FRESH'
        WHEN DATEDIFF('day', MAX(transaction_date), CURRENT_DATE) <= 1
                                THEN '⚠️ 1 DAY OLD'
        ELSE                         '❌ STALE'
    END                         AS freshness_status
FROM transactions;
