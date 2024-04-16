-- Ex1 -------------------------------------------------------------------------------------------------------------------
C1
-- công ty có job title trùng
WITH company AS(
SELECT DISTINCT company_id FROM job_listings as a
WHERE title IN (SELECT title FROM job_listings 
                  WHERE company_id=a.company_id AND job_id <> a.job_id) 
)
-- COUNT(company mà post job title trùng)
SELECT COUNT(company_id) FROM company

C2
-- count job theo title theo id_job và theo từng công ty
WITH company AS (
SELECT company_id, title, COUNT(job_id) as amount_job FROM job_listings
GROUP BY company_id, title 
)
-- COUNT(company) với điều kiện count(job) >1 
SELECT COUNT(DISTINCT company) FROM company
WHERE amount_job >1

  
-- Ex2 -------------------------------------------------------------------------------------------------------------------
-- select distinct -> tìm category => tìm 2 product > nhất từng category rồi Union
(SELECT category, product, SUM(spend) as total_spend
FROM product_spend
WHERE category = 'appliance' AND EXTRACT(Year FROM transaction_date) = 2022
GROUP BY category, product
ORDER BY SUM(spend) DESC
LIMIT 2)
UNION ALL
(SELECT category, product, SUM(spend) as total_spend
FROM product_spend
WHERE category = 'electronics' AND EXTRACT(Year FROM transaction_date) = 2022
GROUP BY category, product
ORDER BY SUM(spend) DESC
LIMIT 2)

  
-- Ex3 -------------------------------------------------------------------------------------------------------------------
-- CTEs: danh sách người gọi >=3 cuộc
WITH UHG_caller AS (
SELECT policy_holder_id FROM callers
GROUP BY policy_holder_id 
HAVING COUNT(case_id)>=3 
)
SELECT COUNT(policy_holder_id) FROM UHG_caller


-- Ex4 -------------------------------------------------------------------------------------------------------------------
SELECT a.page_id 
FROM pages AS a
LEFT JOIN page_likes AS b
ON a.page_id = b.page_id
WHERE liked_date IS NULL
ORDER BY a.page_id


-- Ex5 -------------------------------------------------------------------------------------------------------------------
C1:
--CTEs: user tháng trước (t6)
  WITH June AS (
SELECT distinct user_id
FROM user_actions
WHERE EXTRACT(MONTH from event_date)=6 AND EXTRACT(YEAR from event_date)=2022 
)
SELECT EXTRACT(MONTH from a.event_date) as month, COUNT(DISTINCT b.user_id) as monthly_active_users
FROM user_actions as a
LEFT JOIN June as b ON b.user_id = a.user_id
WHERE EXTRACT(MONTH from a.event_date)=7 AND EXTRACT(YEAR from a.event_date)=2022
      AND b.user_id IS NOT NULL
GROUP BY month

C2:
SELECT EXTRACT(MONTH from a.event_date) as month, COUNT(DISTINCT a.user_id) as monthly_active_users
FROM user_actions as a
INNER JOIN user_actions as b 
ON a.user_id = b.user_id AND EXTRACT(MONTH from b.event_date) = EXTRACT(MONTH from a.event_date - interval '1 month')
WHERE EXTRACT(MONTH from a.event_date)=7 AND EXTRACT(YEAR from a.event_date)=2022
GROUP BY month
-- để cộng/trừ thời gian: date/time + interval '___'


-- Ex6 ------------------------------------------------------------------------------------------------------------------- 
SELECT TO_CHAR(trans_date, 'YYYY-MM') as month, country,
        COUNT(id) as trans_count, 
        COUNT(CASE WHEN state='approved' THEN 1 END) as approved_count,
        SUM(amount) as trans_total_amount,
        SUM(CASE WHEN state='approved' THEN amount ELSE 0 END) as approved_total_amount
FROM transactions
GROUP BY month, country


-- Ex7  -------------------------------------------------------------------------------------------------------------------
-- CTEs: min year của từng product_id
WITH min_year AS (
SELECT MIN(year) as min, product_id
FROM Sales
GROUP BY product_id
)
SELECT a.product_id, b.min  as first_year, a.quantity, a.price
FROM sales AS a
INNER JOIN min_year as b
ON a.year = b.min AND a.product_id = b.product_id


-- Ex8  -------------------------------------------------------------------------------------------------------------------
SELECT customer_id
FROM customer
GROUP BY customer_id
HAVING COUNT(DISTINCT product_key) = (SELECT COUNT(product_key) FROM Product)

  
-- Ex9  -------------------------------------------------------------------------------------------------------------------
SELECT a.employee_id
FROM employees as a
LEFT JOIN employees as b
ON a.manager_id = b.employee_id
WHERE b.employee_id IS NULL and a.manager_id IS NOT NULL
        AND a.salary<30000
ORDER BY a.employee_id


-- Ex10  -------------------------------------------------------------------------------------------------------------------
--giống câu 1
  

-- Ex11  -------------------------------------------------------------------------------------------------------------------
-- name of user có số lượng rating nhất, sắp xếp theo user_id 
-- UNION
-- name of movide có trung bình rating cao nhất ở 2/2020
(
SELECT b.name as Results
FROM MovieRating AS a
LEFT JOIN Users AS b
ON a.user_id = b.user_id
GROUP BY b.name
ORDER BY COUNT(a.rating) DESC, b.name ASC
LIMIT 1
)
UNION ALL
(
SELECT b.title as Results
FROM MovieRating AS a
LEFT JOIN Movies AS b
ON a.movie_id = b.movie_id
WHERE created_at BETWEEN '2020-02-01' AND '2020-02-29'
GROUP BY b.title
ORDER BY AVG(a.rating) DESC, b.title ASC
LIMIT 1
)


-- Ex12  -------------------------------------------------------------------------------------------------------------------
WITH counta AS (
(SELECT accepter_id as id, COUNT(accepter_id) as count
FROM RequestAccepted
GROUP BY accepter_id
)
UNION ALL 
(SELECT requester_id as id, COUNT(requester_id) as count
FROM RequestAccepted
GROUP BY requester_id
)
)
SELECT id, SUM(count) as num
FROM counta
GROUP BY id
ORDER BY num DESC
LIMIT 1
