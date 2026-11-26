-- ============================================
-- Data quality checks
-- Each check raises an exception if it fails, so
--   psql -v ON_ERROR_STOP=1 -f data_quality_checks.sql
-- exits non-zero and fails CI.
-- ============================================

CREATE OR REPLACE FUNCTION pg_temp.assert_zero(check_name text, bad_rows bigint)
RETURNS void LANGUAGE plpgsql AS $$
BEGIN
    IF bad_rows <> 0 THEN
        RAISE EXCEPTION 'FAILED: % (% rows)', check_name, bad_rows;
    END IF;
    RAISE NOTICE 'passed: %', check_name;
END $$;

-- Completeness: every completed or refunded order has exactly one payment
SELECT pg_temp.assert_zero('completed/refunded orders without a payment', (
    SELECT COUNT(*) FROM orders o
    LEFT JOIN payments p ON p.order_id = o.order_id
    WHERE o.status IN ('completed', 'refunded') AND p.payment_id IS NULL));

SELECT pg_temp.assert_zero('orders with more than one payment', (
    SELECT COUNT(*) FROM (
        SELECT order_id FROM payments GROUP BY order_id HAVING COUNT(*) > 1) x));

-- Validity: cancelled orders should never be paid
SELECT pg_temp.assert_zero('cancelled orders with a payment', (
    SELECT COUNT(*) FROM payments p JOIN orders o ON o.order_id = p.order_id
    WHERE o.status = 'cancelled'));

-- Consistency: payment amount equals the sum of line items
SELECT pg_temp.assert_zero('payments that do not match order line totals', (
    SELECT COUNT(*) FROM payments p
    JOIN (SELECT order_id, SUM(quantity * unit_price) AS total
          FROM order_items GROUP BY order_id) t ON t.order_id = p.order_id
    WHERE ABS(p.amount - t.total) > 0.01));

-- Timeliness: no payment before its order, no order before customer signup
SELECT pg_temp.assert_zero('payments dated before the order', (
    SELECT COUNT(*) FROM payments p JOIN orders o ON o.order_id = p.order_id
    WHERE p.payment_date < o.order_date));

SELECT pg_temp.assert_zero('orders dated before customer signup', (
    SELECT COUNT(*) FROM orders o JOIN customers c ON c.customer_id = o.customer_id
    WHERE o.order_date < c.signup_date));

-- Integrity: every order has at least one line item
SELECT pg_temp.assert_zero('orders without line items', (
    SELECT COUNT(*) FROM orders o
    LEFT JOIN order_items oi ON oi.order_id = o.order_id
    WHERE oi.order_item_id IS NULL));

-- Reconciliation: headline numbers used in the README
SELECT pg_temp.assert_zero('net revenue reconciles to README figure ($107,948)', (
    SELECT CASE WHEN ROUND(SUM(p.amount)) = 107948 THEN 0 ELSE 1 END
    FROM payments p JOIN orders o ON o.order_id = p.order_id
    WHERE o.status = 'completed'));
