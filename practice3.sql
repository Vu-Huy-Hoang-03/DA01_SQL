-- Ex1
SELECT Name
FROM Students
WHERE marks >75
ORDER BY RIGHT(Name,3), ID

-- Ex2
SELECT user_id, 
CONCAT(UPPER(LEFT(Name,1)), LOWER(RIGHT(Name, LENGTH(Name)-1))) as name
FROM Users
Order by user_id

SELECT user_id
CONCAT(UPPER(LEFT(name,1), LOWER(SUBSTRING(Name,2)))) as name
FROM Users
Order by user_id
-- nếu không nhập số ký tự cần tách -> SUBSTRING sẽ tách từ ký tự __ đến hết

-- Ex3
SELECT manufacturer, CONCAT('$', ROUND(CAST(SUM(total_sales) AS DECIMAL)/1000000, 0),' ' ,'million') as sale
FROM pharmacy_sales
GROUP BY manufacturer
ORDER BY SUM(total_sales) DESC, manufacturer

-- Ex4
SELECT EXTRACT(MONTH from submit_date) as mth, product_id,
        ROUND(AVG(stars),2) as avg_star
FROM reviews
GROUP BY EXTRACT(MONTH from submit_date), product_id
ORDER BY EXTRACT(MONTH from submit_date), product_id

-- Ex5
SELECT sender_id, COUNT(message_id) as message_count
FROM messages
WHERE DATE(sent_date) BETWEEN '2022-08-01' AND '2022-08-31'
GROUP BY sender_id
ORDER BY COUNT(message_id) DESC
LIMIT 2

-- Ex6
SELECT tweet_id
FROM tweets
WHERE LENGTH(content)>15x6

-- Ex7
select activity_date as day, COUNT(DISTINCT user_id) as active_users
from activity
where activity_date between '2019-06-27' AND '2019-07-27'
group by activity_date

-- Ex8
select  COUNT(last_name) as amount_new_employees
from employees
where extract(month from joining_date) between 1 and 7 
        and extract(year from joining_date) =2022

-- Ex9
select position('a' from first_name)
from worker
where first_name = 'Amitah'
-- POSITION phân biệt chữ hoa/thường

-- Ex10
select SUBSTRING(title, LENGTH(winery)+2, 4)
from winemag_p2
where coountry = 'Macedonia'












