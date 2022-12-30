-- 11
-- STATISTICAL FUNCTIONS IN SQL

-- Creating a Census Stats Table

-- Let’s return to one of my favorite data sources, the US Census Bureau. 
-- This time, you’ll use county data from the 2014–2018 American Community Survey 
-- (ACS) 5-Year Estimates, another product from the bureau.

-- Listing 11-1: Creating a 2014-2018 ACS 5-Year Estimates table and importing data

CREATE TABLE acs_2014_2018_stats (
    geoid text CONSTRAINT geoid_key PRIMARY KEY,
    county text NOT NULL,
    st text NOT NULL,
    pct_travel_60_min numeric(5,2),
    pct_bachelors_higher numeric(5,2),
    pct_masters_higher numeric(5,2),
    median_hh_income integer,
    CHECK (pct_masters_higher <= pct_bachelors_higher)
);

COPY acs_2014_2018_stats
FROM '/Users/dmitrijvaledinskij/SQL/practical-sql-2-main/Chapter_11/acs_2014_2018_stats.csv'
WITH (FORMAT CSV, HEADER);

SELECT * FROM acs_2014_2018_stats;

--------------------------------------------------------------------------
-- Measuring Correlation with corr(Y, X)
--------------------------------------------------------------------------
-- Correlation describes the statistical relationship between two variables, 
-- measuring the extent to which a change in one is associated with a change in the other.

-- The Pearson correlation coefficient (generally denoted as r, falls between −1 and 1) measures the strength and direction 
-- of a linear relationship between two variables. End of the range indicates a perfect correlation, 
-- whereas values near zero indicate a random distribution with little correlation. 
-- A positive r value indicates a direct relationship: as one variable increases, the other does too.
-- A negative r value indicates an inverse relationship: as one variable increases, the other decreases.

-- Table 11-1: Interpreting Correlation Coefficients

-- Correlation coefficient (+/−)	What it could mean
-- 				0					No relationship
-- 			.01 to .29				Weak relationship
-- 			.3 to .59				Moderate relationship
-- 			.6 to .99				Strong to nearly perfect relationship
-- 				1					Perfect relationship

-- In standard ANSI SQL and PostgreSQL, we calculate the Pearson correlation coefficient using corr(Y, X). 
-- It’s one of several binary aggregate functions in SQL and is so named because these functions 
-- accept two inputs. The input Y is the dependent variable whose variation depends on the value of another variable, 
-- and X is the independent variable whose value doesn’t depend on another variable.

-- NOTE
-- Even though SQL specifies the Y and X inputs for the corr() function, 
-- correlation calculations don’t distinguish between dependent and independent variables. 
-- Switching the order of inputs in corr() produces the same result. 
-- However, for convenience and readability, these examples order the input variables according 
-- to dependent and independent.

-- We’ll use corr(Y, X) to discover the relationship between education level and income, 
-- with income as our dependent variable and education as our independent variable. 
-- Enter the code in Listing 11-2 to use corr(Y, X) with median_hh_income and pct_bachelors_higher as inputs.

SELECT corr(median_hh_income, pct_bachelors_higher)
    AS bachelors_income_r
FROM acs_2014_2018_stats;


-- Checking Additional Correlations


-- Listing 11-3: Using corr(Y, X) on additional variables

SELECT
    round(
      corr(median_hh_income, pct_bachelors_higher)::numeric, 2
      ) AS bachelors_income_r,
    round(
      corr(pct_travel_60_min, median_hh_income)::numeric, 2
      ) AS income_travel_r,
    round(
      corr(pct_travel_60_min, pct_bachelors_higher)::numeric, 2
      ) AS bachelors_travel_r
FROM acs_2014_2018_stats;


-- Predicting Values with Regression Analysis

-- Researchers also want to predict values using available data. 
-- For example, let’s say 30 percent of a county’s population has a bachelor’s degree or higher. 
-- Given the trend in our data, what would we expect that county’s median household income to be? 
-- Likewise, for each percent increase in education, how much increase, on average, 
-- would we expect in income?

-- We can answer both questions using linear regression. 
-- Simply put, the regression method finds the best linear equation, or straight line, 
-- that describes the relationship between an independent variable (such as education) 
-- and a dependent variable (such as income). We can then look at points along this line 
-- to predict values where we don’t have observations. 
-- Standard ANSI SQL and PostgreSQL include functions that perform linear regression.

-- Y = bX + a
-- Y is the predicted value, which is also the value on the y-axis, or dependent variable.
-- b is the slope of the line, which can be positive or negative. It measures how many units the y-axis value will increase or decrease for each unit of the x-axis value.
-- X represents a value on the x-axis, or independent variable.
-- a is the y-intercept, the value at which the line crosses the y-axis when the X value is zero.


-- Let’s apply this formula using SQL. Earlier, we questioned the expected 
-- median household income in a county where than 30 percent or more of the population 
-- had a bachelor’s degree. In our scatterplot, the percentage with bachelor’s degrees 
-- falls along the x-axis, represented by X in the calculation. 
-- Let’s plug that value into the regression line formula in place of X:

-- Y = b(30) + a

-- To calculate Y, which represents the predicted median household income, 
-- we need the line’s slope, b, and the y-intercept, a. 
-- To get these values, we’ll use the SQL functions regr_slope(Y, X) and regr_intercept(Y, X), 
-- as shown in Listing 11-4.

SELECT
    round(
        regr_slope(median_hh_income, pct_bachelors_higher)::numeric, 2
        ) AS slope,
    round(
        regr_intercept(median_hh_income, pct_bachelors_higher)::numeric, 2
        ) AS y_intercept
FROM acs_2014_2018_stats;

-- Run the query; the result should show the following:

slope      y_intercept
-------    -----------
1016.55       29651.42

Y = 1016.55(30) + 29651.42
Y = 60147.92

--------------------------------------------------------------------------
-- Finding the Effect of an Independent Variable with r-Squared
--------------------------------------------------------------------------

-- Beyond determining the direction and strength of the relationship between two variables, 
-- we can also calculate the extent that the variation in the x (independent) variable explains 
-- the variation in the y (dependent) variable. 
-- To do this we square the r value to find the coefficient of determination, 
-- better known as r-squared. An r-squared indicates the percentage of the variation that is explained by the independent variable, and is a value between zero and one. For example, if r-squared equals 0.1, we would say that the independent variable explains 10 percent of the variation in the dependent variable, or not much at all.

-- To find r-squared, we use the regr_r2(Y, X) function in SQL. 
-- Let’s apply it to our education and income variables using the code in Listing 11-5.

-- Listing 11-5: Calculating the coefficient of determination, or r-squared

SELECT round(
        regr_r2(median_hh_income, pct_bachelors_higher)::numeric, 3
        ) AS r_squared
FROM acs_2014_2018_stats;

-- This time we’ll round off the output to the nearest thousandth place and alias the result 
-- to r_squared. The query should return the following result:

r_squared
---------
    0.490
	
-- The r-squared value of 0.490 indicates that about 49 percent of the variation 
-- in median household income among counties can be explained by the percentage of people 
-- with a bachelor’s degree or higher in that county. Any number of factors could explain 
-- the other 51 percent, and statisticians will typically test numerous combinations of variables 
-- to determine what they are.


--------------------------------------------------------------------------
-- Finding Variance and Standard Deviation
--------------------------------------------------------------------------

-- Variance and standard deviation describe the degree to which a set of values varies from the average of those values. 
-- Variance, often used in finance, is the average of each number’s squared distance from the average.
-- Standard deviation is the square root of the variance and is most useful for assessing data whose 
-- values form a normal distribution, usually visualized as a symmetrical bell curve.

-- When calculating variance and standard deviation, note that they report different units. 
-- Standard deviation is expressed in the same units as the values, 
-- while variance is not — it reports a number that is larger than the units, on a scale of its own.

-- These are the functions for calculating variance:

-- var_pop(numeric) 
	-- Calculates the population variance of the input values. 
	-- In this context, population refers to a dataset that contains all possible values, 
	-- as opposed to a sample that just contains a portion of all possible values.

-- var_samp(numeric) 
-- Calculates the sample variance of the input values. 
-- Use this with data that is sampled from a population, as in a random sample survey.

-- For calculating standard deviation, we use these:

-- stddev_pop(numeric) Calculates the population standard deviation.
-- stddev_samp(numeric) Calculates the sample standard deviation.

-- With functions covering correlation, regression, and other descriptive statistics, 
-- you have a basic toolkit for obtaining a preliminary survey of your data before doing 
-- more rigorous analysis. All these topics are worth in-depth study to better understand 
-- when you might use them and what they measure.
--------------------------------------------------------------------------
-- A classic, easy-to-understand resource I recommend is 
-- the book 'Statistics' by David Freedman, Robert Pisani, and Roger Purves.
--------------------------------------------------------------------------


-- Creating Rankings with SQL

-- Ranking with rank() and dense_rank()

-- Standard ANSI SQL includes several ranking functions, but we’ll just focus on two: rank() and dense_rank(). 
-- Both are window functions, which are defined as functions that perform calculations across 
-- a set of rows relative to the current row. 
-- Unlike aggregate functions, which combine rows to calculate values, with window functions 
-- the query first generates a set of rows, and then the window function runs across the result set 
-- to calculate the value it will return.

-- The difference between rank() and dense_rank() is the way they handle the next rank value 
-- after a tie: 
			-- rank() includes a gap in the rank order, 
			-- but dense_rank() does not. 
-- This concept is easier to understand in action, so let’s look at an example. 
-- Consider a Wall Street analyst who covers the highly competitive widget manufacturing market. 
-- The analyst wants to rank companies by their annual output. 
-- The SQL statements in Listing 11-6 create and fill a table with this data 
-- and then rank the companies by widget output.

-- Listing 11-6: Using the rank() and dense_rank() window functions

CREATE TABLE widget_companies (
    id integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    company text NOT NULL,
    widget_output integer NOT NULL
);

INSERT INTO widget_companies (company, widget_output)
VALUES
    ('Dom Widgets', 125000),
    ('Ariadne Widget Masters', 143000),
    ('Saito Widget Co.', 201000),
    ('Mal Inc.', 133000),
    ('Dream Widget Inc.', 196000),
    ('Miles Amalgamated', 620000),
    ('Arthur Industries', 244000),
    ('Fischer Worldwide', 201000);

SELECT
    company,
    widget_output,
    rank() OVER (ORDER BY widget_output DESC),
    dense_rank() OVER (ORDER BY widget_output DESC)
FROM widget_companies
ORDER BY widget_output DESC;

-- Notice the syntax in the SELECT statement that includes rank() and dense_rank(). 
-- After the function names, we use the OVER clause and in parentheses place an expression 
-- that specifies the “window” of rows the function should operate on. 
-- The window is the set of rows relative to the current row, and in this case, 
-- we want both functions to work on all rows of the widget_output column, 
-- sorted in descending order.

-- Both ways of handling ties have merit, but in practice rank() is used most often. 
-- It’s also what I recommend using, because it more accurately reflects the total number of companies ranked, 
-- shown by the fact that Dream Widget Inc. has four companies ahead of it in total output, not three.


--------------------------------------------------------------------------
-- Ranking Within Subgroups with PARTITION BY
--------------------------------------------------------------------------

-- The ranking we just did was a simple overall ranking based on widget output. 
-- But sometimes you’ll want to produce ranks within groups of rows in a table. 
-- For example, you might want to rank government employees by salary within each department 
-- or rank movies by box-office earnings within each genre.

-- To use window functions in this way, we’ll add PARTITION BY to the OVER clause. 
-- A PARTITION BY clause divides table rows according to values in a column we specify.

-- Here’s an example using made-up data about grocery stores. 
-- Enter the code in Listing 11-7 to fill a table called store_sales.

-- Listing 11-7: Applying rank() within groups using PARTITION BY

CREATE TABLE store_sales (
    store text NOT NULL,
    category text NOT NULL,
    unit_sales bigint NOT NULL,
    CONSTRAINT store_category_key PRIMARY KEY (store, category)
);

INSERT INTO store_sales (store, category, unit_sales)
VALUES
    ('Broders', 'Cereal', 1104),
    ('Wallace', 'Ice Cream', 1863),
    ('Broders', 'Ice Cream', 2517),
    ('Cramers', 'Ice Cream', 2112),
    ('Broders', 'Beer', 641),
    ('Cramers', 'Cereal', 1003),
    ('Cramers', 'Beer', 640),
    ('Wallace', 'Cereal', 980),
    ('Wallace', 'Beer', 988);

SELECT
    category,
    store,
    unit_sales,
    rank() OVER (PARTITION BY category ORDER BY unit_sales DESC)
FROM store_sales
ORDER BY category, rank() OVER (PARTITION BY category 
        ORDER BY unit_sales DESC);


SELECT
    store,
    category,
    unit_sales,
    rank() OVER (PARTITION BY store ORDER BY unit_sales DESC)
FROM store_sales
ORDER BY store, rank() OVER (PARTITION BY store 
        ORDER BY unit_sales DESC);
		
-- The final SELECT statement creates a result set showing how each store’s sales ranks within 
-- each category. The new element is the addition of PARTITION BY in the OVER clause. 
-- In effect, the clause tells the program to create rankings one category at a time, 
-- using the store’s unit sales in descending order.

-- To display the results by category and rank, we add an ORDER BY clause that includes 
-- the category column and the same rank() function syntax.

-- You can apply this concept to many other scenarios: 
		-- for each auto manufacturer, finding the vehicle with the most consumer complaints; 
		-- figuring out which month had the most rainfall in each of the last 20 years; 
		-- finding the team with the most wins against left-handed pitchers; 
-- and so on.

--------------------------------------------------------------------------
-- Calculating Rates for Meaningful Comparisons
--------------------------------------------------------------------------

-- Rankings based on raw counts aren’t always meaningful; in fact, they can be misleading.
-- A more accurate way to compare these numbers is to convert them to rates. 
-- Analysts often calculate a rate per 1,000 people.

-- The math behind this is simple. 
-- Let’s say your town had 115 births and a population of 2,200 women ages 15 to 44. 
-- You can find the per-1,000 rate as follows:

(115 / 2,200) × 1,000 = 52.3

-- In your town, there were 52.3 births per 1,000 women ages 15 to 44, 
-- which you can now compare to other places regardless of their size.


--------------------------------------------------------------------------
-- Finding Rates of Tourism-Related Businesses
--------------------------------------------------------------------------

-- Let’s try calculating rates using SQL and census data. 
-- We’ll join two tables: the census population estimates you imported in Chapter 5 
-- plus data I compiled about tourism-related businesses from the census’ County Business Patterns program. 
-- (You can read about the program methodology at https://www.census.gov/programs-surveys/cbp/about.html.)

-- Listing 11-8: Creating and filling a table for Census county business pattern data

CREATE TABLE cbp_naics_72_establishments (
    state_fips text,
    county_fips text,
    county text NOT NULL,
    st text NOT NULL,
    naics_2017 text NOT NULL,
    naics_2017_label text NOT NULL,
    year smallint NOT NULL,
    establishments integer NOT NULL,
    CONSTRAINT cbp_fips_key PRIMARY KEY (state_fips, county_fips)
);

COPY cbp_naics_72_establishments
FROM '/Users/dmitrijvaledinskij/SQL/practical-sql-2-main/Chapter_11/cbp_naics_72_establishments.csv'
WITH (FORMAT CSV, HEADER);

SELECT *
FROM cbp_naics_72_establishments
ORDER BY state_fips, county_fips
LIMIT 5;

-- Each row contains descriptive information about a county along with the number of business establishments 
-- that fall under code 72 of the North American Industry Classification System (NAICS). 
-- Code 72 covers “Accommodation and Food Services” establishments, mainly hotels, inns, bars, and restaurants. 
-- The number of those businesses in a county is a good proxy for the amount of tourist and recreation activity in the area.

-- Let’s find out which counties have the highest concentration of such businesses per 1,000 population, 
-- using the code in Listing 11-9:
-- Listing 11-9: Finding business rates per thousand population in counties with 50,000 or more people

SELECT
    cbp.county,
    cbp.st,
    cbp.establishments,
    pop.pop_est_2018,
    round( (cbp.establishments::numeric / pop.pop_est_2018) * 1000, 1 )
        AS estabs_per_1000 
FROM cbp_naics_72_establishments cbp JOIN us_counties_pop_est_2019 pop 
    ON cbp.state_fips = pop.state_fips 
    AND cbp.county_fips = pop.county_fips 
WHERE pop.pop_est_2018 >= 50000 
ORDER BY cbp.establishments::numeric / pop.pop_est_2018 DESC; -- ?
-- ORDER BY estabs_per_1000 DESC;


--------------------------------------------------------------------------
-- Smoothing Uneven Data
--------------------------------------------------------------------------
-- A rolling average is an average calculated for each time period in a dataset, 
-- using a moving window of rows as input each time. 
-- Think of a hardware store: it might sell 20 hammers on Monday, 15 hammers on Tuesday, and just a few the rest of the week. 
-- The next week, hammer sales might spike on Friday. 
-- To find the big-picture story in such uneven data, we can smooth numbers by calculating the rolling average, 
-- sometimes called a moving average.

-- Here are two weeks of hammer sales at that hypothetical hardware store:


Date        Hammer sales  Seven-day average
----------  ------------  -----------------
2022-05-01       0
2022-05-02      20
2022-05-03      15
2022-05-04       3
2022-05-05       6
2022-05-06       1
1 2022-05-07       1             6.6
2 2022-05-08       2             6.9
2022-05-09      18             6.6
2022-05-10      13             6.3
2022-05-11       2             6.1
2022-05-12       4             5.9
2022-05-13      12             7.4
2022-05-14       2             7.6


-- Let’s say that for every day we want to know the average sales over the last seven days 
-- (we can choose any period, but a week is an intuitive unit). Once we have seven days of data 1, 
-- we calculate the average of sales over the seven-day period that includes the current day. 
-- The average of hammer sales from May 1 to May 7, 2022, is 6.6 per day.

-- The next day 2, we again average sales over the most recent seven days, 
-- from May 2 to May 8, 2022. The result is 6.9 per day. 
-- As we continue each day, despite the ups and downs in the daily sales, 
-- the seven-day average remains fairly steady. 
-- Over a long period of time, we’ll be able to better discern a trend.

-- Let’s use the window function syntax again to perform this calculation using the code in Listing 11-10.

-- Listing 11-10: Creating a rolling average for export data

CREATE TABLE us_exports (
    year smallint,
    month smallint,
    citrus_export_value bigint,	
    soybeans_export_value bigint
);

COPY us_exports
FROM '/Users/dmitrijvaledinskij/SQL/practical-sql-2-main/Chapter_11/us_exports.csv'
WITH (FORMAT CSV, HEADER);

-- View the monthly citrus data
SELECT year, month, citrus_export_value
FROM us_exports
ORDER BY year, month;

-- Calculate rolling average
SELECT year, month, citrus_export_value,
    round(   
       avg(citrus_export_value) 
            OVER(ORDER BY year, month 
                 ROWS BETWEEN 11 PRECEDING AND CURRENT ROW), 0)
       AS twelve_month_avg
FROM us_exports
ORDER BY year, month;

-- In the SELECT values list, we place an avg() 5 function to calculate the average of the values 
-- in the citrus_export_value column. We follow the function with an OVER clause 6 that has two elements 
-- in parentheses: an ORDER BY clause that sorts the data for the period we plan to average, 
-- and the number of rows to average, using the keywords ROWS BETWEEN 11 PRECEDING AND CURRENT ROW 7. 
-- This tells PostgreSQL to limit the window to the current row and the 11 rows before it — 12 total.

-- We wrap the entire statement, from the avg() function through the OVER clause, 
-- in a round() function to limit the output to whole numbers.

--------------------------------------------------------------------------
-- The window function syntax offers multiple options for analysis. 
-- For example, instead of calculating a rolling average, you could substitute the sum() function 
-- to find the rolling total over a time period. If you calculated a seven-day rolling sum, 
-- you’d know the weekly total ending on any day in your dataset.

-- NOTE
-- Calculating rolling averages or sums works best when there are no breaks in the time periods 
-- in your data. A missing month, for example, will turn a 12-month sum into a 13-month sum 
-- because the window function pays attention to rows, not dates.
--------------------------------------------------------------------------
-- SQL offers additional window functions. 
-- Check the official PostgreSQL documentation at https://www.postgresql.org/docs/current/tutorial-window.html 
-- for an overview of window functions, and check https://www.postgresql.org/docs/current/functions-window.html 
-- for a listing of window functions.
