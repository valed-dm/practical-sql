-- Basic addition, subtraction, and multiplication with SQL
SELECT 2 + 2;
SELECT 9 - 1;
SELECT 3 * 4;

SELECT 3 * 4 AS result;


-- Performing Division and Modulo
SELECT 11 / 6; -- division of one integer by another — by reporting only the integer quotient without any remainder

SELECT 11 % 6; -- modulo operator % returns just the remainder, in this case 5
-- Modulo is useful for more than just fetching a remainder: you can also use it as a test condition. 
-- For example, to check whether a number is even, you can test it using the % 2 operation. 
-- If the result is 0 with no remainder, the number is even.

SELECT 11.0 / 6; -- if one or both of the numbers is a numeric, the result will by default be expressed as a numeric.

-- if you’re working with data stored only as integers and need to force decimal division,
-- you can use CAST to convert one of the integers to a numeric type
SELECT CAST(11 AS numeric(3,1)) / 6;
SELECT CAST(11 AS text) / 6; -- ERROR:  operator does not exist: text / integer


-- Using Exponents, Roots, and Factorials

-- Again, these operators are specific to PostgreSQL; they’re not part of the SQL standard.

-- The exponentiation operator (^) allows you to raise a given base number to an exponent
-- colloquially, we’d call that three to the fourth power:
SELECT 3 ^ 4;

SELECT |/ 10; -- square root of a number
SELECT sqrt(10); -- square root of a number

SELECT ||/ 10; -- cube root

-- the factorial of a number -  the most common is to determine how many ways a number of items can be ordered
-- Say you have four photographs. 
-- How many ways could you order them on a wall? 
-- To find the answer, you’d calculate the factorial by starting with the number of items 
-- and multiplying it by all the smaller positive integers. 
-- So, at 4, the function factorial(4) is equivalent to 4 × 3 × 2 × 1. That’s 24 ways to order four photos.
SELECT factorial(4); 
SELECT 4 !; -- PostgreSQL 13 and earlier only

-- Minding the Order of Operations:

-- Exponents and roots
-- Multiplication, division, modulo
-- Addition and subtraction

SELECT 7 + 8 * 9;
SELECT (7 + 8) * 9;
SELECT 3 ^ 3 - 1;
SELECT 3 ^ (3 - 1);



-- Doing Math Across Census Table Columns

SELECT county_name AS county,
       state_name AS state,
       pop_est_2019 AS pop,
       births_2019 AS births,
       deaths_2019 AS deaths,
       international_migr_2019 AS int_migr,
       domestic_migr_2019 AS dom_migr,
       residual_2019 AS residual
FROM us_counties_pop_est_2019;

-- Adding and Subtracting Columns

SELECT county_name AS county,
       state_name AS state,
       births_2019 AS births,
       deaths_2019 AS deaths,
       births_2019 - deaths_2019 AS natural_increase
FROM us_counties_pop_est_2019
WHERE births_2019 - deaths_2019 > 0
ORDER BY state_name, county_name;

-- Now, let’s build on this to test our data and validate that we imported columns correctly. 
-- The population estimate for 2019 should equal the sum of the 2018 estimate and 
-- the columns about births, deaths, migration, and residual factor.

SELECT county_name AS county,
       state_name AS state,
       pop_est_2019 AS pop,
       pop_est_2018 + births_2019 - deaths_2019 + 
           international_migr_2019 + domestic_migr_2019 +
           residual_2019 AS components_total,
       pop_est_2019 - (pop_est_2018 + births_2019 - deaths_2019 + 
           international_migr_2019 + domestic_migr_2019 +
           residual_2019) AS difference
FROM us_counties_pop_est_2019
ORDER BY difference DESC;

-- Finding Percentages of the Whole

SELECT county_name AS county,
       state_name AS state,
       area_water::numeric / (area_land + area_water) * 100 AS pct_water
FROM us_counties_pop_est_2019
ORDER BY pct_water DESC;

SELECT county_name AS county,
       state_name AS state,
       CAST(area_water AS numeric(12,1)) / (area_land + area_water) * 100 AS pct_water
FROM us_counties_pop_est_2019
ORDER BY pct_water DESC;

-- Tracking Percent Change

-- Another key indicator in data analysis is percent change: how much bigger, or smaller, is one number than another? 
-- Percent change calculations are often employed when analyzing change over time, 
-- and they’re particularly useful for comparing change among similar items.

-- Some examples include the following:

-- The year-over-year change in the number of vehicles sold by each automobile maker
-- The monthly change in subscriptions to each email list owned by a marketing firm
-- The annual increase or decrease in enrollment at schools across a nation
-- The formula to calculate percent change can be expressed like this:

-- (new number – old number) / old number

CREATE TABLE percent_change (
	department text,
	spend_2019 numeric(10,2),
	spend_2022 numeric(10,2)
);

INSERT INTO percent_change
VALUES
    ('Assessor', 178556, 179500),
    ('Building', 250000, 289000),
    ('Clerk', 451980, 650000),
    ('Library', 87777, 90001),
    ('Parks', 250000, 223000),
    ('Water', 199000, 195000);

SELECT * FROM percent_change

SELECT department,
       spend_2019,
       spend_2022,
       round( (spend_2022 - spend_2019) /
                    spend_2019 * 100, 2) AS pct_change
FROM percent_change;

-- Using Aggregate Functions for Averages and Sums

-- SQL also lets you calculate a result from values within the same column using aggregate functions.
-- You can see a full list of PostgreSQL aggregates, which calculate a single result from multiple inputs, 
-- at https://www.postgresql.org/docs/current/functions-aggregate.html. 
-- Two of the most-used aggregate functions in data analysis are avg() and sum().

SELECT sum(pop_est_2019) AS county_sum,
       round(avg(pop_est_2019), 0) AS county_average
FROM us_counties_pop_est_2019;

-- Finding the Median

-- The median value in a set of numbers is as important an indicator, if not more so, than the average. 
-- Here’s the difference between median and average:

		-- Average: The sum of all the values divided by the number of values
		-- Median: The “middle” value in an ordered set of values

-- A good test is to calculate the average and the median for a group of values. 
-- If they’re close, the group is probably normally distributed (the familiar bell curve), and the average is useful. 
-- If they’re far apart, the values are not normally distributed, and the median is the better representation.


-- Finding the Median with Percentile Functions

-- PostgreSQL (as with most relational databases) does not have a built-in median() function like you’d find in Excel or other spreadsheet programs.
-- SQL percentile function to find the median and use quantiles or cut points to divide a group of numbers 
-- into equal sizes. 
-- Percentile functions are part of standard ANSI SQL.
-- In statistics, percentiles indicate the point in an ordered set of data 
-- below which a certain percentage of the data is found. 
-- For example, a doctor might tell you that your height places you in the 60th percentile 
-- for an adult in your age group. 
-- That means 60 percent of people are shorter than you.

-- percentile_cont(n: calculates percentiles as continuous values
-- percentile_disc(n): returns only discrete values, meaning the result will be rounded 
-- to one of the numbers in the set.

CREATE TABLE percentile_test (
	numbers integer
)

SELECT * from percentile_test

INSERT INTO percentile_test (numbers) VALUES
	(1),  (2), (3), (4), (5), (6);

DROP TABLE percentile_test

SELECT
    percentile_cont(.5)
    WITHIN GROUP (ORDER BY numbers),
    percentile_disc(.5)
    WITHIN GROUP (ORDER BY numbers)
FROM percentile_test;


-- Finding Median and Percentiles with Census Data

-- Our census data can show how a median tells a different story than an average:
SELECT sum(pop_est_2019) AS county_sum,
       round(avg(pop_est_2019), 0) AS county_average,
       percentile_cont(.5)
       WITHIN GROUP (ORDER BY pop_est_2019) AS county_median
FROM us_counties_pop_est_2019;


-- Finding Other Quantiles with Percentile Functions

-- You can also slice data into smaller equal groups for analysis:
-- Most common are quartiles (four equal groups), 
-- quintiles (five groups), 
-- and deciles (10 groups).

-- you can pass values into percentile_cont() using an array, a list of items.

-- quartiles
SELECT percentile_cont(ARRAY[.25,.5,.75])
       WITHIN GROUP (ORDER BY pop_est_2019) AS quartiles
FROM us_counties_pop_est_2019;
-- Because we passed in an array, PostgreSQL returns an array, 
-- denoted in the results by curly brackets. Each quartile is separated by commas.
-- See the PostgreSQL documentation at https://www.postgresql.org/docs/current/arrays.html 
-- for examples of declaring, searching, and modifying arrays.

-- Arrays also come with a host of functions 
-- (noted for PostgreSQL at https://www.postgresql.org/docs/current/functions-array.html) 
-- that allow you to perform tasks such as adding or removing values or counting the elements. 
-- A handy function for working with the result returned in Listing 6-12 
-- is unnest(), 
-- which makes the array easier to read by turning it into rows. Listing 6-13 shows the code.

SELECT unnest(
			percentile_cont(ARRAY[.25,.5,.75])
            WITHIN GROUP (ORDER BY pop_est_2019)
            ) AS quartiles
FROM us_counties_pop_est_2019;

-- Extra:
-- quintiles
SELECT unnest(
			percentile_cont(ARRAY[.2,.4,.6,.8])
       		WITHIN GROUP (ORDER BY pop_est_2019)
			) AS quintiles
FROM us_counties_pop_est_2019;

-- deciles
SELECT unnest(
			percentile_cont(ARRAY[.1,.2,.3,.4,.5,.6,.7,.8,.9])
       		WITHIN GROUP (ORDER BY pop_est_2019)
			) AS deciles
FROM us_counties_pop_est_2019;


-- Finding the Mode
-- We can find the mode, the value that appears most often, using the PostgreSQL mode() function. 
-- The function is not part of standard SQL and has a syntax similar to the percentile functions.

SELECT mode() WITHIN GROUP (ORDER BY births_2019)
FROM us_counties_pop_est_2019;


-- exercises

-- Write a SQL statement for calculating the area of a circle whose radius is 5 inches.
-- Do you need parentheses in your calculation? Why or why not?
SELECT 3.141592653 * 5 ^ 2 as circle_area

-- Using the 2019 US Census county estimates data, 
-- calculate a ratio of births to deaths for each county in New York state. 
-- Which region of the state generally saw a higher ratio of births to deaths in 2019?

SELECT state_name AS state,
	   county_name AS county,
       births_2019 AS births,
       deaths_2019 AS deaths,
       round(
		   births_2019::numeric / deaths_2019,
		   4
		   ) AS ratio
FROM us_counties_pop_est_2019
WHERE state_name ILIKE 'new york'
ORDER BY ratio DESC;


-- Was the 2019 median county population estimate higher in California or New York?

SELECT percentile_cont(.5)
	   WITHIN GROUP (ORDER BY pop_est_2019) as new_york_median
FROM us_counties_pop_est_2019
WHERE state_name ILIKE 'new york'; -- 86687

SELECT percentile_cont(.5)
	   WITHIN GROUP (ORDER BY pop_est_2019) as california_median
FROM us_counties_pop_est_2019
WHERE state_name ILIKE 'california'; -- 187029



