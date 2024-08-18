/*

Created at: 2024-08-17 10:00:45
Purpose: Denormalization of books_dataset where I'll have unified dataset.
Each row will represent unique book with no other foreign keys to look up tables.

In this script, I'll create a new table, do required transformations and insert the existing values joined from several look up tables.
I'll remove the duplicate entries, concat the author name, add a new primary key (serial).

*/

-- creating a new joined table - where i collected all the data from look up tables

DROP TABLE IF EXISTS demo_library;
CREATE TABLE demo_library (
	book_id INT,
	book_name VARCHAR(150),
	author VARCHAR(150),
	price INT,
	year TEXT,
	comment TEXT,
	created_at DATE,
	updated_at DATE,
	publisher TEXT,
	transaction_type VARCHAR(150),
	read_unread	VARCHAR(150),
	genre VARCHAR(150),
	binding_type VARCHAR(150),
	language VARCHAR(150),
	rating VARCHAR(150),
	author_book_id INT
);

-- Inserting the values into the new 'demo_library' table - here I'll perform some transformation before injecting them into another final table 'library' 

INSERT INTO demo_library (
SELECT 
	b.id AS book_id,
	b.name AS book_name, 
	a.name AS author,
	price, 
	year, 
	comment, 
	created_at, 
	updated_at,
	p.publisher_name AS publisher,
	t.method AS transaction_type,
	r.read_unread AS read_unread,
	g.genre AS genre,
	bi.binding_type AS binding_type,
	l.language AS language,
	ra.rating AS rating,
	author_book_junction.author_id AS author_id	
FROM public.book_title b
JOIN publisher p ON b.publisher_id = p.id
JOIN transaction_method t ON b.transaction_method_id = t.id
JOIN read_unread r ON b.read_unread_id = r.id
JOIN genre g ON b.genre_id = g.id
JOIN binding_type bi ON b.binding_id = bi.id
JOIN language l ON b.language_id = l.id
JOIN rating ra ON b.rating_id = ra.id
JOIN author_book_junction ON b.id = author_book_junction.book_id
JOIN author a ON a.id = author_book_junction.author_id
ORDER BY 
	created_at, 
	b.name, 
	a.name
);


-- It returns 155 rows with duplicate book entries (which differ only in author names)

-- I don't have some books in my library, so I removed them 
DELETE FROM demo_library
WHERE book_id IN (17, 88, 8, 182); 

-- It returns 151 rows.



-- Creating final table 'library' that will have similar structure as 'demo_library, except it would now have an autoincrement serial id. The id will represent one unique row of book data.

DROP TABLE IF EXISTS library;

CREATE TABLE library (
    book_id SERIAL PRIMARY KEY,
    book_name VARCHAR(255),
    author VARCHAR(255),
    price NUMERIC,
    year TEXT,
    comment TEXT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    publisher VARCHAR(255),
    transaction_type VARCHAR(255),
    read_unread VARCHAR(255),
    genre VARCHAR(255),
    binding_type VARCHAR(255),
    language VARCHAR(255),
    rating VARCHAR(255)
);




-- Inserting Data into the New Table

-- Since in the normalized tables I had one row that had one book and one author and if there were many authors for a book, the data will have duplicate book entries with different author name. 
-- In the new table however, I will have only one row per book.
-- So i need to have all the authors(in case of many authors penning a book) in a single column.
-- therefore, I concatenated the authors using STRING_AGG () function, separated by , and grouped by book_name.
-- In the same step, I changed the cases of the rows to Proper case using INITCAP() function

INSERT INTO library (
    book_name, author, price, year, comment, created_at, updated_at, 
    publisher, transaction_type, read_unread, genre, binding_type, language, rating
)
SELECT 
    INITCAP(book_name) AS book_name,
    INITCAP(STRING_AGG(author, ', ')) AS author,
    price,
    year,
    comment,
    created_at,
    updated_at,
    INITCAP(publisher) AS publisher,
    INITCAP(transaction_type) AS transaction_type,
    INITCAP(read_unread) AS read_unread,
    INITCAP(genre) AS genre,
    INITCAP(binding_type) AS binding_type,
    INITCAP(language) AS language,
    INITCAP(rating) AS rating
FROM 
    public.demo_library
GROUP BY 
    book_name, price, year, comment, created_at, updated_at, publisher, transaction_type, read_unread, genre, binding_type, language, rating
ORDER BY 
    created_at, 
	book_name;



-- Removing the demo_library table since I don't need it anymore
DROP TABLE demo_library;



-- A few Updates

-- Changed the column header 'read_unread' to read_status
ALTER TABLE library
RENAME COLUMN read_unread TO read_status;

-- Dropped the updated at column
ALTER TABLE library
DROP COLUMN updated_at;

-- Changed publisher = Iias into IIAS
UPDATE library 
SET publisher = 'IIAS'
WHERE publisher = 'Iias';

-- commenting on Leo Tolstoy's 'War and Peace'
UPDATE library 
SET comment = 'It is my book of the year for 2024. Completed the book in just one month.'
WHERE book_id = 144;

-- Changed the genre from Non-Fiction to Fictions for these books
UPDATE library 
SET genre = 'Fiction'
WHERE book_id IN (137, 143,144);

-- updated the rating for these books;
UPDATE library 
SET rating = 'Excellent'
WHERE book_id IN (140, 144);

UPDATE library 
SET rating = 'Moderate'
WHERE book_id IN (137, 143);


-- Inserted new entries
INSERT INTO library (
    book_name, author, price, year, comment, created_at,
    publisher, transaction_type, read_status, genre, binding_type, language, rating
) VALUES 
(
'Brief Answers To The Big Questions', 'Stephen Hawking', 317, 2024,'One of my favorite books on Cosmology', NOW(), 'John Murray', 'Online', 'Yes','Non-Fiction','Paperback', 'English', 'Excellent'	
),
(
'Predictably Irrational', 'Dan Ariely', 298, 2024,'' ,NOW(),'Harper','Online', 'No','Non-Fiction','Paperback', 'English', 'None' 
),
(
'The Hundred-Page Machine Learning Book', 'Andriy Burkov', 449, 2024,'','',NOW(),'Online', 'No','Non-Fiction','Paperback', 'English', 'None'
)

