-- TRY IT YOURSELF

-- In this exercise, you’ll turn the meat_poultry_egg_establishments table into useful information. 
-- You need to answer two questions: 
		-- 1. how many of the plants in the table process meat, 
		-- 2. and how many process poultry?

-- The answers to these two questions lie in the activities column. 
-- Unfortunately, the column contains an assortment of text with inconsistent input. 
-- Here’s an example of the kind of text you’ll find in the activities column:

	-- Poultry Processing, Poultry Slaughter
	-- Meat Processing, Poultry Processing
	-- Poultry Processing, Poultry Slaughter
	
SELECT activities, count(*)
FROM meat_poultry_egg_establishments
GROUP BY activities
ORDER BY count(*) DESC;

-- The mishmash of text makes it impossible to perform a typical count that would allow you 
-- to group processing plants by activity. However, you can make some modifications to fix this data. 
-- Your tasks are as follows:

-- Create two new columns called meat_processing and poultry_processing in your table.
-- Each can be of the type boolean.

ALTER TABLE meat_poultry_egg_establishments ADD COLUMN meat_processing boolean;
ALTER TABLE meat_poultry_egg_establishments ADD COLUMN poultry_processing boolean;

-- Using UPDATE, set meat_processing = TRUE on any row in which the activities column contains 
-- the text Meat Processing.

UPDATE meat_poultry_egg_establishments
SET meat_processing = TRUE
WHERE activities LIKE '%Meat Processing%'
RETURNING activities, meat_processing;

-- Do the same update on the poultry_processing column, but this time look for the text Poultry Processing in activities.

UPDATE meat_poultry_egg_establishments
SET poultry_processing = TRUE
WHERE activities LIKE '%Poultry Processing%'
RETURNING activities, poultry_processing;

-- Use the data from the new, updated columns to count how many plants perform each type of activity.

SELECT
	(SELECT count(*) AS qty_total FROM meat_poultry_egg_establishments),
	(SELECT count(*) AS qty_meat
	FROM meat_poultry_egg_establishments
	WHERE meat_processing),
	(SELECT count(*) AS qty_poultry
	FROM meat_poultry_egg_establishments
	WHERE poultry_processing);
	
-- For a bonus challenge, count how many plants perform both activities.

SELECT
	(SELECT count(*) AS qty_total FROM meat_poultry_egg_establishments),
	(SELECT count(*) AS qty_meat
	FROM meat_poultry_egg_establishments
	WHERE meat_processing),
	(SELECT count(*) AS qty_poultry
	FROM meat_poultry_egg_establishments
	WHERE poultry_processing),
	(SELECT count(*) AS qty_meat_poultry
	FROM meat_poultry_egg_establishments
	WHERE meat_processing AND poultry_processing);

------------------------------------------------------------------------
SELECT * FROM meat_poultry_egg_establishments;
SELECT TRUE AND TRUE AS logical_operation;