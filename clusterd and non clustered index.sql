-- Index
  -- An index is a separate data structure that the database uses to quickly find rows in a table without searching every row.
  
-- Clustered Index
     -- A clustered index determines the physical order of rows in the table.
     -- Usually created on the PRIMARY KEY. (mysql dosent support clustered index so here primary key is always clustered index)
     -- A table can have only ONE clustered index.
     -- All rows are physically ordered by clustered index
     -- Very fast for range queries and primary lookups
	drop table if exists Student;
CREATE TABLE Student (
    StudentID INT PRIMARY KEY,      -- Clustered Index will be on this
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Age INT,
    City VARCHAR(50)
);

INSERT INTO Student (StudentID, FirstName, LastName, Age, City)
VALUES
(1, 'John', 'Doe', 20, 'Dallas'),
(2, 'Emma', 'Stone', 22, 'Houston'),
(3, 'Liam', 'Smith', 21, 'Austin'),
(4, 'Mia', 'Brown', 23, 'Dallas'),
(5, 'Noah', 'Johnson', 22, 'San Antonio');

select * from Student where StudentID  = '2';
explain select * from Student where StudentID ='2';

-- Non clustered index 
   -- A non-clustered index is a separate structure from the actual table data that stores:
   -- A pointer to the actual data row
   -- Ideal for filtering , searching on non primary keys
   -- Can have multiple non clustered index for table
   -- Slower than clustered index for look ups as it adds extra look up
   -- The data in the table dose not change its order
   
   CREATE INDEX idx_city ON Student (City);     -- here non clustered index only works on city as i created index on city
  SELECT * FROM Student WHERE City = 'Dallas';
  explain SELECT * FROM Student WHERE City = 'Dallas';

-- Note : The clustred index searching or filtering with where condition directly goes to the row and will give that particular row as output 
-- But in Non clustered index the searching or filtering with where condition works on non clustered index and goes to clustered index as the 
    -- full row will not be present in non clustered index
