-- =============================================================
-- rolling_averages.sql
-- Calculate rolling/moving averages over time windows
--
-- Interview relevance: META, Capital One, Netflix
-- Concepts: ROWS BETWEEN, RANGE BETWEEN, frame clauses
-- =============================================================

-- ── DAILY ACTION COUNTS (base dataset) ───────────────────────

WITH daily_counts AS (
    SELECT
        action_date,
        COUNT(*)                    AS daily_actions,
        COUNT(DISTINCT user_id)     AS daily_active_users
    FROM user_actions
    GROUP BY action_date
)

-- ── 7-DAY ROLLING AVERAGE ─────────────────────────────────────
SELECT
    action_date,
    daily_actions,
    daily_active_users,

    -- 7-day rolling average (exactly 7 rows)
    ROUND(AVG(daily_actions) OVER (
        ORDER BY action_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ), 2)                                           AS rolling_7d_avg_actions,

    -- 7-day rolling average of DAU
    ROUND(AVG(daily_active_users) OVER (
        ORDER BY action_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ), 2)                                           AS rolling_7d_avg_dau,

    -- 30-day rolling average
    ROUND(AVG(daily_actions) OVER (
        ORDER BY action_date
        ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
    ), 2)                                           AS rolling_30d_avg,

    -- Cumulative total since beginning
    SUM(daily_actions) OVER (
        ORDER BY action_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    )                                               AS cumulative_actions

FROM daily_counts
ORDER BY action_date;

-- =============================================================
-- ROWS vs RANGE — Critical difference (Meta interviews test this!)
--
-- ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
--   → Exactly 7 physical rows regardless of date gaps
--   → If dates are: Jan 1, Jan 2, Jan 5 (gap!)
--     → Jan 5 window includes Jan 1, Jan 2, Jan 5 (3 rows only)
--
-- RANGE BETWEEN INTERVAL '6 DAYS' PRECEDING AND CURRENT ROW
--   → 7 calendar days — handles date gaps correctly
--   → Jan 5 window includes all rows from Dec 30 to Jan 5
--
-- For daily activity metrics: use ROWS (simpler, more predictable)
-- For calendar-based windows: use RANGE with INTERVAL
-- =============================================================

-- ── RANGE-BASED WINDOW (handles date gaps) ────────────────────
WITH daily_counts AS (
    SELECT
        action_date,
        COUNT(*) AS daily_actions
    FROM user_actions
    GROUP BY action_date
)
SELECT
    action_date,
    daily_actions,
    ROUND(AVG(daily_actions) OVER (
        ORDER BY action_date::DATE
        RANGE BETWEEN INTERVAL '6 DAYS' PRECEDING AND CURRENT ROW
    ), 2)   AS rolling_7d_calendar_avg
FROM daily_counts
ORDER BY action_date;
