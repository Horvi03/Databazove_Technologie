SELECT
    c.customer_name,
    o.order_id,
    o.sales
FROM customers c
FULL OUTER JOIN orders o
    ON c.customer_id = o.customer_id
