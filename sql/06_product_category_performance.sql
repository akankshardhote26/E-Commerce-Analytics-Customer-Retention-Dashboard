
-- Analysis 06: Product Category Performance
-- Dataset: Olist Brazilian E-Commerce
-- Revenue: Delivered orders, excluding freight

WITH category_sales AS (
    SELECT
        COALESCE(
            t.product_category_name_english,
            p.product_category_name,
            'Unknown'
        ) AS product_category,

        COUNT(DISTINCT o.order_id) AS total_orders,
        COUNT(*) AS items_sold,
        ROUND(SUM(oi.price), 2) AS total_revenue

    FROM order_items AS oi

    INNER JOIN orders AS o
        ON oi.order_id = o.order_id

    LEFT JOIN products AS p
        ON oi.product_id = p.product_id

    LEFT JOIN category_translation AS t
        ON p.product_category_name =
           t.product_category_name

    WHERE o.order_status = 'delivered'

    GROUP BY 1
),

ranked_categories AS (
    SELECT
        product_category,
        total_orders,
        items_sold,
        total_revenue,

        DENSE_RANK() OVER (
            ORDER BY total_revenue DESC
        ) AS revenue_rank,

        ROUND(
            100.0 * total_revenue /
            NULLIF(SUM(total_revenue) OVER (), 0),
            2
        ) AS revenue_contribution_pct

    FROM category_sales
)

SELECT *
FROM ranked_categories
ORDER BY total_revenue DESC
LIMIT 10;
