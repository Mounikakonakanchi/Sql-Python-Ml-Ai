DROP DATABASE IF EXISTS sakila;
CREATE DATABASE sakila;
USE sakila;

USE sakila;
SHOW TABLES;
------------------------------------------------------
-- Nov 7
-- select 
-- Extracts data from a Database
select * from customer;

select title , count(rental_rate) as rate from  film
group by title;

select count(*) from film;

select count(distinct first_name) from actor;

select distinct(first_name) from actor;

select * from film
where film_id is not null;

-- count and ditinct count
-- Count returns the number of rows 
-- Distinct count returns distinct number of rows

select count(*) from actor;

select count(distinct title) from film;

select distinct(title) from film;

-- limit
-- returns only n number of values

select first_name from actor
limit 5;

select release_year from film
where release_year <='2026'
limit 3;

-- where
-- used to filter records based on a condition
select * from film
where rental_rate >=3;

select film_id , rating from film
where rating = 'G';

-- filtering / Order by
-- used to sort the result in aither asce or desc
select rental_rate from film
order by rental_rate;

select title, film_id from film
where film_id is not null
order by film_id asc;

-- AND OR
-- And is used to filter records based on more than one condition
-- OR is used to filter records based on more than one condition
select * from film
where rental_rate >= 4 and rating = 'G'
order by film_id desc;

select * from payment
where staff_id = 1 or amount >= 2
order by payment_id;

-- Not
-- is a logical operator used to reverse a condition.
select * from payment
where not amount >=2
order by payment_id;

select * from payment
where not payment_id in (2, 3, 5)
order by payment_id;

-- Like
-- The like operator is used in where for a specified pattern
select * from actor
where first_name like 'a%';

select * from actor
where last_name like 'a%n' ;

-- Null
-- used to check null values in the data
select * from actor
where first_name is not null;

select * from payment
where payment_date is null;

-- Between
-- used to filter data bewteen two dates
select * from payment
where payment_date between '2005-05-25' and '2005-06-10';


-- Group by and Having
-- group by is used to group rows with same values 
select count(*) as total from film
group by rental_rate
having count(*) > 20;


-- Nov 12
-- strings

-- left pads the string with another string
select title , lpad(title , 20 ,'*') as padded
from film;

-- right  pads the string with another string
select title , rpad(title , 20 ,'*') as padded
from film;

-- susbtring is a part of a string within the given length
select title , substring(title , 5,9 ) as short_title
from film;

-- concat is used to combine two strings using + , * ...
select first_name , last_name, concat(first_name ,'*', last_name) as c_name
from actor;

-- reverse is used to reverse the characters in the string
select first_name , reverse(first_name) as reverese_name
from actor;

-- length is used to caluclate the length of characters
select first_name , length(first_name) as_lengthof_title
 from actor;

-- A function in SQL that extracts a part of a string starting from a given position and for a given length.
select email , substring(email , locate('@' , email)+1)as located_email
from staff;

-- It splits the string using '@' and returns the part after the @.
select substring_index(email , '@' ,  +1)as located_email
from staff;

-- Converts the characters to upper case
select first_name , upper(first_name) as reverese_name
from actor;

-- Converts the characters to lower case
select first_name ,lower(first_name) as reverese_name
from actor;

-- LEFT is a string  that returns a specified number of characters from the left of a string.
select first_name , left(first_name , 5) as left_name
from actor;

-- Right is a string  that returns a specified number of characters from the Right of a string.
select first_name , right(first_name, 5) as right_name
from actor;

-- CASE is a conditional expression that allows to apply IF-ELSE logic inside a query.
select rental_rate ,
case when rental_rate >= 4 then 'high'
     when rental_rate <=3 then 'low'
     else 'other'
     end as 't.rating'
from film;

-- Replace is a function used to replace one character with other
select first_name , replace(first_name ,'A' , 'Z' ) R_NMAE
FROM actor;

-- Regexp allows  to search for text using patterns, not just exact matches.
select first_name from actor
where first_name REGEXP'[aeiouAEIOU]{2}';

-- CAST is a function used to convert one data type into another data type.
select first_name , cast(first_name as decimal) as c_name
from actor;

-- Generates a random number between 0 & 1
SELECT title FROM film
ORDER BY RAND()
LIMIT 5;

-- rounds a number up to the nearest integer like smallest integere
SELECT title, rental_rate, ceiling(rental_rate) AS rounded_length
FROM film;

-- rounds a number up to the specified number of decimal places
SELECT title, rental_rate, round(rental_rate) AS rounded_length
FROM film;

-- Removes unwanted spaces either leading or trailing
select email , trim(' ' from email) as trimmed_mail from staff;

-- Repeat is a function used to repeat the charcters with the given integer
select email ,repeat(email,2) as trimmed_mail from staff;

-- Returns the numeric ASCII value of the first character of a string.
select first_name ,ascii(first_name) from actor;
---------------------------------------
-- Nov 14
-- subqueries
-- Query inside a query(Nested)

-- It returns the lastest date
select max(payment_date) from  payment;

-- it returns all the payment dates from yesterday
select customer_id , payment_date , amount from payment
where payment_date >= now() - interval 1 day;


select customer_id , payment_date , amount from payment
where payment_date >= (
select max(payment_date)  - interval 10 day from  payment
);

-- It returns the current date And time
select now() - interval 1 day as yesterday;

select concat('today is :', curdate()) as message;
select concat('today is :', now()) as message;

-- Curdate() is used to get current date
select curdate() , now() , current_time();

select first_name , last_name from customer
where address_id in ( select address_id from customer 
where address_id = 5);

--- subquery in select
select first_name , last_name , actor_id,
( select count(*) from film_actor
WHERE film_actor.actor_id = actor.actor_id )as film_count
from actor;

--- derived tables
select a.actor_id , a.first_name , a.last_name , fa.film_count
from actor a join(
select actor_id , count(film_id) as film_count  from film_actor
group by actor_id , last_update
having count(film_id) >10
) fa on a.actor_id = fa.actor_id;

select * from (
select last_name ,
case 
  when left(last_name , 1) between 'A' AND 'M' then 'group a- m'
  when left(last_name , 1) between 'N' and  'z' then 'group n- z'
  else 'other'
  end as grouped_list
  from customer ) as grouped_customers
 where grouped_list = 'group a- m' ;
 
 -- select in where
 select customer_id , amount from payment
 where amount > (select avg(amount) from payment);
  
  select first_name ,
  (select address_id from address where district = 'california'  limit 1) as cali_address
  from customer;
  
select title , 
(select count(*) from film_actor fa 
where fa.film_id = f.film_id) as actor_count
from film f;

-- corelated Subquerey
-- The inner and outer qurey related to each other , and uses one column from either queries
select payment_id , customer_id , amount , payment_date from payment p
where amount>( select avg(amount) from payment p1
where p.customer_id = p1.customer_id);

-- Non Corelated subquerey
-- Independent of the outer query and runs once and returns a value or set of values.
SELECT first_name
FROM customer
WHERE store_id = (SELECT MIN(store_id) FROM store);

-- Advantages of Subqueries
-- Can break complex queries into smaller, readable parts.
-- Avoids using multiple separate queries in your application.
-- Can be used where JOINs might be diificult.
-- Flexible: Can return a single value, a list, or a table.

-- Disadvantages of Subqueries
-- Performance issues for correlated subqueries, which run for each outer row.
-- Sometimes JOINs are faster for large datasets.
-- Can become hard to read if nested deeply.
-- Some databases limit subquery capabilities in certain clauses.
---------------------------------------------
-- Nov 17
-- Joins , Relation ships

-- 1-1
-- 1 row in a table maps one row in other table
-- Get the manager of each store
-- Each store has one manager
SELECT s.store_id, s.manager_staff_id, st.first_name, st.last_name
FROM store s
JOIN staff st ON s.manager_staff_id = st.staff_id;

-- 1 - Many
-- 1 row in a table maps multiple rows in other table
-- One customer can have many payments.
SELECT c.customer_id, c.first_name, c.last_name, p.payment_id, p.amount
FROM customer c
JOIN payment p ON c.customer_id = p.customer_id;

-- Many - 1
-- Many rows in a table maps one row in other table
-- Many films belong to one category.
SELECT f.film_id, f.title, c.category_id, c.name AS category_name
FROM film f
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id;

-- Many - Many
--  Many rows in a table maps many rows in other table
SELECT f.film_id, f.title, a.actor_id, a.first_name, a.last_name
FROM film f
JOIN film_actor fa ON f.film_id = fa.film_id
JOIN actor a ON fa.actor_id = a.actor_id;

-- Left join
-- Returns all rows from the left table and matching rows from the right table
-- Get all customers and their payments
SELECT c.customer_id, c.first_name, c.last_name, p.payment_id, p.amount
FROM customer c
LEFT JOIN payment p ON c.customer_id = p.customer_id;

-- Right join
-- Returns all rows from the right table and matching rows from the left table
-- Get all payments and customer info if available
SELECT c.customer_id, c.first_name, c.last_name, p.payment_id, p.amount
FROM customer c
RIGHT JOIN payment p ON c.customer_id = p.customer_id;


-- Inner join
-- Returns only rows that have matching values in both tables
-- Get payments and customer info for matching records
SELECT p.payment_id, p.amount, p.payment_date, c.first_name, c.last_name
FROM payment p
INNER JOIN customer c ON p.customer_id = c.customer_id;

-- Full Outer Join
-- Returns all rows from both tables, with NULL where there’s no match.
-- Sql dosen't support full outer so we use Union
SELECT c.customer_id, c.first_name, p.payment_id, p.amount
FROM customer c
LEFT JOIN payment p ON c.customer_id = p.customer_id
UNION
SELECT c.customer_id, c.first_name, p.payment_id, p.amount
FROM customer c
RIGHT JOIN payment p ON c.customer_id = p.customer_id;


-- cross join
-- Returns all possible combinations of rows from both tables
-- Combine all stores with all staff
SELECT s.store_id, t.staff_id, t.first_name, t.last_name
FROM store s
CROSS JOIN staff t;

-- self join
-- A table is joined to itself
-- Find payments by customers who share the same last name
SELECT c1.customer_id AS customer1, c2.customer_id AS customer2, c1.last_name
FROM customer c1
JOIN customer c2 ON c1.last_name = c2.last_name AND c1.customer_id <> c2.customer_id;


select rental_duration , title from film #7
group by rental_duration 
having avg(length) = 112.9113; 




SELECT title, length, rental_duration,
    (SELECT AVG(length) 
     FROM film 
     WHERE rental_duration = 3) AS avg_length
FROM film
WHERE rental_duration = 3;


SELECT 
    title,
    release_year,
    CAST(release_year AS CHAR) AS release_year_text
FROM film
LIMIT 5;



