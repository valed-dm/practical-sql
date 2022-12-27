-- INSPECTING AND MODIFYING DATA

-- Importing Data on Meat, Poultry, and Egg Producers
CREATE TABLE meat_poultry_egg_establishments (
    establishment_number text CONSTRAINT est_number_key PRIMARY KEY,
    company text,
    street text,
    city text,
    st text,
    zip text,
    phone text,
    grant_date date,
    activities text,
    dbas text
);

COPY meat_poultry_egg_establishments
FROM '/Users/dmitrijvaledinskij/SQL/practical-sql-2-main/Chapter_10/MPI_Directory_by_Establishment_Name.csv'
WITH (FORMAT CSV, HEADER);

CREATE INDEX company_idx ON meat_poultry_egg_establishments (company);

-- Count the rows imported:
SELECT count(*) FROM meat_poultry_egg_establishments;
SELECT * FROM meat_poultry_egg_establishments;

-- Listing 10-2: Finding multiple companies at the same address

SELECT company,
       street,
       city,
       st,
       count(*) AS address_count
FROM meat_poultry_egg_establishments
GROUP BY company, street, city, st
HAVING count(*) > 1
ORDER BY company, street, city, st;


-- Checking for Missing Values

-- Listing 10-3: Grouping and counting states
SELECT st, 
       count(*) AS st_count
FROM meat_poultry_egg_establishments
GROUP BY st
ORDER BY st;
-- the row at the bottom of the list has a NULL value in the st column 
-- and a 3 in st_count. That means three rows have a NULL in st. 
-- To see the details of those facilities, let’s query those rows:

-- NOTE
-- Depending on the database implementation, NULL values will appear either first 
-- or last in a sorted column. In PostgreSQL, they appear last by default. 
-- The ANSI SQL standard doesn’t specify one or the other, but it lets you 
-- add NULLS FIRST or NULLS LAST to an ORDER BY clause to specify a preference. 
-- For example, to make NULL values appear first in the preceding query, 
-- the clause would read ORDER BY st NULLS FIRST.

-- Listing 10-4: Using IS NULL to find missing values in the st column

SELECT establishment_number,
       company,
       city,
       st,
       zip
FROM meat_poultry_egg_establishments
WHERE st IS NULL;

-- Checking for Inconsistent Data Values

-- Listing 10-5: Using GROUP BY and count() to find inconsistent company names
SELECT company,
       count(*) AS company_count
FROM meat_poultry_egg_establishments
GROUP BY company
ORDER BY company ASC;

-- Listing 10-6: Using length() and count() to test the zip column
-- The example introduces length(), a string function that counts the number of characters 
-- in a string. We combine length() with count() and GROUP BY to determine how many rows have 
-- five characters in the zip field and how many have a value other than five. 
-- To make it easy to scan the results, we use length() in the ORDER BY clause:
SELECT length(zip),
       count(*) AS length_count
FROM meat_poultry_egg_establishments
GROUP BY length(zip)
ORDER BY length(zip) ASC;
-- Using the WHERE clause, we can see which states these shortened ZIP codes correspond to, 
-- as shown in Listing 10-7:
-- Listing 10-7: Filtering with length() to find short zip values
SELECT st,
       count(*) AS st_count
FROM meat_poultry_egg_establishments
WHERE length(zip) < 5
GROUP BY st
ORDER BY st ASC;

---------------------------------------------------------------------------------
-- So far, we need to correct the following issues in our dataset:

-- Missing values for three rows in the st column
-- Inconsistent spelling of at least one company’s name
-- Inaccurate ZIP codes due to file conversion

-- Next, we’ll look at how to use SQL to fix these issues by modifying your data.
---------------------------------------------------------------------------------

-- Modifying Tables, Columns, and Data

-- Almost nothing in a database, from tables to columns and the data types and values they contain, 
-- is set in concrete after it’s created. As your needs change, you can use SQL to add columns to 
-- a table, change data types on existing columns, and edit values. 
-- Given the issues we discovered in the meat_poultry_egg_establishments table, being able to modify our database will come in handy.

---------------------------------------------------------------------------------
-- We’ll use two SQL commands.
-- 1
-- The first, ALTER TABLE, is part of the ANSI SQL standard and provides options to ADD COLUMN, 
-- ALTER COLUMN, and DROP COLUMN, among others.
---------------------------------------------------------------------------------

-- NOTE
-- Typically, PostgreSQL and other databases include implementation-specific extensions 
-- to ALTER TABLE that provide an array of options for managing database objects 
-- (see https://www.postgresql.org/docs/current/sql-altertable.html). 
-- For our exercises, we’ll stick with the core options.

---------------------------------------------------------------------------------
-- 2
-- The second command, UPDATE, also included in the SQL standard, allows you to change values 
-- in a table’s columns. You can supply criteria using WHERE to choose which rows to update.
---------------------------------------------------------------------------------



-- Modifying Tables with ALTER TABLE


-- We can use the ALTER TABLE statement to modify the structure of tables. 
-- The following examples show standard ANSI SQL syntax for common operations, 
-- starting with the code for adding a column to a table:

ALTER TABLE table ADD COLUMN column data_type;

-- We can remove a column with the following syntax:

ALTER TABLE table DROP COLUMN column;

-- To change the data type of a column, we would use this code:

ALTER TABLE table ALTER COLUMN column SET DATA TYPE data_type;

-- We add a NOT NULL constraint to a column like so:

ALTER TABLE table ALTER COLUMN column SET NOT NULL;

-- Note that in PostgreSQL and some other systems, adding a constraint to the table causes 
-- all rows to be checked to see whether they comply with the constraint. 
-- If the table has millions of rows, this could take a while.

-- Removing the NOT NULL constraint looks like this:

ALTER TABLE table ALTER COLUMN column DROP NOT NULL;

-- PostgreSQL won’t give you any warning about deleting data when you drop a column, 
-- so use extra caution before dropping a column.


-- Modifying Values with UPDATE

-- The UPDATE statement, part of the ANSI SQL standard, modifies the data in a column 
-- that meets a condition. It can be applied to all rows or a subset of rows. 
-- Its basic syntax for updating the data in every row in a column follows this form:

UPDATE table
SET column = value;

-- We first pass UPDATE the name of the table. 
-- Then to SET we pass the column we want to update. 
-- The new value to place in the column can be a string, number, the name of another column, 
-- or even a query or expression that generates a value. 
-- The new value must be compatible with the column data type.

-- We can update values in multiple columns by adding additional columns and source values 
-- and separating each with a comma:

UPDATE table
SET column_a = value,
    column_b = value;
	
-- To restrict the update to particular rows, we add a WHERE clause with some criteria 
-- that must be met before the update can happen, such as rows where values equal a date 
-- or match a string:

UPDATE table
SET column = value
WHERE criteria;

------------------------------------------------------------------------------------
-- We can also update one table with values from another table.
------------------------------------------------------------------------------------
-- Standard ANSI SQL requires that we use a subquery, a query inside a query, 
-- to specify which values and rows to update:

UPDATE table
SET column = (SELECT column
              FROM table_b
              WHERE table.column = table_b.column)
WHERE EXISTS (SELECT column
              FROM table_b
              WHERE table.column = table_b.column);

-- The value portion of SET, inside the parentheses, is a subquery. 
-- A SELECT statement inside parentheses generates the values for the update by joining columns 
-- in both tables on matching row values. Similarly, the WHERE EXISTS clause uses a SELECT statement 
-- to ensure that we only update rows where both tables have matching values. 
-- If we didn’t use WHERE EXISTS, we might inadvertently set some values to NULL without planning to. 
-- (If this syntax looks somewhat complicated, that’s okay. I’ll cover subqueries in detail in Chapter 13.)

-- Some database managers offer additional syntax for updating across tables. 
-- PostgreSQL supports the ANSI standard but also a simpler syntax using a FROM clause:

UPDATE table
SET column = table_b.column
FROM table_b
WHERE table.column = table_b.column;
------------------------------------------------------------------------------------


-- Viewing Modified Data with RETURNING


-- If you add an optional RETURNING clause to UPDATE, you can view the values that were modified 
-- without having to run a second, separate query. The syntax of the clause uses the RETURNING keyword 
-- followed by a list of columns or a wildcard in the same manner that we name columns following SELECT. 
-- Here’s an example:

UPDATE table
SET column_a = value
RETURNING column_a, column_b, column_c;

-- Instead of just noting the number of rows modified, 
-- RETURNING directs the database to show the columns you specify for the rows modified. 
-- This is a PostgreSQL-specific implementation that you also can use with INSERT and DELETE FROM. 
-- We’ll try it with some of our examples.


-- Creating Backup Tables

-- Before modifying a table, it’s a good idea to make a copy for reference and backup 
-- in case you accidentally destroy some data. 
-- Listing 10-8 shows how to use a variation of the familiar CREATE TABLE statement 
-- to make a new table from the table we want to duplicate.

CREATE TABLE meat_poultry_egg_establishments_backup AS
SELECT * FROM meat_poultry_egg_establishments;

-- The result should be a pristine copy of your table with the new specified name. You can confirm this by counting the number of records in both tables at once:

SELECT
    (SELECT count(*) FROM meat_poultry_egg_establishments) AS original,
    (SELECT count(*) FROM meat_poultry_egg_establishments_backup) AS backup;
	
-- The results should return the same count from both tables, like this:

original    backup
--------    ------
    6287      6287
	
-- If the counts match, you can be sure your backup table is an exact copy of the structure 
-- and contents of the original table. 
-- As an added measure and for easy reference, 
-- we’ll use ALTER TABLE to make copies of column data within the table we’re updating.

-- NOTE
-- Indexes are not copied when creating a table backup using the CREATE TABLE statement. 
-- If you decide to run queries on the backup, be sure to create a separate index on that table.


-- Restoring Missing Column Values


The query in Listing 10-4 earlier revealed that three rows in the meat_poultry_egg_establishments table don’t have a value in the st column:

est_number           company                            city      st    zip
-----------------    -------------------------------    ------    --    -----
V18677A              Atlas Inspection, Inc.             Blaine          55449
M45319+P45319        Hall-Namie Packing Company, Inc                    36671
M263A+P263A+V263A    Jones Dairy Farm                                   53538

To get a complete count of establishments in each state, we need to fill those missing values using an UPDATE statement.

-- Creating a Column Copy

-- Even though we’ve backed up this table, let’s take extra caution and make a copy 
-- of the st column within the table so we still have the original data 
-- if we make some dire error somewhere. Let’s create the copy and fill it with the 
-- existing st column values as in Listing 10-9:

ALTER TABLE meat_poultry_egg_establishments ADD COLUMN st_copy text;

UPDATE meat_poultry_egg_establishments
SET st_copy = st;

-- We can confirm the values were copied properly with a simple SELECT query on both columns, 
-- as in Listing 10-10:

SELECT st,
       st_copy
FROM meat_poultry_egg_establishments
WHERE st IS DISTINCT FROM st_copy
ORDER BY st;

-- NOTE
-- Because IS DISTINCT FROM treats NULL as a known value, comparisons between values 
-- always will evaluate to true or false. That’s different than the <> operator, 
-- in which a comparison that includes a NULL will return NULL. 
-- Run SELECT 'a' <> NULL; to see this behavior.

SELECT 'a' <> NULL;


-- Updating Rows Where Values Are Missing

-- To update those rows’ missing values, we first find the values we need 
-- with a quick online search: 
-- Atlas Inspection is located in Minnesota; 
-- Hall-Namie Packing is in Alabama; 
-- and Jones Dairy is in Wisconsin. 
-- We add those states to the appropriate rows in Listing 10-11:

-- Listing 10-11: Updating the st column for three establishments

UPDATE meat_poultry_egg_establishments
SET st = 'MN'
WHERE establishment_number = 'V18677A';

UPDATE meat_poultry_egg_establishments
SET st = 'AL'
WHERE establishment_number = 'M45319+P45319';

UPDATE meat_poultry_egg_establishments
SET st = 'WI'
WHERE establishment_number = 'M263A+P263A+V263A'
RETURNING establishment_number, company, city, st, zip;

----------------------------------------------------------------------
-- If we rerun the code in Listing 10-4 to find rows where st is NULL, 
-- the query should return nothing. 
-- Success! Our count of establishments by state is now complete:

SELECT establishment_number,
       company,
       city,
       st,
       zip
FROM meat_poultry_egg_establishments
WHERE st IS NULL;
----------------------------------------------------------------------
-- Restoring Original Values
-- 1:
UPDATE meat_poultry_egg_establishments
SET st = st_copy;

-- OR 2:
UPDATE meat_poultry_egg_establishments original
SET st = backup.st
FROM meat_poultry_egg_establishments_backup backup
WHERE original.establishment_number = backup.establishment_number;
----------------------------------------------------------------------


-- Updating Values for Consistency

Here are the spelling variations of Armour-Eckrich Meats in Listing 10-5:

--snip--
Armour - Eckrich Meats, LLC
Armour-Eckrich Meats LLC
Armour-Eckrich Meats, Inc.
Armour-Eckrich Meats, LLC
--snip--

-- We can standardize the spelling using an UPDATE statement. 
-- To protect our data, we’ll create a new column for the standardized spellings, 
-- copy the names in company into the new column, and work in the new column. Listing 10-13 has the code for both actions.

ALTER TABLE meat_poultry_egg_establishments ADD COLUMN company_standard text;

UPDATE meat_poultry_egg_establishments
SET company_standard = company;


UPDATE meat_poultry_egg_establishments
SET company_standard = 'Armour-Eckrich Meats'
WHERE company LIKE 'Armour%'
RETURNING company, company_standard;


-- Repairing ZIP Codes Using Concatenation

-- Our final fix repairs values in the zip column that lost leading zeros.
-- We’ll use UPDATE in conjunction with the double-pipe string concatenation operator (||). 
-- Concatenation combines two string values into one (it will also combine a string and a number 
-- into a string). 
-- For example, inserting || between the strings abc and xyz results in abcxyz. 
-- The double-pipe operator is a SQL standard for concatenation supported by PostgreSQL. 
-- You can use it in many contexts, such as UPDATE queries and SELECT, 
-- to provide custom output from existing as well as new data.

-- First, Listing 10-15 makes a backup copy of the zip column as we did earlier.

ALTER TABLE meat_poultry_egg_establishments ADD COLUMN zip_copy text;

UPDATE meat_poultry_egg_establishments
SET zip_copy = zip;

-- Listing 10-16: Modify codes in the zip column missing two leading zeros

UPDATE meat_poultry_egg_establishments
SET zip = '00' || zip
WHERE st IN('PR','VI') AND length(zip) = 3
RETURNING st, zip;

-- Listing 10-17: Modify codes in the zip column missing one leading zero

UPDATE meat_poultry_egg_establishments
SET zip = '0' || zip
WHERE st IN('CT','MA','ME','NH','NJ','RI','VT') AND length(zip) = 4;

-- Now, let’s check our progress. Earlier in Listing 10-6, when we aggregated rows 
-- in the zip column by length, we found 86 rows with three characters and 496 with four.

-- Listing 10-6: Using length() and count() to test the zip column
SELECT length(zip),
       count(*) AS length_count
FROM meat_poultry_egg_establishments
GROUP BY length(zip)
ORDER BY length(zip) ASC;
-- Using the same query now returns a more desirable result: all the rows have a five-digit ZIP code.

length    count
------    -----
     5     6287



-- Updating Values Across Tables

-- Let’s say we’re setting an inspection deadline for each of the companies in our table. 
-- We want to do this by US regions, such as Northeast, Pacific, and so on, 
-- but those regional designations don’t exist in our table. 

-- Listing 10-18: Creating and filling a state_regions table

CREATE TABLE state_regions (
    st text CONSTRAINT st_key PRIMARY KEY,
    region text NOT NULL
);

COPY state_regions
FROM '/Users/dmitrijvaledinskij/SQL/practical-sql-2-main/Chapter_10/state_regions.csv'
WITH (FORMAT CSV, HEADER);

SELECT * FROM state_regions;

-- Next, let’s return to the meat_poultry_egg_establishments table, 
-- add a column for inspection dates, and then fill in that column with 
-- the New England states. 
-- Listing 10-19 shows the code:

ALTER TABLE meat_poultry_egg_establishments
    ADD COLUMN inspection_deadline timestamp with time zone;

UPDATE meat_poultry_egg_establishments establishments
SET inspection_deadline = '2022-12-01 00:00 EST'
WHERE EXISTS (SELECT state_regions.region
              FROM state_regions
              WHERE establishments.st = state_regions.st 
                    AND state_regions.region = 'New England');
-- RETURNING st, inspection_deadline;

-- WHERE EXISTS includes a subquery that connects the meat_poultry_egg_establishments table 
-- to the state_regions table we created in Listing 10-18 and specifies which rows to update. 
-- The subquery (in parentheses, beginning with SELECT) looks for rows in the state_regions table 
-- where the region column matches the string New England. At the same time, it joins 
-- the meat_poultry_egg_establishments table with the state_regions table 
-- using the st column from both tables. 
-- In effect, the query is telling the database to find all the st codes that correspond to 
-- the New England region and use those codes to filter the update.			

-- Listing 10-20: Viewing updated inspection_deadline values:
SELECT st, inspection_deadline
FROM meat_poultry_egg_establishments
WHERE inspection_deadline IS NOT NULL
GROUP BY st, inspection_deadline
ORDER BY st;


-- Deleting Unneeded Data

-- NOTE
-- It’s easy to exclude unwanted data in queries using a WHERE clause, 
-- so decide whether you truly need to delete the data or can just filter it out. 
-- Cases where deleting may be the best solution include:
		-- data with errors, 
		-- data imported incorrectly, 
		-- or almost no disk space.


-- Deleting Rows from a Table

-- To remove rows from a table, we can use either DELETE FROM or TRUNCATE, which are both part of the ANSI SQL standard. 
-- Each offers options that are useful depending on your goals.

-- Using DELETE FROM, we can remove all rows from a table, or we can add a WHERE clause to delete only 
-- the portion that matches an expression we supply. To delete all rows from a table, 
-- use the following syntax:

DELETE FROM table_name;

-- To remove only selected rows, add a WHERE clause along with the matching value or pattern to specify which ones you want to delete:

DELETE FROM table_name WHERE expression;

-- For example, to exclude US territories from our processors table, we can remove the companies 
-- in those locations using the code in Listing 10-21.

DELETE FROM meat_poultry_egg_establishments
WHERE st IN('AS','GU','MP','PR','VI');

-- With large tables, using DELETE FROM to remove all rows can be inefficient because it scans the entire 
-- table as part of the process. In that case, you can use TRUNCATE, which skips the scan. 
-- To empty the table using TRUNCATE, use the following syntax:

TRUNCATE table_name;

-- A handy feature of TRUNCATE is the ability to reset an IDENTITY sequence, such as one you may 
-- have created to serve as a surrogate primary key, as part of the operation. 
-- To do that, add the RESTART IDENTITY keywords to the statement:

TRUNCATE table_name RESTART IDENTITY;

-- We’ll skip truncating any tables for now as we need the data for the rest of the chapter.


-- Deleting a Column from a Table

-- Earlier we created a backup zip column called zip_copy. 
-- Now that we’ve finished working on fixing the issues in zip, we no longer need zip_copy. 
-- We can remove the backup column, including all the data within the column, 
-- from the table using the DROP keyword in the ALTER TABLE statement.

-- The syntax for removing a column is similar to other ALTER TABLE statements:

ALTER TABLE table_name DROP COLUMN column_name;

-- The code in Listing 10-22 removes the zip_copy column:

ALTER TABLE meat_poultry_egg_establishments DROP COLUMN zip_copy;


-- Deleting a Table from a Database

-- The DROP TABLE statement is a standard ANSI SQL feature that deletes a table from the database.

-- The syntax for the DROP TABLE command is simple:

DROP TABLE table_name;

-- For example, Listing 10-23 deletes the backup version of the meat_poultry_egg_establishments table.

DROP TABLE meat_poultry_egg_establishments_backup;

-----------------------------------------------------------------------------
-- Using Transactions to Save or Revert Changes
-----------------------------------------------------------------------------
-- after you run a DELETE or UPDATE query (or any other query that alters your data or database structure), 
-- the only way to undo the change is to restore from a backup.

-- However, there is a way to check your changes before finalizing them and cancel the change 
-- if it’s not what you intended. You do this by enclosing the SQL statement within a transaction, 
-- which includes keywords that allow you to commit your changes if they are successful 
-- or roll them back if not. You define a transaction using the following keywords 
-- at the beginning and end of the query:

	-- START TRANSACTION Signals the start of the transaction block. 
	-- 	In PostgreSQL, you can also use the non-ANSI SQL BEGIN keyword.
	
	-- COMMIT Signals the end of the block and saves all changes.
	
	-- ROLLBACK Signals the end of the block and reverts all changes.

Company
---------------------------
AGRO Merchants Oakland LLC
AGRO Merchants Oakland LLC
AGRO Merchants Oakland, LLC

START TRANSACTION;

UPDATE meat_poultry_egg_establishments
SET company = 'AGRO Merchantss Oakland LLC'
WHERE company = 'AGRO Merchants Oakland, LLC';

SELECT company
FROM meat_poultry_egg_establishments
WHERE company LIKE 'AGRO%'
ORDER BY company;

ROLLBACK;

-- Beginning with START TRANSACTION; we’ll run each statement separately. 
-- The database responds with the message START TRANSACTION, letting you know that any succeeding 
-- changes you make to data will not be made permanent unless you issue a COMMIT command. 
-- Next, we run the UPDATE statement, which changes the company name in the row where it has an 
-- extra comma. I intentionally added an extra s in the name used in the SET clause 
-- to introduce a mistake.

-- When we view the names of companies starting with the letters AGRO using the SELECT statement,
-- we see that, oops, one company name is misspelled now.

Company
---------------------------
AGRO Merchants Oakland LLC
AGRO Merchants Oakland LLC
AGRO Merchantss Oakland LLC

-- Instead of rerunning the UPDATE statement to fix the typo, we can simply discard the change 
-- by running the ROLLBACK; command. When we rerun the SELECT statement to view the company names, 
-- we’re back to where we started:

Company
---------------------------
AGRO Merchants Oakland LLC
AGRO Merchants Oakland LLC
AGRO Merchants Oakland, LLC

START TRANSACTION;

UPDATE meat_poultry_egg_establishments
SET company = 'AGRO Merchants Oakland LLC'
WHERE company = 'AGRO Merchants Oakland, LLC';

SELECT company
FROM meat_poultry_egg_establishments
WHERE company LIKE 'AGRO%'
ORDER BY company;

ROLLBACK;

COMMIT;

-- NOTE
-- When you start a transaction in PostgreSQL, any changes you make to the data aren’t visible 
-- to other database users until you execute COMMIT. Other databases may behave differently 
-- depending on their settings.


-- Improving Performance When Updating Large Tables

-- With PostgreSQL, adding a column to a table and filling it with values can quickly inflate 
-- the table’s size because the database creates a new version of the existing row each time 
-- a value is updated, but it doesn’t delete the old row version. That essentially doubles the table’s size.

-- For small datasets, the increase is negligible, but for tables with hundreds of thousands 
-- or millions of rows, the time required to update rows and the resulting extra disk usage 
-- can be substantial.

-- Instead of adding a column and filling it with values, we can save disk space by copying 
-- the entire table and adding a populated column during the operation.
-- Then, we rename the tables so the copy replaces the original, and the original becomes a backup. 
-- Thus, we have a fresh table without the added old rows.

-- Listing 10-25: Backing up a table while adding and filling a new column

CREATE TABLE meat_poultry_egg_establishments_backup AS
SELECT *,
       '2023-02-14 00:00 EST'::timestamp with time zone AS reviewed_date
FROM meat_poultry_egg_establishments;
-- The query is a modified version of the backup script in Listing 10-8.

-- Then we use Listing 10-26 to swap the table names:

-- Listing 10-26: Swapping table names using ALTER TABLE

ALTER TABLE meat_poultry_egg_establishments 
    RENAME TO meat_poultry_egg_establishments_temp;
ALTER TABLE meat_poultry_egg_establishments_backup 
    RENAME TO meat_poultry_egg_establishments;
ALTER TABLE meat_poultry_egg_establishments_temp 
    RENAME TO meat_poultry_egg_establishments_backup;
--  This process avoids updating rows and thus inflating the table.
