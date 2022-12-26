-- EXTRACTING INFORMATION BY GROUPING AND SUMMARIZING

-- For this exercise, we’ll assume the role of an analyst who just received a fresh copy
-- of the library dataset to produce a report describing trends from the data. 
-- We’ll create three tables to hold data from the 2018, 2017, and 2016 surveys. 
-- (Often, it’s helpful to assess multiple years of data to discern trends.) 
-- Then we’ll summarize the more interesting data in each table and join the tables 
-- to see how measures changed over time.

-- Creating the 2018 Library Data Table
-- Listing 9-1: Creating and filling the 2018 Public Libraries Survey table

CREATE TABLE pls_fy2018_libraries (
    stabr text NOT NULL,
    fscskey text CONSTRAINT fscskey_2018_pkey PRIMARY KEY,
    libid text NOT NULL,
    libname text NOT NULL,
    address text NOT NULL,
    city text NOT NULL,
    zip text NOT NULL,
    county text NOT NULL,
    phone text NOT NULL,
    c_relatn text NOT NULL,
    c_legbas text NOT NULL,
    c_admin text NOT NULL,
    c_fscs text NOT NULL,
    geocode text NOT NULL,
    lsabound text NOT NULL,
    startdate text NOT NULL,
    enddate text NOT NULL,
    popu_lsa integer NOT NULL,
    popu_und integer NOT NULL,
    centlib integer NOT NULL,
    branlib integer NOT NULL,
    bkmob integer NOT NULL,
    totstaff numeric(8,2) NOT NULL,
    bkvol integer NOT NULL,
    ebook integer NOT NULL,
    audio_ph integer NOT NULL,
    audio_dl integer NOT NULL,
    video_ph integer NOT NULL,
    video_dl integer NOT NULL,
    ec_lo_ot integer NOT NULL,
    subscrip integer NOT NULL,
    hrs_open integer NOT NULL,
    visits integer NOT NULL,
    reference integer NOT NULL,
    regbor integer NOT NULL,
    totcir integer NOT NULL,
    kidcircl integer NOT NULL,
    totpro integer NOT NULL,
    gpterms integer NOT NULL,
    pitusr integer NOT NULL,
    wifisess integer NOT NULL,
    obereg text NOT NULL,
    statstru text NOT NULL,
    statname text NOT NULL,
    stataddr text NOT NULL,
    longitude numeric(10,7) NOT NULL,
    latitude numeric(10,7) NOT NULL
);

COPY pls_fy2018_libraries
FROM '/Users/dmitrijvaledinskij/SQL/practical-sql-2-main/Chapter_09/pls_fy2018_libraries.csv'
WITH (FORMAT CSV, HEADER);

CREATE INDEX libname_2018_idx ON pls_fy2018_libraries (libname);

SELECT DISTINCT libname FROM pls_fy2018_libraries
ORDER BY libname;



-- Creating the 2017 and 2016 Library Data Tables

-- (Code to create and fill both tables in Listing 9-2)

COPY pls_fy2017_libraries
FROM '/Users/dmitrijvaledinskij/SQL/practical-sql-2-main/Chapter_09/pls_fy2017_libraries.csv'
WITH (FORMAT CSV, HEADER);

COPY pls_fy2016_libraries
FROM '/Users/dmitrijvaledinskij/SQL/practical-sql-2-main/Chapter_09/pls_fy2016_libraries.csv'
WITH (FORMAT CSV, HEADER);

CREATE INDEX libname_2017_idx ON pls_fy2017_libraries (libname);
CREATE INDEX libname_2016_idx ON pls_fy2016_libraries (libname);

-- The documentation for the survey years is 
-- at https://www.imls.gov/research-evaluation/data-collection/public-libraries-survey/. 
-- Now, let’s mine this data to discover its story.



-- Exploring the Library Data Using Aggregate Functions

-- Aggregate functions combine values from multiple rows, perform an operation on those values, 
-- and return a single result. For example, you might return the average of values with 
-- the avg() aggregate function, as you learned in Chapter 6. 
-- Some aggregate functions are part of the SQL standard, and others are specific to PostgreSQL 
-- and other database managers. Most of the aggregate functions used in this chapter 
-- are part of standard SQL (a full list of PostgreSQL aggregates is at 
-- https://www.postgresql.org/docs/current/functions-aggregate.html).


-- Counting Rows and Values Using count()

-- The count() aggregate function, which is part of the ANSI SQL standard, makes it easy 
-- to check the number of rows and perform other counting tasks. 
-- If we supply an asterisk as an input, such as count(*), the asterisk acts as a wildcard, 
-- so the function returns the number of table rows regardless of whether they include NULL values.

SELECT count(*)
FROM pls_fy2018_libraries;

SELECT count(*)
FROM pls_fy2017_libraries;

SELECT count(*)
FROM pls_fy2016_libraries;

-- All three results match the number of rows we expected. 
-- This is a good first step because it will alert us to issues such as missing rows 
-- or a case where we might have imported the wrong file.


-- Counting Values Present in a Column

-- If we supply a column name instead of an asterisk to count(), 
-- it will return the number of rows that are not NULL.

SELECT count(phone)
FROM pls_fy2018_libraries; -- The result shows 9,261 rows have a value in phone, the same as the total rows we found earlier.


-- Counting Distinct Values in a Column


SELECT count(libname)
FROM pls_fy2018_libraries;

SELECT count(DISTINCT libname)
FROM pls_fy2018_libraries;


-- Finding Maximum and Minimum Values Using max() and min()

-- The max() and min() functions give us the largest and smallest values in a column 
-- and are useful for a couple of reasons. First, they help us get a sense of the scope 
-- of the values reported. Second, the functions can reveal unexpected issues with data, 
-- as you’ll see now.

SELECT max(visits), min(visits)
FROM pls_fy2018_libraries;

-- In this case, negative values in number columns indicate the following:

-- A value of -1 indicates a “nonresponse” to that question.
-- A value of -3 indicates “not applicable” and is used when a library agency has closed either temporarily or permanently.

-- We’ll need to account for and exclude negative values as we explore the data, 
-- because summing a column and including the negative values will result in an incorrect total. 
-- We can do this using a WHERE clause to filter them. It’s a good reminder to always 
-- read the documentation for the data to get ahead of the issue instead of having to backtrack 
-- after spending a lot of time on deeper analysis!

-- NOTE
-- A better alternative for this negative value scenario is to use NULL in rows in the visits column 
-- where response data is absent and then create a separate visits_flag column to hold codes explaining why.


-- Aggregating Data Using GROUP BY


-- When you use the GROUP BY clause with aggregate functions, you can group results according 
-- to the values in one or more columns. This allows us to perform operations such as 
-- sum() or count() for every state in the table or for every type of library agency.

-- Let’s explore how using GROUP BY with aggregate functions works. 
-- On its own, GROUP BY, which is also part of standard ANSI SQL, 
-- eliminates duplicate values from the results, similar to DISTINCT:

SELECT stabr -- stabr = state abbrevation
FROM pls_fy2018_libraries
GROUP BY stabr
ORDER BY stabr;

-- You’re not limited to grouping just one column.

SELECT city, stabr
FROM pls_fy2018_libraries
GROUP BY city, stabr
ORDER BY city, stabr;

-- This grouping returns 9,013 rows, 248 fewer than the total table rows. 
-- The result indicates that the file includes multiple instances where there’s 
-- more than one library agency for a particular city and state combination.


-- Combining GROUP BY with count()

-- If we combine GROUP BY with an aggregate function, such as count(), 
-- we can pull more descriptive information from our data. 
-- For example, we know 9,261 library agencies are in the 2018 table. 
-- We can get a count of agencies by state and sort them to see which states have the most.

SELECT stabr, count(*)
FROM pls_fy2018_libraries
GROUP BY stabr
ORDER BY count(*) DESC;


-- Using GROUP BY on Multiple Columns with count()

-- Listing 9-10 shows the code for counting the number of agencies in each state that moved, 
-- had a minor address change, or had no change 
-- using GROUP BY with stabr and stataddr and adding count().

-- 00 => no change from last year
-- 07 => Moved to a new location
-- 15 => Minor address change

SELECT stabr, stataddr, count(*)
FROM pls_fy2018_libraries
GROUP BY stabr, stataddr
ORDER BY stabr, stataddr;
	-- The key sections of the query are the column names and the count() function after SELECT, 
	-- and making sure both columns are reflected in the GROUP BY clause to ensure that count() 
	-- will show the number of unique combinations of stabr and stataddr.


-- Revisiting sum() to Examine Library Activity

-- Now let’s expand our techniques to include grouping and aggregating across joined tables 
-- using the 2018, 2017, and 2016 libraries data. 
-- Our goal is to identify trends in library visits spanning that three-year period. 
-- To do this, we need to calculate totals using the sum() aggregate function.
-- Before we dig into these queries, let’s address the values -3 and -1, 
-- which indicate “not applicable” and “nonresponse.” 
-- To prevent these negative numbers from affecting the analysis, 
-- we’ll filter them out using a WHERE clause to limit the queries to rows where values in visits are zero or greater.

-- 2018
SELECT sum(visits) AS visits_2018
FROM pls_fy2018_libraries
WHERE visits >= 0;

-- 2017
SELECT sum(visits) AS visits_2017
FROM pls_fy2017_libraries
WHERE visits >= 0;

-- 2016
SELECT sum(visits) AS visits_2016
FROM pls_fy2016_libraries
WHERE visits >= 0;

-- Let’s refine this approach. 
-- These queries sum visits recorded in each table. 
-- But from the row counts we ran earlier in the chapter, we know that each table contains 
-- a different number of library agencies: 9,261 in 2018; 9,245 in 2017; and 9,252 in 2016. 
-- The differences are likely due to agencies opening, closing, or merging. 
-- So, let’s determine how the sum of visits will differ if we limit the analysis 
-- to library agencies that exist in all three tables and have a non-negative value for visits. 
-- We can do that by joining the tables, as shown in Listing 9-12.

SELECT sum(pls18.visits) AS visits_2018,
       sum(pls17.visits) AS visits_2017,
       sum(pls16.visits) AS visits_2016
FROM pls_fy2018_libraries pls18
       JOIN pls_fy2017_libraries pls17 ON pls18.fscskey = pls17.fscskey
       JOIN pls_fy2016_libraries pls16 ON pls18.fscskey = pls16.fscskey
WHERE pls18.visits >= 0
       AND pls17.visits >= 0
       AND pls16.visits >= 0;
	   
-- For a full picture of how library use is changing, we’d want to run a similar query on all of the columns 
-- that contain performance indicators to chronicle the trend in each. 
-- For example, the column wifisess shows how many times users connected to the library’s 
-- wireless internet. If we use wifisess instead of visits in Listing 9-11, we get this result:

SELECT sum(pls18.wifisess) AS wifi_2018,
       sum(pls17.wifisess) AS wifi_2017,
       sum(pls16.wifisess) AS wifi_2016
FROM pls_fy2018_libraries pls18
       JOIN pls_fy2017_libraries pls17 ON pls18.fscskey = pls17.fscskey
       JOIN pls_fy2016_libraries pls16 ON pls18.fscskey = pls16.fscskey
WHERE pls18.wifisess >= 0
       AND pls17.wifisess >= 0
       AND pls16.wifisess >= 0;
	   
-- Grouping Visit Sums by State

-- Now that we know library visits dropped for the United States as a whole 
-- between 2016 and 2018, you might ask yourself, 
-- “Did every part of the country see a decrease, 
-- or did the degree of the trend vary by region?” 
-- We can answer this question by modifying our preceding query 
-- to group by the state code. Let’s also use a percent-change calculation 
-- to compare the trend by state. 
-- Listing 9-13 contains the full code.

SELECT pls18.stabr,
       sum(pls18.visits) AS visits_2018,
       sum(pls17.visits) AS visits_2017,
       sum(pls16.visits) AS visits_2016,
       round( (sum(pls18.visits::numeric) - sum(pls17.visits)) /
            sum(pls17.visits) * 100, 1 ) AS chg_2018_17,
       round( (sum(pls17.visits::numeric) - sum(pls16.visits)) /
            sum(pls16.visits) * 100, 1 ) AS chg_2017_16
FROM pls_fy2018_libraries pls18
       JOIN pls_fy2017_libraries pls17 ON pls18.fscskey = pls17.fscskey
       JOIN pls_fy2016_libraries pls16 ON pls18.fscskey = pls16.fscskey
WHERE pls18.visits >= 0
       AND pls17.visits >= 0
       AND pls16.visits >= 0
GROUP BY pls18.stabr
ORDER BY chg_2018_17 DESC;


-- Filtering an Aggregate Query Using HAVING

-- To refine our analysis, we can examine a subset of states and territories 
-- that share similar characteristics.
-- With percent change in visits, it makes sense to separate large states from small states.

-- To filter the results of aggregate functions, we need to use the HAVING clause 
-- that’s part of standard ANSI SQL. You’re already familiar with using WHERE 
-- for filtering, but aggregate functions, such as sum(), can’t be used within a WHERE 
-- clause because they operate at the row level, and aggregate functions work across rows.

-- The HAVING clause places conditions on groups created by aggregating. 
-- The code in Listing 9-14 modifies the query in Listing 9-13 
-- by inserting the HAVING clause after GROUP BY.

SELECT pls18.stabr,
       sum(pls18.visits) AS visits_2018,
       sum(pls17.visits) AS visits_2017,
       sum(pls16.visits) AS visits_2016,
       round( (sum(pls18.visits::numeric) - sum(pls17.visits)) /
            sum(pls17.visits) * 100, 1 ) AS chg_2018_17,
       round( (sum(pls17.visits::numeric) - sum(pls16.visits)) /
            sum(pls16.visits) * 100, 1 ) AS chg_2017_16
FROM pls_fy2018_libraries pls18
       JOIN pls_fy2017_libraries pls17 ON pls18.fscskey = pls17.fscskey
       JOIN pls_fy2016_libraries pls16 ON pls18.fscskey = pls16.fscskey
WHERE pls18.visits >= 0
       AND pls17.visits >= 0
       AND pls16.visits >= 0
GROUP BY pls18.stabr
HAVING sum(pls18.visits) > 50000000
ORDER BY chg_2018_17 DESC;

