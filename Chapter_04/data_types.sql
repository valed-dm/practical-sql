CREATE TABLE eagle_watch (
    observation_date date,
    eagles_seen integer,
    notes text
);

CREATE TABLE char_data_types (
    char_column char(10),
    varchar_column varchar(10),
    text_column text
);

INSERT INTO char_data_types
VALUES
    ('abc', 'abc', 'abc'),
    ('defghi', 'defghi', 'defghi');
	
SELECT *
FROM char_data_types

-- In PostgreSQL, COPY table_name FROM is the import function, 
-- and COPY table_name TO is the export function.

COPY char_data_types TO '/Users/dmitrijvaledinskij/SQL/practical-sql-2-main/Chapter_04/typetest.txt'
WITH (FORMAT CSV, HEADER, DELIMITER '|');
-- --------
CREATE TABLE people (
	id serial,
	person_name varchar(100)
);

CREATE TABLE people (
    id integer GENERATED ALWAYS AS IDENTITY,
    person_name varchar(100)
);

-- floating point types
CREATE TABLE number_data_types (
    numeric_column numeric(20,5),
    real_column real,
    double_column double precision
);
-- 
INSERT INTO number_data_types
VALUES
    (.7, .7, .7),
    (2.13579123, 2.13579123, 2.13579123),
    (2.1357987654, 2.1357987654, 2.1357987654);

SELECT * FROM number_data_types;
--
SELECT
    numeric_column * 10000000 AS fixed,
    real_column * 10000000 AS floating
FROM number_data_types
WHERE numeric_column = .7;

-- understanding dates and time

-- Data type	       Storage size	      Description	       Range

-- timestamp	       8 bytes	          Date and time	       4713 BC to 294276 AD
-- date	               4 bytes	          Date (no time)	   4713 BC to 5874897 AD
-- time	               8 bytes	          Time (no date)	   00:00:00 to 24:00:00
-- interval	           16 bytes	          Time interval     	+/− 178,000,000 years

CREATE TABLE date_time_types (
    timestamp_column timestamp with time zone,
    interval_column interval
);

INSERT INTO date_time_types
VALUES
    ('2022-12-31 01:00 EST','2 days'),
    ('2022-12-31 01:00 -8','1 month'),
    ('2022-12-31 01:00 Australia/Melbourne','1 century'),
    (now(),'1 week'),
	('4/2/2021', '1 hour');

SELECT * FROM date_time_types;

-- Using the interval Data Type in Calculations
SELECT
    timestamp_column,
    interval_column,
    timestamp_column - interval_column AS new_date
FROM date_time_types;

-- 
SELECT timestamp_column, CAST(timestamp_column AS varchar(10))
FROM date_time_types;

SELECT numeric_column,
       CAST(numeric_column AS integer),
       CAST(numeric_column AS text)
FROM number_data_types;

-- Does not work:
SELECT CAST(char_column AS integer) FROM char_data_types;

-- Using CAST Shortcut Notation
-- It’s always best to write SQL that can be read by another person who might pick it up 
-- later, and the way CAST() is written makes what you intended when you used it 
-- fairly obvious. However, PostgreSQL also offers a less-obvious shortcut 
-- notation that takes less space: the double colon.

-- Insert the double colon in between the name of the column and the data type 
-- you want to convert it to. For example, these two statements 
-- cast timestamp_column as a varchar:

SELECT timestamp_column, CAST(timestamp_column AS varchar(10))
FROM date_time_types;

SELECT timestamp_column::varchar(10)
FROM date_time_types;

-- Use whichever suits you, but be aware that 
-- the double colon is a PostgreSQL-only implementation 
-- not found in other SQL variants, and so won’t port.

-- exercises:

