-- =========================================================
-- PROJECT: BANK LOAN ANALYSIS
-- DATABASE: MySQL
-- PURPOSE: End-to-End Bank Loan Data Analysis
-- =========================================================


-- 1. CREATE DATABASE
CREATE DATABASE IF NOT EXISTS BankLoanAnalytics;

USE BankLoanAnalytics;


-- 2. EXPLORE THE DATA
-- Check total records
SELECT COUNT(*) AS total_records
FROM bank_loan;

-- View sample records
SELECT *
FROM bank_loan
LIMIT 10;

-- Check unique loan IDs
SELECT COUNT(DISTINCT id) AS unique_loan_ids
FROM bank_loan;

-- Check available loan statuses
SELECT DISTINCT loan_status
FROM bank_loan;

-- Check available loan purposes
SELECT DISTINCT purpose
FROM bank_loan;


-- 3. DATA QUALITY CHECKS

-- Check duplicate loan IDs
SELECT id, COUNT(*) AS duplicate_count
FROM bank_loan
GROUP BY id
HAVING COUNT(*) > 1;

-- Check missing values
SELECT
    SUM(CASE WHEN id IS NULL THEN 1 ELSE 0 END) AS missing_id,
    SUM(CASE WHEN loan_amount IS NULL THEN 1 ELSE 0 END)
        AS missing_loan_amount,
    SUM(CASE WHEN loan_status IS NULL THEN 1 ELSE 0 END)
        AS missing_loan_status,
    SUM(CASE WHEN issue_date IS NULL THEN 1 ELSE 0 END)
        AS missing_issue_date,
    SUM(CASE WHEN int_rate IS NULL THEN 1 ELSE 0 END)
        AS missing_interest_rate,
    SUM(CASE WHEN total_payment IS NULL THEN 1 ELSE 0 END)
        AS missing_total_payment
FROM bank_loan;

-- Check invalid loan amounts
SELECT *
FROM bank_loan
WHERE loan_amount <= 0;

-- Check negative payments
SELECT *
FROM bank_loan
WHERE total_payment < 0;


-- 4. KEY PERFORMANCE INDICATORS (KPIs)

-- Total loan applications
SELECT COUNT(DISTINCT id) AS total_loan_applications
FROM bank_loan;

-- Total loan amount
SELECT SUM(loan_amount) AS total_loan_amount
FROM bank_loan;

-- Average loan amount
SELECT ROUND(AVG(loan_amount), 2) AS average_loan_amount
FROM bank_loan;

-- Total amount received
SELECT SUM(total_payment) AS total_amount_received
FROM bank_loan;

-- Average interest rate
SELECT ROUND(AVG(int_rate), 2) AS average_interest_rate
FROM bank_loan;

-- Average debt-to-income ratio
SELECT ROUND(AVG(dti), 2) AS average_dti
FROM bank_loan;


-- 5. LOAN STATUS ANALYSIS

-- Loan count and amount by status
SELECT
    loan_status,
    COUNT(*) AS total_loans,
    SUM(loan_amount) AS total_loan_amount,
    SUM(total_payment) AS total_payment_received,
    ROUND(AVG(int_rate), 2) AS average_interest_rate
FROM bank_loan
GROUP BY loan_status
ORDER BY total_loans DESC;

-- Percentage distribution of loan statuses
SELECT
    loan_status,
    COUNT(*) AS loan_count,
    ROUND(
        COUNT(*) * 100.0 /
        NULLIF((SELECT COUNT(*) FROM bank_loan), 0),
        2
    ) AS percentage_of_loans
FROM bank_loan
GROUP BY loan_status
ORDER BY loan_count DESC;


-- 6. GOOD LOAN AND BAD LOAN ANALYSIS
-- Definition:
-- Good loans: Fully Paid
-- Bad loans: Charged Off
-- Current loans remain a separate category.

SELECT
    CASE
        WHEN loan_status = 'Fully Paid' THEN 'Good Loan'
        WHEN loan_status = 'Charged Off' THEN 'Bad Loan'
        WHEN loan_status = 'Current' THEN 'Current Loan'
        ELSE 'Other Status'
    END AS loan_category,
    COUNT(*) AS total_loans,
    SUM(loan_amount) AS total_loan_amount,
    SUM(total_payment) AS total_payment_received
FROM bank_loan
GROUP BY loan_category
ORDER BY total_loans DESC;

-- Good loan percentage
SELECT
    ROUND(
        SUM(CASE WHEN loan_status = 'Fully Paid'
                 THEN 1 ELSE 0 END) * 100.0 /
        NULLIF(COUNT(*), 0),
        2
    ) AS fully_paid_percentage
FROM bank_loan;

-- Charged-off loan percentage
SELECT
    ROUND(
        SUM(CASE WHEN loan_status = 'Charged Off'
                 THEN 1 ELSE 0 END) * 100.0 /
        NULLIF(COUNT(*), 0),
        2
    ) AS charged_off_percentage
FROM bank_loan;


-- 7. MONTHLY LOAN ANALYSIS

-- Monthly applications and loan amounts
SELECT
    DATE_FORMAT(issue_date, '%Y-%m') AS loan_month,
    COUNT(*) AS total_applications,
    SUM(loan_amount) AS total_loan_amount,
    SUM(total_payment) AS total_payment_received
FROM bank_loan
GROUP BY DATE_FORMAT(issue_date, '%Y-%m')
ORDER BY loan_month;

-- Month-over-month application growth
WITH monthly_loans AS (
    SELECT
        DATE_FORMAT(issue_date, '%Y-%m') AS loan_month,
        COUNT(*) AS total_applications
    FROM bank_loan
    GROUP BY DATE_FORMAT(issue_date, '%Y-%m')
),
loan_growth AS (
    SELECT
        loan_month,
        total_applications,
        LAG(total_applications) OVER (
            ORDER BY loan_month
        ) AS previous_month_applications
    FROM monthly_loans
)
SELECT
    loan_month,
    total_applications,
    previous_month_applications,
    ROUND(
        (total_applications - previous_month_applications)
        * 100.0 /
        NULLIF(previous_month_applications, 0),
        2
    ) AS month_over_month_growth_pct
FROM loan_growth
ORDER BY loan_month;


-- 8. LOAN PURPOSE ANALYSIS

SELECT
    purpose,
    COUNT(*) AS total_applications,
    SUM(loan_amount) AS total_loan_amount,
    SUM(total_payment) AS total_payment_received,
    ROUND(AVG(int_rate), 2) AS average_interest_rate
FROM bank_loan
GROUP BY purpose
ORDER BY total_loan_amount DESC;


-- 9. STATE-WISE LOAN ANALYSIS

SELECT
    address_state,
    COUNT(*) AS total_applications,
    SUM(loan_amount) AS total_loan_amount,
    SUM(total_payment) AS total_payment_received,
    ROUND(AVG(int_rate), 2) AS average_interest_rate
FROM bank_loan
GROUP BY address_state
ORDER BY total_loan_amount DESC;

-- Top 10 states by loan amount
SELECT
    address_state,
    COUNT(*) AS total_applications,
    SUM(loan_amount) AS total_loan_amount
FROM bank_loan
GROUP BY address_state
ORDER BY total_loan_amount DESC
LIMIT 10;


-- 10. LOAN GRADE ANALYSIS

SELECT
    grade,
    COUNT(*) AS total_loans,
    SUM(loan_amount) AS total_loan_amount,
    ROUND(AVG(int_rate), 2) AS average_interest_rate,
    SUM(total_payment) AS total_payment_received
FROM bank_loan
GROUP BY grade
ORDER BY grade;


-- 11. HOME OWNERSHIP ANALYSIS

SELECT
    home_ownership,
    COUNT(*) AS total_applications,
    SUM(loan_amount) AS total_loan_amount,
    SUM(total_payment) AS total_payment_received,
    ROUND(AVG(int_rate), 2) AS average_interest_rate
FROM bank_loan
GROUP BY home_ownership
ORDER BY total_applications DESC;


-- 12. INTEREST RATE ANALYSIS

SELECT
    CASE
        WHEN int_rate < 8 THEN 'Below 8%'
        WHEN int_rate < 12 THEN '8% - 12%'
        WHEN int_rate < 16 THEN '12% - 16%'
        WHEN int_rate < 20 THEN '16% - 20%'
        ELSE '20% and Above'
    END AS interest_rate_band,
    COUNT(*) AS total_loans,
    AVG(loan_amount) AS average_loan_amount,
    SUM(total_payment) AS total_payment_received
FROM bank_loan
WHERE int_rate IS NOT NULL
GROUP BY interest_rate_band
ORDER BY MIN(int_rate);


-- 13. DEBT-TO-INCOME (DTI) ANALYSIS

SELECT
    CASE
        WHEN dti < 10 THEN 'Low DTI'
        WHEN dti < 20 THEN 'Moderate DTI'
        WHEN dti < 30 THEN 'High DTI'
        ELSE 'Very High DTI'
    END AS dti_category,
    COUNT(*) AS total_loans,
    ROUND(AVG(loan_amount), 2) AS average_loan_amount,
    ROUND(AVG(int_rate), 2) AS average_interest_rate
FROM bank_loan
WHERE dti IS NOT NULL
GROUP BY dti_category
ORDER BY MIN(dti);


-- 14. CHARGED-OFF LOAN ANALYSIS

SELECT
    grade,
    COUNT(*) AS charged_off_loans,
    SUM(loan_amount) AS charged_off_loan_amount,
    SUM(total_payment) AS payment_received
FROM bank_loan
WHERE loan_status = 'Charged Off'
GROUP BY grade
ORDER BY charged_off_loans DESC;


-- 15. FULLY PAID LOAN ANALYSIS

SELECT
    purpose,
    COUNT(*) AS fully_paid_loans,
    SUM(loan_amount) AS fully_paid_loan_amount,
    SUM(total_payment) AS total_payment_received
FROM bank_loan
WHERE loan_status = 'Fully Paid'
GROUP BY purpose
ORDER BY fully_paid_loans DESC;


-- 16. AVERAGE LOAN AMOUNT BY STATUS

SELECT
    loan_status,
    ROUND(AVG(loan_amount), 2) AS average_loan_amount,
    ROUND(AVG(total_payment), 2) AS average_payment_received
FROM bank_loan
GROUP BY loan_status
ORDER BY average_loan_amount DESC;


-- 17. LOAN AMOUNT DISTRIBUTION

SELECT
    CASE
        WHEN loan_amount < 5000 THEN 'Below 5,000'
        WHEN loan_amount < 10000 THEN '5,000 - 9,999'
        WHEN loan_amount < 20000 THEN '10,000 - 19,999'
        WHEN loan_amount < 30000 THEN '20,000 - 29,999'
        ELSE '30,000 and Above'
    END AS loan_amount_band,
    COUNT(*) AS total_loans,
    SUM(loan_amount) AS total_loan_amount
FROM bank_loan
WHERE loan_amount IS NOT NULL
GROUP BY loan_amount_band
ORDER BY MIN(loan_amount);


-- 18. FINAL SUMMARY BY LOAN STATUS

SELECT
    COUNT(*) AS total_applications,
    SUM(CASE WHEN loan_status = 'Fully Paid'
             THEN 1 ELSE 0 END) AS fully_paid_loans,
    SUM(CASE WHEN loan_status = 'Current'
             THEN 1 ELSE 0 END) AS current_loans,
    SUM(CASE WHEN loan_status = 'Charged Off'
             THEN 1 ELSE 0 END) AS charged_off_loans,
    SUM(loan_amount) AS total_loan_amount,
    SUM(total_payment) AS total_payment_received
FROM bank_loan;
