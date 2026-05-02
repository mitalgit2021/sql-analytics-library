-- =============================================================
-- create_tables.sql
-- Sample tables used across the SQL Analytics Library
-- Run this first before executing any other queries
-- Compatible with: Snowflake, PostgreSQL, Redshift
-- =============================================================

-- ── USER ANALYTICS TABLES ─────────────────────────────────────

CREATE TABLE IF NOT EXISTS users (
    user_id       INT PRIMARY KEY,
    username      VARCHAR(100),
    email         VARCHAR(200),
    signup_date   DATE,
    country       VARCHAR(50),
    plan_type     VARCHAR(20)   -- 'free', 'premium', 'enterprise'
);

CREATE TABLE IF NOT EXISTS user_actions (
    action_id     INT PRIMARY KEY,
    user_id       INT,
    action_type   VARCHAR(50),  -- 'like', 'comment', 'share', 'view', 'purchase'
    action_date   DATE,
    action_time   TIME,
    session_id    VARCHAR(100)
);

-- ── FINANCIAL TABLES ──────────────────────────────────────────

CREATE TABLE IF NOT EXISTS accounts (
    account_id    INT PRIMARY KEY,
    user_id       INT,
    account_type  VARCHAR(50),  -- 'checking', 'savings', 'investment'
    opened_date   DATE,
    status        VARCHAR(20)   -- 'active', 'closed', 'suspended'
);

CREATE TABLE IF NOT EXISTS transactions (
    transaction_id   INT PRIMARY KEY,
    account_id       INT,
    amount           DECIMAL(15,2),
    transaction_date DATE,
    transaction_type VARCHAR(50), -- 'debit', 'credit', 'transfer', 'wire'
    merchant_name    VARCHAR(200),
    merchant_category VARCHAR(50),
    country          VARCHAR(50),
    status           VARCHAR(20)  -- 'completed', 'pending', 'failed'
);

-- Source system transactions (for reconciliation)
CREATE TABLE IF NOT EXISTS transactions_source (
    transaction_id   INT PRIMARY KEY,
    account_id       INT,
    amount           DECIMAL(15,2),
    transaction_date DATE,
    status           VARCHAR(20)
);

-- ── DIMENSION TABLES ──────────────────────────────────────────

CREATE TABLE IF NOT EXISTS dim_customer (
    customer_key     INT PRIMARY KEY,       -- surrogate key
    customer_id      INT,                   -- natural key
    customer_name    VARCHAR(200),
    city             VARCHAR(100),
    state            VARCHAR(50),
    country          VARCHAR(50),
    is_current       BOOLEAN DEFAULT TRUE,
    valid_from       DATE,
    valid_to         DATE DEFAULT '9999-12-31'
);

-- ── SAMPLE DATA ───────────────────────────────────────────────

INSERT INTO users VALUES
(1, 'alice',   'alice@example.com',   '2025-01-15', 'US',  'premium'),
(2, 'bob',     'bob@example.com',     '2025-02-01', 'US',  'free'),
(3, 'carol',   'carol@example.com',   '2025-01-20', 'UK',  'enterprise'),
(4, 'dave',    'dave@example.com',    '2025-03-10', 'US',  'free'),
(5, 'eve',     'eve@example.com',     '2025-01-05', 'CA',  'premium'),
(6, 'frank',   'frank@example.com',   '2025-04-01', 'US',  'free'),
(7, 'grace',   'grace@example.com',   '2025-02-15', 'AU',  'enterprise'),
(8, 'henry',   'henry@example.com',   '2025-01-30', 'US',  'premium');

INSERT INTO user_actions VALUES
(1,  1, 'like',     '2026-01-05', '10:00:00', 'S001'),
(2,  1, 'comment',  '2026-01-06', '11:00:00', 'S001'),
(3,  1, 'share',    '2026-02-10', '14:00:00', 'S002'),
(4,  2, 'like',     '2026-01-08', '09:00:00', 'S003'),
(5,  2, 'view',     '2026-01-15', '15:00:00', 'S003'),
(6,  3, 'purchase', '2026-01-10', '12:00:00', 'S004'),
(7,  3, 'like',     '2026-02-05', '13:00:00', 'S005'),
(8,  3, 'comment',  '2026-03-01', '10:00:00', 'S006'),
(9,  4, 'view',     '2026-01-20', '16:00:00', 'S007'),
(10, 5, 'like',     '2026-01-25', '11:00:00', 'S008'),
(11, 5, 'share',    '2026-02-28', '09:00:00', 'S009'),
(12, 6, 'view',     '2026-02-01', '14:00:00', 'S010'),
(13, 1, 'like',     '2026-03-15', '10:00:00', 'S011'),
(14, 2, 'comment',  '2026-03-20', '11:00:00', 'S012'),
(15, 7, 'purchase', '2026-01-12', '15:00:00', 'S013');

INSERT INTO transactions VALUES
(1,  1001, 125.50,    '2026-04-01', 'debit',  'Amazon',        'E-COMMERCE', 'US', 'completed'),
(2,  1001, 47000.00,  '2026-04-01', 'wire',   'Wire Transfer', 'WIRE',       'UK', 'completed'),
(3,  1002, 85.20,     '2026-04-02', 'debit',  'Starbucks',     'FOOD',       'US', 'completed'),
(4,  1002, 1500.00,   '2026-04-02', 'debit',  'Best Buy',      'RETAIL',     'US', 'completed'),
(5,  1003, 250000.00, '2026-04-03', 'wire',   'Wire Transfer', 'WIRE',       'SG', 'pending'),
(6,  1001, 99.99,     '2026-04-03', 'debit',  'Netflix',       'SUBSCR',     'US', 'completed'),
(7,  1004, 45.00,     '2026-04-04', 'debit',  'Uber',          'TRANSPORT',  'US', 'completed'),
(8,  1002, 8500.00,   '2026-04-04', 'debit',  'Casino',        'GAMBLING',   'MO', 'completed'),
(9,  1003, 320.00,    '2026-04-05', 'debit',  'Delta Airlines','TRAVEL',     'US', 'completed'),
(10, 1001, 15.99,     '2026-04-05', 'debit',  'Spotify',       'SUBSCR',     'US', 'completed'),
(11, 1005, 12000.00,  '2026-04-06', 'wire',   'ATM Withdrawal','CASH',       'MX', 'completed'),
(12, 1004, 89.50,     '2026-04-06', 'debit',  'CVS Pharmacy',  'HEALTHCARE', 'US', 'completed'),
(13, 1003, 500.00,    '2026-04-07', 'debit',  'Apple Store',   'ELECTRONICS','US', 'completed'),
(14, 1002, 95000.00,  '2026-04-07', 'wire',   'Wire Transfer', 'WIRE',       'CH', 'pending'),
(15, 1005, 35.00,     '2026-04-08', 'debit',  'McDonald''s',   'FOOD',       'US', 'completed');

-- Source system (slightly different — for reconciliation demo)
INSERT INTO transactions_source VALUES
(1,  1001, 125.50,    '2026-04-01', 'completed'),
(2,  1001, 47000.00,  '2026-04-01', 'completed'),
(3,  1002, 85.20,     '2026-04-02', 'completed'),
(4,  1002, 1500.00,   '2026-04-02', 'completed'),
(5,  1003, 250000.00, '2026-04-03', 'pending'),
-- Transaction 16 exists in source but NOT in target (reconciliation gap)
(16, 1006, 750.00,    '2026-04-08', 'completed');
