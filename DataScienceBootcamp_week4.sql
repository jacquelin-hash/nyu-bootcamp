-- Purpose: Count the total number of distinct orders on March 18, 2023
/* This query retrieves the count of unique orders 
   that were completed on a specific date */

SELECT 
    COUNT(DISTINCT Order_id) AS total_orders  
FROM 
    SALES  
WHERE 
    Date = '2023-03-18';  

-- Purpose: Find orders for a specific customer (John Doe) on a specific date
/* This query joins the SALES and CUSTOMERS tables
   to filter orders by both customer name and date */

SELECT 
    COUNT(DISTINCT s.Order_id) AS total_orders  
FROM 
    SALES s  
JOIN 
    CUSTOMERS c  
    ON s.Customer_id = c.customer_id  
WHERE 
    s.Date = '2023-03-18'  
    AND c.first_name = 'John'  
    AND c.last_name = 'Doe';  

-- Purpose: Analyze customer activity and spending for January 2023

/* This query uses a subquery to:
   1. Calculate each customer's total spending for January 2023
   2. Count unique customers who made purchases in that period
   3. Calculate the average amount spent per customer */

SELECT 
    COUNT(DISTINCT Customer_id) AS total_customers, 
    AVG(customer_total) AS average_spend  
FROM (
    SELECT 
        Customer_id,  
        SUM(Revenue) AS customer_total  
    FROM 
        SALES  
    WHERE 
        Date BETWEEN '2023-01-01' AND '2023-01-31'  
    GROUP BY 
        Customer_id  
) AS customer_totals;  

-- Purpose: Identify underperforming departments in 2022

/* This query:
   1. Joins sales data with item information to get department
   2. Calculates total revenue by department for the year 2022
   3. Filters to show only departments below the $600 threshold */

SELECT 
    i.department,  
    SUM(s.Revenue) AS total_revenue  
FROM 
    SALES s  
JOIN 
    ITEMS i  -- Items table with alias 'i'
    ON s.Item_id = i.Item_id  
WHERE 
    s.Date BETWEEN '2022-01-01' AND '2022-12-31'  -- Full year 2022
GROUP BY 
    i.department  -- Group results by department
HAVING 
    SUM(s.Revenue) < 600  
ORDER BY 
    total_revenue DESC;  -- Sort from highest to lowest revenue


-- Purpose: Find revenue extremes across all orders

/* This query uses a subquery to:
   1. Calculate the total revenue for each order
   2. Find both the maximum and minimum order values
   Helps identify our highest and lowest value transactions */

SELECT 
    MAX(order_total) AS highest_order_revenue,  
    MIN(order_total) AS lowest_order_revenue  
FROM (
    SELECT 
        Order_id,  
        SUM(Revenue) AS order_total  
    FROM 
        SALES  
    GROUP BY 
        Order_id  
) AS order_totals;  

-- Purpose: Analyze items in our highest-revenue order

/* This query:
   1. Uses a Common Table Expression (CTE) to identify our highest-revenue order
   2. Joins with the items table to get product details
   3. Returns all items purchased in that order
   Useful for understanding what makes up our most valuable transactions */

WITH most_lucrative_order AS (
    SELECT 
        Order_id  
    FROM 
        SALES  
    GROUP BY 
        Order_id  
    ORDER BY 
        SUM(Revenue) DESC  
    LIMIT 1  
)


SELECT 
    s.Order_id,  
    i.Item_name,  
    s.Quantity, 
    s.Revenue  
FROM 
    SALES s 
JOIN 
    ITEMS i  
    ON s.Item_id = i.Item_id  
WHERE 
    s.Order_id = (SELECT Order_id FROM most_lucrative_order)  
ORDER BY 
    s.Revenue DESC;  
    