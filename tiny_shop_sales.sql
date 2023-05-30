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
	price = (
	SELECT
		MAX(price)
	FROM
		products);

----------------------------------------------------------------------
 product_name | highest_price 
--------------+---------------
 Product M    |         70.00
----------------------------------------------------------------------


----------------------------------------------------------------------
-- 2) Which customer has made the most orders?
----------------------------------------------------------------------

with total_orders as (						-- make subquery "total_orders"
select
	c.first_name first_name,				-- give some nicer column names
	c.last_name last_name,
	count(o.order_id) as number_of_orders	-- calculate the number of orders per customer
from
	customers as c
join orders as o
		using (customer_id)
group by
	customer_id
)
select
	first_name,								-- select the nicely named columns
	last_name,
	number_of_orders
from
	total_orders							-- select columns from the new table "total_orders"
where										-- only select the rows with the maximum number of orders of all customers
	number_of_orders = (
	select
		max(number_of_orders)
	from
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

select
	o.product_id,
	p.price,
	p.price * sum(o.quantity) as total_revenue	-- sum up quantity by product_id across all orders
from
	products as p
join											-- inner join by product_id
	order_items as o
		using (product_id)
group by										-- group by for aggregating   
	o.product_id,
	p.price										-- grouping must match both columns id and price
order by
	o.product_id;                             	-- order output
    

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

with revenue_by_date as (							-- make subquery with revenues for ALL dates                              
select
	o.order_date order_date,
	p.price * sum(oi.quantity) as revenue_per_date
from
	order_items as oi
join
    orders as o
		using (order_id)
join
    products as p
		using (product_id)
group by
	o.order_date,
	p.product_id,
	p.price
)
select												-- from the subquery with ALL dates ...
	order_date,
	revenue_per_date
from
	revenue_by_date
where
	revenue_per_date = (							-- ... select only those with the maximum revenue
	select
		max (revenue_per_date)
	from
		revenue_by_date
);

 order_date | revenue_per_date 
------------+------------------
 2023-05-16 |           210.00
 2023-05-11 |           210.00


----------------------------------------------------------------------
-- 5) Find the first order (by date) for each customer.
----------------------------------------------------------------------

select
	o.customer_id,
	concat(c.first_name || ' ' || c.last_name) full_name,
	min(o.order_date) first_order
from
	orders as o
join
    customers as c
		using (customer_id)
group by
	o.customer_id,
	c.first_name,
	c.last_name
order by
	o.customer_id;


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

select
	o.customer_id,
	c.first_name,
	c.last_name,
	o.order_id,
	sum(oi.product_id * oi.quantity) as number_of_items
from
	orders as o
join order_items as oi
		using (order_id)
join customers as c
		using (customer_id)
group by
	o.order_id,
	c.first_name,
	c.last_name
order by
	number_of_items desc
limit 3;

 customer_id | first_name | last_name | order_id | number_of_items 
-------------+------------+-----------+----------+-----------------
          13 | Sophia     | Thomas    |       16 |              63
           7 | George     | Harris    |       10 |              52
           8 | Ivy        | Jones     |       11 |              51


----------------------------------------------------------------------
-- 7) Which product has been bought the least in terms of quantity?
----------------------------------------------------------------------

with bought as (
select
	oi.product_id as product_id,
	p.product_name as product_name,
	SUM(oi.quantity) as total_bought
from
	order_items as oi
join products as p
		using (product_id)
group by
	oi.product_id,
	p.product_name
)
select
	product_id,
	product_name,
	total_bought
from
	bought
where
	total_bought = (
	select
		min(total_bought)
	from
		bought
    )
order by
	product_id;


 product_id | product_name | total_bought 
------------+--------------+--------------
          4 | Product D    |            3
          5 | Product E    |            3
          7 | Product G    |            3
          8 | Product H    |            3
          9 | Product I    |            3
         11 | Product K    |            3
         12 | Product L    |            3


----------------------------------------------------------------------
-- 8) What is the median order total?
----------------------------------------------------------------------
with order_sums as
(
select
	oi.order_id as order_id,
	sum( oi.quantity * p.price ) as order_total
from
	order_items as oi
join orders as o
		using
    (order_id)
join products as p
		using
    (product_id)
group by
	oi.order_id
)
select
	percentile_cont(.5 ) within group(
order by
	order_total ) as median_order_total
from
	order_sums ;


 median_order_total 
--------------------
              112.5


----------------------------------------------------------------------
-- 9) For each order, determine if it was ‘Expensive’ (total over 300), ‘Affordable’ (total over 100), or ‘Cheap’.
----------------------------------------------------------------------

SELECT
	oi.order_id AS order_id,
	sum(oi.quantity * p.price) AS order_total,
	CASE
		WHEN sum(oi.quantity * p.price) <= 100 THEN 'Cheap'
		WHEN sum(oi.quantity * p.price) <= 300 THEN 'Affordable'
		ELSE 'Expensive'
	END AS price_category
FROM
	order_items AS oi
JOIN orders AS o
		USING
    (order_id)
JOIN products AS p
		USING
    (product_id)
GROUP BY
	oi.order_id
ORDER BY
	oi.order_id;


 order_id | order_total | price_category 
----------+-------------+----------------
        1 |       35.00 | Cheap
        2 |       75.00 | Cheap
        3 |       50.00 | Cheap
        4 |       80.00 | Cheap
        5 |       50.00 | Cheap
        6 |       55.00 | Cheap
        7 |       85.00 | Cheap
        8 |      145.00 | Affordable
        9 |      140.00 | Affordable
       10 |      285.00 | Affordable
       11 |      275.00 | Affordable
       12 |       80.00 | Cheap
       13 |      185.00 | Affordable
       14 |      145.00 | Affordable
       15 |      225.00 | Affordable
       16 |      340.00 | Expensive


----------------------------------------------------------------------
-- 10) Find customers who have ordered the product with the highest price.
----------------------------------------------------------------------

with highest_price as (
select
	product_id,
	max(price) as max_price
from
	products
group by
	product_id
order by
	max(price) desc
)
select
	c.customer_id,
	c.first_name,
	c.last_name
from
	highest_price
join products as p
		using (product_id)
join order_items as oi
		using (product_id)
join orders as o
		using (order_id)
join customers as c
		using (customer_id)
where
	p.price = (
	select
		MAX(price)
	from
		products);
    
    
 customer_id | first_name | last_name 
-------------+------------+-----------
          13 | Sophia     | Thomas
           8 | Ivy        | Jones
           
           
