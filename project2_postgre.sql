-- Creating Tables & Importing Data
CREATE TABLE order_item
(
	id numeric primary key,
	order_id numeric,
	user_id numeric,
	product_id numeric ,
	inventory_item_id numeric,
	status varchar,
	created_at  timestamp,
	shipped_at timestamp,
	delivered_at timestamp,
	returned_at timestamp,
	sale_price numeric
)
	
CREATE TABLE orders
(
	order_id numeric primary key,
	user_id numeric,
	status varchar,
	gender varchar,
	created_at  timestamp,
	returned_at timestamp,
	shipped_at timestamp,
	delivered_at timestamp,
	num_of_item numeric
)

CREATE TABLE products
(
	id numeric primary key,
	cost numeric,
	category varchar,
	name varchar,
	brand varchar,
	retail_price numeric,
	department varchar,
	sku varchar,
	distribution_center_id numeric
)

CREATE TABLE users
(
	id numeric primary key,
	first_name varchar,
	last_name varchar,
	email varchar,
	age numeric, 
	gender varchar,
	state varchar,
	street_address varchar,
	postal_code varchar,
	city varchar,
	country varchar,
	latitude numeric,
	longitude numeric,
	traffic_source varchar,
	created_at timestamp
)


-- Cleaning & Structuring Data
select * from order_item
where id is NULL

select * from orders
where order_id is NULL

select * from products
where id IS NULL 

-- 0 values IS NULL


-- Analyzing
/* Amount of Customers and Orders each months from January 2019 to April 2022 */
-- Output: month_year ( yyyy-mm) , total_user, total_order
SELECT	TO_CHAR(created_at, 'yyyy-mm') as month_year,
		COUNT(order_id) as total_order,
		COUNT(DISTINCT user_id) as total_user
FROM orders
WHERE DATE(created_at) BETWEEN '2019-01-01' AND '2022-04-30'
GROUP BY TO_CHAR(created_at, 'yyyy-mm')

/* Average Order Value (AOV) and Monthly Active Customers 
- from January 2019 to April 2022 */
-- Output: month_year ( yyyy-mm), distinct_users, average_order_value
SELECT	TO_CHAR(a.created_at, 'yyyy-mm') as month_year,
		ROUND(
			  AVG(b.sale_price)
			,2) as average_order_value,
		COUNT(DISTINCT a.user_id) as total_user
FROM orders as a
INNER JOIN order_item as b
	ON a.order_id = b.order_id
WHERE DATE(a.created_at) BETWEEN '2019-01-01' AND '2022-04-30'
GROUP BY TO_CHAR(a.created_at, 'yyyy-mm')

/* Customer Segmentation by Age: Identify the youngest and oldest customers 
for each gender from January 2019 to April 2022 */
-- Output: full_name, gender, age, tag (youngest-oldest)
(SELECT	CONCAT(first_name, ' ', last_name) as full_name,
		gender,
		MIN(age) OVER(PARTITION BY gender) as age,
		'youngest' as tag
FROM users as a
WHERE age IN (SELECT MIN(age) FROM users)
	AND DATE(a.created_at) BETWEEN '2019-01-01' AND '2022-04-30')
UNION ALL
(SELECT	CONCAT(first_name, ' ', last_name) as full_name,
		gender,
		MAX(age) OVER(PARTITION BY gender) as age,
		'oldest' as tag
FROM users as a
WHERE age IN (SELECT MAX(age) FROM users)
	AND DATE(a.created_at) BETWEEN '2019-01-01' AND '2022-04-30')
	
/* Top 5 products with the highest profit each month (rank each product) */
-- Output: month_year ( yyyy-mm), product_id, product_name, 
-- sales, cost, profit, rank_per_month

-- B1: rank profit by month
WITH B_1 AS(
SELECT 	TO_CHAR(a.created_at, 'yyyy-mm') as month_year,
		a.product_id,
		b.name,
		ROUND(
			SUM(a.sale_price),2) as sales,
		ROUND(
			SUM(b.cost),2) as cost,
		ROUND(
			SUM(a.sale_price) - SUM(b.cost),2) as profit,
		DENSE_RANK() OVER(
						PARTITION BY TO_CHAR(a.created_at, 'yyyy-mm')
						ORDER BY (SUM(a.sale_price) - SUM(b.cost)) DESC) as rank_per_month
FROM order_item as a
INNER JOIN products as b
	on a.product_id = b.id
GROUP BY TO_CHAR(a.created_at, 'yyyy-mm'),a.product_id,b.name 
)
SELECT * FROM B_1
WHERE rank_per_month <5

-------  
