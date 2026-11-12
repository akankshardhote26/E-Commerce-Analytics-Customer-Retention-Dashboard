
-- Analysis 09: Customer RFM Metrics
-- Dataset: Olist Brazilian E-Commerce
-- Population: Delivered orders only
-- Revenue excludes freight

WITH order_revenue AS (
    SELECT
        order_id,
        SUM(price) AS product_revenue
    FROM order_items
    GROUP BY order_id
),

customer_metrics AS (
    SELECT
        c.customer_unique_id,

        MAX(o.order_purchase_timestamp) AS last_purchase_date,

        COUNT(DISTINCT o.order_id) AS frequency,

        ROUND(SUM(r.product_revenue), 2) AS monetary

    FROM orders AS o

    INNER JOIN customers AS c
        ON o.customer_id = c.customer_id

    INNER JOIN order_revenue AS r
        ON o.order_id = r.order_id

    WHERE o.order_status = 'delivered'
      AND c.customer_unique_id IS NOT NULL

    GROUP BY c.customer_unique_id
),


rfm AS (
    SELECT
        customer_unique_id,

        CAST(
            julianday(DATE('2018-08-30 15:00:37'))
            - julianday(DATE(last_purchase_date))
            AS INTEGER
        ) AS recency_days,

        frequency,
        monetary

    FROM customer_metrics
)

SELECT
    customer_unique_id,
    recency_days,
    frequency,
    monetary

FROM rfm

ORDER BY monetary DESC

LIMIT 10;

