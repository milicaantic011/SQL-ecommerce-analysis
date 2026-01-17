-- ========================================
-- 1. REVENUE ANALYSIS
-- ========================================
SELECT 
    STRFTIME('%Y-%m', order_date) AS month,
    COUNT(order_id) AS total_orders,
    ROUND(SUM(total_amount), 2) AS total_revenue,
    ROUND(AVG(total_amount), 2) AS avg_order_value
FROM orders
WHERE status = 'Completed'
GROUP BY STRFTIME('%Y-%m', order_date)
ORDER BY month;


-- ========================================
-- 2. TOP PERFORMING PRODUCTS
-- ========================================
SELECT 
    p.product_name,
    p.category,
    SUM(oi.quantity) AS units_sold,
    ROUND(SUM(oi.quantity * oi.price_per_unit), 2) AS total_revenue,
    ROUND(SUM(oi.quantity * (oi.price_per_unit - p.cost)), 2) AS total_profit,
    ROUND(SUM(oi.quantity * (oi.price_per_unit - p.cost)) / 
          SUM(oi.quantity * oi.price_per_unit) * 100, 2) AS profit_margin_pct
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.status = 'Completed'
GROUP BY p.product_id, p.product_name, p.category
ORDER BY total_profit DESC;


-- ========================================
-- 3. CUSTOMER SEGMENTATION (RFM ANALYSIS)
-- ========================================
WITH customer_metrics AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        JULIANDAY('now') - JULIANDAY(MAX(o.order_date)) AS recency_days,
        COUNT(o.order_id) AS frequency,
        SUM(o.total_amount) AS monetary_value
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    WHERE o.status = 'Completed'
    GROUP BY c.customer_id, c.customer_name
),
rfm_scores AS (
    SELECT 
        customer_id,
        customer_name,
        CAST(recency_days AS INTEGER) AS recency_days,
        frequency,
        ROUND(monetary_value, 2) AS monetary_value,
        NTILE(3) OVER (ORDER BY recency_days ASC) AS r_score,
        NTILE(3) OVER (ORDER BY frequency DESC) AS f_score,
        NTILE(3) OVER (ORDER BY monetary_value DESC) AS m_score
    FROM customer_metrics
)
SELECT 
    customer_name,
    recency_days,
    frequency,
    monetary_value,
    r_score,
    f_score,
    m_score,
    CASE 
        WHEN r_score = 3 AND f_score = 3 AND m_score = 3 THEN 'Champions'
        WHEN r_score >= 2 AND f_score >= 2 AND m_score >= 2 THEN 'Loyal Customers'
        WHEN r_score >= 2 AND f_score <= 2 AND m_score <= 2 THEN 'Potential Loyalists'
        WHEN r_score <= 2 AND f_score >= 2 AND m_score >= 2 THEN 'At Risk'
        WHEN r_score <= 1 AND f_score <= 2 THEN 'Lost Customers'
        ELSE 'New Customers'
    END AS customer_segment
FROM rfm_scores
ORDER BY monetary_value DESC;


-- ========================================
-- 4. PRODUCT CATEGORY PERFORMANCE
-- ========================================
SELECT 
    p.category,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.quantity) AS units_sold,
    ROUND(SUM(oi.quantity * oi.price_per_unit), 2) AS revenue,
    ROUND(AVG(oi.quantity * oi.price_per_unit), 2) AS avg_revenue_per_order,
    ROUND(SUM(oi.quantity * (oi.price_per_unit - p.cost)), 2) AS profit
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.status = 'Completed'
GROUP BY p.category
ORDER BY profit DESC;


-- ========================================
-- 5. CUSTOMER RETENTION ANALYSIS
-- ========================================
WITH customer_order_counts AS (
    SELECT 
        customer_id,
        COUNT(order_id) AS order_count
    FROM orders
    WHERE status = 'Completed'
    GROUP BY customer_id
)
SELECT 
    SUM(CASE WHEN order_count = 1 THEN 1 ELSE 0 END) AS one_time_customers,
    SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END) AS repeat_customers,
    COUNT(*) AS total_customers,
    ROUND(CAST(SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END) AS REAL) / 
          COUNT(*) * 100, 2) AS repeat_rate_pct
FROM customer_order_counts;


-- ========================================
-- 6. SALES TREND ANALYSIS
-- ========================================
WITH monthly_sales AS (
    SELECT 
        STRFTIME('%Y-%m', order_date) AS month,
        SUM(total_amount) AS revenue
    FROM orders
    WHERE status = 'Completed'
    GROUP BY STRFTIME('%Y-%m', order_date)
)
SELECT 
    month,
    ROUND(revenue, 2) AS current_month_revenue,
    LAG(revenue) OVER (ORDER BY month) AS previous_month_revenue,
    ROUND(((revenue - LAG(revenue) OVER (ORDER BY month)) / 
           LAG(revenue) OVER (ORDER BY month) * 100), 2) AS growth_rate_pct
FROM monthly_sales
ORDER BY month;


-- ========================================
-- 7. GEOGRAPHIC ANALYSIS
-- ========================================
SELECT 
    c.city,
    c.country,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    COUNT(o.order_id) AS total_orders,
    ROUND(SUM(o.total_amount), 2) AS total_revenue,
    ROUND(AVG(o.total_amount), 2) AS avg_order_value
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.status = 'Completed'
GROUP BY c.city, c.country
ORDER BY total_revenue DESC;


-- ========================================
-- 8. CANCELLATION RATE ANALYSIS
-- ========================================
SELECT 
    status,
    COUNT(*) AS order_count,
    ROUND(CAST(COUNT(*) AS REAL) * 100.0 / 
          (SELECT COUNT(*) FROM orders), 2) AS percentage
FROM orders
GROUP BY status
ORDER BY order_count DESC;


-- ========================================
-- 9. CUSTOMER LIFETIME VALUE (CLV)
-- ========================================
SELECT 
    ROUND(AVG(customer_value), 2) AS avg_customer_lifetime_value,
    ROUND(MIN(customer_value), 2) AS min_clv,
    ROUND(MAX(customer_value), 2) AS max_clv
FROM (
    SELECT 
        customer_id,
        SUM(total_amount) AS customer_value
    FROM orders
    WHERE status = 'Completed'
    GROUP BY customer_id
);


-- ========================================
-- 10. PRODUCT AFFINITY ANALYSIS
-- ========================================
SELECT 
    p1.product_name AS product_1,
    p2.product_name AS product_2,
    COUNT(*) AS times_bought_together
FROM order_items oi1
JOIN order_items oi2 ON oi1.order_id = oi2.order_id 
    AND oi1.product_id < oi2.product_id
JOIN products p1 ON oi1.product_id = p1.product_id
JOIN products p2 ON oi2.product_id = p2.product_id
GROUP BY p1.product_name, p2.product_name
ORDER BY times_bought_together DESC
LIMIT 10;