-- 1757. Recyclable and Low Fat Products ---------------------------------------------------------------------------------------------------------------------
-- output: product_id 
SELECT product_id
FROM products 
WHERE low_fats ='Y' AND recyclable = 'Y'

-- 1378. Replace Employee ID With The Unique Identifier  -----------------------------------------------------------------------------------------------------
--output: unique_id, name
SELECT b.unique_id, name
FROM employees as a
LEFT JOIN employeeUNI as b
    ON a.id = b.id

-- 1068. Product Sales Analysis I
-- output:  product_name, year, price 
SELECT b.product_name, a.year, a.price
FROM sales as a
INNER JOIN product as b
  ON a.product_id = b.product_id

-- 1581. Customer Who Visited but Did Not Make Any Transactions ----------------------------------------------------------------------------------------------
-- output: customer_id, count_no_trans
-- C1: count_no_trans = count(a.visit_id) - b.visit_id
SELECT a.customer_id, (COUNT(a.visit_id) - COUNT(b.visit_id)) as count_no_trans
FROM visits as a
LEFT JOIN transactions as b
    ON a.visit_id = b.visit_id
GROUP BY a.customer_id
HAVING (COUNT(a.visit_id) - COUNT(b.visit_id)) >0

-- C2: SubQuery in Where 
SELECT customer_id, COUNT(visit_id) as count_no_trans
FROM visits
WHERE visit_id NOT IN (SELECT visit_id FROM transactions)
GROUP BY customer_id
HAVING COUNT(visit_id) >0

-- 197. Rising Temperature  ----------------------------------------------------------------------------------------------------------------------------------
-- output:id (higher temperatures compare to yesterday)
-- C1: LAG OVER(ORDER BY recordDate)
SELECT id 
FROM (
SELECT  id, recordDate, temperature,
        LAG(recordDate) OVER(ORDER BY recordDate) as prev_date,
        LAG(temperature) OVER(ORDER BY recordDate) as prev_tem
FROM weather) as tablet
WHERE   temperature > prev_tem
        AND recordDate - prev_date = 1

-- C2: intervals '1 day'
SELECT a.id
FROM weather as a
INNER JOIN weather as b
    ON a.recordDate = b.recordDate + interval '1 days'
WHERE a.temperature > b.temperature

-- 1661. Average Time of Process per Machine  ----------------------------------------------------------------------------------------------------------------
/* C1 */
-- B1: SELF JOIN -> để cho 1 dòng hiện cả thời gian bắt đầu và kết thúc
-- đặt điều kiện a.type = start -> tránh lặp
-- B2: SubQuery B1 trong FROM -> AVG() gom khối theo machine_id
SELECT  DISTINCT machine_id, 
        ROUND(
            CAST(AVG(process_time) OVER(PARTITION BY machine_id) as decimal)
        ,3) as processing_time
FROM (
SELECT a.machine_id, a.process_id, ABS(a.timestamp - b.timestamp) as process_time
FROM activity as a
INNER JOIN activity as b
    ON a.machine_id = b.machine_id 
    AND a.process_id = b.process_id
    AND a.activity_type != b.activity_type
WHERE a.activity_type = 'start'
) as B1
ORDER BY processing_time ASC

/* C2 */
SELECT  machine_id,
        ROUND(CAST (AVG(CASE
                    WHEN activity_type = 'start' THEN -(timestamp)
                    WHEN activity_type = 'end' THEN (timestamp)
                    END) 
                as DECIMAL) *2  /*vì có 2 dòng machine_id nên nếu AVG luôn sẽ bị chia 2 */
            ,3) as processing_time
FROM activity
GROUP BY machine_id

-- 577. Employee Bonus ---------------------------------------------------------------------------------------------------------------------------------------
--output: name, bonus (<1000)
SELECT a.name, b.bonus
FROM employee as a
LEFT JOIN bonus as b
    ON a.empID = b.empID 
WHERE   b.bonus <1000 
        OR b.bonus IS NULL

-- 1280. Students and Examinations ---------------------------------------------------------------------------------------------------------------------------
-- output: student_id, student_name, subject_name, attended_exams
SELECT  a.student_id, a.student_name, c.subject_name,
        COUNT(b.student_id) as attended_exams
FROM students as a 
CROSS JOIN subjects as c
LEFT JOIN examinations as b                                                /* LEFT JOIN vì trong bảng này có HV 0 thi 1 số môn */
    ON a.student_id = b.student_id AND c.subject_name = b.subject_name
GROUP BY a.student_id, a.student_name, c.subject_name
ORDER BY student_id

/*  CROSS JOIN = FULL JOIN nhưng không cần key join mà kết nối full dữ liệu theo toàn bộ các tổ hợp
    FULL JOIN thì với các môn học không có trong bảng Examinations thì các thông tin khác như student_id, name sẽ bị NULL */

-- 570. Managers with at Least 5 Direct Reports --------------------------------------------------------------------------------------------------------------
-- output name
/* C1 */
SELECT b.name
FROM employee as a
INNER JOIN employee as b
    ON a.managerID = b.id
GROUP BY b.id, b.name
HAVING COUNT(a.managerId) >=5

/* C2 */
SELECT name FROM Employee
WHERE id IN (
            select managerId from employee 
            group by managerId 
            having count(id) >= 5
            )

-- 1934. Confirmation Rate --------------------------------------------------------------------------------------------------------------------------------------
-- output: user_id, confirmation_rate 
SELECT  a.user_id,
        ROUND(
            AVG(CASE WHEN b.action = 'confirmed' THEN 1 ELSE 0 END)
            ,2) as confirmation_rate 
FROM signups as a
LEFT JOIN confirmations as b
    ON a.user_id = b.user_id
GROUP BY a.user_id

-- 620. Not Boring Movies --------------------------------------------------------------------------------------------------------------------------------------
-- output: id, movie, des, rating
-- id số lẻ (!2=1), des <> 'boring' 
SELECT * FROM Cinema
WHERE id%2 <>0 AND description <> 'boring'
ORDER BY rating DESC

-- 1251. Average Selling Price ---------------------------------------------------------------------------------------------------------------------------------
-- output: product_id, average_price = AVG(price*units / units)
-- price: purchase_date BETWEEN start AND end
SELECT  a.product_id, 
        COALESCE(
                ROUND(
                    SUM(a.price * b.units) / 
                    CAST(SUM(b.units) AS DECIMAL)
                    ,2)
                ,0) as average_price
FROM prices as a
LEFT JOIN unitssold as b
    ON a.product_id = b.product_id
    AND b.purchase_date BETWEEN a.start_date AND a.end_date
GROUP BY a.product_id

-- 1075. Project Employees I ---------------------------------------------------------------------------------------------------------------------------------
-- output: project, average_years = AVG(experience_years) GROUP BY project_id
SELECT a.project_id, ROUND(AVG(b.experience_years),2) as average_years
FROM project as a
INNER JOIN employee as b
    ON a.employee_id = b.employee_id
GROUP BY a.project_id

-- 1633. Percentage of Users Attended a Contest --------------------------------------------------------------------------------------------------------------
-- output: contest_id, percentage (% ppl join in that contest)
SELECT  b.contest_id,
        ROUND(
            100.00* COUNT(a.user_id) 
            / (SELECT COUNT(*) FROM users),2) as percentage 
FROM users as a
INNER JOIN register as b
    ON a.user_id = b.user_id
GROUP BY b.contest_id
ORDER BY percentage DESC, contest_id ASC

-- 1211. Queries Quality and Percentage -----------------------------------------------------------------------------------------------------------------------
-- output: query_name, quality = SUM(position * rating) / COUNT(query_name)
-- poor_query_percentage = COUNT(query_name) WHERE (rating<3) / COUNT(*)
WITH query_perc AS (
SELECT DISTINCT query_name,
                ROUND(
                    100.00 * COUNT(query_name) / 
                    (SELECT COUNT(query_name) FROM queries  
                    WHERE query_name = a.query_name GROUP BY query_name)
                    ,2) as poor_query_percentage
FROM queries as a
WHERE rating <3
GROUP BY query_name)

SELECT  query_name, 
        ROUND(
            AVG(CAST(rating as DECIMAL) / position)
            ,2) as quality,
        COALESCE(
            (SELECT poor_query_percentage FROM query_perc WHERE query_name = a.query_name)
            ,0) as poor_query_percentage
FROM queries as a
WHERE query_name IS NOT NULL
GROUP BY query_name


-- 


-- 


