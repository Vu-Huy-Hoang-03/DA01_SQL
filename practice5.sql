-- Ex1
SELECT b.continent, FLOOR(AVG(a.population)) AS avg_city_population
FROM city AS a
INNER JOIN country AS b
ON a.countrycode = b.code
GROUP BY b.continent

-- Ex2
SELECT ROUND( CAST(COUNT(CASE WHEN b.signup_action = 'Confirmed' THEN 1 END) AS DECIMAL) / COUNT(*) , 2) AS confirm_rate
FROM emails as a
RIGHT JOIN texts as b
ON a.email_id = b.email_id
-- RIGHT JOIN để khi COUNT(*) ra tổng số lượt email đã gửi

-- Ex3
SELECT b.age_bucket,
        ROUND(SUM(CASE WHEN a.activity_type = 'open' THEN time_spent ELSE 0 END)*100 /SUM(time_spent),2) as open_perc,
        ROUND(SUM(CASE WHEN a.activity_type = 'send' THEN time_spent ELSE 0 END)*100 /SUM(time_spent),2 ) as send_perc
FROM activities AS a
LEFT JOIN age_breakdown AS b 
ON a.user_id = b.user_id
WHERE a.activity_type IN ('open', 'send')
GROUP BY b.age_bucket

-- Ex4
SELECT customer_id
FROM customer_contracts as a
LEFT JOIN products as b 
ON a.product_id = b.product_id
GROUP BY customer_id
HAVING COUNT(DISTINCT b.product_category) = 3
--COUNT(distinct product_category) FROM products = 3 = tổng sl category
  
SELECT customer_id
FROM customer_contracts as a
LEFT JOIN products as b 
ON a.product_id = b.product_id
GROUP BY customer_id
HAVING COUNT(DISTINCT b.product_category) = (select count(distinct product_category) from products)

-- Ex5 --
SELECT b.employee_id, b.name, COUNT(a.employee_id) as reports_count, ROUND(AVG(a.age),0) as average_age
FROM employees as a
INNER JOIN employees as b
ON a.reports_to = b.employee_id
GROUP BY b.employee_id, b.name
ORDER BY b.employee_id
  
-- Ex6
select b.product_name, SUM(unit) as unit
from orders as a
left join products as b
on a.product_id = b.product_id
where extract(month from order_date) =2 AND extract(year from order_date) =2020
group by b.product_name
having sum(unit)>=100

-- Ex7
SELECT a.page_id
FROM pages as a
LEFT JOIN page_likes as b
ON a.page_id = b.page_id
WHERE b.liked_date IS NULL
ORDER BY a.page_id

SELECT a.page_id
FROM pages as a
LEFT JOIN page_likes as b
ON a.page_id = b.page_id
GROUP BY a.page_id
HAVING COUNT(b.liked_date) = 0
ORDER BY a.page_id


