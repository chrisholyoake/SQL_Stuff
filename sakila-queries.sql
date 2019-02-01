USE sakila; 

-- 1a. Display the first and last names of all actors from the table actor.
SELECT first_name, last_name
	FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT CONCAT(UPPER(first_name), ' ', UPPER(last_name)) as 'Actor Name'
	FROM actor; 

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?

SELECT *
	FROM actor
    WHERE first_name = 'joe';
    
-- 2b. Find all actors whose last name contain the letters GEN:
SELECT * 
	FROM actor
    WHERE last_name LIKE '%gen%';
    
-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT * 
	FROM actor
    WHERE last_name LIKE '%li%';
    ORDER BY last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
	SELECT country_id, country
    FROM country
    WHERE country IN ('Afghanistan', 'Bangladesh', 'China');
    
-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
	ALTER TABLE actor
    ADD description BLOB;
    
    SELECT * FROM actor;
        
-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.

	ALTER TABLE actor
    DROP COLUMN description;
    
-- 4a. List the last names of actors, as well as how many actors have that last name.
	SELECT last_name, count(last_name) 
		FROM actor
        GROUP BY last_name;
        
-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
	SELECT last_name, count(last_name)
		FROM actor
        GROUP BY last_name
        HAVING count(last_name) >=2;
        

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
UPDATE actor
	SET first_name = 'HARPO'
    WHERE actor_id = 172;
    
    SELECT * FROM actor
    WHERE actor_id = 172;

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
    SET SQL_SAFE_UPDATES=0;
    
UPDATE ACTOR
	SET first_name = 'GROUCHO'
    WHERE first_name = 'HARPO';
    
-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
	SELECT * FROM staff;
    SELECT * FROM address;
    
    SELECT staff.address_id, staff.first_name, staff.last_name, address.address
		FROM staff
        INNER JOIN address on staff.address_id = address.address_id
    
-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT * FROM payment;
SELECT * FROM staff;

SELECT staff.staff_id, SUM(payment.amount)
	FROM staff
	INNER JOIN payment ON payment.staff_id = staff.staff_id
    WHERE payment.payment_date BETWEEN '2005-08-01' AND '2005-08-31'
    GROUP BY staff.staff_id;
    
-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT * FROM film; -- film_id, title
SELECT * FROM film_actor; -- actor_id, film_id

SELECT film.title, count(film_actor.actor_id)
FROM film
INNER JOIN film_actor ON film.film_id = film_actor.film_id
GROUP BY film.title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT * FROM film;

SELECT f.title, COUNT(i.inventory_id) AS 'number_of_copies'
	FROM inventory i
    INNER JOIN film f ON f.film_id = i.film_id
    WHERE title ='Hunchback Impossible'
    GROUP BY i.film_id;

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
	SELECT * FROM payment;
    SELECT * FROM customer;
    
    SELECT c.first_name,c.last_name, SUM(p.amount) AS 'Total Amount Paid'
		FROM customer c
        INNER JOIN payment p ON c.customer_id = p.customer_id
        GROUP BY c.first_name,c.last_name
        ORDER BY last_name ASC;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT * FROM film;
SELECT * FROM language;

SELECT title FROM film
	WHERE language_id = 1 AND title IN(
		SELECT title 
		FROM film
		WHERE title LIKE 'K%' 
        OR title LIKE 'Q%'); 

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT * FROM film_actor;
SELECT * FROM actor;

-- gets actor IDs in that movie
SELECT actor_id FROM film_actor
	WHERE film_id = 
		(SELECT film_id FROM film
		WHERE title = 'Alone Trip');

SELECT first_name,last_name FROM actor
	WHERE actor_id IN (
		SELECT actor_id FROM film_actor
		WHERE film_id = 
		(SELECT film_id FROM film
		WHERE title = 'Alone Trip'));

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT * FROM customer; -- email, address_id
SELECT * FROM address; -- address_id, city_id
SELECT * FROM city; -- city_id, country_id
SELECT * FROM country; -- country_id, country 

SELECT first_name, last_name,email FROM customer
WHERE address_id IN (
	SELECT address_id FROM address -- gets addresses
	WHERE city_id IN(
		SELECT city_id FROM city -- gets city IDs
		WHERE country_id = 
			(SELECT country_id FROM country -- gets country id
			WHERE country = 'Canada')));
            
-- Same as above, but using joins
SELECT c.first_name,c.last_name,c.email from customer c
INNER JOIN address a ON a.address_id = c.address_id
INNER JOIN city ci ON a.city_id = ci.city_id
INNER JOIN country co ON co.country_id = ci.country_id
WHERE co.country = 'Canada';



-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT * FROM film_category;
SELECT * FROM film;
SELECT * FROM category;

SELECT title FROM film 
WHERE film_id IN(
	SELECT film_id FROM film_category
	WHERE category_id IN(
		SELECT category_id FROM category
		WHERE name = 'family'));

-- 7e. Display the most frequently rented movies in descending order.
SELECT * FROM rental;
SELECT * FROM inventory;
SELECT * FROM film;

SELECT inventory_id, COUNT(*) as 'Number of Times Rented'
FROM rental
GROUP BY inventory_id;

SELECT f.title, f.film_id, inventory_id 
	FROM film f
    INNER JOIN inventory i ON i.film_id = f.film_id;

** NOT WORKING **

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT * FROM store; -- store id
SELECT * FROM payment; -- rental id, amount
SELECT * FROM rental; -- rental_id, staff_id
SELECT * FROM staff; -- store_id, staff_id 

SELECT s.store_id, SUM(p.amount) AS 'Revenue' 
	FROM payment p
	INNER JOIN staff s ON s.staff_id = p.staff_id
	GROUP BY p.staff_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT * FROM store; -- store id, address_id
SELECT * FROM address; -- address_id, city_id
SELECT * FROM city; -- city_id, country_id
SELECT * FROM country; -- country_id, country 

SELECT s.store_id, c.city, co.country
	FROM store s
    INNER JOIN address a ON a.address_id = s.address_id
    INNER JOIN city c ON c.city_id = a.city_id
    INNER JOIN country co ON c.country_id = co.country_id;

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT * FROM category -- category id
SELECT * FROM film_category -- category_id, film id
SELECT * FROM inventory -- film id, inventory_id
SELECT * FROM rental -- rental_id, inventory id, customer id, staff id
SELECT * FROM payment -- rental_id, amount

SELECT c.name, SUM(p.amount) as 'Revenue'
	FROM payment p
	INNER JOIN rental r ON r.rental_id = p.rental_id
	INNER JOIN inventory i ON i.inventory_id = r.inventory_id
	INNER JOIN film_category fc ON fc.film_id = i.film_id
	INNER JOIN category c ON c.category_id = fc.category_id
	GROUP BY c.name
	ORDER BY Revenue DESC;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.

CREATE VIEW top_5_genres_by_revenue AS
SELECT c.name, SUM(p.amount) as 'Revenue' 
	FROM payment p
	INNER JOIN rental r ON r.rental_id = p.rental_id
	INNER JOIN inventory i ON i.inventory_id = r.inventory_id
	INNER JOIN film_category fc ON fc.film_id = i.film_id
	INNER JOIN category c ON c.category_id = fc.category_id
	GROUP BY c.name
	ORDER BY Revenue DESC
    LIMIT 5;
    
-- 8b. How would you display the view that you created in 8a?
SELECT * FROM top_5_genres_by_revenue;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.

DROP VIEW top_5_genres_by_revenue;

