/* ============================================================
   SaaS Trial Conversion Funnel Analysis
   Dataset : RavenStack (synthetic SaaS dataset)
             Credit: River @ Rivalytics
   Tables  : accounts (500 rows), subscriptions (5,000 rows)
   Tool    : MySQL 8.0
   ============================================================ */


/* ---------- DATABASE SETUP ---------- */

CREATE DATABASE IF NOT EXISTS ravenstack;
USE ravenstack;


/* ---------- TABLE SCHEMA ---------- */
/* Boolean-style columns (is_trial, churn_flag, etc.) are stored
   as VARCHAR(5) to match the source data, which uses the literal
   text values 'True' / 'False'. */

CREATE TABLE accounts (
    account_id      VARCHAR(20) PRIMARY KEY,
    account_name    VARCHAR(50),
    industry        VARCHAR(30),
    country         VARCHAR(5),
    signup_date     DATE,
    referral_source VARCHAR(20),
    plan_tier       VARCHAR(20),
    seats           INT,
    is_trial        VARCHAR(5),
    churn_flag      VARCHAR(5)
);

CREATE TABLE subscriptions (
    subscription_id   VARCHAR(20) PRIMARY KEY,
    account_id        VARCHAR(20),
    start_date        DATE,
    end_date          DATE NULL,
    plan_tier         VARCHAR(20),
    seats             INT,
    mrr_amount        DECIMAL(10,2),
    arr_amount        DECIMAL(10,2),
    is_trial          VARCHAR(5),
    upgrade_flag      VARCHAR(5),
    downgrade_flag    VARCHAR(5),
    churn_flag        VARCHAR(5),
    billing_frequency VARCHAR(20),
    auto_renew_flag   VARCHAR(5),
    FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);


/* ---------- DATA LOAD ---------- */
/* Loaded directly from CSV using LOAD DATA LOCAL INFILE.
   end_date is set to NULL (instead of a blank string) for
   subscriptions that are still active. Paths below are relative
   to this repo's /data folder - clone the repo and run as-is,
   or update the paths to point wherever you've saved the CSVs. */

LOAD DATA LOCAL INFILE 'data/ravenstack_accounts.csv'
INTO TABLE accounts
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(account_id, account_name, industry, country, signup_date, referral_source, plan_tier, seats, is_trial, churn_flag);

LOAD DATA LOCAL INFILE 'data/ravenstack_subscriptions.csv'
INTO TABLE subscriptions
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(subscription_id, account_id, start_date, @end_date, plan_tier, seats, mrr_amount, arr_amount, is_trial, upgrade_flag, downgrade_flag, churn_flag, billing_frequency, auto_renew_flag)
SET end_date = NULLIF(@end_date, '');


/* ---------- VALIDATION ---------- */

SELECT COUNT(*) AS accounts_row_count FROM accounts;          -- expected: 500
SELECT COUNT(*) AS subscriptions_row_count FROM subscriptions; -- expected: 5000
SELECT COUNT(*) AS active_subscriptions FROM subscriptions WHERE end_date IS NULL; -- expected: 4514


/* ============================================================
   ANALYSIS
   ============================================================ */

-- 1. Overall churn rate
SELECT
    churn_flag,
    COUNT(*) AS accounts,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM accounts), 1) AS pct
FROM accounts
GROUP BY churn_flag;

-- 2. Trial-to-paid conversion rate by referral source
SELECT
    referral_source,
    COUNT(*) AS total_accounts,
    SUM(CASE WHEN is_trial = 'False' THEN 1 ELSE 0 END) AS converted_accounts,
    ROUND(100.0 * SUM(CASE WHEN is_trial = 'False' THEN 1 ELSE 0 END) / COUNT(*), 1) AS conversion_rate_pct
FROM accounts
GROUP BY referral_source
ORDER BY conversion_rate_pct DESC;

-- 3. Trial-to-paid conversion rate by plan tier
SELECT
    plan_tier,
    COUNT(*) AS total_accounts,
    SUM(CASE WHEN is_trial = 'False' THEN 1 ELSE 0 END) AS converted_accounts,
    ROUND(100.0 * SUM(CASE WHEN is_trial = 'False' THEN 1 ELSE 0 END) / COUNT(*), 1) AS conversion_rate_pct
FROM accounts
GROUP BY plan_tier
ORDER BY conversion_rate_pct DESC;

-- 4. Revenue comparison: trial vs paid subscriptions
SELECT
    is_trial,
    COUNT(*) AS subscription_count,
    ROUND(AVG(mrr_amount), 2) AS avg_mrr,
    ROUND(SUM(mrr_amount), 2) AS total_mrr
FROM subscriptions
GROUP BY is_trial;

-- 5. Monthly conversion rate trend
SELECT
    DATE_FORMAT(signup_date, '%Y-%m') AS signup_month,
    COUNT(*) AS total_signups,
    SUM(CASE WHEN is_trial = 'False' THEN 1 ELSE 0 END) AS converted,
    ROUND(100.0 * SUM(CASE WHEN is_trial = 'False' THEN 1 ELSE 0 END) / COUNT(*), 1) AS conversion_rate_pct
FROM accounts
GROUP BY signup_month
ORDER BY signup_month;

-- 6. Conversion rate by referral source and plan tier (cross-tab)
SELECT
    referral_source,
    plan_tier,
    COUNT(*) AS total_accounts,
    SUM(CASE WHEN is_trial = 'False' THEN 1 ELSE 0 END) AS converted_accounts,
    ROUND(100.0 * SUM(CASE WHEN is_trial = 'False' THEN 1 ELSE 0 END) / COUNT(*), 1) AS conversion_rate_pct
FROM accounts
GROUP BY referral_source, plan_tier
ORDER BY referral_source, conversion_rate_pct DESC;
