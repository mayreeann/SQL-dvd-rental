 /* Question1
 We want to understand more about the movies that families are watching. The following categories 
 are considered family movies: Animation, Children, Classics, Comedy, Family and Music.
 Create a query that lists each movie, the film category it is classified in, 
 and the number of times it has been rented out.
 */
 
SELECT f.title film_title,c.name category, COUNT(*) rental_count
FROM film_category fc
JOIN film f
ON fc.film_id = f.film_id
JOIN category c
ON fc.category_id = c.category_id
JOIN inventory i
ON i.film_id = f.film_id
JOIN rental r
ON r.inventory_id = i.inventory_id
WHERE c.name IN ('Animation', 'Children', 'Classics', 'Comedy','Family','Music')
GROUP BY 1,2
ORDER BY 2,1;

/* Question2
Finally, provide a table with the family-friendly film category, each of the quartiles, and the corresponding
count of movies within each combination of film category for each corresponding rental duration category. 
The resulting table should have three columns: Category,Rental length category,Count
*/

SELECT category,rental_duration_category, COUNT(*) movie_count 
FROM(SELECT f.title movie,c.name category,f.rental_duration,
			NTILE(4) OVER(ORDER BY f.rental_duration) rental_duration_category
	 FROM film_category fc
	 JOIN film f
	 ON fc.film_id = f.film_id
	 JOIN category c
	 ON c.category_id = fc.category_id
	 WHERE c.name IN ('Animation', 'Children', 'Classics', 'Comedy','Family','Music')) sub
GROUP BY 1,2
ORDER BY 1,2;

/* Question3
We want to find out how the two stores compare in their count of rental orders during every month
for all the years we have data for. Write a query that returns the store ID for the store, the year and month
and the number of rental orders each store has fulfilled for that month. Your table should include a column
for each of the following: year, month, store ID and count of rental orders fulfilled during that month
*/

SELECT DATE_PART('month',r.rental_date) AS rental_month,
	   DATE_PART('year',r.rental_date) AS rental_year,
       s.store_id,
       COUNT(*) rental_orders
FROM store s
JOIN staff st
ON s.store_id = st.store_id
JOIN rental r
ON r.staff_id = st.staff_id
GROUP BY 1,2,3
ORDER BY 4 DESC;

/* Question4
We would like to know who were our top 10 paying customers, how many payments they made on a monthly basis 
during 2007, and what was the amount of the monthly payments. 
Can you write a query to capture the customer name, month and year of payment, 
and total payment amount for each month by these top 10 paying customers?
*/

WITH top10 AS (SELECT c.first_name||' '||c.last_name full_name,
		           SUM(p.amount) payment_amount, c.customer_id
				FROM customer c
				JOIN payment p
				ON c.customer_id = p.customer_id
				GROUP BY 1,3
				ORDER BY 2 DESC
				LIMIT 10)
SELECT DATE_TRUNC('month',p.payment_date) payment_month,
       c.first_name||' '||c.last_name full_name,
	   SUM(p.amount) payment_amount,
	   COUNT(*) AS payment_count
FROM customer c
JOIN payment p
ON c.customer_id = p.customer_id
WHERE c.first_name||' '||c.last_name IN (SELECT full_name FROM top10)
GROUP BY 1,2
ORDER BY 2,1;