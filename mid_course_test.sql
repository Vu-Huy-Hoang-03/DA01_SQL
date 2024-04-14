-- Ex1
select distinct replacement_cost from film
order by replace_ment_cost

-- Ex2
SELECT CASE
		WHEN replacement_cost BETWEEN 9.99 AND 19.99 THEN 'low'
		WHEN replacement_cost BETWEEN 20.00 AND 24.99 THEN 'medium'
		WHEN replacement_cost BETWEEN 25.00 AND 29.99 THEN 'high'
		END as category,
	COUNT(film_id)
FROM film
GROUP BY category

-- Ex3
SELECT a.title, a.length, c.name
FROM film as a
INNER JOIN film_category as b ON a.film_id=b.film_id
INNER JOIN category as c ON b.category_id=c.category_id
WHERE c.name IN ('Drama', 'Sports')
ORDER BY a.length DESC

-- Ex4
SELECT c.name as category, count(a.title) as amount_movie
FROM film as a
INNER JOIN film_category as b ON a.film_id=b.film_id
INNER JOIN category as c ON b.category_id=c.category_id
GROUP BY c.name
ORDER BY count(a.title) DESC 

-- Ex5
SELECT a.last_name as họ, a.first_name as tên, COUNT(b.actor_id) as sl_phim
FROM actor as a
RIGHT JOIN film_actor as b 
ON a.actor_id = b.actor_id
GROUP BY a.last_name, a.first_name
ORDER BY COUNT(b.actor_id) DESC 

-- Ex6
SELECT a.address
FROM address as a
LEFT JOIN customer as b
ON a.address_id = b.address_id
WHERE b.customer_id IS NULL

-- Ex7
SELECT a.city, SUM(d.amount) as amount_per_city
FROM city AS a
INNER JOIN address AS b ON a.city_id=b.city_id
INNER JOIN customer AS c ON b.address_id=c.address_id
INNER JOIN payment AS d ON c.customer_id=d.customer_id
GROUP BY a.city 
ORDER BY SUM(d.amount) DESC 

-- Ex8
SELECT CONCAT(d.city, ', ', e.country) as city_country,
		SUM(a.amount) as amount_per_city_country
FROM payment as a
INNER JOIN customer as b ON a.customer_id=b.customer_id
INNER JOIN address as c ON b.address_id=c.address_id
INNER JOIN city as d ON c.city_id=d.city_id
INNER JOIN country as e ON d.country_id=e.country_id
GROUP BY city_country
ORDER BY SUM(a.amount) DESC



