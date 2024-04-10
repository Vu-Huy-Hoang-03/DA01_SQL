-- Ex1
SELECT Name FROM City
WHERE CountryCode = 'USA' AND Population >120000;

-- Ex2
SELECT * FROM City
WHERE CountryCode = 'JPN';

-- Ex3
/* longtitude = trục y = kinh độ 
   latitude = trục x = vĩ độ     */
SELECT City, State
From Station;

--Ex4
SELECT DISTINCT City From Station
WHERE City LIKE '[a,e,i,o,u]%';

SELECT DISTINCT City from Station
WHERE City LIKE 'a%' OR City LIKE 'e%' OR City LIKE 'i%' 
OR City LIKE 'o%' OR City LIKE 'u%';

SELECT DISTINCT City From Station
WHERE LEFT(City,1) in ('a', 'e', 'i' , 'o', 'u');

-- Ex5
SELECT DISTINCT City From Station
WHERE City LIKE '%[a,e,i,o,u]';

SELECT DISTINCT City From Station
WHERE City LIKE '%a' OR City LIKE '%e' OR City LIKE '%i' 
OR City LIKE '%o' OR City LIKE '%u';

-- Ex6
SELECT DISTINCT City FROM Station
Where LEFT(City,1) NOT IN ('a', 'e', 'i', 'o', 'u');

-- Ex7
SELECT name FROM Employee
ORDER BY name ASC;

-- Ex8
SELECT name FROM Employee
WHERE salary >2000 AND months <10
ORDER BY employee_id ASC;

-- Ex9
SELECT product_id FROM Products
WHERE low_fats = 'Y' AND recyclable = 'Y'

-- Ex10
-- IS NULL do có dữ liệu trống
SELECT name FROM Customer
WHERE referee_id <> 2 OR referee_id IS NULL

-- Ex11
SELECT name, population, area
FROM World
WHERE area >= 3000000 OR population >= 25000000;

-- Ex12
SELECT DISTINCT author_id AS id FROM Views
WHERE viewer_id = author_id
ORDER BY id ASC

-- Ex13
SELECT part, assembly_step FROM parts_assembly
WHERE finish_date IS NULL;

-- Ex14
select * from lyft_drivers
where yearly_salary <=30000 or yearly_salary >=70000

-- Ex15
select * from lyft_drivers
where yearly_salary <=30000 or yearly_salary >=70000












