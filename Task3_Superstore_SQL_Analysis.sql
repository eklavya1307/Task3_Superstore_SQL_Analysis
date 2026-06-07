-- ============================================================
-- TASK 3 : SUPERSTORE SQL ANALYSIS
-- Objective:
-- Analyze sales data using SQL by applying Subqueries,
-- CTEs, and Window Functions to solve business queries.

-- Step 1: Setup Data
-- Step 1.1: Create Database
CREATE DATABASE IF NOT EXISTS superstore_db;
USE superstore_db;

-- Step 1.2: Verify Imported Dataset
-- Dataset already imported as 'superstore'
SELECT * FROM superstore
LIMIT 10;

-- Step 1.3: Check Table Structure
DESCRIBE superstore;

-- Step 1.4: Create Customers Table
DROP TABLE IF EXISTS customers;
CREATE TABLE customers AS
SELECT DISTINCT
       `Customer ID`,
       `Customer Name`,
       Segment
FROM superstore;

-- Step 1.5: Verify Customers Table
SELECT * FROM customers
LIMIT 10;

-- Step 1.6: Create Orders Table
DROP TABLE IF EXISTS orders;
CREATE TABLE orders AS
SELECT DISTINCT
       `Order ID`,
       `Customer ID`,
       `Order Date`,
       Sales
FROM superstore;

-- Step 1.7: Verify Orders Table
SELECT * FROM orders
LIMIT 10;

-- Step 1.8: Create Products Table
DROP TABLE IF EXISTS products;
CREATE TABLE products AS
SELECT DISTINCT
       `Product ID`,
       `Product Name`,
       Category,
       `Sub-Category`
FROM superstore;

-- Step 1.9: Verify Products Table
SELECT * FROM products
LIMIT 10;

-- STEP 2: Required Queries
-- ============================================================
-- Query 1
-- Find All Orders Where Sales Are Greater Than Average Sales
-- (Subquery)
SELECT * FROM orders
WHERE Sales >
(
    SELECT AVG(Sales)
    FROM orders
);

-- Query 2
-- Find Highest Sales Order For Each Customer
-- (Subquery)
SELECT o.*
FROM orders o
JOIN
(
    SELECT
           `Customer ID`,
           MAX(Sales) AS Max_Sales

    FROM orders

    GROUP BY `Customer ID`

) m
ON o.`Customer ID` = m.`Customer ID`
AND o.Sales = m.Max_Sales;

-- Query 3
-- Calculate Total Sales For Each Customer
-- (CTE)
WITH customer_sales AS
(
    SELECT
           `Customer ID`,
           SUM(Sales) AS Total_Sales

    FROM orders

    GROUP BY `Customer ID`
)
SELECT * FROM customer_sales;

-- Query 4
-- Find Customers Whose Total Sales Are Above Average
-- (CTE + Subquery)
WITH customer_sales AS
(
    SELECT
           `Customer ID`,
           SUM(Sales) AS Total_Sales

    FROM orders

    GROUP BY `Customer ID`
)
SELECT * FROM customer_sales
WHERE Total_Sales >
(
    SELECT AVG(Total_Sales)
    FROM customer_sales
);

-- Query 5
-- Rank All Customers Based On Total Sales
-- (Window Function)
WITH customer_sales AS
(
    SELECT
           `Customer ID`,
           SUM(Sales) AS Total_Sales

    FROM orders

    GROUP BY `Customer ID`
)

SELECT
       `Customer ID`,
       Total_Sales,

       RANK() OVER
       (
           ORDER BY Total_Sales DESC
       ) AS Customer_Rank
FROM customer_sales;

-- Query 6
-- Assign Row Numbers To Each Order Within A Customer
-- (ROW_NUMBER)
SELECT
       `Customer ID`,
       `Order ID`,
       Sales,

       ROW_NUMBER() OVER
       (
           PARTITION BY `Customer ID`
           ORDER BY Sales DESC
       ) AS Row_Num
FROM orders;

-- Query 7
-- Display Top 3 Customers Based On Total Sales

WITH customer_sales AS
(
    SELECT
           `Customer ID`,
           SUM(Sales) AS Total_Sales

    FROM orders

    GROUP BY `Customer ID`
)

SELECT * FROM
(
    SELECT
           `Customer ID`,
           Total_Sales,

           RANK() OVER
           (
               ORDER BY Total_Sales DESC
           ) AS Customer_Rank

    FROM customer_sales
) ranked_customers
WHERE Customer_Rank <= 3;

-- ============================================================
-- Step 3: Final Combined Query
-- Customer Name + Total Sales + Rank
-- Using JOIN + CTE + Window Function

WITH customer_sales AS
(
    SELECT
           `Customer ID`,
           SUM(Sales) AS Total_Sales

    FROM orders

    GROUP BY `Customer ID`
)

SELECT
       c.`Customer Name`,
       cs.Total_Sales,

       RANK() OVER
       (
           ORDER BY cs.Total_Sales DESC
       ) AS Customer_Rank

FROM customer_sales cs

JOIN customers c
ON cs.`Customer ID` = c.`Customer ID`;

-- ============================================================
-- Step 4: Mini Project – Customer Sales Insights
-- ============================================================
-- Insight Query 1
-- Who Are The Top 5 Customers?

WITH customer_sales AS
(
    SELECT
           `Customer ID`,
           SUM(Sales) AS Total_Sales

    FROM orders

    GROUP BY `Customer ID`
)

SELECT
       c.`Customer Name`,
       cs.Total_Sales

FROM customer_sales cs

JOIN customers c
ON cs.`Customer ID` = c.`Customer ID`

ORDER BY cs.Total_Sales DESC

LIMIT 5;

-- Insight Query 2
-- Who Are The Bottom 5 Customers?

WITH customer_sales AS
(
    SELECT
           `Customer ID`,
           SUM(Sales) AS Total_Sales

    FROM orders

    GROUP BY `Customer ID`
)

SELECT
       c.`Customer Name`,
       cs.Total_Sales

FROM customer_sales cs

JOIN customers c
ON cs.`Customer ID` = c.`Customer ID`

ORDER BY cs.Total_Sales ASC

LIMIT 5;

-- Insight Query 3
-- Which Customers Made Only One Order?
SELECT
       `Customer ID`,
       COUNT(`Order ID`) AS Total_Orders

FROM orders

GROUP BY `Customer ID`

HAVING COUNT(`Order ID`) = 1;

-- Insight Query 4
-- Which Customers Have Above Average Sales?

WITH customer_sales AS
(
    SELECT
           `Customer ID`,
           SUM(Sales) AS Total_Sales

    FROM orders

    GROUP BY `Customer ID`
)

SELECT *

FROM customer_sales

WHERE Total_Sales >
(
    SELECT AVG(Total_Sales)
    FROM customer_sales
);

-- Insight Query 5
-- What Is The Highest Order Value Per Customer?
SELECT
       `Customer ID`,
       MAX(Sales) AS Highest_Order_Value

FROM orders

GROUP BY `Customer ID`;




WITH customer_orders AS
(
    SELECT
           `Customer ID`,
           COUNT(`Order ID`) AS Total_Orders

    FROM orders

    GROUP BY `Customer ID`
)

SELECT
       CASE
           WHEN Total_Orders = 1
           THEN 'Single Order Customer'
           ELSE 'Repeat Customer'
       END AS Customer_Type,

       COUNT(*) AS Customer_Count

FROM customer_orders

GROUP BY Customer_Type;