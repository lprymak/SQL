USE sakila;

-- 1a ----------------------------------------------------------------------------

SELECT first_name, last_name FROM actor;

-- 1b ----------------------------------------------------------------------------

/*Combine first and last name*/
SELECT CONCAT(first_name,' ', last_name) as 'Actor Name' FROM actor;

-- 2a ----------------------------------------------------------------------------

/*Look only at entries where first name = Joe*/
SELECT actor_id, first_name, last_name FROM actor
WHERE first_name='Joe';

-- 2b ----------------------------------------------------------------------------

/*Combine first and last name only for last anems containing 'GEN' anywhere*/
SELECT CONCAT(first_name,' ', last_name) as 'Actor Name' FROM actor
WHERE last_name LIKE '%GEN%';

-- 2c ----------------------------------------------------------------------------

/*Look at the first and last names for actors with 'LI' in last name*/
SELECT last_name, first_name FROM actor
WHERE last_name LIKE '%LI%'
ORDER BY last_name, first_name ASC;

-- 2d ----------------------------------------------------------------------------

/*Using WHERE IN, find only country ids matching subset given*/
SELECT country_id, country FROM country WHERE country IN ('Afghanistan','Bangladesh','China');

-- 3a ----------------------------------------------------------------------------

/*Add description column into actor table*/
ALTER TABLE actor
ADD description BLOB;
SELECT * FROM actor;

-- 3b ----------------------------------------------------------------------------

/*Remove description column from actor table*/
ALTER TABLE actor
DROP description;
SELECT * FROM actor;

-- 4a ----------------------------------------------------------------------------

/*Display number of actors with each last name*/
SELECT last_name, COUNT(last_name) FROM actor
GROUP BY last_name;

-- 4b ----------------------------------------------------------------------------

/*Display number of actors with each last name for counts greater than 1*/
SELECT last_name, COUNT(last_name) FROM actor
GROUP BY last_name HAVING COUNT(last_name)>1;

-- 4c ----------------------------------------------------------------------------

/*Change first name of actor with last name Williams*/
SELECT * FROM actor WHERE last_name='WILLIAMS';
UPDATE actor
SET first_name='HARPO'
WHERE last_name='WILLIAMS' AND first_name='GROUCHO';

-- 4d ----------------------------------------------------------------------------

/*Change first name back to Groucho*/
UPDATE actor
SET first_name='GROUCHO'
WHERE first_name='HARPO';

-- 5a ----------------------------------------------------------------------------

/*Make basic table for address entries*/
CREATE TABLE address (
address_id INTEGER AUTO_INCREMENT NOT NULL,
address VARCHAR(200),
address2 VARCHAR(10),
district VARCHAR(50),
city_id INTEGER(5),
postal_code INTEGER(5),
phone BIGINT,
location BLOB,
last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 6a ----------------------------------------------------------------------------

/*Join staff first and last names from staff table with addresses from address table on address_id*/
SELECT staff.first_name, staff.last_name, address.address
FROM staff
JOIN address ON
address.address_id=staff.address_id;

-- 6b ----------------------------------------------------------------------------

/*Join total amouts from payment table with first and last anmes from staff table on staff_id
Group by staff_id*/
SELECT SUM(payment.amount), staff.first_name, staff.last_name FROM staff
JOIN payment ON payment.staff_id=staff.staff_id
GROUP BY payment.staff_id;

-- 6c ----------------------------------------------------------------------------

/*Join title from film table with count of film_ids from film_actor for each title*/
SELECT film.title, COUNT(film_actor.film_id) AS 'Number of Actors' FROM film_actor
INNER JOIN film ON film.film_id=film_actor.film_id
GROUP BY film_actor.film_id;

-- 6d ----------------------------------------------------------------------------

/*Join title from film with number of copies from inventory for each title*/
SELECT film.title, COUNT(inventory.film_id) As 'Number of Copies' FROM film
JOIN inventory ON inventory.film_id=film.film_id
GROUP BY inventory.film_id;

-- 6e ----------------------------------------------------------------------------

 /*Join first and last name for the customers from customer table with total amount from payment table grouped by each customer
 and sorted in ascending oreder by last name*/
SELECT customer.first_name, customer.last_name, SUM(payment.amount) As 'Total Amount Paid' FROM customer
JOIN payment ON payment.customer_id=customer.customer_id
GROUP BY payment.customer_id
ORDER BY last_name ASC;

-- 7a ----------------------------------------------------------------------------

/**/
SELECT title FROM film WHERE title like 'k%' or title like 'Q%' and
language_id IN (SELECT language_id FROM language WHERE
name='English'); 

-- 7b ----------------------------------------------------------------------------

/**/
SELECT first_name, last_name FROM actor WHERE actor_id IN (
SELECT actor_id FROM film_actor WHERE film_id IN (
SELECT film_id FROM film WHERE
title='ALONE TRIP')); 

-- 7c ----------------------------------------------------------------------------

/**/
SELECT customer.first_name, customer.last_name, customer.email FROM customer
INNER JOIN address ON customer.address_id=address.address_id;
SELECT city.city_id FROM city
INNER JOIN country ON city.country_id=country.country_id
WHERE country.country='Canada';

SELECT x.first_name, x.last_name, x.email FROM
(SELECT first_name,last_name,email, address_id FROM
customer) as x
INNER JOIN
(SELECT address_id, city_id FROM address WHERE (SELECT city_id FROM country WHERE country='Canada')) as y
ON x.address_id=y.address_id;

CREATE VIEW canCity AS
SELECT city_id FROM city
WHERE country_id IN (SELECT 
	country_id FROM country WHERE country='Canada');
SELECT * FROM canCity;
SELECT first_name, last_name, email FROM customer
WHERE address_id IN (SELECT 
	address_id FROM address WHERE city_id IN (SELECT
    city_id FROM canCity));
    
SELECT * FROM canCity;
DROP VIEW canCity;

-- 7d ----------------------------------------------------------------------------

/**/
SELECT title FROM film WHERE film_id IN (
SELECT film_id FROM film_category WHERE category_id IN (
SELECT category_id FROM category WHERE name='Family'));

-- 7e ----------------------------------------------------------------------------

/* Create table joining inventory ids with titles*/
CREATE VIEW inventory_titles AS
SELECT x.title AS title, y.inventory_id AS inventory_id FROM (
SELECT title, film_id FROM film) AS x
JOIN
(SELECT film_id, inventory_id FROM inventory) AS y
ON x.film_id=y.film_id;

/*Join new table with inventory counts from rental table*/
SELECT y.title, SUM(x.times_rented) AS 'Times Rented' FROM
(SELECT inventory_id, COUNT(inventory_id) AS times_rented FROM rental
GROUP BY inventory_id) AS x
JOIN
(SELECT title, inventory_id FROM inventory_titles) AS y
ON x.inventory_id=y.inventory_id
GROUP BY y.title;

-- 7f ----------------------------------------------------------------------------

/* Formats with dollar signs for each value, could also just put '(in dollars)' in the column header*/
SELECT  y.store_id, CONCAT('$',x.total) AS Total
FROM (
SELECT staff_id, SUM(amount) AS total FROM payment
GROUP BY staff_id) AS x
INNER JOIN 
(SELECT staff_id, store_id FROM staff) AS y
ON
x.staff_id=y.staff_id;

-- 7g ----------------------------------------------------------------------------

/*Display location and store_id from following joined tables:
1- Join city_id, city and country using subqueries of tables city, address, and store
2- Join city_id and store_id using subqueries of tables address and store */
SELECT iden.store_id, loc.Location FROM
	(SELECT z.city_id, CONCAT(z.city,", ", v.country) AS Location FROM (
		SELECT city, city_id, country_id FROM city WHERE city_id IN (
		SELECT city_id FROM address WHERE address_id IN (
			SELECT address_id FROM store))) AS z
	LEFT JOIN
	(SELECT country, country_id FROM country WHERE country_id IN (
		SELECT country_id FROM city WHERE city_id IN (
		SELECT city_id FROM address WHERE address_id IN (
		SELECT address_id FROM store)))) AS v
	ON z.country_id=v.country_id) AS loc
JOIN
	(SELECT address.city_id, store.store_id FROM address
	INNER JOIN store ON address.address_id=store.address_id) AS iden
	ON iden.city_id = loc.city_id;

-- 7h ----------------------------------------------------------------------------

/*Display total amount per genre*/
SELECT SUM(x.amount) AS Total, y.name As Category FROM 
/*Group payment amounts, inventory ids and join with group of titles, category name*/
	(SELECT payment.amount, rental.inventory_id FROM payment
	INNER JOIN rental ON payment.rental_id=rental.rental_id) AS x
			LEFT JOIN
	(SELECT i.title, f.name, i.inventory_id FROM
		(SELECT category.name, film_category.film_id FROM category
		INNER JOIN film_category 
			ON category.category_id=film_category.category_id) AS f
/*Join with title, film_id on inventory_id from film and inventory tables*/
JOIN
	(SELECT film.title, film.film_id, inventory.inventory_id FROM inventory
		JOIN film ON film.film_id=inventory.film_id) AS i
		ON f.film_id=i.film_id) AS y
ON x.inventory_id=y.inventory_id
/*group by category name sorted from highest grossing first*/
GROUP BY y.name
ORDER BY total DESC;

-- 8a ----------------------------------------------------------------------------

/*Create view based on the previous joined tables*/
CREATE VIEW top_genres AS
SELECT SUM(x.amount) AS Total, y.name As Category FROM 
	/*Group payment amounts, inventory ids and join with group of titles, category name*/
	(SELECT payment.amount, rental.inventory_id FROM payment
	INNER JOIN rental ON payment.rental_id=rental.rental_id) AS x
			LEFT JOIN
	(SELECT i.title, f.name, i.inventory_id FROM
		(SELECT category.name, film_category.film_id FROM category
		INNER JOIN film_category 
			ON category.category_id=film_category.category_id) AS f
JOIN
	(SELECT film.title, film.film_id, inventory.inventory_id FROM inventory
		JOIN film ON film.film_id=inventory.film_id) AS i
		ON f.film_id=i.film_id) AS y
ON x.inventory_id=y.inventory_id
GROUP BY y.name
ORDER BY total DESC
;

-- 8b ----------------------------------------------------------------------------

SELECT * FROM top_genres;

-- 8c ----------------------------------------------------------------------------

DROP VIEW top_five_genres;