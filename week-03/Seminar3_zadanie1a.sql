--Uloha 1
CREATE VIEW high_value_sales AS
SELECT c.customer_id,
       c.customer_name,
       SUM(o.sales) AS total_sales
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING SUM(o.sales) > 2000;

--Uloha 2
CREATE VIEW regional_monthly_sales AS
SELECT
    c.region,
    DATE_TRUNC('month', o.order_date) AS month,
    SUM(o.sales) AS monthly_sales
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY
    c.region,
    DATE_TRUNC('month', o.order_date);

--Uloha 3
CREATE VIEW analyst_orders AS
SELECT order_id,
       customer_id,
       product_id,
       sales,
       quantity,
       discount
FROM orders;

--Uloha 4
CREATE INDEX idx_orders_customer_id
ON orders(customer_id);
SELECT *
FROM orders
WHERE customer_id = 'C001';

--Uloha 5
CREATE INDEX idx_orders_customer_id
ON orders(order_date);
SELECT
    DATE_TRUNC('month', order_date) AS month,
    SUM(sales) AS sum
FROM orders
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY month ASC;

--Uloha 6
CREATE INDEX idx_orders_region_category
ON orders(customer_id, order_date);

SELECT
    o.customer_id,
    o.order_date,
    o.profit,
    c.region
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
WHERE c.region = 'West'
  AND o.order_date >= '2024-01-01';

--Uloha 7
EXPLAIN ANALYZE
SELECT *
FROM orders
WHERE customer_id = 'C001';

--Priprava databazy retail_sales
CREATE DATABASE retail_sales;
CREATE TABLE orders (
    order_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20) NOT NULL,
    product_id VARCHAR(20) NOT NULL,
    order_date DATE NOT NULL,
    region VARCHAR(20) NOT NULL,
    category VARCHAR(50) NOT NULL,
    ship_mode VARCHAR(30) NOT NULL,
    sales DECIMAL(10,2) NOT NULL,
    profit DECIMAL(10,2) NOT NULL
);
ALTER DATABASE retail_sales
SET datestyle TO 'ISO, MDY';
SELECT * FROM orders;

--Uloha 8
CREATE OR REPLACE PROCEDURE get_customer_sales(p_customer_id VARCHAR(20))
LANGUAGE plpgsql
AS $$
DECLARE
    total_sales DECIMAL(10,2);
BEGIN
    SELECT COALESCE(SUM(sales), 0)
    INTO total_sales
    FROM orders
    WHERE customer_id = p_customer_id;

    RAISE NOTICE 'Customer: %, Total sales: %',
        p_customer_id, total_sales;
END;
$$;
CALL get_customer_sales('C001');

--Uloha 9
CREATE OR REPLACE PROCEDURE apply_regional_discount(region_name VARCHAR(20), discount_rate DECIMAL(5,4))
LANGUAGE plpgsql
AS $$
DECLARE
    total_sales DECIMAL(10,2);
BEGIN
    UPDATE orders 
    SET sales = sales * (1-discount_rate)
    WHERE region = region_name;
    RAISE NOTICE 'Applied % discount to region %',
        discount_rate, region_name;
END;
$$;
CALL apply_regional_discount('West', 0.10);

--Uloha 10
CREATE OR REPLACE PROCEDURE get_sales_between(
    start_date DATE,
    end_date DATE
)
LANGUAGE plpgsql
AS $$
DECLARE
    total_sales DECIMAL(10,2);
BEGIN
    SELECT COALESCE(SUM(sales), 0)
    INTO total_sales
    FROM orders
    WHERE order_date BETWEEN start_date AND end_date;

    RAISE NOTICE 'From % to %, Total sales: %',
        start_date, end_date, total_sales;
END;
$$;
CALL get_sales_between('2024-01-01', '2024-03-31');