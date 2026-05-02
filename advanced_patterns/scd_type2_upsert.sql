-- =============================================================
-- scd_type2_upsert.sql
-- Slowly Changing Dimension Type 2 — full history tracking
-- The most important DW pattern for senior DE interviews
--
-- Interview relevance: ALL companies — especially Goldman, DTCC
-- Concepts: MERGE, valid_from/valid_to, surrogate keys, SCD
-- =============================================================

-- ── WHAT IS SCD TYPE 2? ───────────────────────────────────────
-- When a customer's city changes from 'New York' to 'Chicago':
-- SCD Type 1: Overwrite → lose history
-- SCD Type 2: Add new row → full history preserved ✅
-- SCD Type 3: Add column → only previous value stored

-- Current dim_customer table structure:
-- customer_key (surrogate), customer_id (natural),
-- customer_name, city, is_current, valid_from, valid_to

-- ── STEP 1: See current state ─────────────────────────────────

SELECT
    customer_key,
    customer_id,
    customer_name,
    city,
    is_current,
    valid_from,
    valid_to
FROM dim_customer
ORDER BY customer_id, valid_from;

-- ── STEP 2: MERGE statement — SCD Type 2 upsert ───────────────
-- Snowflake MERGE syntax
-- Handles: new customers, changed attributes, unchanged records

MERGE INTO dim_customer AS target
USING (
    -- Incoming source data (new/updated customer records)
    SELECT
        101         AS customer_id,
        'Alice'     AS customer_name,
        'Chicago'   AS city,        -- Changed from 'New York'
        'US'        AS country,
        CURRENT_DATE AS valid_from
) AS source

ON target.customer_id = source.customer_id
   AND target.is_current = TRUE

-- When record exists AND something changed → expire old row
WHEN MATCHED AND (
    target.city    <> source.city OR
    target.country <> source.country
) THEN UPDATE SET
    target.is_current = FALSE,
    target.valid_to   = DATEADD('day', -1, source.valid_from)

-- When no match → insert new customer
WHEN NOT MATCHED THEN INSERT (
    customer_id,
    customer_name,
    city,
    country,
    is_current,
    valid_from,
    valid_to
)
VALUES (
    source.customer_id,
    source.customer_name,
    source.city,
    source.country,
    TRUE,
    source.valid_from,
    '9999-12-31'
);

-- ── STEP 3: Insert new current row for changed records ────────
-- After expiring old row, insert the new version

INSERT INTO dim_customer (
    customer_id, customer_name, city, country,
    is_current, valid_from, valid_to
)
SELECT
    101, 'Alice', 'Chicago', 'US',
    TRUE, CURRENT_DATE, '9999-12-31'
WHERE EXISTS (
    SELECT 1 FROM dim_customer
    WHERE customer_id = 101
      AND is_current  = FALSE        -- old row was just expired
      AND valid_to    = DATEADD('day', -1, CURRENT_DATE)
);

-- ── STEP 4: Query historical data ─────────────────────────────
-- "What city was customer 101 in on March 1, 2026?"

SELECT
    customer_id,
    customer_name,
    city,
    valid_from,
    valid_to
FROM dim_customer
WHERE customer_id = 101
  AND '2026-03-01' BETWEEN valid_from AND valid_to;

-- ── STEP 5: Current state only ────────────────────────────────

SELECT *
FROM dim_customer
WHERE is_current = TRUE;

-- =============================================================
-- PRODUCTION NOTE:
-- I implemented SCD Type 2 in the Oracle-to-Snowflake migration
-- for customer and product dimensions.
-- This was critical for FDIC audit traceability —
-- regulators need to know what a customer's status was
-- on ANY historical date.
-- =============================================================
