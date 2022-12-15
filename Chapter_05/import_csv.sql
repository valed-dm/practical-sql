SELECT * FROM us_counties_pop_est_2019

SELECT county_name, area_land, area_water
FROM us_counties_pop_est_2019
WHERE county_name ILIKE 'yukon%'

SELECT county_name, state_name, area_land
FROM us_counties_pop_est_2019
ORDER BY area_land DESC
LIMIT 3;

SELECT county_name, state_name, internal_point_lat, internal_point_lon
FROM us_counties_pop_est_2019
ORDER BY internal_point_lon DESC
LIMIT 5;

CREATE TABLE supervisor_salaries (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    town text,
    county text,
    supervisor text,
    start_date text,
    salary numeric(10,2),
    benefits numeric(10,2)
);

SELECT * FROM supervisor_salaries
WHERE id < 3

-- Importing a Subset of Columns with COPY
COPY supervisor_salaries (town, supervisor, salary)
FROM '/Users/dmitrijvaledinskij/SQL/practical-sql-2-main/Chapter_05/supervisor_salaries.csv'
WITH (FORMAT CSV, HEADER);

DELETE FROM supervisor_salaries;

-- Importing a Subset of Rows with COPY
COPY supervisor_salaries (town, supervisor, salary)
FROM '/Users/dmitrijvaledinskij/SQL/practical-sql-2-main/Chapter_05/supervisor_salaries.csv'
WITH (FORMAT CSV, HEADER)
WHERE town = 'New Brillig';

-- Adding a Value to a Column During Import

-- What if you know that “Mills” is the name that should be added to the county column 
-- during the import, even though that value is missing from the CSV file? 
-- One way to modify your import to include the name is by loading your CSV 
-- into a temporary table before adding it to supervisors_salary. 
-- Temporary tables exist only until you end your database session. 
-- When you reopen the database (or lose your connection), those tables disappear. 
-- They’re handy for performing intermediary operations on data as part 
-- of your processing pipeline; we’ll use one to add the county name 
-- to the supervisor_salaries table as we import the CSV.