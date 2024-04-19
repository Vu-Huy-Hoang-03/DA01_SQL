Ex1: --------------------------------------------------------------------------------------------------------------------------------------------
/* output = immediate / all + round( ,2)
dk: first_order = MIN(order_date) OVER(PARTITION BY customer_id) */

  
C1:
-- B1: CTEs bảng: KH + first_order
-- B2: INNER JOIN để tìm các ttin còn lại + CASE-WHEN (immediate - scheduled)
-- B3: Coi KQ B2 là bảng -> COUNT + CASE-WHEN
  
/* tips: thay vì [ CAST(COUNT(type) AS DECIMAL) ] => nhân 100.0 = DECIMAL/INT */
  
SELECT ROUND(100.0*
            COUNT(CASE WHEN type='immediate' THEN 1 END)
            / COUNT(type)
            ,2) as immediate_percentage
FROM (

WITH first_time AS (
SELECT customer_id, MIN(order_date) as min_date
FROM Delivery
GROUP BY customer_id
)
SELECT  a.delivery_id, a.customer_id, b.min_date, a.customer_pref_delivery_date,
        CASE 
            WHEN b.min_date = a.customer_pref_delivery_date THEN 'immediate'
            ELSE 'scheduled'
        END as type
FROM Delivery as a
INNER JOIN first_time as b 
ON  a.customer_id = b.customer_id AND a.order_date = b.min_date

) as tablet


C2: 
B1: Truy vấn tương quan ở WHERE -> tìm MIN order_date
B2: AVG(CASE-WHEN) -> % 
SELECT ROUND(
            AVG(
                CASE WHEN order_date = customer_pref_delivery_date THEN 100.0
                ELSE 0
                END
                ),2
            ) as immediate_percentage
FROM delivery as a
WHERE order_date = (
                    SELECT MIN(order_date) 
                    FROM delivery
                    WHERE customer_id = a.customer_id
                    GROUP BY customer_id)


Ex2: --------------------------------------------------------------------------------------------------------------------------------------------
/* output = % (loggin trong 2 ngày tiếp kể từ ngày đầu tiên) / COUNT(DISTINCT player_id) */
  
-- B1: tìm ngày min mỗi id = MIN OVER(PARTITION BY player_id ORDER BY event_date)
-- B2: KQ B1 = CTEs + COUNT(CASE-WHEN) 0<diff<2

WITH min_diff AS (
SELECT  *,
        MIN(event_date) OVER(PARTITION BY player_id ORDER BY event_date) as min_date
FROM activity
) 
SELECT ROUND(1.0*
            COUNT(DISTINCT CASE WHEN event_date - min_date < 2 AND event_date - min_date > 0
                                THEN player_id END) 
            / COUNT(DISTINCT player_id)
            ,2) as fraction
FROM min_diff


Ex3: --------------------------------------------------------------------------------------------------------------------------------------------
-- đổi chỗ 2 học sinh liền kề nhau (nếu tổng số hs là lẻ thì hs cuối k )

SELECT  id,
        CASE
            WHEN id =(SELECT MAX(id) FROM Seat) and id%2 <> 0 THEN student
            WHEN id%2=0 THEN LAG(student) OVER(ORDER BY id)
            WHEN id%2<>0 THEN LEAD(student) OVER(ORDER BY id)
        END as student
FROM Seat as a
  
Ex4: --------------------------------------------------------------------------------------------------------------------------------------------
/* output: visited_on , moving_amount + moving_average (6 ngày trước+ ngày hiện tại)
_ KO hiện KQ 6 ngày đầu */
-- B1: tính tổng theo ngày 
-- B2: lấy KQ B1 làm bảng -> tính running SUM + AVG (kết hợp ROWS BETWEEN) 
-- B3: CTEs KQ b1-b2 => rank>6 (để k hiện KQ 6 ngày đầu)

WITH all_rank AS (
SELECT  visited_on,
        SUM(daily_amount) OVER(ORDER BY visited_on 
                           ROWS BETWEEN 6 preceding AND current row
                                ) as amount,
        ROUND(AVG(daily_amount) OVER(ORDER BY visited_on 
                                 ROWS BETWEEN 6 preceding AND current row
                                    )
            ,2) as average_amount,
        ROW_NUMBER() OVER(ORDER BY visited_on) as ranking
FROM (
     SELECT visited_on, SUM(amount) as daily_amount
     FROM customer
     GROUP BY visited_on
    ) as SUM_daily
)

SELECT  visited_on,
        amount,
        average_amount
FROM all_rank
WHERE ranking >6
  

Ex5: --------------------------------------------------------------------------------------------------------------------------------------------
/* SUM(tiv_2016) 
_ đk1: tiv_2015 giống với 1 hoặc nhiều tiv_2015 khác 
_ đk2: thành phố phải khác nhau so với toàn bộ các pid khác */

/* xác định giá trị giống + khác nhau 
= COUNT([cộtA]) OVER(PARTITION BY [cộtA]) = đếm giá trị trong cột + gom khối theo cột đó 
=> nếu có nhiều giá trị trùng nhau -> COUNT với giá trị đó sẽ >1 (do trong khối đó có nhiều giá trị giống nhau) */

WITH count AS (
SELECT  pid, tiv_2015, tiv_2016,
        CONCAT(lat, lon) as location,
        COUNT(CONCAT(lat,lon)) OVER(PARTITION BY CONCAT(lat,lon)) as count_location,
        COUNT(tiv_2015) OVER(PARTITION BY tiv_2015) as count_15
FROM Insurance
) 

SELECT ROUND(
            CAST( SUM(tiv_2016) AS DECIMAL )
            ,2) as tiv_2016
FROM count
WHERE count_location =1 AND count_15 >1


Ex6: --------------------------------------------------------------------------------------------------------------------------------------------
/* output: Department - Employee - Salary (top3 theo Department) */
-- B1: DENSE_RANK salary theo khối Department
      /* top three unique salaries => DENSE_RANK để rank + không nhảy cách */
-- B2: CTEs B1 -> where rank<=3

WITH rank_salary AS (
SELECT  a.salary, a.departmentID,
        a.name as Employee,
        b.name,
        DENSE_RANK() OVER(PARTITION BY departmentID
                          ORDER BY salary DESC) as ranking
FROM Employee as a
INNER JOIN Department as b 
ON a.departmentID = b.id 
)

SELECT  name as Department,
        Employee,
        salary
FROM rank_salary
WHERE ranking <=3
  

Ex7: --------------------------------------------------------------------------------------------------------------------------------------------  
-- person_name - người cuối cùng lên xe

--B1: tính running total weight by turn
--B2: đk running_total <=1000 + limit 1

WITH total_weight AS (
SELECT  *,
        SUM(weight) OVER(ORDER BY turn) as running_weight
FROM Queue
)

SELECT person_name
FROM total_weight
WHERE running_weight <=1000
ORDER BY turn DESC
LIMIT 1

  
Ex8: --------------------------------------------------------------------------------------------------------------------------------------------
/* output: product_id, price
_ tính đến ngày 2019-08-16 */

-- B1: tìm giá max từng sp
-- B2: CTE B1 + left join (tìm xem product nào NULL) -> CASE-WHEN

WITH maxing AS (
SELECT  product_id, MAX(new_price) as max_price
FROM Products
WHERE change_date <= '2019-08-16'
GROUP BY product_id
)

SELECT DISTINCT a.product_id,
                CASE
                    WHEN b.product_id IS NULL THEN 10
                    ELSE b.max_price 
                END as price
FROM Products as a
LEFT JOIN maxing as b 
ON a.product_id = b.product_id
ORDER BY a.product_id

