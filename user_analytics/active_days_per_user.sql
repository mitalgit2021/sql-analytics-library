-- =============================================================
-- active_days_per_user.sql
-- Calculate engagement span for each user
-- Days between first and last activity
--
-- Interview relevance: META (asked in mock session!)
-- Concepts: DATEDIFF, MIN/MAX aggregation, HAVING, CTE
-- =============================================================

-- ── MAIN QUERY: Active days per user ──────────────────────────

WITH user_activity_span AS (
    SELECT
        user_id,
        MIN(action_date)                                    AS first_action,
        MAX(action_date)                                    AS last_action,
        DATEDIFF('day', MIN(action_date), MAX(action_date)) AS active_span_days,
        COUNT(*)                                            AS total_actions,
        COUNT(DISTINCT action_date)                         AS distinct_active_days,
        COUNT(DISTINCT action_type)                         AS unique_action_types
    FROM user_actions
    GROUP BY user_id
)
SELECT
    user_id,
    first_action,
    last_action,
    active_span_days,
    total_actions,
    distinct_active_days,
    unique_action_types
FROM user_activity_span
WHERE active_span_days > 30        -- Only users active for 30+ days
ORDER BY active_span_days DESC;

-- ── ENGAGEMENT CLASSIFICATION ─────────────────────────────────
-- Categorize users by engagement level

WITH user_activity_span AS (
    SELECT
        user_id,
        DATEDIFF('day', MIN(action_date), MAX(action_date)) AS active_span_days,
        COUNT(*)                                            AS total_actions,
        COUNT(DISTINCT action_date)                         AS distinct_active_days
    FROM user_actions
    GROUP BY user_id
)
SELECT
    user_id,
    active_span_days,
    total_actions,
    distinct_active_days,
    CASE
        WHEN active_span_days >= 90 AND total_actions >= 50 THEN 'Power User'
        WHEN active_span_days >= 30 AND total_actions >= 10 THEN 'Regular User'
        WHEN active_span_days >= 7                          THEN 'Casual User'
        ELSE                                                     'One-Time User'
    END                                                     AS user_segment
FROM user_activity_span
ORDER BY active_span_days DESC;

-- =============================================================
-- WHY DATEDIFF INSTEAD OF date subtraction?
--
-- Direct subtraction: MAX(date) - MIN(date)
--   → Returns an INTERVAL in PostgreSQL
--   → Returns a numeric in some MySQL versions
--   → Inconsistent behavior across databases
--
-- DATEDIFF('day', start, end):
--   → Always returns integer number of days
--   → Consistent across Snowflake, SQL Server, Redshift
--   → Explicit and readable
--
-- Always use DATEDIFF for portable, production-safe code!
-- =============================================================
