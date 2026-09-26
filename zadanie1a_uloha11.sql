SELECT
    c.region,
    SUM(o.sales) AS total_sales,
    AVG(o.discount) AS avg_discount,
    COUNT(o.order_id) AS order_count
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
GROUP BY c.region
ORDER BY c.region;