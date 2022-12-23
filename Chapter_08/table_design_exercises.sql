-- EXERCISES

-- Are you ready to test yourself on the concepts covered in this chapter? 
-- Consider the following two tables from a database you’re making to keep track of your 
-- vinyl LP collection.

	-- Start by reviewing these CREATE TABLE statements:

CREATE TABLE albums (
    album_id bigint GENERATED ALWAYS AS IDENTITY,
    catalog_code text,
    title text,
    artist text,
    release_date date,
    genre text,
    description text
);

CREATE TABLE songs (
    song_id bigint GENERATED ALWAYS AS IDENTITY,
    title text,
    composers text,
    album_id bigint
);

-- The albums table includes information specific to the overall collection of songs on the disc. 
-- The songs table catalogs each track on the album. 
-- Each song has a title and a column for its composers, who might be different than the album artist.

-- Use the tables to answer these questions:

-- 1. Modify these CREATE TABLE statements to include primary and foreign keys 
   -- plus additional constraints on both tables. Explain why you made your choices.

-- 2. Instead of using album_id as a surrogate key for your primary key, 
   -- are there any columns in albums that could be useful as a natural key? 
   -- What would you have to know to decide?
   
-- 3. To speed up queries, which columns are good candidates for indexes?

CREATE TABLE albums (
    album_id bigint GENERATED ALWAYS AS IDENTITY,
    catalog_code text,
    title text NOT NULL,
    artist text NOT NULL,
    release_date date NOT NULL,
    genre text NOT NULL,
    description text,
	CONSTRAINT album_key PRIMARY KEY (album_id),
	CONSTRAINT catalog_code_unique UNIQUE (catalog_code)
);

CREATE TABLE songs (
    song_id bigint GENERATED ALWAYS AS IDENTITY,
    title text NOT NULL,
    composers text NOT NULL,
    album_id bigint REFERENCES albums (album_id) ON DELETE CASCADE,
	CONSTRAINT song_key PRIMARY KEY (song_id)
);

CREATE INDEX album_id_idx ON songs (album_id);