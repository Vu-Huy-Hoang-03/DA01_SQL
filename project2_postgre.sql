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
-- B2: CTEs B1 with WHERE rank<=5
SELECT * FROM B_1
WHERE rank_per_month <=5

/* Revenue for each category: total daily revenue for each product category 
over the past 3 months (assuming the current date is 15/4/2022) */
SELECT  b.category,
       	DATE(a.created_at) as dates,
        ROUND(SUM(a.sale_price),2) as profit
FROM order_item as a
INNER JOIN products as b
ON a.product_id = b.id
WHERE DATE(a.created_at) BETWEEN '2022-01-15' AND '2022-04-15'
GROUP BY DATE(a.created_at),b.category
ORDER BY b.category,dates


/* CREATING DATASET + COHORT ANALYSIS */
-- 1. Creating Dataset
-- B1:
WITH B_1 AS (
SELECT  EXTRACT(MONTH FROM c.created_at) as  month,
        EXTRACT(YEAR FROM c.created_at) as  year,
        b.category,
        ROUND(
              SUM(a.sale_price),2) as TPV,
        COUNT(a.order_id) as TPO,
        ROUND(
              SUM(b.cost),2) as total_cost,
        ROUND(
              SUM(a.sale_price)-SUM(b.cost),2) as total_profit,
        ROUND(1.00*
              (SUM(a.sale_price)-SUM(b.cost))
              / SUM(b.cost)
              ,2) as profit_to_cost_ratio
FROM order_item as a
INNER JOIN products as b
ON a.product_id = b.id
INNER JOIN orders as c
		ON a.order_id =c.order_id
GROUP BY year, month, b.category
ORDER BY year, month, b.category
)
-- B2: 
SELECT  month,
        year,
        category,
        TPV,
        TPO,
        COALESCE(
        ROUND(100.00*
                (TPV - prev_TPV) / prev_TPV
                ,2) || '%'
                ,'0.00%') as Revenue_growth,
        COALESCE(
        ROUND(100.00*
                (TPO - prev_TPO) / prev_TPV
                ,2) || '%' 
                ,'0.00%') as Order_growth,
        total_cost,
        total_profit,
        profit_to_cost_ratio
FROM (
SELECT  *,
        LAG(TPV) OVER(PARTITION BY category ORDER BY year,month) as prev_TPV,
        LAG(TPO) OVER(PARTITION BY category ORDER BY year,month) as prev_TPO
FROM B_1
) as tablet