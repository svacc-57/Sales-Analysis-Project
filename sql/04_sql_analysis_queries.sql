-- SQL Analysis Queries
--Creating queries that covers KPI, sales and profit aby region/state,category/sub-category, monthly sales/profiT,year over year comparison by month and top 10 products by sales.

--1)KPI Queries:
SELECT 
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT o.customer_id) AS total_customers,
    SUM(o.sales) AS total_sales,
    SUM(o.profit) AS total_profit,
    ROUND(SUM(o.profit) / SUM(o.sales) * 100, 2) AS profit_margin_percentage,
    ROUND(SUM(o.sales) / COUNT(DISTINCT o.order_id), 2) AS average_order_value
FROM orders o;


--2) Sales,Profit and Orders by Region/State:
SELECT
c.region,
c.state,
COUNT(DISTINCT o.order_id) AS orders,
    SUM(o.sales) AS total_sales,
    SUM(o.profit) AS total_profit,
    ROUND(SUM(o.profit) / SUM(o.sales) * 100, 2) AS profit_margin_percentage
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.region, c.state
ORDER BY total_sales DESC;



--3) Sales and Profit by Category/Sub-Category:
SELECT
    p.category,
    p.sub_category,
    SUM(o.quantity) AS units_sold,
    SUM(o.sales) AS total_sales,
    SUM(o.profit) AS total_profit,
    ROUND(SUM(o.profit) / SUM(o.sales) * 100, 2) AS profit_margin_percentage
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY p.category, p.sub_category
ORDER BY total_sales DESC;


---4) Monthly Sales and Profit:
SELECT
    DATE_FORMAT(o.order_date, '%Y-%m') AS order_month,
    SUM(o.sales)                       AS total_sales,
    SUM(o.profit)                      AS total_profit,
    COUNT(DISTINCT o.order_id)         AS orders
FROM orders o
GROUP BY order_month
ORDER BY order_month;


--5) Year over Year Comparison by Month:
SELECT
MONTH(o.order_date) AS month_number,
YEAR(o.order_date) AS year,
SUM(o.sales) AS total_sales
FROM orders o
GROUP BY year, month_number
ORDER BY total_sales ASC;


--6) Top 10 Products by Sales:
SELECT
p.product_name,
p.category,
SUM(o.quantity) AS units_sold,
    SUM(o.sales) AS total_sales,
    SUM(o.profit) AS total_profit
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY p.product_id, p.product_name, p.category
ORDER BY total_sales DESC
LIMIT 10;

