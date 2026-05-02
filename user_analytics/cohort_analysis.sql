-- =============================================================
-- cohort_analysis.sql
-- Monthly cohort retention — tracks how users acquired in
-- a given month behave in subsequent months
--
-- Interview relevance: META, Capital One, Netflix
-- Concepts: Self-join, DATE_TRUNC, cohort methodology
-- =============================================================

-- ── STEP 1: Assign each user to their signup cohort ──────────

WITH user_cohorts AS (
    SELECT
        user_id,
        DATE_TRUNC('month', signup_date)    AS cohort_month
    FROM users
),

-- ── STEP 2: Get all months each user was active ───────────────

user_activity_months AS (
    SELECT
        user_id,
        DATE_TRUNC('month', action_date)    AS activity_month
    FROM user_actions
    GROUP BY user_id, DATE_TRUNC('month', action_date)
),

-- ── STEP 3: Calculate months since cohort signup ──────────────

cohort_activity AS (
    SELECT
        c.cohort_month,
        a.activity_month,
        DATEDIFF('month', c.cohort_month, a.activity_month)  AS months_since_signup,
        COUNT(DISTINCT a.user_id)                             AS active_users
    FROM user_cohorts c
    JOIN user_activity_months a ON c.user_id = a.user_id
    GROUP BY c.cohort_month, a.activity_month,
             DATEDIFF('month', c.cohort_month, a.activity_month)
),

-- ── STEP 4: Get cohort sizes (Month 0 = signup month) ─────────

cohort_sizes AS (
    SELECT
        cohort_month,
        active_users    AS cohort_size
    FROM cohort_activity
    WHERE months_since_signup = 0
)

-- ── STEP 5: Calculate retention rates ─────────────────────────

SELECT
    ca.cohort_month,
    cs.cohort_size,
    ca.months_since_signup,
    ca.active_users,
    ROUND(ca.active_users * 100.0 / cs.cohort_size, 1)  AS retention_pct
FROM cohort_activity ca
JOIN cohort_sizes cs ON ca.cohort_month = cs.cohort_month
ORDER BY ca.cohort_month, ca.months_since_signup;

-- ── PIVOT FORMAT (easier to read) ─────────────────────────────
-- Shows Month 0, Month 1, Month 2... as columns

WITH user_cohorts AS (
    SELECT user_id, DATE_TRUNC('month', signup_date) AS cohort_month
    FROM users
),
cohort_data AS (
    SELECT
        c.cohort_month,
        DATEDIFF('month', c.cohort_month,
            DATE_TRUNC('month', a.action_date))     AS month_number,
        COUNT(DISTINCT a.user_id)                   AS users
    FROM user_cohorts c
    JOIN user_actions a ON c.user_id = a.user_id
    GROUP BY c.cohort_month,
             DATEDIFF('month', c.cohort_month, DATE_TRUNC('month', a.action_date))
)
SELECT
    cohort_month,
    MAX(CASE WHEN month_number = 0 THEN users END)  AS month_0,
    MAX(CASE WHEN month_number = 1 THEN users END)  AS month_1,
    MAX(CASE WHEN month_number = 2 THEN users END)  AS month_2,
    MAX(CASE WHEN month_number = 3 THEN users END)  AS month_3
FROM cohort_data
GROUP BY cohort_month
ORDER BY cohort_month;
