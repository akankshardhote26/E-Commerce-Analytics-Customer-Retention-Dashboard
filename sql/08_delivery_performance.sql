
-- Analysis 08: Delivery Performance by State
-- Dataset: Olist Brazilian E-Commerce
-- Population: Delivered orders with valid delivery dates

WITH delivery_data AS (
    SELECT
        o.order_id,
        c.customer_state,

        julianday(o.order_delivered_customer_date)
        - julianday(o.order_purchase_timestamp)
            AS delivery_days,

        CASE
            WHEN julianday(o.order_delivered_customer_date)
                 <= julianday(o.order_estimated_delivery_date)
            THEN 1
            ELSE 0
        END AS on_time_flag,

        CASE
            WHEN julianday(o.order_delivered_customer_date)
                 > julianday(o.order_estimated_delivery_date)
            THEN
                julianday(o.order_delivered_customer_date)
                - julianday(o.order_estimated_delivery_date)
            ELSE 0
        END AS late_days

    FROM orders AS o

    INNER JOIN customers AS c
        ON o.customer_id = c.customer_id

    WHERE o.order_status = 'delivered'
      AND o.order_purchase_timestamp IS NOT NULL
      AND o.order_delivered_customer_date IS NOT NULL
      AND o.order_estimated_delivery_date IS NOT NULL
)

SELECT
    customer_state,

    COUNT(*) AS delivered_orders,

    ROUND(AVG(delivery_days), 2)
        AS avg_delivery_days,

    ROUND(
        100.0 * SUM(on_time_flag) / COUNT(*),
        2
    ) AS on_time_delivery_pct,

    ROUND(AVG(late_days), 2)
        AS avg_late_days_all_orders

FROM delivery_data

GROUP BY customer_state

ORDER BY delivered_orders DESC;
