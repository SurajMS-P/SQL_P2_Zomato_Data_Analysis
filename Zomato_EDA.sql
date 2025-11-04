-- Zomato EDA 

Select * from customers;
Select * from restaurants;
Select * from orders;
Select * from rider;
Select * from deliveries;

Select * from deliveries
where 
     rider_id is Null;

----------------------
-- Analysis & Reports
----------------------

-- Q.1
-- Write a query to find the top 5 most frequently ordered dishes by customer called "Arjun Mehta" in the last 1 year.

/*
-- Join orders and customers table
-- Count Orders
-- Filter only for 'Arjun Mehta' and Order >= 'Last 1 Year'
-- Group by
-- Order by desc
-- Limit for 5
*/

-- Query without Windows 

Select 
	c.customer_name, 
	o.order_item as dishes,
	count(o.order_id) as total_orders
from orders as o
inner join
customers as c
on o.customer_id = c.customer_id
where 
c.customer_name = 'Arjun Mehta'
and
order_date >= current_date - INTERVAL '1 Year' 
group by 1,2
order by count(o.order_id) desc
limit 5;

-- Query using Windows (Dense_rank) gives more accurate data in case if there is repeated count of values
-- Using Sub_Query to filter out Top_5 ordered dish

Select 
	customer_name, dishes, total_orders, Top_5 
from 
	(Select 
		c.customer_name, 
		o.order_item as dishes,
		count(o.order_id) as total_orders,
		dense_rank() over(order by count(o.order_id) desc) as Top_5
	from orders as o
	inner join
	customers as c
	on o.customer_id = c.customer_id
	where 
	c.customer_name = 'Arjun Mehta'
	and
	order_date >= current_date - INTERVAL '1 Year' 
	group by 1,2) as frequently_ordered_dishes
where top_5 <= 5;

--================================================================================================================

-- 2. Popular Time Slots
-- Question: Identify the time slots during which the most orders are placed. based on 2-hour intervals.

Select * from orders;

Select
(generate_series(
    '2025-01-01 00:00:00'::timestamp,
    '2025-01-01 23:59:59'::timestamp,
    '2 hours'::interval
))::time AS interval_start,
count(order_id)
from orders
group by 1;

Select 
	Case
	WHEN Extract(Hour from Order_time) between 0 and 1 THEN '00:00 - 02;00'
	WHEN Extract(Hour from Order_time) between 2 and 3 THEN '02:00 - 04:00'
	WHEN Extract(Hour from Order_time) between 4 and 5 THEN '04:00 - 06:00'
	WHEN Extract(Hour from Order_time) between 6 and 7 THEN '06:00 - 08:00'
	WHEN Extract(Hour from Order_time) between 8 and 9 THEN '08:00 - 10:00'
	WHEN Extract(Hour from Order_time) between 10 and 11 THEN '10:00 - 12:00'
	WHEN Extract(Hour from Order_time) between 12 and 13 THEN '12:00 - 14:00'
	WHEN Extract(Hour from Order_time) between 14 and 15 THEN '14:00 - 16:00'
	WHEN Extract(Hour from Order_time) between 16 and 17 THEN '16:00 - 18:00'
	WHEN Extract(Hour from Order_time) between 18 and 19 THEN '18:00 - 20:00'
	WHEN Extract(Hour from Order_time) between 20 and 21 THEN '20:00 - 22:00'
	WHEN Extract(Hour from Order_time) between 22 and 23 THEN '22:00 - 00:00'
END as Time_Slot,
count(order_id) as count_orders
from orders
group by time_slot
order by count_orders desc;


--================================================================================================================

-- 3. Order Value Analysis
-- Question: Find the average order value per customer who has placed more than 300 orders.
-- Return customer_name, and aov(average order value)
/*
-- Join Orders and Customers table
-- Count orders
-- Filter orders placed only by particular customer > 300 orders
-- Avg value 
-- Sub-Query 
*/

Select Customer_name, Avg_amount from 
(Select
	c.customer_name as Customer_name,
	ROUND(avg(total_amount)) as Avg_amount,
	count(o.order_id) as O_C
from orders as o
inner join
customers as c
on o.customer_id = c.customer_id
group by 1
having count(o.order_id) > 300
order by Avg_amount desc) as Order_Value_Analysis;

--================================================================================================================

-- 4. High-Value Customers
-- Question: List the customers who have spent more than 100K in total on food orders.
-- return customer_name, and customer_id

/*
-- Join Orders and Customers table
-- Sum order value
-- Filter order value > 100K
-- Sub-Query 
-- Result = Out of 33 Customer, 32 customers have spent more then 100K
*/

Select customer_name, customer_id from 
(Select 
	c.customer_name,
	o.customer_id,
	sum(o.total_amount) as Total_spent
from orders as o
inner join
customers as c
on o.customer_id = c.customer_id
group by 1,2
having sum(o.total_amount) > 100000
order by Total_spent desc) as High_Value_Customers
order by 2 asc;

--================================================================================================================

-- 5. Orders Without Delivery
-- Question: Write a query to find orders that were placed but not delivered.
-- Return each restuarant name, city and number of not delivered orders

Select * from restaurants;
Select * from deliveries;

Select restaurant_name, city, count(Deliver_stat) as Count_Not_Delivered from
(Select 
	r.restaurant_name, 
	r.city,
	d.delivery_status as Deliver_stat
from restaurants as r
inner join
orders as o      -- First join with orders table
on r.restaurant_id = o.restaurant_id
inner join
deliveries as d  -- Then join with deliveries table (No common column b/w restaurants & deliveries table )
on o.order_id = d.order_id
where d.delivery_status = 'Not Delivered') as Orders_Without_Delivery
group by 1,2
order by Count_Not_Delivered desc;

--================================================================================================================

-- Q. 6
-- Restaurant Revenue Ranking:
-- Rank restaurants by their total revenue from the last year, including their name,
-- total revenue, and rank within their city.

Select * from restaurants;
Select * from orders;

Select 
	r.city,
	r.restaurant_name,
	sum(o.total_amount) as Total_revenue,
	dense_rank() over(partition by r.city order by sum(o.total_amount) desc) as restaurant_rank
from 
orders as o 
inner join 
restaurants as r
on o.restaurant_id = r.restaurant_id
where extract(year from o.order_date) = extract(year from current_date) - 1
group by 1,2;

--================================================================================================================

-- Q. 7
-- Most Popular Dish by City:
-- Identify the most popular dish in each city based on the number of orders.

Select * from restaurants;
Select * from orders;

Select city, Most_Popular_Dish_by_City from
(Select 
	r.city,
	o.order_item as Most_Popular_Dish_by_City,
	count(o.order_id) as Number_of_orders,
	dense_rank() over(partition by r.city order by count(o.order_id) desc) as rnk
from 
orders as o
inner join
restaurants as r
on o.restaurant_id = r.restaurant_id
group by 1,2) as Most_Popular_Dish
where rnk = 1;

--================================================================================================================

-- Q.8 Customer Churn:
-- Find customers who haven't placed an order in 2024 but did in 2023.

Select * from customers;
Select * from orders;

/* Finding distinct Customers who haven't placed an order in 2024 but did in 2023
   Resulted to '0' Customers as all the customers have ordered in both years
   Solved Query in 2 ways */

-- By joining Orders and Customers table

Select distinct c.customer_id
	from 
	customers as c
	inner join
	orders as o
on c.customer_id = o.customer_id 
where 
extract(year from o.order_date) = 2023
and
c.customer_id not in
(Select distinct c.customer_id
	from 
	customers as c
	inner join
	orders as o
on c.customer_id = o.customer_id 
where extract(year from o.order_date) = 2024);

-- By Comparing 2 tables

Select distinct customer_id
	from 
	customers 
where 
extract(year from current_date) = extract(year from current_date) - 1
and
customer_id not in
(Select distinct customer_id
	from 
	orders
where 
extract(year from current_date) = extract(year from current_date));

--================================================================================================================

-- Q.9 Rider Average Delivery Time:
-- Determine each rider's average delivery time.

Select 
	o.order_id,
	o.order_time,
	d.delivery_time,
	d.rider_id,
	d.delivery_time - o.order_time as time_difference,
extract(EPOCH from ( d.delivery_time - o.order_time +
	Case when d.delivery_time < o.order_time then interval '1 day'
	else interval '0 day' end))/60 as time_difference_in_sec
from orders as o
inner join
deliveries as d
on o.order_id = d.order_id
where d.delivery_status = 'Delivered';

--================================================================================================================

-- Q.10 Monthly Restaurant Growth Ratio:
-- Calculate each restaurant's growth ratio based on the total number of delivered orders since its joining

Select 
		restaurant_id,
		month,
		Curr_month_orders,
		prev_month_orders,
		round((Curr_month_orders::numeric-prev_month_orders::numeric)/prev_month_orders::numeric * 100,2) as Growth_ratio from (
Select
	o.restaurant_id,
	to_char(o.order_date, 'mm') as month,
	Count(o.order_id) as Curr_month_orders,
	lag(Count(o.order_id),1) over(partition by o.restaurant_id order by to_char(o.order_date, 'mm')) as prev_month_orders
from orders as o
join
deliveries as d
on o.order_id = d.order_id
where d.delivery_status = 'Delivered'
group by 1,2
order by 1,2) as Growth_Ratio;

--================================================================================================================





