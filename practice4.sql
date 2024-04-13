-- Ex1
SELECT 
      COUNT(CASE
              WHEN device_type = 'laptop' THEN 1 END) as laptop_views,
      COUNT(CASE
              WHEN device_type IN('tablet', 'phone') THEN 1 END) as mobile_views
FROM viewership

SELECT 
      SUM(CASE
              WHEN device_type = 'laptop' THEN 1 ELSE 0 END) as laptop_views,
      SUM(CASE
              WHEN device_type IN('tablet', 'phone') THEN 1 ELSE 0 END) as mobile_views
FROM viewership


-- Ex2
SELECT x,y,z,
CASE
    WHEN x+y>z AND ABS(x-y)<z THEN 'Yes' ELSE 'No'
END as triangle
FROM triangle

-- Ex3
SELECT ( COUNT(CASE WHEN call_category ='n/a' THEN 1 END) / CAST(COUNT(*) AS DECIMAL) ) *100 AS call_percentage
FROM callers;

SELECT ( COUNT(call_category) / COUNT(*) ) *100 as call_percentage
FROM callers
WHERE call_category = 'n/a'

-- Ex4
SELECT CASE WHEN referee_id <> 2 OR referee_id IS NULL THEN name END as name
FROM customer
WHERE (CASE WHEN referee_id <> 2 OR referee_id IS NULL THEN name END) IS NOT NULL
  
SELECT name FROM Customer
WHERE referee_id <> 2 OR referee_id IS NULL

-- Ex5
SELECT survived,
    COUNT(CASE WHEN pclass=1 THEN 1 END) as first_class,
    COUNT(CASE WHEN pclass=2 THEN 1 END) as second_class,
    COUNT(CASE WHEN pclass=3 THEN 1 END) as third_class
FROM titanic
GROUP BY survived






