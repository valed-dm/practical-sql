-- Put your grouping and aggregating skills to the test with these challenges:

-- We saw that library visits have declined recently in most places. 
-- But what is the pattern in library employment? 
-- All three library survey tables contain the column totstaff, 
-- which is the number of paid full-time equivalent employees. 
-- Modify the code in Listings 9-13 and 9-14 to calculate the percent change in the sum of the column over time, 
-- examining all states as well as states with the most visitors. Watch out for negative values!

-- check if totstaff contains negative values -->
SELECT stabr, totstaff
FROM pls_fy2018_libraries
WHERE totstaff < 0
-------------------------------------------------

SELECT pls18.stabr,
       sum(pls18.visits) AS visits_2018,
	   sum(pls18.totstaff) AS totstaff_2018,
       sum(pls17.visits) AS visits_2017,
	   sum(pls17.totstaff) AS totstaff_2017,
       sum(pls16.visits) AS visits_2016,
	   sum(pls16.totstaff) AS totstaff_2016,
       round( (sum(pls18.visits::numeric) - sum(pls17.visits)) /
            sum(pls17.visits) * 100, 1 ) AS chg_2018_17,
	   round( (sum(pls18.totstaff) - sum(pls17.totstaff)) /
            sum(pls17.totstaff) * 100, 1 ) AS chg_staff_2018_17,
       round( (sum(pls17.visits::numeric) - sum(pls16.visits)) /
            sum(pls16.visits) * 100, 1 ) AS chg_2017_16,
	   round( (sum(pls17.totstaff) - sum(pls16.totstaff)) /
            sum(pls16.totstaff) * 100, 1 ) AS chg_staff_2017_16
FROM pls_fy2018_libraries pls18
       JOIN pls_fy2017_libraries pls17 ON pls18.fscskey = pls17.fscskey
       JOIN pls_fy2016_libraries pls16 ON pls18.fscskey = pls16.fscskey
WHERE pls18.visits >= 0
       AND pls17.visits >= 0
       AND pls16.visits >= 0
	   AND pls18.totstaff >= 0
	   AND pls17.totstaff >= 0
	   AND pls16.totstaff >= 0
GROUP BY pls18.stabr
HAVING sum(pls18.visits) > 30000000
ORDER BY visits_2018 DESC;


-- The library survey tables contain a column called obereg, 
-- a two-digit Bureau of Economic Analysis Code that classifies each library agency according to 
-- a region of the United States, such as New England, Rocky Mountains, and so on. 
-- Just as we calculated the percent change in visits grouped by state, 
-- do the same to group percent changes in visits by US region using obereg. 
-- Consult the survey documentation to find the meaning of each region code:
-- OBEREG 02 A † Bureau of Economic Analysis Code (formerly, Office of Business Economics)
		01–New England (CT ME MA NH RI VT)
		02–Mid East (DE DC MD NJ NY PA)
		03–Great Lakes (IL IN MI OH WI)
		04–Plains (IA KS MN MO NE ND SD)
		05–Southeast (AL AR FL GA KY LA MS NC SC TN VA WV)
		06–Southwest (AZ NM OK TX)
		07–Rocky Mountains (CO ID MT UT WY)
		08–Far West (AK CA HI NV OR WA)
		09–Outlying Areas (AS GU MP PR VI)
		
SELECT pls18.obereg,
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
GROUP BY pls18.obereg
ORDER BY chg_2018_17 DESC;

-- For a bonus challenge, create a table with the obereg code as the primary key and the region name as text, 
-- and join it to the summary query to group by the region name rather than the code.

CREATE TABLE regions (
	obereg text PRIMARY KEY,
	region_name text
	);

INSERT INTO regions
	VALUES
	('01', 'New England'),
	('02', 'Mid East'),
	('03', 'Great Lakes'),
	('04', 'Plains'),
	('05', 'Southeast'),
	('06', 'Southwest'),
	('07', 'Rocky Mountains'),
	('08', 'Far West'),
	('09', 'Outlying Areas');

SELECT * FROM regions;

SELECT regions.region_name,
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
	   JOIN regions ON pls18.obereg = regions.obereg
WHERE pls18.visits >= 0
       AND pls17.visits >= 0
       AND pls16.visits >= 0
GROUP BY regions.region_name
ORDER BY chg_2018_17 DESC;


-- Thinking back to the types of joins you learned in Chapter 7, which join type 
-- will show you all the rows in all three tables, including those without a match? 
-- Write such a query and add an IS NULL filter in a WHERE clause to show agencies not included 
-- in one or more of the tables.

SELECT 
	pls18.libname AS agencies_diff_2018, 
	pls17.libname AS agencies_diff_2017,
	pls16.libname AS agencies_diff_2016
FROM pls_fy2018_libraries pls18
	FULL OUTER JOIN pls_fy2017_libraries pls17
	USING (fscskey)
	FULL OUTER JOIN pls_fy2016_libraries pls16
	USING (fscskey)
WHERE pls18.libname IS NULL OR pls17.libname IS NULL OR pls16.libname IS NULL
ORDER BY agencies_diff_2018, agencies_diff_2017, agencies_diff_2016;

