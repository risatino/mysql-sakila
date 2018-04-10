-- 1a. Display the first and last names of all actors from the table `actor`

use sakila;
select first_name, last_name from actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`

use sakila;
select concat(first_name," ", last_name) as Actor_Name
from actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?

use sakila;
select actor_id, first_name, last_name
from actor
where first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters `GEN`:

use sakila;
select last_name
from actor
where last_name like '%GEN%';

-- 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:

use sakila;
select last_name, first_name
from actor
where last_name like '%LI%'
order by last_name, first_name;

-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:

use sakila;
select country_id, country
from country
where country in ('Afghanistan', 'Bangladesh', 'China');

-- 3a. Add a `middle_name` column to the table `actor`. Position it between `first_name` and `last_name`. Hint: you will need to specify the data type

use sakila;
alter table actor
add column middle_name varchar(55) after first_name;

-- 3b. You realize that some of these actors have tremendously long last names. Change the data type of the `middle_name` column to `blobs`

alter table actor
modify middle_name blob;

-- 3c. Now delete the `middle_name` column

alter table actor
drop column middle_name;

-- 4a. List the last names of actors, as well as how many actors have that last name

select last_name, count(last_name) as "Count of Last Name"
from actor
group by last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors

select last_name, count(last_name) as "Count of Last Name"
from actor
group by last_name
having count(last_name) >= 2;

-- 4c. Oh, no! The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`, the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record

update actor
set first_name = 'Harpo'
where first_name = 'GROUCHO' and last_name = 'WILLIAMS';

-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`. Otherwise, change the first name to `MUCHO GROUCHO`, as that is exactly what the actor will be with the grievous error. BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO `MUCHO GROUCHO`, HOWEVER! (Hint: update the record using a unique identifier.)
 
 update actor
 set first_name = case
	when first_name = 'HARPO' then 'GROUCHO'
	else 'MUCHO GROUCHO'
	end
 where actor_id = 172;

 -- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?

show create table sakila.address;

-- CREATE TABLE `address` (
--   `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
--   `address` varchar(50) NOT NULL,
--   `address2` varchar(50) DEFAULT NULL,
--   `district` varchar(20) NOT NULL,
--   `city_id` smallint(5) unsigned NOT NULL,
--   `postal_code` varchar(10) DEFAULT NULL,
--   `phone` varchar(20) NOT NULL,
--   `location` geometry NOT NULL,
--   `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
--   PRIMARY KEY (`address_id`),
--   KEY `idx_fk_city_id` (`city_id`),
--   SPATIAL KEY `idx_location` (`location`),
--   CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
-- ) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8

-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:

select first_name, last_name, address
from staff s
inner join address a
on s.address_id = a.address_id;

-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`

select first_name, last_name, sum(amount)
from staff s
inner join payment p
on s.staff_id = p.staff_id
where payment_date between '2005-08-01' and '2005-08-31'
group by p.staff_id
order by last_name asc;

-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join

select title, count(actor_id)
from film f
inner join film_actor fa
on f.film_id = fa.film_id
group by title;

-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?

select title, count(inventory_id)
from film f
inner join inventory i 
on f.film_id = i.film_id
where title = "Hunchback Impossible";

-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:

select last_name, first_name, sum(amount)
from payment p
inner join customer c
on p.customer_id = c.customer_id
group by p.customer_id
order by last_name asc;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English

use sakila;
select title from film
where language_id in
	(select language_id 
	from language
	where name = "English" )
and (title like "K%") or (title like "Q%");

-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`

use sakila;
select last_name, first_name from actor
where actor_id in(
	select actor_id from film_actor
	where film_id in(
    select film_id from film
		where title = "Alone Trip"
	)
);
			
-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information

use sakila;
select first_name, last_name, email
from customer
inner join address
using (address_id)
	inner join city
	using (city_id)
		inner join country
		using (country_id) where country.country = 'Canada';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films

use sakila;
select title, category
from film_list
where category = 'Family';

-- 7e. Display the most frequently rented movies in descending order.

use sakila;
select film.title, count(film.title) as times_rented
from rental 
inner join inventory 
on rental.inventory_id = inventory.inventory_id
inner join film 
on inventory.film_id = film.film_id
group by film.title
order by times_rented desc;

-- 7f. Write a query to display how much business, in dollars, each store brought in.

select store.store_id, sum(amount)
from store
inner join staff
on store.store_id = staff.store_id
inner join payment p 
on p.staff_id = staff.staff_id
group by store.store_id
order by sum(amount);

-- 7g. Write a query to display for each store its store ID, city, and country

select store_id, city, country
from store
join address
on store.address_id = address.address_id
join city c
on (address.city_id = c.city_id) 
join country co
on c.country_id = co.country_id;

-- 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

select c.name, 
	   sum(p.amount)
from payment p
inner join rental
using (rental_id)
	inner join inventory
    using (inventory_id)
		inner join film_category 
        using (film_id)
			inner join category c
			using (category_id)
group by c.name
order by sum(p.amount) desc
limit 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.

create view top_five_gross_revenue_by_genre as
select category.name, sum(payment.amount) as gross_revenue
from category 
inner join film_category 
on category.category_id = film_category.category_id
inner join inventory 
on film_category.film_id = inventory.film_id
inner join rental
on inventory.inventory_id = rental.inventory_id
inner join payment 
on rental.rental_id = payment.rental_id
group by name
order by gross_revenue desc
limit 5;

-- 8b. How would you display the view that you created in 8a?

select * from top_five_gross_revenue_by_genre;

-- 8c. You find that you no longer need the view TopRevenueByCategory. Write a query to delete it.

drop view top_five_gross_revenue_by_genre;