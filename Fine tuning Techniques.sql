-- Sql querey fine tuning techniques

-- Use only necessary columns (Avoid using *)
select * from actor;
select first_name , last_name from actor;

-- Use where before group by and having
SELECT customer_id, COUNT(*) AS rentals FROM rental
WHERE staff_id = 1
GROUP BY customer_id
HAVING COUNT(*) > 2;

-- use joins instead of subqueries
   -- ( subqureies are less efficient)
select first_name from customer where store_id in ( select store_id from store where address_id = '2');

SELECT DISTINCT c.first_name
FROM customer c
JOIN store s ON c.store_id = s.store_id
WHERE s.address_id = '2';
 
 
-- Avoid Functions on indexed columns
explain select * from rental where year(rental_date) = '2005';

-- Preserves index
explain select * from rental where year(rental_date) = '2005-01-01' and '2005-12-31';

-- use limit effectively
select * from actor
limit 10;

-- use cte for readable query breakdown
WITH CustomerRentals AS (
    SELECT customer_id, COUNT(*) AS total_rentals
    FROM rental
    GROUP BY customer_id
)
SELECT c.customer_id, CONCAT(c.first_name, ' ', c.last_name) AS customer_name, cr.total_rentals
FROM CustomerRentals cr
JOIN customer c ON cr.customer_id = c.customer_id
WHERE cr.total_rentals > 3;

-- use explain to understand query execution plan
explain select * from customer where address_id = 1;

-- maintanance commands use periodically
analyze table customer;
optimize table rental;

-- Avoid large offsets in pagination
  -- Inefficient
  select * from payment limit 1000,10;
  -- Efficient
  select * from payment where payment_id > 1000 limit 10;