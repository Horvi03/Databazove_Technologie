SELECT 
    c.region, 
    SUM(o.sales) as total_sales
FROM orders o
LEFT JOIN customers c
    ON c.customer_id = o.customer_id
GROUP BY c.region
ORDER BY c.region;