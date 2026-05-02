-- =============================================================
-- null_detection.sql
-- Comprehensive NULL analysis across all critical columns
--
-- Interview relevance: DTCC, Citi, Meta, all DE roles
-- Concepts: COALESCE, CASE, IS NULL, NULL handling patterns
-- =============================================================

-- ── QUICK NULL COUNT PER COLUMN ───────────────────────────────

SELECT
    COUNT(*)                                            AS total_records,
    SUM(CASE WHEN transaction_id   IS NULL THEN 1 END)  AS null_transaction_id,
    SUM(CASE WHEN account_id       IS NULL THEN 1 END)  AS null_account_id,
    SUM(CASE WHEN amount           IS NULL THEN 1 END)  AS null_amount,
    SUM(CASE WHEN transaction_date IS NULL THEN 1 END)  AS null_date,
    SUM(CASE WHEN merchant_name    IS NULL THEN 1 END)  AS null_merchant,
    SUM(CASE WHEN status           IS NULL THEN 1 END)  AS null_status,

    -- Percentage format
    ROUND(SUM(CASE WHEN amount IS NULL THEN 1 END) * 100.0 / COUNT(*), 2)
                                                        AS null_amount_pct
FROM transactions;

-- ── FIND ROWS WITH ANY NULL IN CRITICAL FIELDS ────────────────

SELECT
    transaction_id,
    account_id,
    amount,
    transaction_date,
    status,
    CONCAT_WS(', ',
        CASE WHEN account_id       IS NULL THEN 'account_id'       END,
        CASE WHEN amount           IS NULL THEN 'amount'           END,
        CASE WHEN transaction_date IS NULL THEN 'transaction_date' END,
        CASE WHEN status           IS NULL THEN 'status'           END
    )                                   AS null_fields
FROM transactions
WHERE account_id       IS NULL
   OR amount           IS NULL
   OR transaction_date IS NULL
   OR status           IS NULL;

-- ── NULL-SAFE AGGREGATIONS ────────────────────────────────────
-- Common mistake: AVG(amount) silently excludes NULLs
-- Always check NULL impact on aggregations

SELECT
    COUNT(*)                AS total_rows,
    COUNT(amount)           AS non_null_amounts,      -- excludes NULLs
    COUNT(*) - COUNT(amount) AS null_amounts,
    AVG(amount)             AS avg_amount,            -- NULLs excluded
    SUM(amount)             AS sum_amount,            -- NULLs treated as 0
    SUM(COALESCE(amount,0)) AS sum_with_zeros,        -- explicit zero handling
    MAX(amount)             AS max_amount,
    MIN(amount)             AS min_amount
FROM transactions;

-- ── NULL HANDLING PATTERNS ────────────────────────────────────

SELECT
    transaction_id,
    -- Replace NULL with default
    COALESCE(amount, 0)                     AS amount_or_zero,
    -- Replace NULL with descriptive label
    COALESCE(merchant_name, 'UNKNOWN')      AS merchant_clean,
    -- NULL-safe comparison
    CASE WHEN amount IS NULL THEN 'Missing'
         WHEN amount = 0     THEN 'Zero'
         WHEN amount < 0     THEN 'Negative'
         ELSE                     'Valid'
    END                                     AS amount_status,
    -- NULLIF — convert zero to NULL (opposite of COALESCE)
    NULLIF(amount, 0)                       AS amount_no_zero
FROM transactions;
