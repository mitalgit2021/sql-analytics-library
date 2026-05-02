-- =============================================================
-- period_over_period.sql
-- Month-over-month and year-over-year growth calculations
--
-- Interview relevance: Capital One, Goldman Sachs, JPMorgan
-- Concepts: LAG, window functions, growth calculations
-- =============================================================

-- ── MONTH-OVER-MONTH REVENUE GROWTH ───────────────────────────

WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', transaction_date)   AS revenue_month,
        SUM(amount)                             AS total_revenue,
        COUNT(*)                                AS transaction_count,
        COUNT(DISTINCT account_id)              AS active_accounts
    FROM transactions
    WHERE status = 'completed'
    GROUP BY DATE_TRUNC('month', transaction_date)
)
SELECT
    revenue_month,
    total_revenue,
    transaction_count,
    active_accounts,

    -- Previous month revenue using LAG
    LAG(total_revenue) OVER (
        ORDER BY revenue_month
    )                                           AS prev_month_revenue,

    -- Month-over-month change
    total_revenue - LAG(total_revenue) OVER (
        ORDER BY revenue_month
    )                                           AS mom_change,

    -- Month-over-month growth percentage
    ROUND(
        (total_revenue - LAG(total_revenue) OVER (ORDER BY revenue_month))
        * 100.0
        / NULLIF(LAG(total_revenue) OVER (ORDER BY revenue_month), 0)
    , 2)                                        AS mom_growth_pct

FROM monthly_revenue
ORDER BY revenue_month;

-- ── YEAR-OVER-YEAR COMPARISON ─────────────────────────────────
-- Compare same month across different years

WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', transaction_date)   AS revenue_month,
        YEAR(transaction_date)                  AS yr,
        MONTH(transaction_date)                 AS mo,
        SUM(amount)                             AS total_revenue
    FROM transactions
    WHERE status = 'completed'
    GROUP BY DATE_TRUNC('month', transaction_date),
             YEAR(transaction_date),
             MONTH(transaction_date)
)
SELECT
    revenue_month,
    total_revenue,
    -- Same month last year
    LAG(total_revenue, 12) OVER (ORDER BY revenue_month) AS same_month_last_year,
    -- YoY growth
    ROUND(
        (total_revenue - LAG(total_revenue, 12) OVER (ORDER BY revenue_month))
        * 100.0
        / NULLIF(LAG(total_revenue, 12) OVER (ORDER BY revenue_month), 0)
    , 2)                                                  AS yoy_growth_pct
FROM monthly_revenue
ORDER BY revenue_month;

-- ── RUNNING TOTAL ─────────────────────────────────────────────

SELECT
    DATE_TRUNC('month', transaction_date)   AS revenue_month,
    SUM(amount)                             AS monthly_revenue,
    SUM(SUM(amount)) OVER (
        ORDER BY DATE_TRUNC('month', transaction_date)
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    )                                       AS cumulative_revenue
FROM transactions
WHERE status = 'completed'
GROUP BY DATE_TRUNC('month', transaction_date)
ORDER BY revenue_month;
