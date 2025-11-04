-- Zomato Data Analysis

-- Creation of tables : Customers, Restaurants, Orders, Riders, Deliveries

Create table customers
(
customer_id int primary key,	
customer_name varchar(25),
reg_date date
);

Create table restaurants
(
restaurant_id int primary key,
restaurant_name	varchar(55),
city varchar(55),
opening_hours varchar(55)
);

Create table orders
(order_id int primary key,
customer_id	int, -- Coming from customer table
restaurant_id int, -- Coming from resturant table
order_item varchar(55),
order_date date,
order_time time,
order_status varchar(55),
total_amount float
);

-- Add Foreign Keys

Alter table orders 
add constraint FK_customer_id 
foreign key (customer_id)
references customers(customer_id);

Alter table orders 
add constraint FK_restaurant_id
foreign key (restaurant_id)
references restaurants(restaurant_id);

Create table rider
(
rider_id int primary key,
rider_name varchar(55),
sign_up date
);

Create table deliveries
(
delivery_id	int primary key,
order_id int, -- Coming from order table
delivery_status	varchar(55),
delivery_time time,
rider_id int, -- coming from rider table
constraint FK_order_id foreign key (order_id) references orders(order_id),
constraint FK_rider_id foreign key (rider_id) references rider(rider_id)
);

