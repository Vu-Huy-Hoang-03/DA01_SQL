/* Bước 1: Khám phá & làm sạch dữ liệu
- trường dữ liệu nào cần tác động
- check NULL, ''
- chuyển đổi kiểu dữ liệu
- số tiền ; số lượng >0
- check Duplicate */

/* 541909 rows 
_ không có dòng nào NULL 
_ 135080 dòng có khoảng trắng '' _ des(1454) _ cusid(135080)
*/

-- SET datestyle = mdy : chạy câu lệnh này trước 

-- B1_1: bỏ dữ liệu NULL, '' + CAST
WITH B1_1 AS (
SELECT	invoiceno,
		stockcode,
		description,
		CAST(quantity AS INT),
		CAST(invoicedate AS timestamp),
		CAST(unitprice AS DECIMAL),
		customerid,
		country
FROM online_retail
WHERE	customerid <> ''
		AND CAST(quantity AS INT) >0
		AND CAST(unitprice AS DECIMAL) >0
),
  
-- B1_2 + 1_3: xóa dữ liệu NULL = row_number(1_2) và where>1 (1_3)
B1_2 AS(
SELECT	*,
		ROW_NUMBER() OVER(
						PARTITION BY invoiceno,stockcode,quantity,customerid
						ORDER BY invoicedate DESC) as stt
FROM B1_1
),

online_retail_fix AS(
SELECT * FROM B1_2
WHERE stt=1
)

  
/* Bước 2:
- tìm ngày mua hàng đầu tiên của mỗi KH = đặt tên cohort_date
- tìm index = tháng (ngày mua hàng - ngày đầu tiên) +1
- count số lượng KH hoặc tổng DT tại mỗi cohort_date và index tương ứng 
- Pivot table

=> Output = cohort_date, index, count(customer), sum(revenue) */

-- B2_1: (tìm ngày mua hàng đầu tiên =MIN) + (chọn lọc trường dữ liệu cần dùng) 
, B2_1 AS(
SELECT	customerid,
		quantity * unitprice AS amount,
		MIN(invoicedate) OVER(PARTITION BY customerid) AS first_date,
		invoicedate
FROM online_retail_fix
)
  
-- B2_2:(đổi data_type ngày mua đầu tiên) + (tìm chênh lệch ngày mua hiện tại so với ngày đầu tiên - theo tháng)
, B2_2 AS(
SELECT 	customerid,
		amount,
		TO_CHAR(first_date, 'yyyy-mm') as cohort_date,
		invoicedate,
		(EXTRACT(YEAR FROM invoicedate) - EXTRACT(YEAR FROM first_date))*12
		+ (EXTRACT(MONTH FROM invoicedate) - EXTRACT(MONTH FROM first_date))
		+ 1 as index
FROM B2_1
)
  
-- B2_3: đếm slg KH + tổng tiền (gom nhóm theo ngày mua đầu tiên + khoảng cách tháng)
, B2_3 AS(
SELECT	cohort_date,
		index,
		COUNT(customerid) as customer_count,
		SUM(amount) as total_amount
FROM B2_2
GROUP BY cohort_date, index
ORDER BY cohort_date, index
) 
  
-- B2_4: Pivot Table = SUM + CASE-WHEN = cohort chart 
SELECT	cohort_date,
		SUM(CASE WHEN index=1 THEN customer_count ELSE 0 END) as "1",
		SUM(CASE WHEN index=2 THEN customer_count ELSE 0 END) as "2",
		SUM(CASE WHEN index=3 THEN customer_count ELSE 0 END) as "3",
		SUM(CASE WHEN index=4 THEN customer_count ELSE 0 END) as "4",
		SUM(CASE WHEN index=5 THEN customer_count ELSE 0 END) as "5",
		SUM(CASE WHEN index=6 THEN customer_count ELSE 0 END) as "6",
		SUM(CASE WHEN index=7 THEN customer_count ELSE 0 END) as "7",
		SUM(CASE WHEN index=8 THEN customer_count ELSE 0 END) as "8",
		SUM(CASE WHEN index=9 THEN customer_count ELSE 0 END) as "9",
		SUM(CASE WHEN index=10 THEN customer_count ELSE 0 END) as "10",
		SUM(CASE WHEN index=11 THEN customer_count ELSE 0 END) as "11",
		SUM(CASE WHEN index=12 THEN customer_count ELSE 0 END) as "12"
FROM B2_3	
GROUP BY cohort_date

-- B2_5: nếu muốn làm RETENTION cohort chart hoặc CHURN cohort chart
-- CTE KQ B2_4
  
-- Rentention
SELECT	cohort_date,
		ROUND(100.00 * "1"/"1",2) || '%' AS "1",
		ROUND(100.00 * "2"/"1",2) || '%' AS "2",
		ROUND(100.00 * "3"/"1",2) || '%' AS "3",
		ROUND(100.00 * "4"/"1",2) || '%' AS "4",
		ROUND(100.00 * "5"/"1",2) || '%' AS "5",
		ROUND(100.00 * "6"/"1",2) || '%' AS "6",
		ROUND(100.00 * "7"/"1",2) || '%' AS "7",
		ROUND(100.00 * "8"/"1",2) || '%' AS "8",
		ROUND(100.00 * "9"/"1",2) || '%' AS "9",
		ROUND(100.00 * "10"/"1",2) || '%' AS "10",
		ROUND(100.00 * "11"/"1",2) || '%' AS "11",
		ROUND(100.00 * "12"/"1",2) || '%' AS "12"
FROM B2_4

-- Churn
-- tương tự nhưng để " (100 - ROUND(100.00 * "1"/"1",2)) || '%' "

