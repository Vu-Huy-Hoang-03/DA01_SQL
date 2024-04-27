-- Ollivander's Inventory ---------------------------------------------------------------------------------------------------------------------------------------------------
-- output: id, age, coins_neeeded, power 
-- dk: non-evil : is_evil = 0 
/* C1: 
B1: tìm MIN(coins_needed)  PARTITION BY age, power
B2: CTEs B1 -> min = coins */

WITH B1 AS (
SELECT  a.id, b.age, a.coins_needed, a.power,
                MIN(a.coins_needed) OVER(PARTITION BY b.age) as min_coin
FROM wands as a
INNER JOIN wands_property as b
    ON b.code = a.id
WHERE b.is_evil = 0
)

SELECT id, age, coins_needed, power
FROM B1
WHERE coins_needed = min_coin
ORDER BY power DESC, age DESC 

/* C2: Correlated subquery để tìm MIN(coins) theo tuổi và power */
WITH B1 AS(
SELECT  a.id, b.age, a.coins_needed, a.power
FROM wands as a
INNER JOIN wands_property as b
    ON b.code = a.id
WHERE b.is_evil = 0
)

SELECT * 
FROM B1 as a
WHERE  coins_needed = (SELECT MIN(coins_needed) FROM B1 WHERE id = a.id GROUP BY age, power)
ORDER BY power DESC, age DESC 


-- Contest LeaderBoard ---------------------------------------------------------------------------------------------------------------------------------------------------
-- output: hacker_id, name, total score = SUM(MAX(Score) GROUP BY hacker_id, challenge)

-- B1: tính max score theo challenge và hacker
WITH B_1 AS (
SELECT  a.hacker_id, a.name, b.challenge_id,
        MAX(b.score) as max_score
FROM hackers as a
INNER JOIN submissions as b
    ON a.hacker_id = b.hacker_id
GROUP BY a.hacker_id, a.name, b.challenge_id
)
-- B2: SUM(MAX score)
SELECT hacker_id, name, SUM(max_score) as total_score
FROM B_1
GROUP BY hacker_id, name
HAVING SUM(max_score) <> 0 
ORDER BY total_score DESC, hacker_id








