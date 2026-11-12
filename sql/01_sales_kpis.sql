
-- =====================================================
-- Project: E-Commerce Customer Retention Analytics
-- Analysis 01: Sales Performance KPIs
-- Dataset: Olist Brazilian E-Commerce
-- =====================================================

WITH order_revenue AS (
    SELECT
        order_id,
        SUM(price) AS revenue
    FROM order_items
    GROUP BY order_id
)

SELECT
    COUNT(DISTINCT o.order_id) AS total_orders,

    COUNT(DISTINCT c.customer_unique_id)
        AS total_customers,

    ROUND(SUM(r.revenue), 2)
        AS total_revenue,

    ROUND(
        SUM(r.revenue) * 1.0 /
        NULLIF(COUNT(DISTINCT o.order_id), 0),
        2
    ) AS average_order_value

FROM orders AS o

INNER JOIN customers AS c
    ON o.customer_id = c.customer_id

INNER JOIN order_revenue AS r
    ON o.order_id = r.order_id

WHERE o.order_status = 'delivered';
