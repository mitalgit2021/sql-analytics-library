# 📊 SQL Analytics Library

A curated collection of **20+ production-quality SQL queries** for data engineering and analytics — 
built from real-world experience designing data pipelines for financial services and healthcare platforms.

Every query in this library is:
- ✅ **Production-tested** — based on patterns used in FDIC regulatory pipelines and enterprise data warehouses
- ✅ **Snowflake-compatible** — written for modern cloud data warehouses
- ✅ **Fully commented** — explains the WHY, not just the HOW
- ✅ **Edge-case aware** — handles NULLs, ties, and boundary conditions correctly

---

## 📁 Library Structure

| Folder | Queries | Use Cases |
|--------|---------|-----------|
| [user_analytics/](user_analytics/) | 6 queries | Retention, cohort, rolling metrics, top users |
| [financial_analytics/](financial_analytics/) | 6 queries | Revenue, growth, rankings, reconciliation |
| [data_quality/](data_quality/) | 5 queries | NULLs, duplicates, integrity, anomaly detection |
| [advanced_patterns/](advanced_patterns/) | 5 queries | SCD Type 2, funnel, pivoting, gap analysis |

---

## 🚀 Quick Start

### 1. Create sample tables
```sql
-- Run this first to create all sample tables
\i sample_data/create_tables.sql
```

### 2. Run any query
```sql
-- Example: Find top 5 most active users
\i user_analytics/top_active_users.sql
```

---

## 📋 Query Index

### 👤 User Analytics
| File | Description | Key Concepts |
|------|-------------|--------------|
| [top_active_users.sql](user_analytics/top_active_users.sql) | Top N users by activity count | DENSE_RANK, window functions |
| [retention_analysis.sql](user_analytics/retention_analysis.sql) | Users active in Month A but not Month B | EXCEPT, NOT EXISTS |
| [cohort_analysis.sql](user_analytics/cohort_analysis.sql) | Monthly cohort retention rates | Self-join, DATE_TRUNC |
| [rolling_averages.sql](user_analytics/rolling_averages.sql) | 7-day rolling average of daily activity | ROWS BETWEEN frame clause |
| [user_engagement_funnel.sql](user_analytics/user_engagement_funnel.sql) | Step-by-step funnel drop-off | CASE, COUNT DISTINCT |
| [active_days_per_user.sql](user_analytics/active_days_per_user.sql) | Days between first and last activity | DATEDIFF, aggregation |

### 💰 Financial Analytics
| File | Description | Key Concepts |
|------|-------------|--------------|
| [top_accounts_by_volume.sql](financial_analytics/top_accounts_by_volume.sql) | Top accounts by transaction volume | RANK, GROUP BY |
| [running_totals.sql](financial_analytics/running_totals.sql) | Cumulative revenue by date | SUM() OVER (ORDER BY) |
| [period_over_period.sql](financial_analytics/period_over_period.sql) | Month-over-month growth % | LAG, window functions |
| [daily_revenue_summary.sql](financial_analytics/daily_revenue_summary.sql) | Daily revenue with rolling avg | AVG() OVER ROWS BETWEEN |
| [transaction_reconciliation.sql](financial_analytics/transaction_reconciliation.sql) | Source vs destination reconciliation | LEFT JOIN, EXCEPT |
| [highest_value_transactions.sql](financial_analytics/highest_value_transactions.sql) | Top transactions per account | DENSE_RANK PARTITION BY |

### ✅ Data Quality
| File | Description | Key Concepts |
|------|-------------|--------------|
| [null_detection.sql](data_quality/null_detection.sql) | Find NULLs across all critical columns | CASE, COALESCE |
| [duplicate_detection.sql](data_quality/duplicate_detection.sql) | Detect duplicate records by key | COUNT, HAVING, ROW_NUMBER |
| [referential_integrity.sql](data_quality/referential_integrity.sql) | Find orphaned records | LEFT JOIN, IS NULL |
| [data_freshness_check.sql](data_quality/data_freshness_check.sql) | Check how recently data was updated | MAX, DATEDIFF |
| [anomaly_detection.sql](data_quality/anomaly_detection.sql) | Flag statistical outliers | STDDEV, mean ± 2σ |

### ⚡ Advanced Patterns
| File | Description | Key Concepts |
|------|-------------|--------------|
| [scd_type2_upsert.sql](advanced_patterns/scd_type2_upsert.sql) | Slowly Changing Dimension Type 2 | MERGE, valid_from/valid_to |
| [pivot_unpivot.sql](advanced_patterns/pivot_unpivot.sql) | Pivot rows to columns and back | CASE pivot pattern |
| [gaps_and_islands.sql](advanced_patterns/gaps_and_islands.sql) | Find consecutive sequences and gaps | ROW_NUMBER, GROUP BY |
| [recursive_hierarchy.sql](advanced_patterns/recursive_hierarchy.sql) | Walk org charts and parent-child trees | Recursive CTE |
| [percentile_distribution.sql](advanced_patterns/percentile_distribution.sql) | P50, P75, P90, P99 distributions | PERCENTILE_CONT, NTILE |

---

## 💼 Interview Relevance

These queries directly map to common interview questions at:

| Company | Most Relevant Queries |
|---------|----------------------|
| **Meta** | retention_analysis, rolling_averages, cohort_analysis, top_active_users |
| **Capital One** | period_over_period, running_totals, anomaly_detection |
| **Goldman Sachs** | transaction_reconciliation, highest_value_transactions, scd_type2 |
| **DTCC / Citi** | duplicate_detection, referential_integrity, transaction_reconciliation |
| **Netflix** | cohort_analysis, rolling_averages, percentile_distribution |

---

## 🛠️ Compatibility

All queries written for **Snowflake SQL** with notes for:
- PostgreSQL / Redshift equivalents
- SQL Server / Azure Synapse variations
- MySQL / BigQuery adaptations

---

## 🔗 Related Projects

- [Intelligent ETL Pipeline with AI](https://github.com/mitalgit2021/intelligent-etl-pipeline)
- [dbt Data Warehouse Design](https://github.com/mitalgit2021/dbt-warehouse-design)
- [Data Quality Framework](https://github.com/mitalgit2021/data-quality-framework)

---
*Built by Mitalkumar Mehta — Senior Data Engineer*  
*LinkedIn: linkedin.com/in/mmehta24 | GitHub: github.com/mitalgit2021*
