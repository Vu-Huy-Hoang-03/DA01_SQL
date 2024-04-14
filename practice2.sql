-- Ex1
SELECT DISTINCT City FROM Station
WHERE ID%2=0
-- số chẵn -> chia 2 dư 0
-- số lẻ -> chia 2 dư 1

-- Ex2
SELECT ( COUNT(*) - COUNT(DISTINCT city) )
FROM Station

-- Ex3
SELECT CEILING(ABS(AVG(REPLACE(salary,'0', '')) - AVG(salary)))
FROM Employees

-- Ex4
SELECT ROUND(CAST(SUM(item_count * order_occurrences) / SUM(order_occurrences) as DECIMAL), 1)
FROM items_per_order;
-- CAST - chuyển định dạng dữ liệu

-- Ex5
SELECT candidate_id
FROM candidates
WHERE skill IN ('Python', 'Tableau', 'PostgreSQL')
GROUP BY candidate_id 
HAVING COUNT(skill) =3;

-- Ex6
SELECT user_id, (DATE(MAX(post_date)) - DATE(MIN(post_date))) as days_between
FROM posts
WHERE DATE(post_date) BETWEEN '2021-01-01' AND '2021-12-31'
GROUP BY user_id
HAVING COUNT(post_date) >=2
-- lưu ý nếu tgian có cả giờ => nên dùng DATE

-- Ex7
SELECT card_name, (MAX(issued_amount) - MIN(issued_amount)) as difference
FROM monthly_cards_issued
GROUP BY card_name
ORDER BY (MAX(issued_amount) - MIN(issued_amount)) DESC

-- Ex8
SELECT manufacturer, COUNT(product_id) as drug_count,
SUM(cogs - total_sales) as total_loss
FROM pharmacy_sales
WHERE total_sales < cogs
GROUP BY manufacturer
ORDER BY SUM(cogs - total_sales) DESC

-- Ex9
SELECT teacher_id, COUNT(subject_id) as cnt
FROM Teacher
GROUP BY teacher_id

-- Ex10
SELECT teacher_id, COUNT(DISTINCT subject_id) as cnt
FROM Teacher
GROUP BY teacher_id

-- Ex11
SELECT user_id, COUNT(follower_id) as followers_count
FROM Followers
GROUP BY user_id
ORDER BY user_id

-- Ex12
SELECT class
FROM Courses
GROUP BY class
HAVING COUNT(student) >=5









