-- TRY IT YOURSELF
-- Test your new skills with the following questions:

-- In Listing 11-2, the correlation coefficient, or r value, of the variables pct_bachelors_higher 
-- and median_hh_income was about 0.70. Write a query using the same dataset to show the correlation 
-- between pct_masters_higher and median_hh_income. Is the r value higher or lower? 
-- What might explain the difference?

SELECT corr(median_hh_income, pct_bachelors_higher)
    AS bachelors_income_r
FROM acs_2014_2018_stats; -- 0.699

SELECT corr(median_hh_income, pct_masters_higher)
    AS masters_income_r
FROM acs_2014_2018_stats; -- 0.597

-- Using the exports data, create a 12-month rolling sum using the values in the column 
-- soybeans_export_value and the query pattern from Listing 11-8. 
-- Copy and paste the results from the pgAdmin output pane and graph the values using Excel. 
-- What trend do you see?

-- Calculate rolling sum
SELECT year, month, soybeans_export_value,
    round(   
       sum(soybeans_export_value) 
            OVER(ORDER BY year, month 
                 ROWS BETWEEN 11 PRECEDING AND CURRENT ROW), 0)
       AS twelve_month_sum
FROM us_exports
ORDER BY year, month;


-- As a bonus challenge, revisit the libraries data in the table pls_fy2018_libraries in Chapter 9. 
-- Rank library agencies based on the rate of visits per 1,000 population (column popu_lsa), 
-- and limit the query to agencies serving 250,000 people or more.

SELECT
	rank() OVER (ORDER BY popu_lsa DESC),
    libname,
    popu_lsa,
	visits
FROM pls_fy2018_libraries
WHERE visits > 250000 AND popu_lsa >= 0
ORDER BY rank() OVER (ORDER BY popu_lsa DESC);

SELECT *
FROM pls_fy2018_libraries
WHERE libname ILIKE 'MATTITUCK-LAUREL LIBRARY'
