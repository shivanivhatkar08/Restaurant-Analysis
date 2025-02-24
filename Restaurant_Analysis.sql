-- CREATE DATABASE restaurant_db;
USE restaurant_db;

CREATE TABLE order_details (
order_details_id  SMALLINT NOT NULL,
order_id INT NOT NULL,
order_date DATE,
order_time TIME,
item_id SMALLINT,
PRIMARY KEY (order_details_id));

CREATE TABLE menu_items(
menu_item_id SMALLINT NOT NULL,
item_name CHAR(45),
category CHAR(45),
price decimal(5,2),
PRIMARY KEY (menu_item_id));


-- Insert data into table order_details
--
--
-- Insert data into table menu_items
--

SELECT * FROM order_details;
-- View the menu table and the total count of items in the menu
SELECT * FROM menu_items; 
SELECT COUNT(*)  AS total_count FROM menu_items; -- 32 in total

SELECT item_name, price FROM menu_items WHERE price = (SELECT MAX(price) FROM menu_items);
-- The most expensive item in the menu table is the Shrimp Scampi for $19.95.
SELECT item_name, price FROM menu_items WHERE price = (SELECT MIN(price) FROM menu_items);
-- The least expensive item in the menu table is the Edamame for $5.

-- How many Italian dishes are present in the menu?
SELECT category FROM menu_items;
SELECT COUNT(*) AS total_italian_dishes FROM menu_items WHERE category = "Italian"; 
-- So there are total of 9 italian dishes on the menu

-- Now to find the most and least expensive italian dish.
SELECT item_name, price FROM menu_items WHERE category = "Italian" order by price ASC Limit 1; -- Answer is Spaghetti for $14.50
SELECT item_name, price FROM menu_items WHERE category = "Italian" order by price DESC Limit 1; -- Answer is Shrimp Scampi for $19.95

-- Now we have to calculate the how many total dishes are there in each category on the menu
SELECT COUNT(menu_item_id), category FROM menu_items GROUP BY category; -- 6 American, 8 Asian, 9 Mexican, 9 Italian

-- Average price for the dish in each category 
SELECT AVG(price) as average_price, category FROM menu_items GROUP BY category;  --- For American it is 10.06, Asian 13.47, Mexican 11.8, and Italian 16.75


--- View the order table
SELECT * FROM order_details;

SELECT MIN(order_date) as earliest_date, 
max(order_date) as latest_date 
FROM order_details; -- earlist date is 2023-01-01 and latest date is 2023-03-31

-- to find how many orders where within this date range
SELECT COUNT(DISTINCT order_id) as order_ids FROM order_details WHERE order_date BETWEEN '2023-01-01' AND '2023-03-31'; -- 5370 orders were placed it seems

-- to find how many items were ordered in this date range
SELECT count(order_details_id) as items_id FROM order_details WHERE order_date BETWEEN '2023-01-01' AND '2023-03-31'; -- 12234 items were ordered

-- which orders had the most number of items?
SELECT order_id, COUNT(item_id) as num_items FROM order_details GROUP BY order_id ORDER BY num_items DESC;  -- we can many orders had items 14

-- which orders had more than 12 items? -- 20 ORDERS 
SELECT COUNT(*) FROM (SELECT order_id, COUNT(item_id) as num_items FROM order_details 
GROUP BY order_id HAVING num_items > 12) AS num_orders;

-- Analyzing customer behaviour
-- Combining menu and order table into a single table
SELECT * 
FROM order_details 
LEFT JOIN menu_items  ON order_details.item_id = menu_items.menu_item_id;


-- least and most ordered items
SELECT item_name, category, count(order_details_id) as num_purchases
FROM order_details 
LEFT JOIN menu_items  ON order_details.item_id = menu_items.menu_item_id
GROUP BY item_name,category
order by num_purchases DESC;  -- least chicken tacos and most is hamburger

--- top 5 that spent the most
SELECT order_id, SUM(price) as total 
FROM order_details 
LEFT JOIN menu_items  ON order_details.item_id = menu_items.menu_item_id
GROUP BY order_id
order by total DESC LIMIT 5;  -- top 5 are 440 = 192.15, 2075 = 191.05, 1957 = 190.10, 330 = 189.70, and 2675 = 185.10


--- HIGHEST SPENT ORDER
SELECT category, COUNT(item_id) as num_items
FROM order_details 
LEFT JOIN menu_items  ON order_details.item_id = menu_items.menu_item_id
WHERE order_id = 440
GROUP BY category; --- it is italian


---- top 5 highest spent orders and insights
SELECT order_id, category, COUNT(item_id) as num_items
FROM order_details 
LEFT JOIN menu_items  ON order_details.item_id = menu_items.menu_item_id
WHERE order_id IN (440, 2075, 1957, 330, 2675)
GROUP BY order_id, category; 
---- We can see that italian food is the most ordered food 


--- What are the busiest hours of the day?
SELECT TIME_FORMAT(order_time, '%H:%i') as order_hour, COUNT(order_id) as total_orders
FROM order_details
GROUP BY order_hour
ORDER BY total_orders DESC LIMIT 5;  -- so the busiest hours of the day is from 12 to 2 pm

-- Now we want to know the busiest days of the week and the slow days for discounts
SELECT dayname(order_date) as order_day, COUNT(order_id) as total_orders
FROM order_details
GROUP BY order_date
ORDER BY total_orders desc LIMIT 5 ;

-- Cross - selling analysis ( which item is often bought with a specific item)
SELECT x.item_name AS main_item, y.item_name AS paired_item, COUNT(*) AS paired_count
FROM order_details od1 
JOIN order_details od2 
ON od1.order_id = od2.order_id AND od1.item_id <> od2.item_id
JOIN menu_items x ON od1.item_id = x.menu_item_id
JOIN menu_items y ON od2.item_id = y.menu_item_id
WHERE x.item_name = "Hamburger"
GROUP BY main_item, paired_item
ORDER BY paired_count DESC Limit 5; -- The most ordered item Shrimp scampi is often bought with Edamame with a paired count of 34

--- Category Based Item pairing (to identify which categories were bought together)

SELECT LEAST(a.category, b.category) AS cat_1, GREATEST(a.category, b.category) as cat_2, COUNT(*) as paired_count
FROM order_details od1
JOIN order_details od2 
ON od1.order_id = od2.order_id AND od1.item_id <> od2.item_id
JOIN menu_items a ON od1.item_id = a.menu_item_id
JOIN menu_items b ON od2.item_id = b.menu_item_id
GROUP BY cat_1, cat_2
ORDER BY paired_count DESC LIMIT 5; -- the top 2 categories are ASIAN WITH MEXICAN COUNT = 4282 AND THEN ASIAN WITH ITALIAN COUNT = 4218


-- BASKET ANALYSIS - ORDERS WITH MORE THAN 2 ITEMS
SELECT order_id , COUNT(item_id) as Total_items
FROM order_details 
GROUP BY order_id
HAVING Total_items > 2
ORDER BY Total_items DESC; -- Order id 330 ordered 14

-- Just to analyze what was order 330. Looks like it was a big party who ordered a lot of food
SELECT * FROM order_details 
LEFT JOIN menu_items  ON order_details.item_id = menu_items.menu_item_id
WHERE order_id = 330;