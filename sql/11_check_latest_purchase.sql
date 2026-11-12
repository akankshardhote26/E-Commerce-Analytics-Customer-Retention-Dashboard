SELECT
    MAX(o.order_purchase_timestamp) AS latest_delivered_purchase
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
  AND c.customer_unique_id IS NOT NULL;