CREATE TABLE customers AS (
SELECT * FROM users
WHERE id IN (
	SELECT 	user_id
	FROM order_item
	WHERE created_at BETWEEN '2023-01-01' AND '2023-12-31' AND status NOT IN ('Cancelled', 'Returned')
	GROUP BY user_id
	ORDER BY user_id )
)

SELECT * FROM customers

--------------------------------------------------

WITH step_1 AS (
SELECT 	user_id, MAX(created_at) as latest_date, 
		('2023-12-31' - MAX(created_at)) as date_diff
FROM order_item
WHERE created_at BETWEEN '2023-01-01' AND '2023-12-31' AND status NOT IN ('Cancelled', 'Returned')
GROUP BY user_id
ORDER BY user_id
),
step_2 AS (
SELECT	*,
		CASE
			WHEN EXTRACT(DAY FROM date_diff) > 90 THEN 'churn'
			ELSE 'normal'
		END as cus_category
FROM step_1
)
-- , step_3 AS (
SELECT a.*, b.cus_category
FROM customers as a
INNER JOIN step_2 as b
	ON a.id = b.user_id
-- )

SELECT country, COUNT(id) as number
FROM step_3
WHERE cus_category = 'churn'
GROUP BY country
ORDER BY number DESC
LIMIT 5

SELECT country, city, COUNT(id) as number
FROM step_3
WHERE cus_category = 'churn'
GROUP BY country, city
ORDER BY number DESC
---
SELECT gender, COUNT(id) as number
FROM step_3
WHERE cus_category = 'churn'
GROUP BY gender
ORDER BY number DESC
---
, number_churn AS (
SELECT traffic_source, COUNT(id) as number_churn
FROM step_3
WHERE cus_category = 'churn'
GROUP BY traffic_source
)
, number_all AS (
SELECT traffic_source, COUNT(id) as number_all
FROM step_3
GROUP BY traffic_source
ORDER BY number_all DESC
)

SELECT 	a.*, b.number_churn,
		ROUND(1.00 * b.number_churn / a.number_all , 2) as churn_perc
FROM number_all AS a
INNER JOIN number_churn AS b
	ON a.traffic_source = b.traffic_source
ORDER BY churn_perc DESC
---
