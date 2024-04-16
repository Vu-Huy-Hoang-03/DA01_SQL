-- WINDOW FUNCTION with SUM(), COUNT(), AVG(), COUNT()
/*Tính tỉ lệ số tiền thanh toán từng ngày với
tổng số tiền đã thanh toán của mỗi KH
output: mã KH, tên KH, ngày thanh toán, số tiền thanh toán theo ngày,
tổng số tiền đã thanh toán theo khách hàng, tỉ lệ */

-- C1: SubQuery + OVER(PARTITION BY)
SELECT 	customer_id, 
		(SELECT first_name FROM customer WHERE customer_id=a.customer_id) as customer_name,
		payment_date,
		amount,
		SUM(amount) OVER(PARTITION BY customer_id) as total_pay_customer,
		ROUND( 
		(amount / SUM(amount) OVER(PARTITION BY customer_id) )*100 
		,3) as pay_perc
FROM payment as a
  
-- C2: (CTEs tên KH) + (tổng tiền thanh toán theo kh)
WITH total AS (
SELECT customer_id, SUM(amount) as total_pay_customer
FROM payment
GROUP BY customer_id
) , 
name AS (
SELECT customer_id, first_name FROM customer
)
SELECT 	a.customer_id, c.first_name, a.payment_date, a.amount,
		b.total_pay_customer,
		ROUND(
		(a.amount / b.total_pay_customer) *100
		,2)
FROM payment as a
INNER JOIN total as b ON a.customer_id = b.customer_id
INNER JOIN name as c ON a.customer_id = c.customer_id
ORDER BY customer_id


-------------------------------------------------------------------------------------------------------------------------------------
/* Viết truy vấn trả về danh sách phim bao gồm
      + film_id
      + tittle
      + length
      + category
      + thời lượng trung bình của phim trong category đó. 
Sắp xếp kết quả theo film_id. */

SELECT 	a.film_id, a.title, a.length,
		c.name as category,
		ROUND(
			AVG(length) OVER( PARTITION BY(b.category_id) )
		,2) as avg_length_cat
FROM film as a
INNER JOIN film_category as b ON b.film_id=a.film_id
INNER JOIN category as c ON c.category_id=b.category_id
ORDER BY b.category_id


-------------------------------------------------------------------------------------------------------------------------------------
/* Viết truy vấn trả về tất cả chi tiết các thanh toán bao gồm số lần thanh toán được thực hiện bởi khách hàng này 
và số tiền đó. Sắp xếp kết quả theo Payment_id */

SELECT 	*,
		COUNT(payment_id) OVER(PARTITION BY customer_id) as count_pay_cus,
		SUM(amount) OVER(PARTITION BY customer_id) as total_pay_cus
FROM payment

  
-- WINDOW FUNCTION with RANK()
-------------------------------------------------------------------------------------------------------------------------------------
/* xếp hạng độ dài phim theo từng thể loại - category
--> output: film_id, category, length, 
xếp hạng độ dài phim theo từng thể loại */

SELECT	a.film_id, c.name as category, a.length,
		RANK() OVER(PARTITION BY c.name ORDER BY length DESC)
FROM film as a
INNER JOIN film_category as b ON b.film_id=a.film_id
INNER JOIN category as c ON c.category_id=b.category_id


-------------------------------------------------------------------------------------------------------------------------------------
/* Viết truy vấn trả về tên khách hàng, quốc gia 
và số lượng thanh toán mà họ có */
  
SELECT DISTINCT a.first_name, d.country,
		            COUNT(e.amount) OVER(PARTITION BY a.customer_id)
FROM customer as a
INNER JOIN address as b ON a.address_id=b.address_id
INNER JOIN city as c ON b.city_id=c.city_id
INNER JOIN country as d ON c.country_id=d.country_id
INNER JOIN payment as e ON e.customer_id=a.customer_id
ORDER BY country

/* Sau đó, tạo bảng xếp hạng những khách hàng có doanh thu cao nhất 
cho mỗi quốc gia. Lọc kết quả chỉ 3 khách hàng đầu của mỗi quốc gia */
/*  B1: CTE tìm tên kh + quốc gia + tổng DT
    B2: rank tổng DT                                                                (không lồng window function được nên phải CTEs)
    B3: coi kết quả B2 là SubQuery ra KQ là 1 bảng -> SELECT * + đặt điều kiện     (do where không chứa window function nên phải subquery) */
    
SELECT * 
FROM (
WITH amount_sum AS (
SELECT DISTINCT a.first_name, d.country,
		SUM(e.amount) OVER(PARTITION BY a.customer_id) as sum
FROM customer as a
INNER JOIN address as b ON a.address_id=b.address_id
INNER JOIN city as c ON b.city_id=c.city_id
INNER JOIN country as d ON c.country_id=d.country_id
INNER JOIN payment as e ON e.customer_id=a.customer_id
)
SELECT 	first_name, country, sum,
		RANK () OVER(PARTITION BY country ORDER BY sum) as rank
FROM amount_sum
) AS rank_table
WHERE rank IN (1,2,3)


-- WINDOW FUNCTION hàm phân tích
-------------------------------------------------------------------------------------------------------------------------------------
/* số tiền thanh toán cho đơn hàng đầu tiên và gần đây nhất của khách hàng */
/*	C1
  CTE1: số tiền thanh toán đầu tiên từng KH = MIN + id
			+ tạo bảng KQ gồm customer_id và ngày đầu tiên theo từng KH
			+ bảng chính INNER JOIN bảng KQ để tìm ra amount theo kh và theo ngày đầu tiên
	CTE2: số tiền thanh toán gần nhất từng KH = MAX + id
			+ tương tự CTE1 -> thay min = max
	INNER JOIN ON id */
							
WITH first_time AS (
SELECT b.customer_id, b.min_date, a.amount
FROM payment as a
INNER JOIN (
SELECT customer_id, MIN(payment_date) as min_date
FROM payment
GROUP BY customer_id
) as b 
ON b.customer_id = a.customer_id AND a.payment_date = b.min_date
),
  
latest_time AS (
SELECT b.customer_id, b.max_date, a.amount
FROM payment as a
INNER JOIN (
SELECT customer_id, MAX(payment_date) as max_date
FROM payment
GROUP BY customer_id
) as b 
ON b.customer_id = a.customer_id AND a.payment_date = b.max_date
)
  
SELECT 	first.customer_id, 
		first.first_date,
		first.amount as first_amount,
		last.last_date,
		last.amount as last_amount
FROM first_time as first
INNER JOIN latest_time as latest
ON first.customer_id = last.customer_id

/*	C2:
    + CTE1: RANK () gom khối theo kh và xếp hạng theo ngày (ASC)
              => tìm ngày đầu tiên
    + CTE2: RANK () gom khối theo kh và xếp hạng theo ngày (DESC)
              => tìm ngày cuối = gần nhất  */

/*	C3: FIRST_VALUE  */



/* tìm chênh lệch giữa các lần thanh toán của từng KH */
-- C1: rank date

-- C2: LEAD - LAG
SELECT	customer_id, amount, payment_date,
		LAG(amount) OVER (PARTITION BY customer_id ORDER BY payment_date) as previous_amount,
		LAG(payment_date) OVER (PARTITION BY customer_id ORDER BY payment_date) as previous_date,
		LEAD(amount) OVER (PARTITION BY customer_id ORDER BY payment_date) as last_amount,
		LEAD(payment_date) OVER (PARTITION BY customer_id ORDER BY payment_date) as last_date
FROM payment


/* viết truy vấn trả về DT trong ngày và DT của ngày hôm trước
	-> tính % tăng trưởng */

