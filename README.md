# Zomato Data Analysis SQL Project

## Project Overview

**Project Title**: Zomato-Data-Analysis-SQL-Project--P2  
**Level**: Intermediate  
**Database**: `Zomato_Pro`

This project is designed to demonstrate SQL skills and techniques typically used by data analysts to explore, clean, and analyze retail sales data. The project involves setting up a retail sales database, performing exploratory data analysis (EDA), and answering specific business questions through SQL queries. This project is ideal for those who are starting their journey in data analysis and want to build a solid foundation in SQL.

## Objectives

1. **Set up a retail sales database**: Create and populate a retail sales database with the provided sales data.
2. **Data Cleaning**: Identify and remove any records with missing or null values.
3. **Exploratory Data Analysis (EDA)**: Perform basic exploratory data analysis to understand the dataset.
4. **Business Analysis**: Use SQL to answer specific business questions and derive insights from the sales data.

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

5. **Write a SQL query to find all transactions where the total_sale is greater than 1000.**:
```sql
SELECT * FROM retail_sales
WHERE total_sale > 1000;
```

6. **Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.**:
```sql
SELECT 
    category,
    gender,
    COUNT(*) as t_transactions,
    COUNT(transactions_id) as t_t
FROM retail_sales
GROUP 
    BY 
    category,
    gender
ORDER BY 1;
```

7. **Write a SQL query to calculate the average sale for each month. Find out best selling month in each year**:
```sql
SELECT 
       yr,
       b_s_mnth,
    avg_sale
FROM 
(    
SELECT 
    YEAR(sale_date) as yr,
    MONTH(sale_date) as b_s_mnth,
    ROUND(AVG(total_sale),0) as avg_sale,
    DENSE_RANK() OVER(PARTITION BY YEAR(sale_date) ORDER BY ROUND(AVG(total_sale),0) ) as rnk
FROM retail_sales
GROUP BY 1, 2
) as best_selling_month 
WHERE rnk = 12;
```

8. **Write a SQL query to find the top 5 customers based on the highest total sales.**:
```sql
SELECT 
    customer_id,
    SUM(total_sale) as total_sales
FROM retail_sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;
```

9. **Write a SQL query to find the number of unique customers who purchased items from each category.**:
```sql
SELECT 
    category,    
    COUNT(DISTINCT customer_id) unique_customer
FROM retail_sales
GROUP BY 1;
```

10. **Write a SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17)**:
```sql
WITH hourly_sale
AS
(
SELECT *,
    CASE
        WHEN HOUR(sale_time) <= 12 THEN 'Morning'
        WHEN HOUR(sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END as shift
FROM retail_sales
)
SELECT 
    shift,
    COUNT(*)   
FROM hourly_sale
GROUP BY shift;
```

```sql
SELECT
    shift,
    COUNT(*)
from
(
Select *,
    Case
        WHEN HOUR(sale_time) <=12 THEN "Morning"
        WHEN HOUR(sale_time) BETWEEN 12 AND 17 THEN "Afternoon"
        ELSE "Evening"
    END as shift
FROM retail_sales
) as ab
GROUP BY 1;
```

## Findings

- **Customer Demographics**: The dataset includes customers from various age groups, with sales distributed across different categories such as Clothing and Beauty.
- **High-Value Transactions**: Several transactions had a total sale amount greater than 1000, indicating premium purchases.
- **Sales Trends**: Monthly analysis shows variations in sales, helping identify peak seasons.
- **Customer Insights**: The analysis identifies the top-spending customers and the most popular product categories.

## Reports

- **Sales Summary**: A detailed report summarizing total sales, customer demographics, and category performance.
- **Trend Analysis**: Insights into sales trends across different months and shifts.
- **Customer Insights**: Reports on top customers and unique customer counts per category.

## Conclusion

This project serves as a comprehensive introduction to SQL for data analysts, covering database setup, data cleaning, exploratory data analysis, and business-driven SQL queries. The findings from this project can help drive business decisions by understanding sales patterns, customer behavior, and product performance.

## How to Use

1. **Clone the Repository**: Clone this project repository from GitHub.
2. **Set Up the Database**: Run the SQL scripts provided in the `database_setup.sql` file to create and populate the database.
3. **Run the Queries**: Use the SQL queries provided in the `analysis_queries.sql` file to perform your analysis.
4. **Explore and Modify**: Feel free to modify the queries to explore different aspects of the dataset or answer additional business questions.

## Author - SURAJ M S

This project is part of my portfolio, showcasing the SQL skills essential for data analyst roles. If you have any questions, feedback, or would like to collaborate, feel free to get in touch!

MAIL: surajmagaji023@gmail.com
Thank you!
