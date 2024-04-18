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



Ex5: --------------------------------------------------------------------------------------------------------------------------------------------










