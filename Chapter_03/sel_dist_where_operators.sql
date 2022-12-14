SELECT * FROM public.teachers;
TABLE teachers
ORDER BY last_name ASC;
SELECT last_name, school, hire_date from public.teachers
ORDER BY 2 ASC, 3 DESC;

SELECT DISTINCT school, salary
FROM teachers
ORDER BY school, salary DESC;

SELECT last_name, school, hire_date
FROM teachers
WHERE school = 'Myers Middle School';

SELECT first_name, last_name, school
FROM teachers
WHERE first_name = 'Janet'

SELECT school
FROM teachers
WHERE school <> 'F.D. Roosevelt HS'

SELECT first_name, last_name, hire_date
FROM teachers
WHERE hire_date < '2001-01-01'

SELECT first_name, last_name, salary
FROM teachers
WHERE salary >= 43500

TABLE teachers

SELECT first_name, last_name, salary
FROM teachers
WHERE salary BETWEEN 40000 AND 65000

SELECT first_name, last_name, salary
FROM teachers
WHERE salary >= 40000 AND salary <= 65000

SELECT first_name
FROM teachers
WHERE first_name LIKE 'sam%'

SELECT first_name
FROM teachers
WHERE first_name ILIKE 'sam%'

SELECT first_name
FROM teachers
WHERE first_name NOT ILIKE 'sam%'

-- combining operators with AND and OR

-- Because we connect the two conditions using AND, 
-- both must be true for a row to meet the criteria 
-- in the WHERE clause and be returned in the query results.
SELECT *
FROM teachers
WHERE school = 'Myers Middle School'
	AND salary < 40000;

-- When we connect conditions using OR, only one of the conditions 
-- must be true for a row to meet the criteria of the WHERE clause.
SELECT *
FROM teachers
WHERE last_name = 'Cole'
	OR last_name = 'Bush'

-- When we place statements inside parentheses, 
-- those are evaluated as a group before being combined with other criteria. 
-- In this case, the school name must be exactly F.D. Roosevelt HS, 
-- and the salary must be either less or higher than specified 
-- for a row to meet the criteria of the WHERE clause.
SELECT *
FROM teachers
WHERE school = 'F.D. Roosevelt HS'
	AND (salary < 38000 OR salary > 40000)
	
-- With the preceding information in mind, let’s combine the concepts 
-- in this chapter into one statement to show how they fit together. 
-- SQL is particular about the order of keywords, so follow this convention.

						SELECT column_names
						FROM table_name
						WHERE criteria
						ORDER BY column_names;

-- 
SELECT first_name, last_name, school, hire_date, salary
FROM teachers
WHERE school LIKE '%Roos%'
ORDER BY hire_date DESC

-- ------------------ control exercise ----------------------
-- TRY IT YOURSELF
-- Explore basic queries with these exercises:

-- The school district superintendent asks for a list of teachers 
-- in each school. Write a query that lists the schools in alphabetical order 
-- along with teachers ordered by last name A–Z.

-- Write a query that finds the one teacher whose first name starts 
-- with the letter S and who earns more than $40,000.

-- Rank teachers hired since January 1, 2010, 
-- ordered by highest paid to lowest.
-- -----------------------------------------------------------
-- TABLE teachers
SELECT DISTINCT school, last_name, first_name
FROM teachers
ORDER BY school, last_name;

SELECT first_name, last_name, salary
FROM teachers
WHERE first_name LIKE 'S%' and salary > 40000;

SELECT hire_date, salary, first_name, last_name
FROM teachers
WHERE hire_date > '2010-01-01'
ORDER BY salary DESC;
