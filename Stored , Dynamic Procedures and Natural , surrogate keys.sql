-- Stored Procedures
  -- It is a pre-written SQL program stored in the database.
  -- It can include:
           -- SQL statements
           -- Conditions (IF)
           -- Loops
           -- Input & output parameters
-- It is like a reusable Function
-- Stored procedures are used for Automating tasks, Repetitive operations , Security 

-- Get all rentals of a given customer.
DELIMITER //
-- IN paramter
CREATE PROCEDURE get_customer_rentals(IN p_customer_id INT)
BEGIN
    SELECT r.rental_id, r.rental_date, f.title
    FROM rental r
    JOIN inventory i ON r.inventory_id = i.inventory_id
    JOIN film f ON i.film_id = f.film_id
    WHERE r.customer_id = p_customer_id;
END //

DELIMITER ;

CALL get_customer_rentals(5);

DELIMITER //
-- Out procedure
CREATE PROCEDURE total_payment(IN p_customer_id INT ,out total decimal (10,2))
BEGIN
    SELECT SUM(amount) AS total_paid
    FROM payment
    WHERE customer_id = p_customer_id;
END //

DELIMITER ;

CALL total_payment(10);

-- Create a table to store select statments
DROP TEMPORARY TABLE IF EXISTS column_select_statements;

CREATE TEMPORARY TABLE column_select_statements (
    id INT AUTO_INCREMENT PRIMARY KEY,
    statement_text TEXT
);
 
 -- Create the procedure
 DELIMITER //

CREATE PROCEDURE GenerateColumnSelects(IN p_table_name VARCHAR(64))
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE col_name VARCHAR(64);
    
    DECLARE cur CURSOR FOR
        SELECT column_name
        FROM information_schema.columns
        WHERE table_name = p_table_name
          AND table_schema = DATABASE();
          
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO col_name;

        IF done THEN
            LEAVE read_loop;
        END IF;

        INSERT INTO column_select_statements(statement_text)
        VALUES (CONCAT('SELECT ', col_name, ' FROM ', p_table_name, ';'));

    END LOOP;

    CLOSE cur;
END //

DELIMITER ;
CALL GenerateColumnSelects('customer');   -- to call
SELECT * FROM column_select_statements;   -- to view



-- Dynamic Procedure
   -- It is a procedure builds SQL statements as text inside the procedure and runs them using
   -- It is used to build flexible queries
   -- Here the table and column names change at runtime

DELIMITER //

CREATE PROCEDURE dynamic_sort_films(IN p_column VARCHAR(50))
BEGIN
    SET @sql = CONCAT('SELECT film_id, title, ', p_column, ' 
                       FROM film 
                       ORDER BY ', p_column, ';');
    PREPARE stmt FROM @sql;                          -- It loads our dynamically built SQL into memory.
    EXECUTE stmt;                                    -- Runs the dynamic SQL stored inside stmt
    DEALLOCATE PREPARE stmt;                         -- Removes the prepared statement from memory.
END //

DELIMITER ;

CALL dynamic_sort_films('rental_rate');              

-- Natural key
  -- It is a key that already exists in the real world and has meaning
  -- Comes from real data like phone number , ssn , license
  -- Not every Natural key is primary key
  -- Might change according to data
CREATE TABLE Cust (
    ssn CHAR(9) PRIMARY KEY,       -- natural key
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100)
);

INSERT INTO Cust (ssn, first_name, last_name, email)
VALUES
('123456789', 'John', 'Doe', 'john@example.com'),
('987654321', 'Jane', 'Smith', 'jane@example.com');

SELECT * FROM Cust;

-- Surrogate Key
 -- A surrogate key is an artificial key created just to uniquely identify a record, usually a number (like AUTO_INCREMENT). 
-- It has no real-world meaning
-- It will be stable doesnt change
-- It is used when no stable natural key exists
CREATE TABLE Cus (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,  -- surrogate key
    ssn CHAR(9) UNIQUE,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100)
);

INSERT INTO Cus (ssn, first_name, last_name, email)
VALUES
('123456789', 'John', 'Doe', 'john@example.com'),
('987654321', 'Jane', 'Smith', 'jane@example.com');

select * from Cus;
