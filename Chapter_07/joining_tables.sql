-- JOINING TABLES IN A RELATIONAL DATABASE

-- SELECT * 
-- FROM table_a JOIN table_b
-- ON table_a.key_column = table_b.foreign_key_column --  the equals comparison operator

-- Relating Tables with Key Columns

CREATE TABLE departments (
    dept_id integer,
    dept text,
    city text,
    CONSTRAINT dept_key PRIMARY KEY (dept_id),
    CONSTRAINT dept_city_unique UNIQUE (dept, city)
);

SELECT * FROM departments;

CREATE TABLE employees (
    emp_id integer,
    first_name text,
    last_name text,
    salary numeric(10,2),
    dept_id integer REFERENCES departments (dept_id),
    CONSTRAINT emp_key PRIMARY KEY (emp_id)
);

SELECT * FROM employees;

INSERT INTO departments
VALUES
    (1, 'Tax', 'Atlanta'),
    (2, 'IT', 'Boston');

INSERT INTO departments
VALUES
    (3, 'Tax', 'Atlanta'),
    (4, 'IT', 'Boston');

	
INSERT INTO employees
VALUES
    (1, 'Julia', 'Reyes', 115300, 1),
    (2, 'Janet', 'King', 98000, 1),
    (3, 'Arthur', 'Pappas', 72700, 2),
    (4, 'Michael', 'Taylor', 89500, 2);

-- The dept_id column is the table’s primary key. 
-- A primary key is a column or collection of columns whose values uniquely identify each row in a table. 
-- A valid primary key column enforces certain constraints:

		-- The column or collection of columns must have a unique value for each row.
		-- The column or collection of columns can’t have missing values.


SELECT *
FROM employees JOIN departments
ON employees.dept_id = departments.dept_id
	ORDER BY employees.dept_id;


-- Understanding JOIN Types

-- JOIN Returns rows from both tables where matching values are found in the joined columns of both tables. 
-- Alternate syntax is INNER JOIN.

-- LEFT JOIN Returns every row from the left table. 
-- When SQL finds a row with a matching value in the right table, values from that row are included in the results. 
-- Otherwise, no values from the right table are displayed.

-- RIGHT JOIN Returns every row from the right table. 
-- When SQL finds a row with a matching value in the left table, values from that row are included in the results. 
-- Otherwise, no values from the left table are displayed.

-- FULL OUTER JOIN Returns every row from both tables and joins the rows where values in the joined columns match. 
-- If there’s no match for a value in either the left or right table, the query result contains no values for that table.

-- CROSS JOIN Returns every possible combination of rows from both tables.


CREATE TABLE district_2020 (
    id integer CONSTRAINT id_key_2020 PRIMARY KEY,
    school_2020 text
);

CREATE TABLE district_2035 (
    id integer CONSTRAINT id_key_2035 PRIMARY KEY,
    school_2035 text
);

INSERT INTO district_2020 VALUES
    (1, 'Oak Street School'),
    (2, 'Roosevelt High School'),
    (5, 'Dover Middle School'),
    (6, 'Webutuck High School');

SELECT * FROM district_2020;

INSERT INTO district_2035 VALUES
    (1, 'Oak Street School'),
    (2, 'Roosevelt High School'),
    (3, 'Morrison Elementary'),
    (4, 'Chase Magnet Academy'),
    (6, 'Webutuck High School');
	
SELECT * FROM district_2035;

-- A common first task for a data analyst—especially if you have tables with many more rows than these — 
-- is to use SQL to identify which schools are present in both tables. 
-- Using different joins can help you find those schools, plus other details.

-- JOIN -- INNER JOIN --
-- We use JOIN, or INNER JOIN, when we want to return only rows from both tables 
-- where values match in the columns we used for the join.
SELECT *
FROM district_2020 JOIN district_2035
ON district_2020.id = district_2035.id
ORDER BY district_2020.id
-- JOIN with USING
-- If you’re using identical names for columns in a join’s ON clause, 
-- you can reduce redundant output and simplify the query syntax by substituting 
-- a USING clause in place of the ON clause

-- If you’re using identical names for columns in a join’s ON clause, 
-- you can reduce redundant output and simplify the query syntax by substituting a USING clause 
-- in place of the ON clause,
SELECT * 
FROM district_2020 JOIN district_2035
USING(id)
ORDER BY district_2020.id

-- LEFT JOIN and RIGHT JOIN
-- In contrast to JOIN, the LEFT JOIN and RIGHT JOIN keywords each return 
-- all rows from one table and, when a row with a matching value in the other table exists, 
-- values from that row are included in the results. Otherwise, no values from the other table are displayed.
SELECT *
FROM district_2020 LEFT JOIN district_2035
ON district_2020.id = district_2035.id
ORDER BY district_2020.id

SELECT *
FROM district_2020 RIGHT JOIN district_2035
ON district_2020.id = district_2035.id
ORDER BY district_2035.id

-- You’d use either of these join types in a few circumstances:

-- You want your query results to contain all the rows from one of the tables.

-- You want to look for missing values in one of the tables. 
-- An example is when you’re comparing data about an entity representing two different time periods.

-- When you know some rows in a joined table won’t have matching values.

-- As with JOIN, you can substitute the USING clause for the ON clause if the tables meet the criteria.
SELECT *
FROM district_2020 RIGHT JOIN district_2035
USING(id)
ORDER BY district_2035.id


-- FULL OUTER JOIN
-- When you want to see all rows from both tables in a join, 
-- regardless of whether any match, use the FULL OUTER JOIN option.
-- The result gives every row from the left table, including matching rows and blanks for missing rows 
-- from the right table, followed by any leftover missing rows from the right table:
SELECT *
FROM district_2020 FULL OUTER JOIN district_2035
ON district_2020.id = district_2035.id
ORDER BY district_2020.id;
-- You can use it for a couple of tasks: 
		-- to link two data sources that partially overlap 
		-- to visualize the degree to which tables share matching values.
SELECT *
FROM district_2020 FULL OUTER JOIN district_2035
USING(id)
ORDER BY district_2035.id;


-- CROSS JOIN
-- In a CROSS JOIN query, the result (also known as a Cartesian product) lines up each row in the left table 
-- with each row in the right table to present all possible combinations of rows.
SELECT *
FROM district_2020 CROSS JOIN district_2035
ORDER BY district_2020.id, district_2035.id;
-- Unless you want to take an extra-long coffee break, I suggest avoiding a CROSS JOIN query on large tables. 
-- Two tables with 250,000 records each would produce a result set of 62.5 billion rows 
-- and tax even the hardiest server. A more practical use would be generating data to create a checklist, 
-- such as all colors you’d want to offer for each of a handful of shirt styles in a store.


-- Using NULL to Find Rows with Missing Values

-- When you have only a handful of rows, eyeballing the data is an easy way to look for rows with missing data, 
-- as we did in the previous join examples. For large tables, you need a better strategy: 
-- filtering to show all rows without a match. 
-- To do this, we employ the keyword NULL.
-- In SQL, NULL is a special value that represents a condition in which there’s no data present 
-- or where the data is unknown because it wasn’t included.
SELECT *
FROM district_2020 LEFT JOIN district_2035
ON district_2020.id = district_2035.id
WHERE district_2035.id IS NULL;
-- Now the result of the join shows only the one row from the table on the left 
-- of the join that didn’t have a match in the table on the right. 
-- This is commonly referred to as an anti-join.


-- Understanding the Three Types of Table Relationships

-- Part of the science (or art, some may say) of joining tables involves understanding 
-- how the database designer intends for the tables to relate, also known as the database’s relational model. 
-- There are three types of table relationships: 
		-- one to one, 
		-- one to many, 
		-- and many to many.
		
-- ONE-TO-ONE: That means any given id in either table will find no more than one match in the other table. 
-- In database parlance, this is called a one-to-one relationship.

-- ONE-TO-MANY: In a one-to-many relationship, a key value in one table will have multiple matching values 
-- in another table’s joined column.

-- MANY-TO-MANY: A many-to-many relationship exists when multiple items in one table can relate 
-- to multiple items in another table, and vice versa.


-- Selecting Specific Columns in a Join

SELECT id 
FROM district_2020 LEFT JOIN district_2035
ON district_2020.id = district_2035.id; -- ERROR:  column reference "id" is ambiguous

-- When joining tables, it’s a best practice to include the table name along with the column. 
-- The reason is that more than one table can contain columns with the same name!

SELECT district_2020.id,
       district_2020.school_2020,
       district_2035.school_2035
FROM district_2020 LEFT JOIN district_2035
ON district_2020.id = district_2035.id
ORDER BY district_2020.id;

SELECT district_2020.id as d20_id,
       district_2020.school_2020,
       district_2035.school_2035
FROM district_2020 LEFT JOIN district_2035
ON district_2020.id = district_2035.id
ORDER BY district_2020.id;


-- Simplifying JOIN Syntax with Table Aliases

SELECT d20.id,
       d20.school_2020,
       d35.school_2035
-- In the FROM clause, we declare the alias d20 to represent district_2020 
-- and the alias d35 to represent district_2035 using the AS keyword. 
FROM district_2020 AS d20 LEFT JOIN district_2035 AS d35
ON d20.id = d35.id
ORDER BY d20.id;

-- Note that the AS keyword is optional here; 
-- you can omit it when declaring an alias for both table names and column names.
SELECT d20.id as d20_id,
       d20.school_2020,
       d35.school_2035
FROM district_2020 d20 RIGHT JOIN district_2035 d35
ON d20.id = d35.id
ORDER BY d35.id;


-- Joining Multiple Tables

-- Of course, SQL joins aren’t limited to two tables. 
-- We can continue adding tables to the query as long as we have columns with matching values to join on.

CREATE TABLE district_2020_enrollment (
    id integer,
    enrollment integer
);

CREATE TABLE district_2020_grades (
    id integer,
    grades varchar(10)
);

INSERT INTO district_2020_enrollment
VALUES
    (1, 360),
    (2, 1001),
    (5, 450),
    (6, 927);

INSERT INTO district_2020_grades
VALUES
    (1, 'K-3'),
    (2, '9-12'),
    (5, '6-8'),
    (6, '9-12');


-- In the SELECT query, we join district_2020 to district_2020_enrollment using the tables’ id columns. 
-- We also declare table aliases to keep the code compact. 
-- Next, the query joins district_2020 to district_2020_grades, again on the id columns:
SELECT d20.id,
       d20.school_2020,
       en.enrollment,
       gr.grades
FROM district_2020 AS d20 
JOIN district_2020_enrollment AS en
    ON d20.id = en.id
JOIN district_2020_grades AS gr
    ON d20.id = gr.id
ORDER BY d20.id;

-- my example just to try other data; has no sense as different years used:
SELECT d35.id,
       d35.school_2035,
       en.enrollment,
       gr.grades
FROM district_2035 AS d35 
JOIN district_2020_enrollment AS en
    ON d35.id = en.id
JOIN district_2020_grades AS gr
    ON d35.id = gr.id
ORDER BY d35.id;


-- Combining Query Results with Set Operators

-- Certain instances require us to re-order our data so that columns from various tables aren’t returned side by side, 
-- as a join produces, but brought together into one result. One way to manipulate our data this way is to use 
-- the ANSI standard SQL set operators UNION, INTERSECT, and EXCEPT. 
-- Set operators combine the results of multiple SELECT queries. Here’s a quick look at what each does:

-- UNION Given two queries, it appends the rows in the results of the second query 
-- to the rows returned by the first query and removes duplicates, producing a combined set of distinct rows. 
-- Modifying the syntax to UNION ALL will return all rows, including duplicates.

-- INTERSECT Returns only rows that exist in the results of both queries and removes duplicates.

-- EXCEPT Returns rows that exist in the results of the first query but not in the results of the second query. 
-- Duplicates are removed.

-- For each of these, both queries must produce the same number of columns, 
-- and the resulting columns from both queries must have compatible data types. 
-- Let’s continue using our school district tables for brief examples of how they work.


-- UNION and UNION ALL

-- Notice that the names of the schools are in the column school_2020, which is part of the first query’s results.
SELECT * FROM district_2020
UNION
SELECT * FROM district_2035
ORDER BY id;

-- If we want the results to include duplicate rows, we substitute UNION ALL for UNION in the query:
SELECT * FROM district_2020
UNION ALL
SELECT * FROM district_2035
ORDER BY id;

-- Finally, it’s often helpful to customize merged results. 
-- You may want to know, for example, which table values in each row came from, 
-- or you may want to include or exclude certain columns.
-- In the first query’s SELECT statement, we designate the string 2020 as the value to fill a column named year. 
-- We also do this in the second query using 2035 as the string. 
-- This is similar to the technique you employed in the section “Adding a Value to a Column During Import” 
-- in Chapter 5. Then, we rename the school_2020 column as school because it will show schools from both years.
SELECT '2020' AS year, school_2020 AS school
FROM district_2020
UNION ALL
SELECT '2035' AS year, school_2035
FROM district_2035
ORDER BY school, year;
-- Now our query produces a year designation for each school, and we can see, for example, 
-- that the row with Dover Middle School comes from the result of querying the district_2020 table.


-- INTERSECT and EXCEPT
-- The query using INTERSECT returns just the rows that exist in the results of both queries and eliminates duplicates:
SELECT * FROM district_2020
INTERSECT
SELECT * FROM district_2035
ORDER BY id;
-- The query using EXCEPT 2 returns rows that exist in the first query but not in the second, also eliminating duplicates if present:
SELECT * FROM district_2020
EXCEPT
SELECT * FROM district_2035
ORDER BY id;


-- Performing Math on Joined Table Columns

-- If you work with any data that has a new release at regular intervals, 
-- you’ll find this concept useful for joining a newly released table to an older one
-- and exploring how values have changed.

CREATE TABLE us_counties_pop_est_2010 (
    state_fips text, 
    county_fips text,
    region smallint,
    state_name text,
    county_name text,
    estimates_base_2010 integer,
    CONSTRAINT counties_2010_key PRIMARY KEY (state_fips, county_fips)
);

COPY us_counties_pop_est_2010
FROM '/Users/dmitrijvaledinskij/SQL/practical-sql-2-main/Chapter_07/us_counties_pop_est_2010.csv'
WITH (FORMAT CSV, HEADER);

SELECT c2019.county_name,
       c2019.state_name,
       c2019.pop_est_2019 AS pop_2019,
       c2010.estimates_base_2010 AS pop_2010,
       c2019.pop_est_2019 - c2010.estimates_base_2010 AS raw_change,
       round( (c2019.pop_est_2019::numeric - c2010.estimates_base_2010)
           / c2010.estimates_base_2010 * 100, 1 ) AS pct_change
FROM us_counties_pop_est_2019 AS c2019
    JOIN us_counties_pop_est_2010 AS c2010
ON c2019.state_fips = c2010.state_fips
    AND c2019.county_fips = c2010.county_fips
ORDER BY pct_change DESC;


-- EXERCISES:

-- According to the census population estimates, which county had the greatest percentage loss of population 
-- between 2010 and 2019? Try an internet search to find out what happened. 
-- (Hint: The decrease is related to a particular type of facility.)

SELECT c2019.county_name,
       c2019.state_name,
       c2019.pop_est_2019 AS pop_2019,
       c2010.estimates_base_2010 AS pop_2010,
       c2019.pop_est_2019 - c2010.estimates_base_2010 AS raw_change,
       round( (c2019.pop_est_2019::numeric - c2010.estimates_base_2010)
           / c2010.estimates_base_2010 * 100, 1 ) AS pct_change
FROM us_counties_pop_est_2019 AS c2019
    JOIN us_counties_pop_est_2010 AS c2010
ON c2019.state_fips = c2010.state_fips
    AND c2019.county_fips = c2010.county_fips
ORDER BY pct_change; -- just remove DESC sort option from previous request.

-- Apply the concepts you learned about UNION to create query results that merge queries 
-- of the census county population estimates for 2010 and 2019. 
-- Your results should include a column called year that specifies the year of the estimate 
-- for each row in the results.

SELECT '2019' AS year, state_name as state, county_name AS county, pop_est_2019 AS pop_est
FROM us_counties_pop_est_2019
UNION
SELECT '2010' AS year, state_name as state, county_name AS county, estimates_base_2010
FROM us_counties_pop_est_2010
ORDER BY state, county;

-- Using the percentile_cont() function from Chapter 6, 
-- determine the median of the percent change in estimated county population between 2010 and 2019.

SELECT percentile_cont(.5) WITHIN GROUP (ORDER BY c2010.estimates_base_2010) AS county_median_2010,
	   percentile_cont(.5) WITHIN GROUP (ORDER BY c2019.pop_est_2019) AS county_median_2019
FROM us_counties_pop_est_2019 AS c2019
    JOIN us_counties_pop_est_2010 AS c2010
ON c2019.state_fips = c2010.state_fips
    AND c2019.county_fips = c2010.county_fips
-----------------------------------------
SELECT sum(pop_est_2019) AS county_sum,
       round(avg(pop_est_2019), 0) AS county_average,
       percentile_cont(.5)
       WITHIN GROUP (ORDER BY pop_est_2019) AS county_median
FROM us_counties_pop_est_2019;

-- we export pct_change data to .csv to memorialize all values:
COPY (
	SELECT round( (c2019.pop_est_2019::numeric - c2010.estimates_base_2010)
           / c2010.estimates_base_2010 * 100, 1 ) AS pct_change
	FROM us_counties_pop_est_2019 AS c2019
    	JOIN us_counties_pop_est_2010 AS c2010
	ON c2019.state_fips = c2010.state_fips
    	AND c2019.county_fips = c2010.county_fips
	ORDER BY pct_change DESC
     )
TO '/Users/dmitrijvaledinskij/SQL/practical-sql-2-main/Chapter_07/pct_change.csv'
WITH (FORMAT CSV, HEADER);


CREATE TABLE pop_pct_change_2010_2019 (
    pct_change numeric(5, 2)
);

DROP TABLE pop_pct_change_2010_2019;

SELECT * FROM pop_pct_change_2010_2019;


COPY pop_pct_change_2010_2019
FROM '/Users/dmitrijvaledinskij/SQL/practical-sql-2-main/Chapter_07/pct_change.csv'
WITH(FORMAT CSV, HEADER)

-- The median of the percent change in estimated county population between 2010 and 2019.
SELECT percentile_cont(.5)
WITHIN GROUP (ORDER BY pct_change) AS median_pct_change_2010_19
FROM pop_pct_change_2010_2019
-----------------------------------------