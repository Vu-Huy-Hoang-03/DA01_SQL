select * from public.sales_dataset_rfm_prj_clean

/* 1) Doanh thu theo từng ProductLine, Year và DealSize?
Output: PRODUCTLINE, YEAR_ID, DEALSIZE, REVENUE */

SELECT	productline,
		year_id,
		dealsize,
		SUM(sales) as revenue
FROM sales_dataset_rfm_prj_clean
GROUP BY productline,year_id,dealsize
ORDER BY year_id


/* 2) Đâu là tháng có bán tốt nhất mỗi năm?
Output: MONTH_ID, REVENUE, ORDER_NUMBER */

SELECT 	month_id,
		SUM(sales) as revenue,
		RANK() OVER(ORDER BY SUM(sales) DESC) as order_number
FROM sales_dataset_rfm_prj_clean
GROUP BY month_id
ORDER BY order_number
LIMIT 1


/* 3) Product line nào được bán nhiều ở tháng 11?
Output: productline, MONTH_ID, REVENUE, ORDER_NUMBER */

SELECT 	month_id,
		productline,
		SUM(sales) as revenue,
		RANK() OVER(ORDER BY SUM(sales) DESC) as order_number
FROM sales_dataset_rfm_prj_clean
WHERE month_id = 11
GROUP BY month_id,productline
ORDER BY order_number


/* 4) Đâu là sản phẩm có doanh thu tốt nhất ở UK mỗi năm?
Xếp hạng các các doanh thu đó theo từng năm.
Output: YEAR_ID, PRODUCTLINE,REVENUE, RANK */

-- B1: tính tổng DT theo từng sp, năm + RANK
WITH B_1 AS (
SELECT 	year_id,
		productline,
		SUM(sales) as revenue,
		RANK() OVER(
					PARTITION BY year_id
					ORDER BY SUM(sales) DESC) as rank_revenue
FROM sales_dataset_rfm_prj_clean
GROUP BY year_id,productline
)
-- B2: WHERE rank=1
SELECT year_id,
		productline,
		revenue
FROM B_1
WHERE rank_revenue =1


/* 5) Ai là khách hàng tốt nhất, phân tích dựa vào RFM
(sử dụng lại bảng customer_segment ở buổi học 23) */

-- B1: tính R _ F _ M
WITH B_1 AS (
SELECT	customername,
		current_date - MAX(orderdate) as R,
		COUNT(ordernumber) as F,
		SUM(sales) as M
FROM public.sales_dataset_rfm_prj_clean
GROUP BY customername
)
-- B2: chia thang 1-5
, B_2 AS (
SELECT	customername,
		NTILE(5) OVER(ORDER BY R DESC) as R,
		NTILE(5) OVER(ORDER BY F) as F,
		NTILE(5) OVER(ORDER BY M) as M
FROM B_1
)
-- B3: ghép R-F-M
, B_3 AS (
SELECT 	customername,
		CONCAT(r,f,m) as RFM
FROM B_2
)
-- B4: INNER JOIN tìm phân khúc
SELECT	a.customername, a.rfm, b.segment
FROM B_3 as a
INNER JOIN segment_score as b
	ON a.rfm = b.scores






