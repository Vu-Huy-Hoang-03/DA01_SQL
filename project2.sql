-- ExII.1: 
/* Thống kê tổng số lượng người mua và số lượng đơn hàng đã hoàn thành mỗi tháng (Từ 1/2019-4/2022) */
-- Output: month_year ( yyyy-mm) , total_user, total_order
SELECT  FORMAT_DATE('%Y-%m', created_at) as month_year,
        COUNT(DISTINCT user_id) as total_user,
        COUNT(order_id) as total_order
FROM bigquery-public-data.thelook_ecommerce.orders
WHERE DATE(created_at) BETWEEN '2019-01-01' AND '2022-04-30'
      AND status = 'Complete'
GROUP BY FORMAT_DATE('%Y-%m', created_at)
ORDER BY month_year


-- ExII.2: 
/* Thống kê giá trị đơn hàng trung bình và tổng số người dùng khác nhau mỗi tháng( Từ 1/2019-4/2022) */
-- Output: month_year ( yyyy-mm), distinct_users, average_order_value
SELECT  FORMAT_DATE('%Y-%m', a.created_at) as month_year,
        COUNT(DISTINCT a.user_id) as distinct_user,
        AVG(b.sale_price) as average_order_value
FROM bigquery-public-data.thelook_ecommerce.orders as a
INNER JOIN bigquery-public-data.thelook_ecommerce.order_items as b
ON a.order_id =b.order_id
WHERE DATE(a.created_at) BETWEEN '2019-01-01' AND '2022-04-30'
GROUP BY FORMAT_DATE('%Y-%m', a.created_at)
ORDER BY month_year


-- ExII.3: 
/* Tìm các khách hàng có trẻ tuổi nhất và lớn tuổi nhất theo từng giới tính (Từ 1/2019-4/2022) */
-- Output: first_name, last_name, gender, age, tag 
-- (hiển thị youngest nếu trẻ tuổi nhất, oldest nếu lớn tuổi nhất)
(SELECT first_name,
        last_name,
        gender,
        age,
        CASE
            WHEN age = (SELECT MAX(age) FROM bigquery-public-data.thelook_ecommerce.users WHERE gender = 'F')
              OR age = (SELECT MAX(age) FROM bigquery-public-data.thelook_ecommerce.users WHERE gender = 'M')
            THEN 'oldest'
            WHEN age = (SELECT MIN(age) FROM bigquery-public-data.thelook_ecommerce.users WHERE gender = 'F')
              OR age = (SELECT MIN(age) FROM bigquery-public-data.thelook_ecommerce.users WHERE gender = 'M') 
            THEN 'youngest'
        END as tag
FROM bigquery-public-data.thelook_ecommerce.users
WHERE age = (SELECT MAX(age) FROM bigquery-public-data.thelook_ecommerce.users
            WHERE gender = 'F')
      AND gender ='F'
      AND DATE(created_at) BETWEEN '2019-01-01' AND '2022-04-30'
)
UNION ALL
(SELECT first_name,
        last_name,
        gender,
        age,
        CASE
            WHEN age = (SELECT MAX(age) FROM bigquery-public-data.thelook_ecommerce.users WHERE gender = 'F')
              OR age = (SELECT MAX(age) FROM bigquery-public-data.thelook_ecommerce.users WHERE gender = 'M')
            THEN 'oldest'
            WHEN age = (SELECT MIN(age) FROM bigquery-public-data.thelook_ecommerce.users WHERE gender = 'F')
              OR age = (SELECT MIN(age) FROM bigquery-public-data.thelook_ecommerce.users WHERE gender = 'M') 
            THEN 'youngest'
        END as tag
FROM bigquery-public-data.thelook_ecommerce.users
WHERE age = (SELECT MAX(age) FROM bigquery-public-data.thelook_ecommerce.users
            WHERE gender = 'M')
      AND gender ='M'
      AND DATE(created_at) BETWEEN '2019-01-01' AND '2022-04-30'
)
UNION ALL
(SELECT first_name,
        last_name,
        gender,
        age,
        CASE
            WHEN age = (SELECT MAX(age) FROM bigquery-public-data.thelook_ecommerce.users WHERE gender = 'F')
              OR age = (SELECT MAX(age) FROM bigquery-public-data.thelook_ecommerce.users WHERE gender = 'M')
            THEN 'oldest'
            WHEN age = (SELECT MIN(age) FROM bigquery-public-data.thelook_ecommerce.users WHERE gender = 'F')
              OR age = (SELECT MIN(age) FROM bigquery-public-data.thelook_ecommerce.users WHERE gender = 'M') 
            THEN 'youngest'
        END as tag
FROM bigquery-public-data.thelook_ecommerce.users
WHERE age = (SELECT MIN(age) FROM bigquery-public-data.thelook_ecommerce.users
            WHERE gender = 'F')
      AND gender ='F'
      AND DATE(created_at) BETWEEN '2019-01-01' AND '2022-04-30'
)
UNION ALL
(SELECT first_name,
        last_name,
        gender,
        age,
        CASE
            WHEN age = (SELECT MAX(age) FROM bigquery-public-data.thelook_ecommerce.users WHERE gender = 'F')
              OR age = (SELECT MAX(age) FROM bigquery-public-data.thelook_ecommerce.users WHERE gender = 'M')
            THEN 'oldest'
            WHEN age = (SELECT MIN(age) FROM bigquery-public-data.thelook_ecommerce.users WHERE gender = 'F')
              OR age = (SELECT MIN(age) FROM bigquery-public-data.thelook_ecommerce.users WHERE gender = 'M') 
            THEN 'youngest'
        END as tag
FROM bigquery-public-data.thelook_ecommerce.users
WHERE age = (SELECT MIN(age) FROM bigquery-public-data.thelook_ecommerce.users
            WHERE gender = 'M')
      AND gender ='M'
      AND DATE(created_at) BETWEEN '2019-01-01' AND '2022-04-30'
)


-- ExII.4: Top 5 sản phẩm mỗi tháng.
/* Thống kê top 5 sản phẩm có lợi nhuận cao nhất từng tháng (xếp hạng cho từng sản phẩm). */
-- Output: month_year ( yyyy-mm), product_id, product_name, sales, cost, profit, rank_per_month

WITH B1 AS(
SELECT  FORMAT_DATE('%Y-%m', a.created_at) as  month_year,
        a.product_id,
        b.name,
        ROUND(SUM(a.sale_price),2) as sale,
        ROUND(SUM(b.cost),2) as cost,
        ROUND((SUM(a.sale_price) - SUM(b.cost)),2) as profit
FROM bigquery-public-data.thelook_ecommerce.order_items as a
INNER JOIN bigquery-public-data.thelook_ecommerce.products as b
ON a.product_id = b.id
GROUP BY FORMAT_DATE('%Y-%m', a.created_at),
         a.product_id,
         b.name
ORDER BY month_year, a.product_id  
)
  
, B2 AS(
SELECT  *,
        DENSE_RANK() OVER(
                          PARTITION BY month_year
                          ORDER BY profit DESC
                        ) as rank_per_month
FROM B1
ORDER BY month_year, rank_per_month 
)
  
SELECT * FROM B2
WHERE rank_per_month <=5


-- ExII.5: Doanh thu tính đến thời điểm hiện tại trên mỗi danh mục
/* Thống kê tổng doanh thu theo ngày của từng danh mục sản phẩm (category) trong 3 tháng qua ( giả sử ngày hiện tại là 15/4/2022) */
-- Output: dates (yyyy-mm-dd), product_categories, revenue

SELECT  b.category,
        FORMAT_DATE('%Y-%m-%d', a.created_at) as  dates,
        ROUND(SUM(a.sale_price),2) as profit,
FROM bigquery-public-data.thelook_ecommerce.order_items as a
INNER JOIN bigquery-public-data.thelook_ecommerce.products as b
ON a.product_id = b.id
WHERE FORMAT_DATE('%Y-%m-%d', a.created_at) BETWEEN '2022-01-15' AND '2022-04-15'
GROUP BY FORMAT_DATE('%Y-%m-%d', a.created_at),
         b.category
ORDER BY b.category,dates


-----------------------------------------------------------------------------------------------------------------
III.
-----------------------------------------------------------------------------------------------------------------
-- ExIII.1:
WITH B1 AS(
SELECT  FORMAT_DATE('%m', c.created_at) as  month,
        FORMAT_DATE('%Y', c.created_at) as  year,
        b.category,
        ROUND(
              SUM(a.sale_price),2) as TPV,
        COUNT(a.order_id) as TPO,
        ROUND(
              SUM(b.cost),2) as total_cost,
        ROUND(
              SUM(a.sale_price)-SUM(b.cost),2) as total_profit,
        ROUND(1.00*
              (SUM(a.sale_price)-SUM(b.cost))
              / SUM(b.cost)
              ,2) as profit_to_cost_ratio
FROM bigquery-public-data.thelook_ecommerce.order_items as a
INNER JOIN bigquery-public-data.thelook_ecommerce.products as b
ON a.product_id = b.id
INNER JOIN bigquery-public-data.thelook_ecommerce.orders as c
ON a.order_id =c.order_id
GROUP BY year, month, b.category
ORDER BY year, month, b.category
)

SELECT  month,
        year,
        category,
        TPV,
        TPO,
        COALESCE(
        ROUND(100.00*
                (TPV - prev_TPV) / prev_TPV
                ,2) || '%'
                ,'0%') as Revenue_growth,
        COALESCE(
        ROUND(100.00*
                (TPO - prev_TPO) / prev_TPV
                ,2) || '%' 
                ,'0%') as Order_growth,
        total_cost,
        total_profit,
        profit_to_cost_ratio
FROM (
SELECT  *,
        LAG(TPV) OVER(PARTITION BY category ORDER BY year,month) as prev_TPV,
        LAG(TPO) OVER(PARTITION BY category ORDER BY year,month) as prev_TPO
FROM B1
) 


-- ExIII.2:

-- B1_1: check + xóa dữ liệu trùng ___ 45,286 dòng trùng
WITH B_1 AS (
SELECT * FROM (
select  *,
        ROW_NUMBER() OVER(
                          PARTITION BY order_id, user_id, product_id
                          ORDER BY created_at DESC
                        ) as stt
from bigquery-public-data.thelook_ecommerce.order_items
where status NOT IN ('Cancelled', 'Returned')
) as tablet
WHERE stt=1
)

-- B2_1: (tìm ngày đầu mua =MIN) + (chọn cột dữ liệu cần dùng)
, B2_1 AS(
SELECT  created_at,
        MIN(created_at) OVER(PARTITION BY user_id) as first_date,
        user_id,
        sale_price
FROM B_1
)

-- B2_2: (đổi date_type ngày đầu mua) + (tính chênh lệch theo tháng)
, B2_2 AS(
SELECT  FORMAT_DATE('%Y-%m', first_date) as cohort_date,
        (EXTRACT(YEAR FROM created_at) - EXTRACT(YEAR FROM first_date))*12
        + (EXTRACT(MONTH FROM created_at) - EXTRACT(MONTH FROM first_date)) +1 as index,
        user_id,
        sale_price
FROM B2_1
)

-- B2_3: tính tổng DT, slg KH theo cohort_date và index 
-- where index <=4
, B2_3 AS(
SELECT  cohort_date, index,
        SUM(sale_price) as revenue,
        COUNT(DISTINCT user_id) as customer,
FROM B2_2
where index <=4
GROUP BY cohort_date, index
ORDER BY cohort_date, index
)

-- B2_4: Cohort Chart = Pivot CASE-WHEN
, B2_4 AS(
SELECT  cohort_date,
        SUM(CASE WHEN index = 1 then customer ELSE 0 END) as t_1,
        SUM(CASE WHEN index = 2 then customer ELSE 0 END) as t_2,
        SUM(CASE WHEN index = 3 then customer ELSE 0 END) as t_3,
        SUM(CASE WHEN index = 4 then customer ELSE 0 END) as t_4
FROM B2_3
GROUP BY cohort_date
ORDER BY cohort_date
)


-- Retention Cohort
-- CTE B2_4
SELECT  cohort_date,
        ROUND(100.00* t_1 / t_1 ,2) as t_1,
        ROUND(100.00* t_2 / t_1 ,2) as t_2,
        ROUND(100.00* t_3 / t_1 ,2) as t_3,
        ROUND(100.00* t_4 / t_1 ,2) as t_4,
FROM B2_4

-- Churn Cohort
-- CTE B2_4
SELECT  cohort_date,
        ROUND(100 - 100.00* t_1 / t_1 ,2) as t_1,
        ROUND(100 - 100.00* t_2 / t_1 ,2) as t_2,
        ROUND(100 - 100.00* t_3 / t_1 ,2) as t_3,
        ROUND(100 - 100.00* t_4 / t_1 ,2) as t_4,
FROM B2_4













