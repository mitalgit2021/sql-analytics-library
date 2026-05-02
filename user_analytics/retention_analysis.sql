-- =============================================================
-- retention_analysis.sql
-- Find users active in one period but NOT another
-- Classic retention / churn analysis pattern
--
-- Interview relevance: META (asked very frequently)
-- Concepts: EXCEPT, NOT EXISTS, NOT IN, date truncation
-- =============================================================

-- ── APPROACH 1: EXCEPT (Cleanest — recommended) ───────────────
-- Users active in January 2026 but NOT in February 2026

SELECT DISTINCT user_id
FROM user_actions
WHERE DATE_TRUNC('month', action_date) = '2026-01-01'

EXCEPT

SELECT DISTINCT user_id
FROM user_actions
WHERE DATE_TRUNC('month', action_date) = '2026-02-01';

-- ── APPROACH 2: NOT EXISTS (Most flexible) ────────────────────
-- Use when you need extra columns or more complex conditions

SELECT DISTINCT
    a.user_id,
    MIN(a.action_date) AS first_jan_action
FROM user_actions a
WHERE DATE_TRUNC('month', a.action_date) = '2026-01-01'
  AND NOT EXISTS (
      SELECT 1
      FROM user_actions b
      WHERE b.user_id = a.user_id
        AND DATE_TRUNC('month', b.action_date) = '2026-02-01'
  )
GROUP BY a.user_id;

-- ── APPROACH 3: LEFT JOIN (Visual — easy to understand) ───────

SELECT DISTINCT jan.user_id
FROM (
    SELECT DISTINCT user_id
    FROM user_actions
    WHERE DATE_TRUNC('month', action_date) = '2026-01-01'
) jan
LEFT JOIN (
    SELECT DISTINCT user_id
    FROM user_actions
    WHERE DATE_TRUNC('month', action_date) = '2026-02-01'
) feb ON jan.user_id = feb.user_id
WHERE feb.user_id IS NULL;     -- NULL means no match in February

-- ── RETENTION RATE CALCULATION ────────────────────────────────
-- What % of January users came back in February?

WITH jan_users AS (
    SELECT COUNT(DISTINCT user_id) AS jan_count
    FROM user_actions
    WHERE DATE_TRUNC('month', action_date) = '2026-01-01'
),
retained_users AS (
    SELECT COUNT(DISTINCT user_id) AS retained_count
    FROM user_actions
    WHERE DATE_TRUNC('month', action_date) = '2026-01-01'
      AND user_id IN (
          SELECT DISTINCT user_id FROM user_actions
          WHERE DATE_TRUNC('month', action_date) = '2026-02-01'
      )
)
SELECT
    j.jan_count                                          AS jan_users,
    r.retained_count                                     AS retained_in_feb,
    j.jan_count - r.retained_count                       AS churned,
    ROUND(r.retained_count * 100.0 / j.jan_count, 2)    AS retention_rate_pct
FROM jan_users j, retained_users r;

-- =============================================================
-- PRODUCTION NOTE:
-- Always add a YEAR filter in production!
-- Without it, Jan 2025 users would mix with Jan 2026 users.
-- Example:
--   WHERE YEAR(action_date) = 2026
--   AND MONTH(action_date) = 1
-- =============================================================
