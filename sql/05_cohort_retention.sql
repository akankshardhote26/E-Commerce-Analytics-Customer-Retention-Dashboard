
-- Analysis 05: Monthly Customer Cohort Retention
-- Dataset: Olist Brazilian E-Commerce
-- Population: Delivered orders only

WITH customer_purchases AS (
    SELECT DISTINCT
        c.customer_unique_id,
        strftime('%Y-%m', o.order_purchase_timestamp)
            AS purchase_month

    FROM orders AS o
    INNER JOIN customers AS c
        ON o.customer_id = c.customer_id

    WHERE o.order_status = 'delivered'
      AND c.customer_unique_id IS NOT NULL
      AND o.order_purchase_timestamp IS NOT NULL
),

customer_cohorts AS (
    SELECT
        customer_unique_id,
        purchase_month,
        MIN(purchase_month) OVER (
            PARTITION BY customer_unique_id
        ) AS cohort_month

    FROM customer_purchases
),

cohort_activity AS (
    SELECT
        cohort_month,

        (
            (
                CAST(SUBSTR(purchase_month, 1, 4) AS INTEGER)
                - CAST(SUBSTR(cohort_month, 1, 4) AS INTEGER)
            ) * 12
            +
            (
                CAST(SUBSTR(purchase_month, 6, 2) AS INTEGER)
                - CAST(SUBSTR(cohort_month, 6, 2) AS INTEGER)
            )
        ) AS cohort_index,

        COUNT(DISTINCT customer_unique_id)
            AS active_customers

    FROM customer_cohorts
    GROUP BY cohort_month, cohort_index
),

cohort_sizes AS (
    SELECT
        cohort_month,
        active_customers AS cohort_size

    FROM cohort_activity
    WHERE cohort_index = 0
)

SELECT
    a.cohort_month,
    a.cohort_index,
    a.active_customers,
    s.cohort_size,

    ROUND(
        100.0 * a.active_customers /
        NULLIF(s.cohort_size, 0),
        2
    ) AS retention_rate_pct

FROM cohort_activity AS a
INNER JOIN cohort_sizes AS s
    ON a.cohort_month = s.cohort_month

ORDER BY
    a.cohort_month,
    a.cohort_index;
