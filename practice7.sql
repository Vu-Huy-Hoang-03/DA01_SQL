EX1: -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/*output year = EXTRACT(YEAR from transaction_date), 
                product_id, 
                SUM(spend) khối theo product_id và year, 
                SUM(spend) khối product_id, năm trước
CTEs: tổng spend theo sp và theo năm = GROUP BY
-> từ bảng CTEs -> lấy output đề yêu cầu */

WITH year_product_spend AS (
SELECT  EXTRACT(YEAR from transaction_date) as year, 
        product_id,
        SUM(spend) as total_spend
FROM user_transactions
GROUP BY EXTRACT(YEAR from transaction_date), product_id
)
SELECT  year, product_id, total_spend as curr_year_spend,
        LAG(total_spend) OVER(PARTITION BY product_id ORDER BY year) as prev_year_spend,
        ROUND (
                ( 
                (total_spend - (LAG(total_spend) OVER(PARTITION BY product_id ORDER BY year))) 
                / (LAG(total_spend) OVER(ORDER BY product_id, year)) 
                )*100
            ,2) as yoy_rate
FROM year_product_spend 

  
EX2: -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT DISTINCT card_name, 
                FIRST_VALUE(issued_amount) OVER(
                                                PARTITION BY card_name 
                                                ORDER BY issue_year, issue_month
                                                ) as issued_amount
FROM monthly_cards_issued
ORDER BY FIRST_VALUE(issued_amount) OVER(PARTITION BY card_name ORDER BY issue_year, issue_month) DESC 


EX3: -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/* output: user_id (spend + transaction_date) thứ 3 tính theo user_id - transaction_dated 
  -> SubQuery (rank) làm bảng -> WHERE rank=3 */

SELECT user_id, spend, transaction_date
FROM (
      SELECT  user_id, spend, transaction_date,
              RANK() OVER(PARTITION BY user_id ORDER BY transaction_date)
      FROM transactions
) as tablet
WHERE rank=3


EX4: -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/* output: transaction_date gần nhất, user_id, COUNT tại ngày đó */

C1: [CTE1_ngày gần nhất = FIRST_VALUE] (INNER JOIN) [CTE2_count theo ngày]

WITH latest_date AS (
SELECT  DISTINCT user_id, 
          FIRST_VALUE(transaction_date) OVER(
                                            PARTITION BY user_id
                                            ORDER BY transaction_date DESC
                                            ) as date
FROM user_transactions
),
count_spend AS (
SELECT  user_id, transaction_date,
        COUNT(spend) as count
FROM user_transactions
GROUP BY user_id, transaction_date
)
SELECT a.date, a.user_id, b.count as purchase_count
FROM latest_date as a
INNER JOIN count_spend as b
ON a.date=b.transaction_date AND a.user_id=b.user_id
ORDER BY b.count, a.user_id DESC

C2: RANK - ORDER BY transaction_date DESC + where rank=1
WITH latest AS (
SELECT  user_id, transaction_date, spend,
        RANK() OVER(
                    PARTITION BY user_id
                    ORDER BY transaction_date DESC
                    ) as ranking
FROM user_transactions
) 

SELECT  transaction_date, user_id, 
        COUNT(spend) as purchase_count
FROM latest as a
WHERE ranking=1
GROUP BY transaction_date, user_id

  
EX6: -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/* COUNT(credit_cart) thời gian cách <10 phút , amount = nhau, credit_cart = nhau, merchant_id = nhau
  _ chỉ count cái bị trùng(cái thứ 2) */
-- LAG(time+amout) để tìm lần chuyển trước đó + gom khối theo credit card 
-- gom khối theo thời gian + merchant_id và amount vì đề yêu cầu 3 cái đó giống nhau nên gom 

WITH tablet AS (
SELECT  *,
        LAG(transaction_timestamp) OVER( 
                                        PARTITION BY credit_card_id, merchant_id, amount 
                                        ORDER BY transaction_timestamp) as previous_time
FROM transactions
) 
SELECT COUNT(transaction_id) as payment_count
FROM tablet
WHERE transaction_timestamp - previous_time <= interval '10 minutes'


EX5: -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/* output: user_id, tweet_date, AVG(count) lũy kế 3 ngày gần nhất */
C1: CASE-WHEN + LAG
SELECT  user_id, tweet_date,
        CASE 
            WHEN LAG(tweet_date,1) OVER(PARTITION BY user_id ORDER BY tweet_date) IS NULL 
            AND LAG(tweet_date,2) OVER(PARTITION BY user_id ORDER BY tweet_date) IS NULL
                THEN ROUND(tweet_count,2)
            WHEN LAG(tweet_date,1) OVER(PARTITION BY user_id ORDER BY tweet_date) IS NOT NULL 
            AND LAG(tweet_date,2) OVER(PARTITION BY user_id ORDER BY tweet_date) IS NULL
                THEN ROUND(
                            ( CAST(tweet_count as DECIMAL)
                              + LAG(tweet_count,1) OVER(PARTITION BY user_id ORDER BY tweet_date) 
                             )/2
                         ,2)
            ELSE ROUND(
                        ( CAST(tweet_count as DECIMAL) 
                          + LAG(tweet_count,1) OVER(PARTITION BY user_id ORDER BY tweet_date) 
                          + LAG(tweet_count,2) OVER(PARTITION BY user_id ORDER BY tweet_date) 
                         )/3
                       ,2)
            END as rolling_avg_3d
FROM tweets

C2: ROWS BETWEEN
SELECT  user_id, tweet_date,
        ROUND( AVG(tweet_count) OVER(
                                    PARTITION BY user_id
                                    ORDER BY tweet_date
                                    ROWS BETWEEN 2 preceding AND current row
                                     ) 
              ,2) as rolling_avg_3d
FROM tweets

  
EX7: -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/* output: category, product, total_spend = SUM(spend)
đk: năm 2022 + chọn 2 sp có tổng spend lớn nhất mỗi category */
-- rank theo (SUM theo sp và cat) + where rank in(1,2)
SELECT Category, Product, spend_product
FROM (
WITH spending AS (
SELECT  Category, Product,
        SUM(spend) as spend_product
FROM product_spend
WHERE EXTRACT(YEAR from transaction_date) = 2022
GROUP BY Category, Product
)
SELECT  Category, Product, spend_product,
        RANK() OVER(PARTITION BY Category ORDER BY spend_product DESC) as ranking
FROM spending
) as tablet
WHERE ranking IN (1,2)

  
EX8: -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
