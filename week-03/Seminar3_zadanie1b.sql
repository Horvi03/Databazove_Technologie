--Uloha 1
WITH daily_sales AS (
    SELECT
        sale_date,
        SUM(total_amount) AS total_daily_sales
    FROM flourmills_sales
    GROUP BY sale_date
)
SELECT
    sale_date,
    total_daily_sales
FROM daily_sales
WHERE total_daily_sales > 3000000
ORDER BY total_daily_sales DESC
LIMIT 5;

--Uloha 2
WITH category_sales AS (
    SELECT
        product_category,
        SUM(total_amount) AS total_sales
    FROM flourmills_sales
    GROUP BY product_category
)
SELECT
    product_category,
    total_sales
FROM category_sales
ORDER BY total_sales DESC;

--Uloha 3

WITH product_sales AS (
    SELECT
        product_category,
        product_name,
        SUM(total_amount) AS total_product_sales
    FROM flourmills_sales
    GROUP BY product_category, product_name
),
ranked_products AS (
    SELECT
        product_category,
        product_name,
        total_product_sales,
        RANK() OVER (
            PARTITION BY product_category
            ORDER BY total_product_sales DESC
        ) AS category_rank
    FROM product_sales
)
SELECT
    product_category,
    total_product_sales,
    category_rank
FROM ranked_products
WHERE category_rank BETWEEN 1 AND 3
ORDER BY product_category, category_rank;

--Uloha 4

WITH customer_sales AS (
    SELECT
        customer_type,
        SUM(total_amount) AS revenue
    FROM flourmills_sales
    GROUP BY customer_type
),
sales_percentages AS (
    SELECT
        customer_type,
        revenue,
        SUM(revenue) OVER () AS total_revenue,
        ROUND(
            (revenue * 100.0 / SUM(revenue) OVER ())::numeric,
            2
        ) AS revenue_percentage
    FROM customer_sales
)
SELECT
    customer_type,
    revenue,
    total_revenue,
    revenue_percentage
FROM sales_percentages
ORDER BY revenue DESC;

--Uloha 5

WITH ranked_transactions AS (
    SELECT
        customer_id,
        product_name,
        sale_date,
        total_amount,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY sale_date DESC
        ) AS row_num
    FROM flourmills_sales
)
SELECT
    customer_id,
    product_name,
    sale_date,
    total_amount
FROM ranked_transactions
WHERE row_num = 1
ORDER BY customer_id ASC
LIMIT 5;

--Uloha 6

WITH RECURSIVE date_bounds AS (
    SELECT
        MIN(sale_date) AS start_date,
        MAX(sale_date) AS end_date
    FROM flourmills_sales
),
calendar AS (
    SELECT start_date AS sale_date
    FROM date_bounds

    UNION ALL

    SELECT (c.sale_date + INTERVAL '1 day')::date
    FROM calendar c
    CROSS JOIN date_bounds b
    WHERE c.sale_date < b.end_date
)
SELECT sale_date
FROM calendar
ORDER BY sale_date ASC;

--Uloha 7

WITH RECURSIVE monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', sale_date)::date AS month,
        SUM(total_amount) AS revenue
    FROM flourmills_sales
    GROUP BY DATE_TRUNC('month', sale_date)
),
ordered_months AS (
    SELECT
        ROW_NUMBER() OVER (ORDER BY month) AS rn,
        month,
        revenue
    FROM monthly_revenue
),
cumulative_target AS (
    SELECT
        rn,
        month,
        revenue,
        revenue AS cumulative_revenue
    FROM ordered_months
    WHERE rn = 1

    UNION ALL

    SELECT
        n.rn,
        n.month,
        n.revenue,
        c.cumulative_revenue + n.revenue
    FROM cumulative_target c
    JOIN ordered_months n
        ON n.rn = c.rn + 1
    WHERE c.cumulative_revenue < 500000000
)
SELECT
    rn,
    month,
    revenue,
    cumulative_revenue
FROM cumulative_target
WHERE cumulative_revenue >= 500000000
ORDER BY rn
LIMIT 1;