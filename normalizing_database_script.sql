-- This SQL script is updated and modified regualrly as new books are added.
-- run the code in sql shell to run the script
--\i C:/Users/Dell/Desktop/normalizing_database_script.sql

-- droping the existing database and creating a new one
DROP DATABASE IF EXISTS books_management; 
CREATE DATABASE books_management WITH OWNER 'arpita';

-- creating the table to hold the data from the csv file
DROP TABLE IF EXISTS books_raw ;

CREATE TABLE books_raw(
name VARCHAR(120) NOT NULL,
writer VARCHAR(120) NULL,	
original_language VARCHAR(50) NULL,
genre VARCHAR(50)  NULL,
binding VARCHAR(50) NULL,
publication VARCHAR(150) NULL,
price INTEGER NULL,
transaction_method VARCHAR(10) NULL,	
year INTEGER NULL,
read_unread VARCHAR(25) NULL,
rating VARCHAR(10) NULL,
writer_gender VARCHAR(10) NULL,
author_id INTEGER,
publisher_id INTEGER,
transaction_method_id INTEGER,
read_unread_id INTEGER ,
genre_id INTEGER,
binding_id INTEGER ,
language_id INTEGER,
rating_id INTEGER,
gender_id INTEGER,
created_at TIMESTAMPTZ DEFAULT  NOW(),
updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- copying the data from the csv file to the table
\copy books_raw(name,writer,original_language,genre,binding,publication,price,transaction_method,year,read_unread,rating,writer_gender ) FROM 'C:\Users\Dell\Desktop\Projects\Do i read all the books i buy\Books_Management.csv' WITH DELIMITER ',' CSV HEADER;

-- doing some simple queries to make sure the data is loaded properly
SELECT name, writer, genre, binding,price,year FROM books_raw LIMIT 5;

SELECT COUNT(*) FROM books_raw;

-- making some adjustments to the table
UPDATE books_raw SET publication = 'Null' WHERE publication IS NULL;
UPDATE books_raw SET writer = 'Null' WHERE writer IS NULL;
UPDATE books_raw SET writer_gender = 'Null' WHERE writer_gender IS NULL;
UPDATE books_raw SET original_language = 'Swedish' WHERE name = 'Plays by August Strindberg';
UPDATE books_raw SET original_language = 'Latin' WHERE name = 'On the shortness of life and on the happy life';
UPDATE books_raw SET writer_gender = 'Null' WHERE name = 'The Complete Greek Drama';
UPDATE books_raw SET writer_gender = 'Null' WHERE name = 'Holy Vedas';
UPDATE books_raw SET gender_id = 2 WHERE name = 'The Complete Greek Drama';
UPDATE books_raw SET gender_id = 2 WHERE name = 'Holy Vedas';


-- Normalizing the table
-- First Normal Form - adding a primary key to the table
ALTER TABLE books_raw ADD COLUMN id SERIAL;
ALTER TABLE books_raw ADD CONSTRAINT books_id PRIMARY KEY (id);


-- Second Normal Form - creating leaf tables with/without functional dependency on book id
DROP TABLE IF EXISTS gender CASCADE;
DROP TABLE IF EXISTS author CASCADE;
DROP TABLE IF EXISTS author_book_junction CASCADE;
DROP TABLE IF EXISTS binding_type CASCADE;
DROP TABLE IF EXISTS book_title CASCADE;
DROP TABLE IF EXISTS genre CASCADE;
DROP TABLE IF EXISTS language CASCADE;
DROP TABLE IF EXISTS publisher CASCADE;
DROP TABLE IF EXISTS read_unread CASCADE;
DROP TABLE IF EXISTS transaction_method CASCADE;
DROP TABLE IF EXISTS rating CASCADE;

-- creating gender table
CREATE TABLE gender (id SERIAL, 
gender VARCHAR(20) UNIQUE,
PRIMARY KEY(id)
);
-- inserting unique gender values from books_raw table into gender table
INSERT INTO gender(gender) SELECT DISTINCT writer_gender FROM books_raw;
-- updating the gender_id column in books_raw table
UPDATE books_raw SET gender_id = (SELECT gender.id FROM gender WHERE gender.gender = books_raw.writer_gender);

SELECT * FROM gender;


-- creating author table
CREATE TABLE author (id SERIAL,
name VARCHAR(120),
gender_id INTEGER REFERENCES gender(id) ON DELETE CASCADE,
PRIMARY KEY(id)
);
--inserting unique author values from books_raw table into author table
INSERT INTO author(name, gender_id) SELECT DISTINCT writer, gender_id FROM books_raw ORDER BY writer;
-- updating the author_id column in books_raw table
UPDATE books_raw SET author_id = (SELECT author.id FROM author WHERE author.name = books_raw.writer);

SELECT * FROM author LIMIT 5;


-- creating rating table
CREATE TABLE rating (id SERIAL, 
rating VARCHAR(10) UNIQUE,
PRIMARY KEY(id)
);
--inserting unique rating values from books_raw table into rating table
INSERT INTO rating(rating) SELECT DISTINCT rating FROM books_raw;
-- updating the rating_id column in books_raw table
UPDATE books_raw SET rating_id = (SELECT rating.id FROM rating WHERE rating.rating = books_raw.rating);

SELECT * FROM rating;


-- creating publisher table
CREATE TABLE publisher (id SERIAL,
publisher_name VARCHAR (150) UNIQUE,
PRIMARY KEY(id)
);
--inserting unique publisher values from books_raw table into publisher table
INSERT INTO publisher(publisher_name) SELECT DISTINCT publication FROM books_raw ORDER BY books_raw.publication;
-- updating the publisher_id column in books_raw table
UPDATE books_raw SET publisher_id = (SELECT publisher.id FROM publisher WHERE publisher.publisher_name = books_raw.publication);

SELECT * FROM publisher LIMIT 3;


-- creating transaction_method table
CREATE TABLE transaction_method (id SERIAL,
method VARCHAR(10) UNIQUE,
PRIMARY KEY(id)
);
--inserting unique transaction_method values from books_raw table into transaction_method table
INSERT INTO transaction_method(method) SELECT DISTINCT transaction_method FROM books_raw ORDER BY transaction_method;
-- updating the transaction_method_id column in books_raw table
UPDATE books_raw SET transaction_method_id = (SELECT transaction_method.id FROM transaction_method WHERE transaction_method.method = books_raw.transaction_method);

SELECT * FROM transaction_method;


-- creating read_unread table
CREATE TABLE read_unread (id SERIAL,
read_unread VARCHAR(15) UNIQUE,
PRIMARY KEY(id)
);
--inserting unique read_unread values from books_raw table into read_unread table
INSERT INTO read_unread(read_unread) SELECT DISTINCT read_unread FROM books_raw ORDER BY read_unread;
-- updating the read_unread_id column in books_raw table
UPDATE books_raw SET read_unread_id = (SELECT read_unread.id FROM read_unread WHERE read_unread.read_unread = books_raw.read_unread);

SELECT * FROM read_unread;


-- creating genre table
CREATE TABLE genre (id SERIAL,
genre VARCHAR(25) UNIQUE,
PRIMARY KEY(id)
);
--inserting unique genre values from books_raw table into genre table
INSERT INTO genre(genre) SELECT DISTINCT genre FROM books_raw ORDER BY genre;
-- updating the genre_id column in books_raw table
UPDATE books_raw SET genre_id = (SELECT genre.id FROM genre WHERE genre.genre = books_raw.genre);

SELECT * FROM genre;


-- creating binding_type table
CREATE TABLE binding_type (id SERIAL,
binding_type VARCHAR(10) UNIQUE,
PRIMARY KEY(id)
);
--inserting unique binding_type values from books_raw table into binding_type table
INSERT INTO binding_type(binding_type) SELECT DISTINCT binding FROM books_raw ORDER BY binding;
-- updating the binding_type _id column in books_raw table
UPDATE books_raw SET binding_id = (SELECT binding_type.id FROM binding_type WHERE binding_type.binding_type = books_raw.binding);

SELECT * FROM binding_type;


-- creating language table
CREATE TABLE language (id SERIAL,
language VARCHAR(20) UNIQUE,
PRIMARY KEY(id)
);
--inserting unique language values from books_raw table into language table
INSERT INTO language(language) SELECT DISTINCT original_language FROM books_raw ORDER BY original_language;
-- updating the language_id column in books_raw table
UPDATE books_raw SET language_id = (SELECT language.id FROM language WHERE language.language = books_raw.original_language);

SELECT * FROM language;


-- creating book_title table
CREATE TABLE book_title(
id SERIAL,
name VARCHAR(120) NOT NULL,
price INTEGER,
year INTEGER,
comment TEXT,
created_at TIMESTAMPTZ DEFAULT NOW(),
updated_at TIMESTAMPTZ DEFAULT NOW(),
author_id INTEGER REFERENCES author(id) ON DELETE CASCADE,
publisher_id INTEGER REFERENCES publisher(id) ON DELETE CASCADE,
transaction_method_id INTEGER REFERENCES transaction_method(id) ON DELETE CASCADE,
read_unread_id INTEGER REFERENCES read_unread(id) ON DELETE CASCADE,
genre_id INTEGER REFERENCES genre(id) ON DELETE CASCADE,
binding_id INTEGER REFERENCES binding_type(id) ON DELETE CASCADE,
language_id INTEGER REFERENCES language(id) ON DELETE CASCADE,
rating_id INTEGER REFERENCES rating(id) ON DELETE CASCADE,
PRIMARY KEY(id)
);
-- inserting values into book_title table from books_raw table
INSERT INTO book_title(name, price,year, author_id,publisher_id, transaction_method_id , read_unread_id ,genre_id ,binding_id,language_id,rating_id) SELECT name, price,year,author_id, publisher_id, transaction_method_id , read_unread_id ,genre_id ,binding_id,language_id,rating_id FROM books_raw;

SELECT * FROM book_title LIMIT 3;

-- since author and books have many-to-many relations, we need to create a linking table to join these two columns
-- creating the author_book_junction table
CREATE TABLE author_book_junction(
book_id INTEGER REFERENCES book_title(id) ON DELETE CASCADE,
author_id INTEGER REFERENCES author(id) ON DELETE CASCADE,
PRIMARY KEY(author_id, book_id)
);

-- inserting the values in author_book_junction
INSERT INTO author_book_junction(book_id, author_id) SELECT id, author_id from book_title;

SELECT * FROM author_book_junction LIMIT 5;

-- since we already have author as well as junction table, we won't need the author_id in book_title table
ALTER TABLE book_title DROP COLUMN author_id CASCADE;


-- some CRUD queries
-- showing name and author of the first 5 books
SELECT book_title.name AS book_name, 
              author.name AS author_name
FROM author_book_junction 
JOIN book_title ON author_book_junction.book_id= book_title.id 
JOIN author ON author_book_junction.author_id = author.id
ORDER BY author_book_junction.book_id  
LIMIT 5;

-- showing all the books written by Lafcadio Hearn
SELECT book_title.name, author.name 
FROM book_title
JOIN author_book_junction ON book_title.id = author_book_junction.book_id
JOIN author ON author.id = author_book_junction.author_id
WHERE author.name = 'Lafcadio Hearn';

-- showing the number of books by rating levels
SELECT COUNT(book_title.name) AS number_of_books, rating.rating 
FROM book_title JOIN rating
ON book_title.rating_id = rating.id
GROUP BY rating.rating
ORDER BY COUNT(book_title.name) DESC ; 

-- Showing 10 books written by female authors
SELECT book_title.name AS book_name,
               author.name AS author_name
FROM author_book_junction
JOIN book_title ON author_book_junction.book_id= book_title.id
JOIN author ON author_book_junction.author_id = author.id
WHERE author.gender_id =2
ORDER BY author_book_junction.book_id
LIMIT 5;


-- inserting a new entry
-- first need to enter a new publisher name in publisher table
INSERT INTO publisher(publisher_name ) VALUES ('Seven Stories Press');

SELECT id FROM  publisher WHERE publisher_name = 'Seven Stories Press';

-- inserting the new book in the book_title
INSERT INTO book_title(name, price,year, transaction_method_id , read_unread_id ,genre_id ,binding_id,language_id,rating_id) VALUES ('A Man''s Place',181, 2023, 3, 3, 3, 3, 3, 2);

-- using subquery to update publisher_id in the book_title
UPDATE book_title SET publisher_id = (SELECT id FROM  publisher WHERE publisher_name = 'Seven Stories Press') WHERE name = 'A Man''s Place';

-- a new author name is added in the author table
INSERT INTO author(name,gender_id) VALUES ('Annie Ernaux', 3);

-- getting the book_id and author_id for inserting into the junction table
SELECT id FROM book_title WHERE name = 'A Man''s Place';
SELECT id FROM author WHERE name = 'Annie Ernaux';

-- inserting the values in junction table
INSERT INTO author_book_junction(book_id, author_id) VALUES (194,141);



-- updating a column
UPDATE book_title SET comment = 'lent it to my friend in 2021, still have not received' WHERE name = 'Pride & Prejudice';

SELECT name, comment FROM book_title WHERE name = 'Pride & Prejudice';


-- deleting an entry
-- I want to delete a book named 'The Alchemist' since i don't have it anymore.
-- I can delete it from book_title table, but it'll only delete the name of the book, not the author.
-- I have to delete the author from author table as well.

-- counting the number of books and authors prior to deletion
SELECT COUNT(*) FROM book_title;
SELECT COUNT(*) FROM author;
SELECT COUNT(*) FROM author_book_junction;

-- getting the book_id and author_id from the linking table
-- this step is optional ( I can either use the name or the id to remove it from the table)
SELECT book_title.name AS book_name,
              author_book_junction.book_id AS book_id,
              author.name AS author_name,
              author_book_junction.author_id AS author_id
FROM author_book_junction 
JOIN book_title ON author_book_junction.book_id= book_title.id 
JOIN author ON author_book_junction.author_id = author.id
WHERE book_title.name = 'The Alchemist';

-- deleting entries from parent tables automatically deletes the record from the linking table
DELETE FROM book_title WHERE  name = 'The Alchemist';
DELETE FROM author WHERE name = 'Paulo Coelho';

-- since deletion is made in the parent tables, it should reflect on the linking table too
SELECT COUNT(*) FROM author;

-- It should return 0 rows
SELECT id FROM book_title WHERE id = 76;
SELECT id FROM author WHERE id = 91;

---------------------------------------------------------------------------------------------
-- New Updates and modifications
---------------------------------------------------------------------------------------------
-- commenting on bad books 
SELECT book_title.name, book_title.comment, rating.rating
FROM book_title JOIN rating ON book_title.rating_id = rating.id 
WHERE rating.id = 3;

UPDATE book_title SET comment = 'Full of commercial wisdom. Sounds cliched and repetitive.' WHERE name = 'The Monk who sold his Ferrari';
UPDATE book_title SET comment = 'Overtly Hyped Emily Bronte novel. Full of strong Emotions and chaotic.' WHERE name = 'Wuthering Heights';
UPDATE book_title SET comment = 'Not as good as Homo Sapiens by Y. N. Harari. Too nihilistic view on AI.' WHERE name = 'Homo Deus';

-- number of partially read books
SELECT COUNT(book_title.name) FROM book_title WHERE read_unread_id = 2;

-- list of partially read books
SELECT book_title.name, read_unread.read_unread
FROM book_title JOIN read_unread ON book_title.read_unread_id = read_unread.id 
WHERE read_unread.id = 2;

-- updating the read_unread id of Kafka on the Shore from partially read to read
UPDATE book_title SET read_unread_id = 3 WHERE name = 'Kafka on the Shore';

-- number of unread books
SELECT COUNT(book_title.name) FROM book_title WHERE read_unread_id = 1;

-- list of unread books
SELECT book_title.name, read_unread.read_unread
FROM book_title JOIN read_unread ON book_title.read_unread_id = read_unread.id 
WHERE read_unread.id = 1;

-- updating 'Critique of Pure Reason' from unread to partially read
UPDATE book_title SET read_unread_id = 2 WHERE name = 'Critique of Pure Reason';


-- Commenting on authors with no informations
SELECT b.id, b.name, a.name
FROM author_book_junction ab
JOIN book_title b ON ab.book_id = b.id
JOIN author a ON ab.author_id = a.id
WHERE a.gender_id = 1;

UPDATE book_title SET comment = 'No information on the writer name or gender.' WHERE id IN (52, 53, 103, 104, 139, 175);


-- Commenting on free books
SELECT id, name FROM book_title WHERE transaction_method_id = 2;

UPDATE book_title SET comment = 'It was a present' WHERE id IN (54, 63, 126);
UPDATE book_title SET comment = 'Self made' WHERE id IN (150, 183,184, 185,186, 187, 188, 189);


------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Adding a new entry- (Seven Pillars of Wisdom, T. E. Lawrence, Penguin, 456, 2023, Online, Read, Non-Fiction, Paperback, English, Excellent rating)
------------------------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO book_title(name, price,year,publisher_id, transaction_method_id , read_unread_id ,genre_id ,binding_id,language_id,rating_id) VALUES ('Seven Pillars of Wisdom',456, 2023,53, 3, 3, 3, 3, 3, 2);

--book_id=195

INSERT INTO author(name, gender_id) VALUES ('T. E. Lawrence', 3);
--author_id = 142

INSERT INTO author_book_junction (book_id, author_id) VALUES (195, 142);


------------------------------------------------------------------------------
-- Removing some e-books that mistakenly I've deleted from the computer
------------------------------------------------------------------------------
DELETE FROM book_title WHERE id IN (1,2,3,4,5,6,7, 165, 166, 167, 168, 169, 170, 174, 190, 191, 193, 175);
DELETE FROM book_title WHERE id BETWEEN 127 and 156;

------------------------------------------------------------------------------
-- Adding a new book 'Letters to Milena' by Franz Kafka
------------------------------------------------------------------------------
SELECT id, publisher_name FROM publisher WHERE publisher_name='Vintage Classics';
-- publisher id = 91
INSERT INTO book_title(name, price,year,publisher_id, transaction_method_id , read_unread_id ,genre_id ,binding_id,language_id,rating_id)
  VALUES ('Letters to Milena',393, 2024,91, 3, 2, 3, 3, 4, 1);
-- book_id = 196
INSERT INTO author (name,gender_id) VALUES ('Franz Kafka',3); 
--author_id = 143
INSERT INTO author_book_junction (book_id, author_id) VALUES (196, 143);


SELECT b.name, a.name, b.price, b.year
FROM author_book_junction ab
JOIN book_title b ON ab.book_id = b.id
JOIN author a ON ab.author_id = a.id
WHERE b.name = 'Letters to Milena';
