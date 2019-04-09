USE sakila;

-- 1a ----------------------------------------------------------------------------

/*Displays names of actors*/
SELECT first_name, last_name 
FROM actor;

-- 1b ----------------------------------------------------------------------------

/*Displays first and last names as a single column*/
SELECT CONCAT(first_name,' ', last_name) as 'Actor Name' 
FROM actor;

-- 2a ----------------------------------------------------------------------------

/*Displays actor_id, first and last name for actors with a first name of Joe*/
SELECT actor_id, first_name, last_name 
FROM actor
WHERE first_name='JOE';

-- 2b ----------------------------------------------------------------------------

/*Displays first and last names for last names containing 'GEN' anywhere*/
SELECT first_name, last_name
FROM actor
WHERE last_name LIKE '%GEN%';

-- 2c ----------------------------------------------------------------------------

/*Displays the first and last names for actors with 'LI' in last name*/
SELECT last_name, first_name 
FROM actor
WHERE last_name LIKE '%LI%'
ORDER BY last_name, first_name ASC;

-- 2d ----------------------------------------------------------------------------

/*Using WHERE IN, finds only country ids matching subset given*/
SELECT country_id, country 
FROM country 
WHERE country IN ('Afghanistan','Bangladesh','China');

-- 3a ----------------------------------------------------------------------------

/*Adds description column into actor table*/
ALTER TABLE actor
ADD description BLOB;
SELECT * FROM actor;

-- 3b ----------------------------------------------------------------------------

/*Removes description column from actor table*/
ALTER TABLE actor
DROP description;
SELECT * FROM actor;

-- 4a ----------------------------------------------------------------------------

/*Displays number of actors with each last name*/
SELECT last_name, COUNT(last_name) 
FROM actor
GROUP BY last_name;

-- 4b ----------------------------------------------------------------------------

/*Displays number of actors with each last name for counts greater than 1*/
SELECT last_name, COUNT(last_name) AS 'Number of Actors'
FROM actor
GROUP BY last_name 
HAVING COUNT(last_name)>1;

-- 4c ----------------------------------------------------------------------------

/*Changes first name of actor with last name Williams and first name Groucho*/
SET SQL_SAFE_UPDATES = 0;
UPDATE actor
SET first_name='HARPO'
WHERE last_name='WILLIAMS' AND first_name='GROUCHO';

-- 4d ----------------------------------------------------------------------------

/*Changes first name back to Groucho*/
UPDATE actor
SET first_name='GROUCHO'
WHERE first_name='HARPO';

-- 5a ----------------------------------------------------------------------------

/*Displays CREATE TABLE statment from previously created address table*/
SHOW CREATE TABLE address;

-- 6a ----------------------------------------------------------------------------

/*Displays name and addresses of each staff member*/
SELECT staff.first_name, staff.last_name, address.address
FROM staff
JOIN address ON
address.address_id=staff.address_id;

-- 6b ----------------------------------------------------------------------------

/*Displays total amount rung up by each staff member in August 2005*/
SELECT SUM(amount), first_name, last_name 
FROM staff
JOIN payment USING (staff_id)
WHERE payment_date like '2005-08-%'
GROUP BY staff_id;

-- 6c ----------------------------------------------------------------------------

/*Displays number of actors in each film by title*/
SELECT film.title, COUNT(film_actor.film_id) AS 'Number of Actors' 
FROM film_actor
INNER JOIN film 
ON film.film_id=film_actor.film_id
GROUP BY film_actor.film_id;

-- 6d ----------------------------------------------------------------------------

/*Displays total number of copies of 'Hunchback Impossible' in inventory*/
SELECT film.title, COUNT(inventory.film_id) As 'Number of Copies' 
FROM film
JOIN inventory 
ON inventory.film_id=film.film_id
WHERE title = 'HUNCHBACK IMPOSSIBLE'
GROUP BY inventory.film_id;

-- 6e ----------------------------------------------------------------------------

 /*Displays total paid by each customer, sorted by last name*/
SELECT customer.first_name, customer.last_name, SUM(payment.amount) As 'Total Amount Paid' 
FROM customer
JOIN payment 
ON payment.customer_id=customer.customer_id
GROUP BY payment.customer_id
ORDER BY last_name ASC;

-- 7a ----------------------------------------------------------------------------

/*Displays English movies that begin with 'C' or 'K'*/
SELECT title 
FROM film 
WHERE title like 'k%' or title like 'Q%' and language_id 
IN (
	SELECT language_id FROM language WHERE
	name='English'
    )
; 

-- 7b ----------------------------------------------------------------------------

/*Displays actors in movie 'Alone Trip'*/
SELECT first_name, last_name 
FROM actor 
WHERE actor_id IN (
	SELECT actor_id 
    FROM film_actor 
    WHERE film_id 
    IN (
		SELECT film_id 
        FROM film 
        WHERE
		title='ALONE TRIP')); 

-- 7c ----------------------------------------------------------------------------

/*Displays names and email addresses for customers in Canada*/
SELECT first_name, last_name, email FROM customer
INNER JOIN address USING (address_id)
INNER JOIN city USING (city_id)
INNER JOIN country USING (country_id)
WHERE country='Canada';

-- 7d ----------------------------------------------------------------------------

/*Displays only the Family films*/
SELECT title As 'Family Films' FROM film
INNER JOIN film_category USING (film_id)
INNER JOIN category USING (category_id)
WHERE name='Family';

-- 7e ----------------------------------------------------------------------------

/* Displays the movies rented 15 times or more*/
SELECT title, COUNT(inventory_id) AS 'Times Rented' FROM rental
INNER JOIN inventory USING (inventory_id)
INNER JOIN film USING (film_id)
GROUP BY title
HAVING `Times Rented` >= 15
ORDER BY `Times Rented` DESC;

-- 7f ----------------------------------------------------------------------------

/* Only displays the store numbers and totals*/
SELECT x.store_id, CONCAT('$', x.total) As 'Total' FROM (
	SELECT store_id, SUM(amount) as total FROM payment
    INNER JOIN staff USING (staff_id)
    INNER JOIN store USING (store_id)
    GROUP BY store_id) AS x;
    
/*Displays the store numbers, totals, and locations*/
SELECT x.store_id, y.`Location`, CONCAT('$',x.total) AS 'Total' FROM (
	SELECT SUM(amount) AS total, s.store_id FROM payment
	INNER JOIN staff USING (staff_id)
	INNER JOIN store AS s USING (store_id)
	GROUP BY staff_id) AS x
JOIN (
	SELECT store_id, CONCAT(city,", ", country) AS 'Location' FROM country
	INNER JOIN city USING (country_id)
	INNER JOIN address USING (city_id)
	INNER JOIN store USING (address_id)
	GROUP BY store_id) AS y
USING (store_id);

-- 7g ----------------------------------------------------------------------------

/*Displays the locations of the store_ids as one entry*/
SELECT store_id, CONCAT(city,", ", country) AS 'Location' FROM country
	INNER JOIN city USING (country_id)
	INNER JOIN address USING (city_id)
	INNER JOIN store USING (address_id)
	GROUP BY store_id;

/*Displays city and country separately*/
SELECT store_id, city, country FROM country
	INNER JOIN city USING (country_id)
	INNER JOIN address USING (city_id)
	INNER JOIN store USING (address_id)
	GROUP BY store_id;
    
-- 7h ----------------------------------------------------------------------------

/*Displays total amount per top 5 grossing genres*/
SELECT name, SUM(amount) AS total FROM payment
INNER JOIN rental USING (rental_id)
INNER JOIN inventory USING (inventory_id)
INNER JOIN film_category USING (film_id)
INNER JOIN category USING (category_id)
GROUP BY name
ORDER BY total DESC
LIMIT 5;

-- 8a ----------------------------------------------------------------------------

/*Create view based on the previous joined tables*/
CREATE VIEW top_genres AS
SELECT name AS 'Category', SUM(amount) AS 'Total' FROM payment
INNER JOIN rental USING (rental_id)
INNER JOIN inventory USING (inventory_id)
INNER JOIN film_category USING (film_id)
INNER JOIN category USING (category_id)
GROUP BY name
ORDER BY `Total` DESC
LIMIT 5;

-- 8b ----------------------------------------------------------------------------

/*Displays previously created view*/
SELECT * FROM top_genres;

-- 8c ----------------------------------------------------------------------------

/*Deletes view*/
DROP VIEW top_genres;