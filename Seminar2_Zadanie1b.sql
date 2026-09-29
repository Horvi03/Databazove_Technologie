--Uloha Vytvorenie Databazy
CREATE DATABASE datacraftinglab_db;
CREATE TABLE flourmills_sales (
    sales_id INT PRIMARY KEY,
    sale_date DATE,
    region VARCHAR(100),
    state VARCHAR(100),
    product_category VARCHAR(100),
    product_name VARCHAR(150),
    customer_type VARCHAR(100),
    customer_id INT,
    quantity_sold INT,
    unit_price DECIMAL(10,2),
    discount_rate INT,
    payment_method VARCHAR(100),
    sales_rep VARCHAR(150),
    warehouse VARCHAR(100),
    delivery_status VARCHAR(100),
    order_channel VARCHAR(100),
    batch_number INT,
    production_date DATE,
    total_amount DECIMAL(10,2)
);

--Uloha 1
SELECT product_name, total_amount FROM flourmills_sales
WHERE total_amount > ( SELECT AVG(total_amount) FROM flourmills_sales);

--Uloha 2
SELECT sales_id, sale_date, region, product_category FROM flourmills_sales
WHERE product_category = (SELECT product_category FROM flourmills_sales GROUP BY product_category ORDER BY SUM(total_amount) DESC LIMIT 1)
ORDER BY sales_id ASC;

--Uloha 3
SELECT product_name, total_amount, (SELECT AVG(total_amount) FROM flourmills_sales) AS avg_amount FROM flourmills_sales;

--Uloha 4
SELECT product_name, total_amount, total_amount / (SELECT SUM(total_amount) FROM flourmills_sales) AS amount_share FROM flourmills_sales;

--Uloha 5
SELECT month, monthly_sales 
FROM (SELECT EXTRACT(MONTH FROM sale_date) AS month, SUM(total_amount) AS monthly_sales FROM flourmills_sales 
GROUP BY EXTRACT(MONTH FROM sale_date)) AS monthly_summary
ORDER BY monthly_sales DESC;

--Uloha 6
SELECT product_category, total_sales
FROM (SELECT product_category, SUM(total_amount) AS total_sales
    FROM flourmills_sales
    GROUP BY product_category
) AS category_sales
WHERE total_sales > 50000000
ORDER BY total_sales DESC;

--Uloha 7
SELECT product_name, product_category, total_amount FROM flourmills_sales
WHERE total_amount > (SELECT AVG(total_amount) FROM flourmills_sales
WHERE product_category = product_category);

--Uloha 8
SELECT product_name, region, total_amount, (SELECT MIN(total_amount) FROM flourmills_sales AS s
WHERE f.region = s.region) AS region_min_amount FROM flourmills_sales AS f;

--Uloha 9
SELECT * FROM flourmills_sales AS f
WHERE EXISTS ( SELECT 1 FROM flourmills_sales AS s
    WHERE s.product_name = f.product_name
    GROUP BY s.product_name
    HAVING COUNT(DISTINCT EXTRACT(MONTH FROM s.sale_date)) > 1
);

--Uloha 10
SELECT product_category, product_name, total_amount FROM flourmills_sales AS f
WHERE EXISTS ( SELECT 1 FROM flourmills_sales AS s
    WHERE s.product_category = f.product_category
    AND s.total_amount>20000
);

--Uloha 11
SELECT product_category FROM flourmills_sales AS f
WHERE EXISTS (SELECT 1 FROM flourmills_sales AS s
 WHERE s.product_category = f.product_category
 GROUP BY s.product_category
 HAVING COUNT(DISTINCT s.region) > 3
);

--Uloha 12
SELECT f.* FROM flourmills_sales AS f
WHERE EXISTS (
    SELECT 1
    FROM flourmills_sales AS s
    WHERE s.region = f.region
      AND EXTRACT(YEAR FROM s.sale_date) = 2024
);

--Uloha 13
SELECT DISTINCT f.product_category FROM flourmills_sales AS f
WHERE NOT EXISTS (
    SELECT 1 FROM flourmills_sales AS s
    WHERE s.product_category = f.product_category
    AND s.total_amount > 500000
);

--Uloha 14
SELECT DISTINCT f.region FROM flourmills_sales AS f
WHERE NOT EXISTS (
    SELECT 1
    FROM flourmills_sales AS s
    WHERE s.region = f.region
      AND s.product_category = 'Flour'
);