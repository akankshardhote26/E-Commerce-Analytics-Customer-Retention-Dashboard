
-- Analysis 10: RFM Customer Segmentation
-- Dataset: Olist Brazilian E-Commerce
-- Population: Delivered orders only
-- Reference date: 2018-08-30 15:00:37
-- Revenue: Product price excluding freight
-- Segmentation: Aligned with Power BI RFM scoring

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
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    JOIN order_revenue r
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
),

monetary_ranks AS (
    SELECT
        *,
        DENSE_RANK() OVER (
            ORDER BY monetary ASC
        ) AS monetary_rank
    FROM rfm
),

rank_totals AS (
    SELECT
        *,
        MAX(monetary_rank) OVER () AS total_ranks
    FROM monetary_ranks
),

rfm_scores AS (
    SELECT
        *,
        CASE
            WHEN recency_days <= 30 THEN 5
            WHEN recency_days <= 60 THEN 4
            WHEN recency_days <= 90 THEN 3
            WHEN recency_days <= 180 THEN 2
            ELSE 1
        END AS r_score,

        CASE
            WHEN frequency >= 5 THEN 5
            WHEN frequency = 4 THEN 4
            WHEN frequency = 3 THEN 3
            WHEN frequency = 2 THEN 2
            ELSE 1
        END AS f_score,

        MIN(
            5,
            CAST(
                (monetary_rank * 5.0 / total_ranks)
                + 0.999999999
                AS INTEGER
            )
        ) AS m_score
    FROM rank_totals
),

customer_segments AS (
    SELECT
        *,
        CASE
            WHEN r_score >= 4
                 AND f_score >= 4
                 AND m_score >= 4
                THEN 'Champions'

            WHEN r_score >= 3
                 AND f_score >= 3
                THEN 'Loyal Customers'

            WHEN r_score >= 4
                 AND f_score <= 2
                THEN 'Potential Loyalists'

            WHEN r_score <= 2
                 AND f_score >= 3
                THEN 'At Risk'

            WHEN r_score <= 2
                 AND f_score <= 2
                THEN 'Hibernating'

            ELSE 'Regular Customers'
        END AS customer_segment
    FROM rfm_scores
)

SELECT
    customer_segment,
    COUNT(*) AS customer_count,
    ROUND(SUM(monetary), 2) AS total_revenue,
    ROUND(AVG(monetary), 2) AS avg_customer_value,
    ROUND(AVG(recency_days), 2) AS avg_recency_days,
    ROUND(AVG(frequency * 1.0), 2) AS avg_frequency,
    ROUND(
        100.0 * COUNT(*) /
        NULLIF(SUM(COUNT(*)) OVER (), 0),
        2
    ) AS customer_share_pct
FROM customer_segments
GROUP BY customer_segment
ORDER BY total_revenue DESC;
