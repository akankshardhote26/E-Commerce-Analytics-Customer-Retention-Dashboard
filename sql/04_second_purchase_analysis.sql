
-- Analysis 04: Time to Second Purchase
-- Dataset: Olist Brazilian E-Commerce
-- Population: Delivered orders

WITH ranked_orders AS (
    SELECT
        c.customer_unique_id,
        o.order_id,
        o.order_purchase_timestamp,

        ROW_NUMBER() OVER (
            PARTITION BY c.customer_unique_id
            ORDER BY
                o.order_purchase_timestamp,
                o.order_id
        ) AS purchase_number,

        LAG(o.order_purchase_timestamp) OVER (
            PARTITION BY c.customer_unique_id
            ORDER BY
                o.order_purchase_timestamp,
                o.order_id
        ) AS previous_purchase_date

    FROM orders AS o
    INNER JOIN customers AS c
        ON o.customer_id = c.customer_id

    WHERE o.order_status = 'delivered'
      AND c.customer_unique_id IS NOT NULL
      AND o.order_purchase_timestamp IS NOT NULL
),

second_purchases AS (
    SELECT
        customer_unique_id,
        (
            julianday(order_purchase_timestamp)
            - julianday(previous_purchase_date)
        ) AS days_to_second_purchase

    FROM ranked_orders

    WHERE purchase_number = 2
)

SELECT
    COUNT(*) AS repeat_customers,

    ROUND(
        AVG(days_to_second_purchase),
        2
    ) AS avg_days_to_second_purchase,

    ROUND(
        MIN(days_to_second_purchase),
        2
    ) AS min_days_to_second_purchase,

    ROUND(
        MAX(days_to_second_purchase),
        2
    ) AS max_days_to_second_purchase

FROM second_purchases;
