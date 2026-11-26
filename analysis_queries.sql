-- ============================================
-- E-Commerce Revenue & Customer Analytics
-- Analysis Queries: analysis_queries.sql
-- ============================================

-- ------------------------------------------------
-- 1. Monthly Revenue Trend
--    Net revenue: completed orders only (refunded and cancelled excluded)
-- ------------------------------------------------
SELECT
    DATE_TRUNC('month', p.payment_date)::date AS month,
    COUNT(DISTINCT p.order_id)                AS orders,
    ROUND(SUM(p.amount), 2)                   AS revenue
FROM payments p
JOIN orders o ON o.order_id = p.order_id
WHERE o.status = 'completed'
GROUP BY 1
ORDER BY 1;


-- ------------------------------------------------
-- 2. RFM Customer Segmentation
--    Recency (days since last order), Frequency (# orders),
--    Monetary (total spend) — each scored 1-4 via NTILE, higher = better
-- ------------------------------------------------
WITH customer_orders AS (
    SELECT
        o.customer_id,
        MAX(o.order_date)                         AS last_order_date,
        COUNT(DISTINCT o.order_id)                AS frequency,
        SUM(p.amount)                             AS monetary
    FROM orders o
    JOIN payments p ON p.order_id = o.order_id
    WHERE o.status = 'completed'
    GROUP BY o.customer_id
),
rfm_scores AS (
    SELECT
        customer_id,
        (SELECT MAX(order_date) FROM orders) - last_order_date AS recency_days,
        frequency,
        monetary,
        NTILE(4) OVER (ORDER BY (SELECT MAX(order_date) FROM orders) - last_order_date DESC) AS recency_score,
        NTILE(4) OVER (ORDER BY frequency ASC)  AS frequency_score,
        NTILE(4) OVER (ORDER BY monetary ASC)   AS monetary_score
    FROM customer_orders
)
SELECT
    customer_id,
    recency_days,
    frequency,
    ROUND(monetary, 2) AS monetary,
    recency_score,
    frequency_score,
    monetary_score,
    (recency_score + frequency_score + monetary_score) AS rfm_total
FROM rfm_scores
ORDER BY rfm_total DESC
LIMIT 20;


-- ------------------------------------------------
-- 3. Cohort Retention Analysis
--    % of each signup-month cohort still ordering in subsequent months
-- ------------------------------------------------
WITH cohort AS (
    SELECT
        customer_id,
        DATE_TRUNC('month', signup_date)::date AS cohort_month
    FROM customers
),
activity AS (
    SELECT
        o.customer_id,
        DATE_TRUNC('month', o.order_date)::date AS order_month
    FROM orders o
    WHERE o.status = 'completed'
),
cohort_activity AS (
    SELECT
        c.cohort_month,
        a.order_month,
        (DATE_PART('year', a.order_month) - DATE_PART('year', c.cohort_month)) * 12
            + (DATE_PART('month', a.order_month) - DATE_PART('month', c.cohort_month)) AS month_number,
        COUNT(DISTINCT a.customer_id) AS active_customers
    FROM cohort c
    JOIN activity a ON a.customer_id = c.customer_id
    GROUP BY 1, 2
),
cohort_size AS (
    SELECT cohort_month, COUNT(*) AS num_customers
    FROM cohort
    GROUP BY 1
)
SELECT
    ca.cohort_month,
    ca.month_number,
    ca.active_customers,
    cs.num_customers,
    ROUND(100.0 * ca.active_customers / cs.num_customers, 1) AS retention_pct
FROM cohort_activity ca
JOIN cohort_size cs ON cs.cohort_month = ca.cohort_month
ORDER BY ca.cohort_month, ca.month_number;


-- ------------------------------------------------
-- 4. Top Products & Categories by Revenue
-- ------------------------------------------------
SELECT
    pr.category,
    pr.product_name,
    SUM(oi.quantity)                          AS units_sold,
    ROUND(SUM(oi.quantity * oi.unit_price),2) AS revenue,
    RANK() OVER (ORDER BY SUM(oi.quantity * oi.unit_price) DESC) AS revenue_rank
FROM order_items oi
JOIN products pr ON pr.product_id = oi.product_id
JOIN orders o ON o.order_id = oi.order_id
WHERE o.status = 'completed'
GROUP BY pr.category, pr.product_name
ORDER BY revenue DESC
LIMIT 10;


-- ------------------------------------------------
-- 5. Average Order Value (AOV) Trend, Month over Month
-- ------------------------------------------------
WITH monthly AS (
    SELECT
        DATE_TRUNC('month', p.payment_date)::date AS month,
        SUM(p.amount) / COUNT(DISTINCT p.order_id) AS aov
    FROM payments p
    JOIN orders o ON o.order_id = p.order_id
    WHERE o.status = 'completed'
    GROUP BY 1
)
SELECT
    month,
    ROUND(aov, 2) AS avg_order_value,
    ROUND(aov - LAG(aov) OVER (ORDER BY month), 2) AS change_vs_prev_month
FROM monthly
ORDER BY month;


-- ------------------------------------------------
-- 6. Customer Lifetime Value (CLV) Estimate
--    Cumulative revenue per customer, ranked
-- ------------------------------------------------
SELECT
    c.customer_id,
    c.full_name,
    c.signup_date,
    COUNT(DISTINCT o.order_id)      AS total_orders,
    ROUND(SUM(p.amount), 2)         AS lifetime_value,
    ROUND(SUM(p.amount) / NULLIF(COUNT(DISTINCT o.order_id),0), 2) AS avg_order_value
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id AND o.status = 'completed'
JOIN payments p ON p.order_id = o.order_id
GROUP BY c.customer_id, c.full_name, c.signup_date
ORDER BY lifetime_value DESC
LIMIT 15;
