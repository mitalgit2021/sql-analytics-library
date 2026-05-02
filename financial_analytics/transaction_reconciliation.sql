-- =============================================================
-- transaction_reconciliation.sql
-- Source vs destination data reconciliation
-- Critical pattern for FDIC regulatory pipelines
--
-- Interview relevance: DTCC, Citi, Goldman Sachs, JPMorgan
-- Concepts: EXCEPT, LEFT JOIN, FULL OUTER JOIN, reconciliation
-- =============================================================

-- ── CHECK 1: Records in source but NOT in target ───────────────
-- These are missing records — pipeline failed to load them

SELECT
    'MISSING_IN_TARGET'     AS issue_type,
    transaction_id,
    account_id,
    amount,
    transaction_date,
    status
FROM transactions_source

EXCEPT

SELECT
    'MISSING_IN_TARGET',
    transaction_id,
    account_id,
    amount,
    transaction_date,
    status
FROM transactions;

-- ── CHECK 2: Records in target but NOT in source ───────────────
-- These are phantom records — loaded but shouldn't exist

SELECT
    'PHANTOM_IN_TARGET'     AS issue_type,
    transaction_id,
    account_id,
    amount,
    transaction_date,
    status
FROM transactions

EXCEPT

SELECT
    'PHANTOM_IN_TARGET',
    transaction_id,
    account_id,
    amount,
    transaction_date,
    status
FROM transactions_source;

-- ── CHECK 3: Amount mismatches ─────────────────────────────────
-- Same transaction ID but different amounts — data corruption

SELECT
    s.transaction_id,
    s.amount            AS source_amount,
    t.amount            AS target_amount,
    s.amount - t.amount AS discrepancy,
    'AMOUNT_MISMATCH'   AS issue_type
FROM transactions_source s
JOIN transactions t ON s.transaction_id = t.transaction_id
WHERE s.amount <> t.amount;

-- ── FULL RECONCILIATION SUMMARY ───────────────────────────────
-- One query that gives complete picture

WITH source_counts AS (
    SELECT
        COUNT(*)        AS source_records,
        SUM(amount)     AS source_total
    FROM transactions_source
),
target_counts AS (
    SELECT
        COUNT(*)        AS target_records,
        SUM(amount)     AS target_total
    FROM transactions
),
missing AS (
    SELECT COUNT(*) AS missing_count
    FROM (
        SELECT transaction_id FROM transactions_source
        EXCEPT
        SELECT transaction_id FROM transactions
    ) m
),
phantom AS (
    SELECT COUNT(*) AS phantom_count
    FROM (
        SELECT transaction_id FROM transactions
        EXCEPT
        SELECT transaction_id FROM transactions_source
    ) p
),
mismatches AS (
    SELECT COUNT(*) AS mismatch_count
    FROM transactions_source s
    JOIN transactions t ON s.transaction_id = t.transaction_id
    WHERE s.amount <> t.amount
)
SELECT
    s.source_records,
    t.target_records,
    s.source_records - t.target_records     AS record_diff,
    s.source_total,
    t.target_total,
    s.source_total - t.target_total         AS amount_diff,
    mi.missing_count,
    ph.phantom_count,
    mm.mismatch_count,
    CASE
        WHEN s.source_records = t.target_records
         AND s.source_total   = t.target_total
         AND mi.missing_count = 0
         AND ph.phantom_count = 0
         AND mm.mismatch_count = 0 THEN '✅ RECONCILED'
        ELSE '❌ DISCREPANCY FOUND'
    END                                     AS reconciliation_status
FROM source_counts s, target_counts t, missing mi, phantom ph, mismatches mm;

-- =============================================================
-- PRODUCTION NOTE:
-- This reconciliation pattern is used in FDIC regulatory
-- pipelines to ensure 100% data accuracy before submission.
-- Any discrepancy triggers an alert and blocks the load.
-- =============================================================
