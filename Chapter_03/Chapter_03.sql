---------------------------------------------------------------------------
-- Practical SQL: A Beginner's Guide to Storytelling with Data, 2nd Edition
-- by Anthony DeBarros

-- Chapter 3 Code Examples
----------------------------------------------------------------------------

-- Listing 3-1: Querying all rows and columns from the teachers table

SELECT * FROM teachers;

-- Note that this standard SQL shorthand also works:

TABLE teachers;

-- Listing 3-2: Querying a subset of columns

SELECT last_name, first_name, salary FROM teachers;

-- Listing 3-3: Sorting a column with ORDER BY

SELECT first_name, last_name, salary
FROM teachers
ORDER BY salary DESC;

-- Note you can also specify the sort column by
-- using a number representing its position in the result.

SELECT first_name, last_name, salary
FROM teachers
ORDER BY 3 DESC;

-- Listing 3-4: Sorting multiple columns with ORDER BY

SELECT last_name, school, hire_date
FROM teachers
ORDER BY school ASC, hire_date DESC;

-- Listing 3-5: Querying distinct values in the school column

SELECT DISTINCT school
FROM teachers
ORDER BY school;

-- Listing 3-6: Querying distinct pairs of values in the school and salary
-- columns

SELECT DISTINCT school, salary
FROM teachers
ORDER BY school, salary;

-- Listing 3-7: Filtering rows using WHERE

SELECT last_name, school, hire_date
FROM teachers
WHERE school = 'Myers Middle School';

-- Examples of WHERE comparison operators

-- Teachers with first name of Janet
SELECT first_name, last_name, school
FROM teachers
WHERE first_name = 'Janet';

-- School names not equal to F.D. Roosevelt HS
SELECT school
FROM teachers
WHERE school <> 'F.D. Roosevelt HS';

-- Teachers hired before Jan. 1, 2000
SELECT first_name, last_name, hire_date
FROM teachers
WHERE hire_date < '2000-01-01';

-- Teachers earning 43,500 or more
SELECT first_name, last_name, salary
FROM teachers
WHERE salary >= 43500;

-- Teachers who earn from $40,000 to $65,000
SELECT first_name, last_name, school, salary
FROM teachers
WHERE salary BETWEEN 40000 AND 65000;

SELECT first_name, last_name, school, salary
FROM teachers
WHERE salary >= 40000 AND salary <= 65000;

-- Listing 3-8: Filtering with LIKE AND ILIKE

SELECT first_name
FROM teachers
WHERE first_name LIKE 'sam%';

SELECT first_name
FROM teachers
WHERE first_name ILIKE 'sam%';

-- Listing 3-9: Combining operators using AND and OR

SELECT *
FROM teachers
WHERE school = 'Myers Middle School'
      AND salary < 40000;

SELECT *
FROM teachers
WHERE last_name = 'Cole'
      OR last_name = 'Bush';

SELECT *
FROM teachers
WHERE school = 'F.D. Roosevelt HS'
      AND (salary < 38000 OR salary > 40000);

-- Note how the results change if we omit parentheses. That's
-- because the AND operator takes precedence over OR and is
-- evaluated first:

SELECT *
FROM teachers
WHERE school = 'F.D. Roosevelt HS'
      AND salary < 38000 OR salary > 40000;

-- Listing 3-10: A SELECT statement including WHERE and ORDER BY

SELECT first_name, last_name, school, hire_date, salary
FROM teachers
WHERE school LIKE '%Roos%'
ORDER BY hire_date DESC;


--   Operator   Function	                       Example
--   =          Equal to	                       WHERE school = 'Baker Middle'
--   <> or !=   Not equal to*	                       WHERE school <> 'Baker Middle'
--   >	    Greater than	                       WHERE salary > 20000
--   <	    Less than	                       WHERE salary < 60500
--   >=	    Greater than or equal to 	           WHERE salary >= 20000
--   <=	    Less than or equal to	           WHERE salary <= 60500
--   BETWEEN    Within a range	                 WHERE salary BETWEEN 20000 AND 40000
--   IN	    Match one of a set of values         WHERE last_name IN ('Bush', 'Roush')
--   LIKE	    Match a pattern (case sensitive)     WHERE first_name LIKE 'Sam%'
--   ILIKE	    Match a pattern (case insensitive)   WHERE first_name ILIKE 'sam%'
--   NOT	    Negates a condition	                 WHERE first_name NOT ILIKE 'sam%'


-- Using LIKE and ILIKE with WHERE
-- Comparison operators are fairly straightforward, 
-- but the matching operators LIKE and ILIKE deserve additional explanation. 
-- Both let you find a variety of values that include characters matching 
-- a specified pattern, which is handy if you don’t know exactly 
-- what you’re searching for or if you’re rooting out misspelled words. 
-- To use LIKE and ILIKE, you specify a pattern to match using one or both 
-- of these symbols:

-- Percent sign (%) A wildcard matching one or more characters
-- Underscore (_) A wildcard matching just one character
-- For example, if you’re trying to find the word baker, the following LIKE patterns will match it:

-- LIKE 'b%'
-- LIKE '%ak%'
-- LIKE '_aker'
-- LIKE 'ba_er'

-- The difference? 
-- The LIKE operator, which is part of the ANSI SQL standard, is case sensitive. 
-- The ILIKE operator, which is a PostgreSQL-only implementation, is case insensitive. 
-- Listing 3-8 shows how the two keywords give you different results.

-- The first WHERE clause uses LIKE 1 to find names that start with the characters sam, 
-- and because it’s case sensitive, it will return zero results.

-- The second, using the case-insensitive ILIKE 2, 
-- will return Samuel and Samantha from the table.

