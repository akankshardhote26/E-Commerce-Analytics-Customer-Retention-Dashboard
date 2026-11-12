
-- Analysis 02: Monthly Revenue Trends
-- Dataset: Olist Brazilian E-Commerce
-- Revenue: Delivered orders, product price excluding freight

WITH monthly_sales AS (
    SELECT
        strftime('%Y-%m', o.order_purchase_timestamp)
            AS purchase_month,
        COUNT(DISTINCT o.order_id) AS total_orders,
        ROUND(SUM(oi.price), 2) AS monthly_revenue
    FROM orders AS o
    INNER JOIN order_items AS oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY
        strftime('%Y-%m', o.order_purchase_timestamp)
),

revenue_comparison AS (
    SELECT
        purchase_month,
        total_orders,
        monthly_revenue,
        LAG(monthly_revenue) OVER (
            ORDER BY purchase_month
        ) AS previous_month_revenue
    FROM monthly_sales
)

SELECT
    purchase_month,
    total_orders,
    monthly_revenue,
    previous_month_revenue,
    ROUND(
        (
            monthly_revenue - previous_month_revenue
        ) * 100.0 /
        NULLIF(previous_month_revenue, 0),
        2
    ) AS mom_growth_pct
FROM revenue_comparison
ORDER BY purchase_month;
