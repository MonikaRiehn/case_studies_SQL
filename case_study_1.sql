----------------------------------------------------------------------
--                    Data In Motion
--                 Free SQL Case Studies
--            SQL Case Study 1: Tiny Shop Sales
--   https://d-i-motion.com/lessons/customer-orders-analysis/
--                Solutions by Monika Riehn
----------------------------------------------------------------------

----------------------------------------------------------------------
-- 1) Which product has the highest price? Only return a single row.
----------------------------------------------------------------------

SELECT 
    product_name, 
    price AS highest_price
FROM 
    products
WHERE
    price = (SELECT MAX(price) FROM products);

----------------------------------------------------------------------
 product_name | highest_price 
--------------+---------------
 Product M    |         70.00
----------------------------------------------------------------------


----------------------------------------------------------------------
-- 2) Which customer has made the most orders?
----------------------------------------------------------------------

WITH total_orders AS (                              -- make subquery "total_orders"
    SELECT
        c.first_name first_name,                    -- give some nicer column names
        c.last_name last_name,
        count(o.order_id) AS number_of_orders       -- calculate the number of orders per customer
    FROM customers AS c
    JOIN orders AS o USING (customer_id)
    GROUP BY customer_id
)
SELECT                                              
    first_name,                                     -- select the nicely named columns
    last_name,
    number_of_orders
FROM total_orders                                   -- select columns from the new table "total_orders"
WHERE                                               -- only select the rows with the maximum number of orders of all customers
    number_of_orders = (
        SELECT
            max(number_of_orders) 
        FROM
            total_orders
    );

----------------------------------------------------------------------
 first_name | last_name | number_of_orders 
------------+-----------+------------------
 Jane       | Smith     |                2
 Bob        | Johnson   |                2
 John       | Doe       |                2
----------------------------------------------------------------------


----------------------------------------------------------------------
-- 3) What’s the total revenue per product?
----------------------------------------------------------------------

SELECT
    o.product_id,
    p.price,
    p.price * sum(o.quantity) AS total_revenue  -- sum up quantity by product_id across all orders
FROM                                            
    products AS p
JOIN                                            -- inner join by product_id
    order_items AS o USING (product_id)
GROUP BY                                        -- group by for aggregating   
    o.product_id, p.price                       -- grouping must match both columns id and price
ORDER BY
    o.product_id;                               -- order output
    

 product_id | price | total_revenue 
------------+-------+---------------
          1 | 10.00 |         50.00
          2 | 15.00 |        135.00
          3 | 20.00 |        160.00
          4 | 25.00 |         75.00
          5 | 30.00 |         90.00
          6 | 35.00 |        210.00
          7 | 40.00 |        120.00
          8 | 45.00 |        135.00


----------------------------------------------------------------------
-- 4) Find the day with the highest revenue.
----------------------------------------------------------------------

WITH revenue_by_date AS (                           -- make subquery with revenues for ALL dates                              
SELECT
    o.order_date order_date,
    p.price * sum(oi.quantity) AS revenue_per_date
FROM
    order_items AS oi
JOIN
    orders AS o USING (order_id)
JOIN
    products AS p USING (product_id)
GROUP BY o.order_date, p.product_id, p.price
)
SELECT                                              -- from the subquery with ALL dates ...
    order_date,
    revenue_per_date
FROM
    revenue_by_date
WHERE revenue_per_date = (                          -- ... select only those with the maximum revenue
        SELECT
            max (revenue_per_date)
        FROM
            revenue_by_date
);

 order_date | revenue_per_date 
------------+------------------
 2023-05-16 |           210.00
 2023-05-11 |           210.00


----------------------------------------------------------------------
-- 5) Find the first order (by date) for each customer.
----------------------------------------------------------------------

SELECT
    o.customer_id,
    concat(c.first_name ||' '|| c.last_name) full_name,
    min(o.order_date) first_order
FROM
    orders AS o
JOIN
    customers AS c USING (customer_id)
GROUP BY o.customer_id, c.first_name, c.last_name
ORDER BY o.customer_id;    


 customer_id |    full_name     | first_order 
-------------+------------------+-------------
           1 | John Doe         | 2023-05-01
           2 | Jane Smith       | 2023-05-02
           3 | Bob Johnson      | 2023-05-03
           4 | Alice Brown      | 2023-05-07
           5 | Charlie Davis    | 2023-05-08
           6 | Eva Fisher       | 2023-05-09
           7 | George Harris    | 2023-05-10
           8 | Ivy Jones        | 2023-05-11
           9 | Kevin Miller     | 2023-05-12
          10 | Lily Nelson      | 2023-05-13
          11 | Oliver Patterson | 2023-05-14
          12 | Quinn Roberts    | 2023-05-15
          13 | Sophia Thomas    | 2023-05-16


----------------------------------------------------------------------
-- 6) Find the top 3 customers who have ordered the most distinct products
----------------------------------------------------------------------



----------------------------------------------------------------------
-- 7) Which product has been bought the least in terms of quantity?
----------------------------------------------------------------------



----------------------------------------------------------------------
-- 8) What is the median order total?
----------------------------------------------------------------------



----------------------------------------------------------------------
-- 9) For each order, determine if it was ‘Expensive’ (total over 300), ‘Affordable’ (total over 100), or ‘Cheap’.
----------------------------------------------------------------------



----------------------------------------------------------------------
-- 10) Find customers who have ordered the product with the highest price.
----------------------------------------------------------------------


