
-- Analysis 07: Payment Method Performance
-- Dataset: Olist Brazilian E-Commerce
-- Population: Delivered orders only

WITH payment_summary AS (
    SELECT
        p.payment_type,

        COUNT(DISTINCT p.order_id) AS total_orders,

        COUNT(*) AS payment_records,

        ROUND(
            SUM(p.payment_value),
            2
        ) AS total_payment_value,

        ROUND(
            AVG(p.payment_installments * 1.0),
            2
        ) AS avg_installments

    FROM payments AS p

    INNER JOIN orders AS o
        ON p.order_id = o.order_id

    WHERE o.order_status = 'delivered'

    GROUP BY p.payment_type
)

SELECT
    payment_type,
    total_orders,
    payment_records,
    total_payment_value,
    avg_installments,

    ROUND(
        100.0 * total_payment_value /
        NULLIF(SUM(total_payment_value) OVER (), 0),
        2
    ) AS payment_value_share_pct

FROM payment_summary

ORDER BY total_payment_value DESC;
