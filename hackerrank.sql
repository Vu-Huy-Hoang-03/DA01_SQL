-- Ollivander's Inventory ---------------------------------------------------------------------------------------------------------------------------------------------------
-- output: id, age, coins_neeeded, power 
-- dk: non-evil : is_evil = 0 
/* C1: 
B1: tìm MIN(coins_needed)  PARTITION BY age, power
B2: CTEs B1 -> min = coins */

SELECT  a.id, b.age, a.coins_needed, a.power,
                MIN(a.coins_needed) OVER(PARTITION BY b.age) as min_coin
FROM wands as a
INNER JOIN wands_property as b
    ON a.code = b.id
WHERE b.is_evil = 0

/* C2: Correlated subquery để tìm MIN(coins) theo tuổi và power */
WITH B1 AS(
SELECT  a.id, b.age, a.coins_needed, a.power
FROM wands as a
INNER JOIN wands_property as b
    ON a.code = b.id
WHERE b.is_evil = 0
)

SELECT * 
FROM B1 as a
WHERE  coins_needed = (SELECT MIN(coins_needed) FROM B1 WHERE id = a.id GROUP BY age, power)


-- Contest LeaderBoard ---------------------------------------------------------------------------------------------------------------------------------------------------










