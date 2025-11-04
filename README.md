# Zomato Data Analysis SQL Project

## Project Overview

**Project Title**: Zomato-Data-Analysis-SQL-Project--P2  
**Level**: Intermediate  
**Database**: `Zomato_Pro`

This project is designed to demonstrate SQL skills and techniques typically used by data analysts to explore, clean, and analyze retail sales data. The project involves setting up a retail sales database, performing exploratory data analysis (EDA), and answering specific business questions through SQL queries. This project is ideal for those who are starting their journey in data analysis and want to build a solid foundation in SQL.

## Objectives

1. **Set up a retail sales database**: Create and populate a Customers, Restaurants, Orders, Riders, Deliveries database with the provided data.
2. **Data Cleaning**: Identify and remove any records with missing or null values.
3. **Exploratory Data Analysis (EDA)**: Perform basic exploratory data analysis to understand the dataset.
4. **Business Analysis**: Use SQL to answer specific business questions and derive insights from the Customers, Restaurants, Orders, Riders, Deliveries data.

## Project Structure

### 1. Database Setup

- **Database Creation**: The project starts by creating a database named `Zomato_Pro`.
- **Tables Creation**:
- 1) A table named `customers` is created to store the customers data. The table structure includes columns for customer_id, customer_name, reg_date.
- 2) A table named `restaurants` is created to store the restaurants data. The table structure includes columns for restaurant_id, restaurant_name, city, opening_hours.
- 3) A table named `orders` is created to store the orders data. The table structure includes columns for order_id, customer_id, restaurant_id, order_item, order_date,           order_time, order_status, total_amount.
- 4) A table named `rider` is created to store the rider data. The table structure includes columns for rider_id, rider_name, sign_up.
- 5) A table named `deliveries` is created to store the deliveries data. The table structure includes columns for delivery_id, order_id, delivery_status, delivery_time,          rider_id.

```sql
CREATE DATABASE Zomato_Pro;

CREATE TABLE customers
(
    customer_id INT PRIMARY KEY,	
    customer_name VARCHAR(25),
    reg_date DATE
);

CREATE TABLE restaurants
(
    restaurant_id INT PRIMARY KEY,	
    restaurant_name VARCHAR(55),
    city VARCHAR(55),
    opening_hours VARCHAR(55),
);

CREATE TABLE orders
(
    order_id INT PRIMARY KEY,
    customer_id INT, -- Coming from customer table
    restaurant_id INT, -- Coming from resturant table
    order_item VARCHAR(55),
    order_date DATE,
    order_time TIME,
    order_status VARCHAR(55),
    total_amount FLOAT
);

CREATE TABLE rider
(
    rider_id INT PRIMARY KEY,	
    rider_name VARCHAR(55),
    sign_up DATE
);

CREATE TABLE deliveries
(
    delivery_id INT PRIMARY KEY,
    order_id INT, -- Coming from order table
    delivery_status VARCHAR(55),
    delivery_time TIME,
    rider_id INT, -- coming from rider table
CONSTRAINT FK_order_id FOREIGN KEY (order_id) REFERENCES orders(order_id),
CONSTRAINT FK_rider_id FOREIGN KEY (rider_id) REFERENCES rider(rider_id)
);
```

### 2. Data Exploration & Cleaning

- **Alter Column**: Alter column accordingly .
- **Null Value Check**: Check for any null values in the dataset and delete records with missing data (No missing values).

```sql
-- Add Foreign Keys

Alter table orders 
add constraint FK_customer_id 
foreign key (customer_id)
references customers(customer_id);

Alter table orders 
add constraint FK_restaurant_id
foreign key (restaurant_id)
references restaurants(restaurant_id);
```

### 3. Data Analysis & Findings

The following SQL queries were developed to answer specific business questions:

1. **Write a query to find the top 5 most frequently ordered dishes by customer called "Arjun Mehta" in the last 1 year**:
**/*
-- Join orders and customers table
-- Count Orders
-- Filter only for 'Arjun Mehta' and Order >= 'Last 1 Year'
-- Group by
-- Order by desc
-- Limit for 5
*/**

**A) Query without Windows**

```sql
SELECT 
	c.customer_name, 
	o.order_item AS dishes,
	COUNT(o.order_id) AS total_orders
FROM orders AS o
INNER JOIN
customers AS c
ON o.customer_id = c.customer_id
WHERE 
c.customer_name = 'Arjun Mehta'
AND
order_date >= current_date - INTERVAL '1 Year' 
GROUP BY 1,2
ORDER BY COUNT(o.order_id) DESC
LIMIT 5;
```
**B) Query using Windows (Dense_rank) gives more accurate data in case if there is repeated count of values
  Using Sub_Query to filter out Top_5 ordered dish**

```sql
SELECT 
	customer_name, dishes, total_orders, Top_5 
FROM 
	(SELECT 
		c.customer_name, 
		o.order_item AS dishes,
		COUNT(o.order_id) AS total_orders,
		DENSE_RANK() OVER(ORDER BY COUNT(o.order_id) DESC) AS top_5
	FROM orders AS o
	INNER JOIN
	customers AS c
	ON o.customer_id = c.customer_id
	WHERE 
	c.customer_name = 'Arjun Mehta'
	AND
	order_date >= current_date - INTERVAL '1 Year' 
	GROUP BY 1,2) AS frequently_ordered_dishes
WHERE top_5 <= 5;
```

2. **Popular Time Slots:
   Identify the time slots during which the most orders are placed. based on 2-hour intervals.**:
   
**A)**
```sql
SELECT
(GENERATE_SERIES(
    '2025-01-01 00:00:00'::TIMESTAMP,
    '2025-01-01 23:59:59'::TIMESTAMP,
    '2 hours'::INTERVAL
))::time AS interval_start,
COUNT(order_id)
FROM orders
GROUP BY 1;
```

**B)**
```sql
SELECT 
	CASE
	WHEN EXTRACT(HOUR FROM Order_time) BETWEEN 0 and 1 THEN '00:00 - 02;00'
	WHEN EXTRACT(HOUR FROM Order_time) BETWEEN 2 and 3 THEN '02:00 - 04:00'
	WHEN EXTRACT(HOUR FROM Order_time) BETWEEN 4 and 5 THEN '04:00 - 06:00'
	WHEN EXTRACT(HOUR FROM Order_time) BETWEEN 6 and 7 THEN '06:00 - 08:00'
	WHEN EXTRACT(HOUR FROM Order_time) BETWEEN 8 and 9 THEN '08:00 - 10:00'
	WHEN EXTRACT(HOUR FROM Order_time) BETWEEN 10 and 11 THEN '10:00 - 12:00'
	WHEN EXTRACT(HOUR FROM Order_time) BETWEEN 12 and 13 THEN '12:00 - 14:00'
	WHEN EXTRACT(HOUR FROM Order_time) BETWEEN 14 and 15 THEN '14:00 - 16:00'
	WHEN EXTRACT(HOUR FROM Order_time) BETWEEN 16 and 17 THEN '16:00 - 18:00'
	WHEN EXTRACT(HOUR FROM Order_time) BETWEEN 18 and 19 THEN '18:00 - 20:00'
	WHEN EXTRACT(HOUR FROM Order_time) BETWEEN 20 and 21 THEN '20:00 - 22:00'
	WHEN EXTRACT(HOUR FROM Order_time) BETWEEN 22 and 23 THEN '22:00 - 00:00'
END AS Time_Slot,
COUNT(order_id) AS count_orders
FROM orders
GROUP BY time_slot
ORDER BY count_orders DESC;
```

3. **Order Value Analysis:
   Find the average order value per customer who has placed more than 300 orders.
   Return customer_name, and aov(average order value)**:

**/*
-- Join Orders and Customers table
-- Count orders
-- Filter orders placed only by particular customer > 300 orders
-- Avg value 
-- Sub-Query 
*/**
   
```sql
SELECT Customer_name, Avg_amount FROM 
(SELECT
	c.customer_name AS Customer_name,
	ROUND(AVG(total_amount)) AS Avg_amount,
	COUNT(o.order_id) AS O_C
FROM orders AS o
INNER JOIN
customers AS c
ON o.customer_id = c.customer_id
GROUP BY 1
HAVING COUNT(o.order_id) > 300
ORDER BY Avg_amount DESC) AS Order_Value_Analysis;
```

4. **High-Value Customers:
   List the customers who have spent more than 100K in total on food orders.
   return customer_name, and customer_id**:

**/*
-- Join Orders and Customers table
-- Sum order value
-- Filter order value > 100K
-- Sub-Query 
-- Result = Out of 33 Customer, 32 customers have spent more then 100K
*/**
   
```sql
SELECT customer_name, customer_id FROM 
(SELECT 
	c.customer_name,
	o.customer_id,
	SUM(o.total_amount) AS Total_spent
FROM orders AS o
INNER JOIN
customers AS c
ON o.customer_id = c.customer_id
GROUP BY 1,2
HAVING SUM(o.total_amount) > 100000
ORDER BY Total_spent DESC) AS High_Value_Customers
ORDER BY 2 ASC;
```

5. **Orders Without Delivery:
   Write a query to find orders that were placed but not delivered.
   Return each restuarant name, city and number of not delivered orders**:
   
```sql
SELECT restaurant_name, city, COUNT(Deliver_stat) AS Count_Not_Delivered FROM
(SELECT 
	r.restaurant_name, 
	r.city,
	d.delivery_status AS Deliver_stat
FROM restaurants AS r
INNER JOIN
orders AS o      -- First join with orders table
ON r.restaurant_id = o.restaurant_id
INNER JOIN
deliveries AS d  -- Then join with deliveries table (No common column b/w restaurants & deliveries table )
ON o.order_id = d.order_id
WHERE d.delivery_status = 'Not Delivered') AS Orders_Without_Delivery
GROUP BY 1,2
ORDER BY Count_Not_Delivered DESC;
```

6. **Restaurant Revenue Ranking:
   Rank restaurants by their total revenue from the last year, including their name,
   total revenue, and rank within their city.**:
   
```sql
SELECT 
	r.city,
	r.restaurant_name,
	SUM(o.total_amount) AS Total_revenue,
	DENSE_RANK() OVER(PARTITION BY r.city ORDER BY SUM(o.total_amount) DESC) AS restaurant_rank
FROM 
orders AS o 
INNER JOIN 
restaurants AS r
ON o.restaurant_id = r.restaurant_id
WHERE EXTRACT(YEAR FROM o.order_date) = EXTRACT(YEAR FROM current_date) - 1
GROUP BY 1,2;
```

7. **Most Popular Dish by City:
   Identify the most popular dish in each city based on the number of orders.**:
   
```sql
SELECT city, Most_Popular_Dish_by_City from
(SELECT 
	r.city,
	o.order_item AS Most_Popular_Dish_by_City,
	COUNT(o.order_id) AS Number_of_orders,
	DENSE_RANK() OVER(PARTITION BY r.city ORDER BY COUNT(o.order_id) DESC) AS rnk
FROM 
orders AS o
INNER JOIN
restaurants AS r
ON o.restaurant_id = r.restaurant_id
GROUP BY 1,2) AS Most_Popular_Dish
WHERE rnk = 1;
```

8. **Customer Churn:
   Find customers who haven't placed an order in 2024 but did in 2023.**:

**/* Finding distinct Customers who haven't placed an order in 2024 but did in 2023
   Resulted to '0' Customers as all the customers have ordered in both years
   Solved Query in 2 ways */**

**A) By joining Orders and Customers table**
```sql
SELECT DISTINCT c.customer_id
	FROM 
	customers AS c
	INNER JOIN
	orders AS o
ON c.customer_id = o.customer_id 
WHERE 
EXTRACT(YEAR FROM o.order_date) = 2023
AND
c.customer_id NOT IN
(SELECT DISTINCT c.customer_id
	FROM 
	customers AS c
	INNER JOIN
	orders AS o
ON c.customer_id = o.customer_id 
WHERE
EXTRACT(YEAR FROM o.order_date) = 2024);
```
**B) By Comparing 2 tables**
```sql
SELECT DISTINCT customer_id
	FROM 
	customers 
WHERE 
EXTRACT(YEAR FROM current_date) = EXTRACT(YEAR FROM current_date) - 1
AND
customer_id NOT IN
(SELECT DISTINCT customer_id
	FROM 
	ORDERS
WHERE 
EXTRACT(YEAR FROM current_date) = EXTRACT(YEAR FROM current_date));
```

9. **Rider Average Delivery Time:
   Determine each rider's average delivery time.**:
   
```sql
SELECT 
	o.order_id,
	o.order_time,
	d.delivery_time,
	d.rider_id,
	d.delivery_time - o.order_time AS time_difference,
EXTRACT(EPOCH FROM ( d.delivery_time - o.order_time +
	CASE WHEN d.delivery_time < o.order_time THEN INTERVAL '1 day'
	ELSE INTERVAL '0 day' END))/60 AS time_difference_in_sec
FROM orders AS o
INNER JOIN
deliveries AS d
ON o.order_id = d.order_id
WHERE d.delivery_status = 'Delivered';
```

10. **Monthly Restaurant Growth Ratio:
    Calculate each restaurant's growth ratio based on the total number of delivered orders since its joining.**:
    
```sql
SELECT 
		restaurant_id,
		month,
		Curr_month_orders,
		prev_month_orders,
		ROUND((Curr_month_orders::NUMERIC-prev_month_orders::NUMERIC)/prev_month_orders::NUMERIC * 100,2) AS Growth_ratio FROM (
SELECT
	o.restaurant_id,
	TO_CHAR(o.order_date, 'mm') AS month,
	COUNT(o.order_id) AS Curr_month_orders,
	LAG(COUNT(o.order_id),1) OVER(PARTITION BY o.restaurant_id ORDER BY TO_CHAR(o.order_date, 'mm')) AS prev_month_orders
FROM orders AS o
JOIN
deliveries AS d
ON o.order_id = d.order_id
WHERE d.delivery_status = 'Delivered'
GROUP BY 1,2
ORDER BY 1,2) AS Growth_Ratio;
```

## Findings

- **Customer Demographics**: The dataset contains customers registered at different times, showing a diverse customer base with varying order frequencies. Some customers        are identified as frequent or high-value users based on their total spending across multiple restaurants.
- **High-Value Orders**: Several orders have a total_amount greater than 1000, indicating premium or large group orders. These transactions highlight customers who prefer       high-value meals or multiple-item purchases.
- **Restaurant Performance**: Analysis of the restaurants table shows variations in order volume by city and opening hours, helping identify top-performing restaurants and      peak business hours.
- **Order Trends**: Monthly and daily analysis of the orders table reveals variations in order frequency, indicating peak dining times and busy days for the platform. This      insight supports better restaurant and rider scheduling.
- **Delivery Efficiency**: By examining the deliveries table, patterns in delivery_status and delivery_time reveal insights into rider performance and operational               efficiency. Some riders consistently complete deliveries faster, indicating potential best practices.
- **Rider Performance**: Analysis of the rider table (using sign_up and delivery data) identifies active riders and delivery reliability trends, which can guide resource        allocation and training.

## Reports

- **Orders Summary**: A detailed report summarizing total orders, customer, restaurant demographics, and category performance.
- **Trend Analysis**: Insights into orders trends across different restaurants and dishes.
- **Customer Insights**: Reports on top customers and unique customer counts per orders.

## Conclusion

This project serves as a comprehensive introduction to SQL for data analysts, covering database setup, data cleaning, exploratory data analysis, and business-driven SQL queries. The findings from this project can help drive business decisions by understanding orders patterns, customer behavior, and restaurant performance.

## How to Use

1. **Clone the Repository**: Clone this project repository from GitHub.
2. **Set Up the Database**: Run the SQL scripts provided in the `database_setup.sql` file to create and populate the database.
3. **Run the Queries**: Use the SQL queries provided in the `analysis_queries.sql` file to perform your analysis.
4. **Explore and Modify**: Feel free to modify the queries to explore different aspects of the dataset or answer additional business questions.

## Author - SURAJ M S

This project is part of my portfolio, showcasing the SQL skills essential for data analyst roles. If you have any questions, feedback, or would like to collaborate, feel free to get in touch!

MAIL: surajmagaji023@gmail.com
Thank you!
