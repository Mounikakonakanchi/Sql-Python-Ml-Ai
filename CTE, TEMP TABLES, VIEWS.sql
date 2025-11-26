-- CTE : Common Table Expression
-- CTE is a temporary named result set that you can reference inside a SQL query.
-- CTE always begins with "with"
-- It is only used in query level and cannot be used outside of the query
-- CTE has two types
  -- Non Recursive
  -- Recursive

-- Find customers who spent more than $20 total.
WITH customer_totals AS (
    SELECT customer_id, SUM(amount) AS total_spent
    FROM payment
    GROUP BY customer_id
)
SELECT customer_id, total_spent
FROM customer_totals
WHERE total_spent > 20;

-- Advantages
   -- Readbility and reusability
   -- Avoids Repeating subqueries
   
-- Recursive cte
   -- Recursive CTEs repeat until a condition is met.
WITH RECURSIVE numbers AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1
    FROM numbers
    WHERE n < 10
)
SELECT * FROM numbers;

-- Temporary Table
  -- A temporary table is a table that exists only for your current session
  -- When you disconnect, it gets deleted automatically.
  -- useful for storing intermediate results
  
CREATE TEMPORARY TABLE long_films AS
SELECT film_id, title, length
FROM film
WHERE length > 120;

SELECT * FROM long_films;

-- Advantages
   -- Once a temporary table is created, you can run many queries on it.
   
-- VIEW
  -- A view is a saved SQL query that behaves like a virtual table

CREATE VIEW customer_fullname AS
SELECT customer_id,
       CONCAT(first_name, ' ', last_name) AS full_name,
       email
FROM customer;

SELECT * FROM customer_fullname;

DROP VIEW customer_fullname;



