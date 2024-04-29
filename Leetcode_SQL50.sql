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
WHERE temperature > prev_tem

-- C2: intervals '1 day'
