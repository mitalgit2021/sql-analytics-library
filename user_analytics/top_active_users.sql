-- =============================================================
-- top_active_users.sql
-- Find the top N most active users by total action count
--
-- Interview relevance: META (asked in almost every screen)
-- Concepts: DENSE_RANK, window functions, PARTITION BY
-- =============================================================

-- ── APPROACH 1: Window Function (PREFERRED) ───────────────────
-- Scans the table once — efficient at scale
-- DENSE_RANK handles ties correctly (no skipped ranks)

WITH user_action_counts AS (
    SELECT
        user_id,
        COUNT(*)                                    AS total_actions,
        COUNT(DISTINCT action_date)                 AS active_days,
        COUNT(DISTINCT action_type)                 AS unique_action_types,
        MIN(action_date)                            AS first_action,
        MAX(action_date)                            AS last_action,
        DENSE_RANK() OVER (ORDER BY COUNT(*) DESC)  AS activity_rank
    FROM user_actions
    GROUP BY user_id
)
SELECT
    user_id,
    total_actions,
    active_days,
    unique_action_types,
    first_action,
    last_action,
    activity_rank
FROM user_action_counts
WHERE activity_rank <= 5           -- Change to get Top N
ORDER BY activity_rank;

-- ── APPROACH 2: Simple TOP N (Alternative) ────────────────────
-- Simpler but loses rank information and tie handling

SELECT
    user_id,
    COUNT(*) AS total_actions
FROM user_actions
GROUP BY user_id
ORDER BY total_actions DESC
LIMIT 5;

-- ── APPROACH 3: Top N Per Day (Meta-style variation) ──────────
-- Find top 3 users by action count FOR EACH DAY
-- This is a very common Meta interview question

WITH daily_counts AS (
    SELECT
        user_id,
        action_date,
        COUNT(*)                                              AS daily_actions,
        DENSE_RANK() OVER (
            PARTITION BY action_date                          -- reset rank for each day
            ORDER BY COUNT(*) DESC
        )                                                     AS daily_rank
    FROM user_actions
    GROUP BY user_id, action_date
)
SELECT
    action_date,
    user_id,
    daily_actions,
    daily_rank
FROM daily_counts
WHERE daily_rank <= 3
ORDER BY action_date, daily_rank;

-- =============================================================
-- WHY DENSE_RANK OVER RANK?
-- Given actions: 10, 10, 8
-- RANK()       → 1, 1, 3   (skips 2 — like sports competitions)
-- DENSE_RANK() → 1, 1, 2   (no gaps — correct for "top N" problems)
-- ROW_NUMBER() → 1, 2, 3   (always unique — use for deduplication)
-- =============================================================
