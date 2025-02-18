# Database Design and Normalization

![spreadsheet to database](https://github.com/Arpita-deb/Books-Database-Normalization/assets/139372731/5cc1ce7f-6c4f-4ea4-a9a4-24af84203876)

# Introduction

It is part of the Data Analysis Project 'Do I read all the books I buy?', where I'll design a database using PostgreSQL to maintain my collection of books digitally. It is done in the Data Cleaning Phase.

# Purpose of the database:

The database is built to organize and manage a personal collection of books. It helps in tracking book details such as title, price, publication year, genre, author(s), language, and ratings. It also supports actions like marking books as read/unread, recording transaction methods (e.g., purchased, borrowed), and storing other key metadata about each book.

# Objectives:

1. Design a database schema and implement it in PostgreSQL database system.
2. Follow the best practices to normalize the tables to reduce data redundancy and increase efficiency.
3. Perform CRUD Operations to add, update or delete data from the database.

# What is Database Normalization?

According to Wikipedia "Database normalization is the process of structuring a relational database in accordance with a series of normal forms in order to reduce data redundancy and improve data integrity." In short, it is the process of organizing the data in the database. It is used to minimize the redundancy from a relation or set of relations. It is also used to eliminate undesirable characteristics like Insertion, Update, and Deletion Anomalies. Normalization divides the larger table into smaller ones and links them using relationships.

The normal form is used to reduce redundancy from the database table.

## Why do we need Normalization? 

The main reason for normalizing the relations is removing Insertion, Update, and Deletion Anomalies. Failure to eliminate anomalies leads to data redundancy and can cause data integrity and other problems as the database grows. Normalization consists of a series of guidelines that help us to create a good database structure.

Data modification anomalies can be categorized into three types:

* **Insertion Anomaly**: Insertion Anomaly refers to when one cannot insert a new tuple into a relationship due to lack of data.

* **Deletion Anomaly**: The delete anomaly refers to the situation where the deletion of data results in the unintended loss of some other important data.

* **Update Anomaly**: The update anomaly is when an update of a single data value requires multiple rows of data to be updated.

# Dataset Used:

For this project I've used a csv file named **Books_Management** which consists of data on 184 books.

## Schema: 

| Column Name | Column Description | Data type |
| :--- | :--- | :--- |
| Name | Name of the book | chr |
| Writer | Name of the writer | chr |
| Original_Language | Language in which the book is originally written | chr |
| Genre | Genre of the book | chr |
| Binding | Whether book is Paperback, hardcover or ebook| chr |
| Publication | Name of the Publication agency | chr |
| Price | Price of the book in INR(₹) | int |
| Transaction_method | Online or Cash or None (if the books are free) | chr |
| Year | Year of buying | int |
| Read/Unread | Yes- If I've read, No- If I've not read; Partially read- If I've started reading but didn't finish | chr |
| Rating | How I rated the books - Excellent, Moderate, Bad, None(for unread books) | chr |
| Gender of the writer | Male, Female, Null(if there's no information | chr |

# Tools used:

For the purpose of this project I've used -

* **PostgreSQL** and **SQL Shell** to create a database design
* **QuickDbd** to create the Entity-Relationship-Diagrams

# Steps taken:

## STEP - 1 LOADING THE DATA INTO THE DATABASE

  To load the data into the database a table named books_raw is created with all the columns that is in the csv file along with some extra id columns that'll later be used as foreign keys.

    DROP TABLE IF EXISTS books_raw ;

    CREATE TABLE books_raw(
     name VARCHAR(120) NOT NULL,
     writer VARCHAR(120) NULL, 
     original_language VARCHAR(120) NULL,
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
     
Using the copy command the data is loaded into the database table.
   
    \copy books_raw(name,writer,original_language,genre,binding,publication,price,transaction_method,year,read_unread,rating,writer_gender ) FROM 'C:\Users\Dell\Desktop\Projects\Do i read all the books i buy\Books_Management.csv' WITH DELIMITER ',' CSV HEADER;

![after copy](https://github.com/Arpita-deb/Books-Database-Normalization/assets/139372731/bd372642-7ddd-41dc-b9e5-78274ea786e3)


## STEP 2 - START NORMALIZING THE DATA
    
  ### 2.1 First Normal Form:
    
  *In the first normal form each field contains a single value. A field may not contain a set of values or a nested record.*

  In order to identify a unique row, a primary key(id) is added into the table.
         
      ALTER TABLE books_raw ADD COLUMN id SERIAL;
      ALTER TABLE books_raw ADD CONSTRAINT books_id PRIMARY KEY (id);

![first db](https://github.com/Arpita-deb/Books-Database-Normalization/assets/139372731/3745e2ad-1d94-460a-976a-0f23ab3f5adc)

![first query](https://github.com/Arpita-deb/Books-Database-Normalization/assets/139372731/64cf71c4-4778-491d-a6ef-8d58dbb9594d)

This satisfies the first normal form.
    
   ### 2.2 Second Normal Form:
   
The rules for second normal form are -

* *Fulfil the requirements of first normal form.*
* *Each non-key attribute must be functionally dependent on the primary key which means each field that is not the primary key is determined by that primary key, so it is specific to that record.*

In this step we identify which column is functionally dependent or independent of the primary key i.e., in our case book id, which represents a book.

From all the columns name, writer,price, year and rating are functionally dependent on book id. So we create a separate table book_title with these columns. 
    
    CREATE TABLE book_title (id SERIAL,
     name VARCHAR(120) NOT NULL,
     writer VARCHAR(120),
     price INTEGER,
     year INTEGER,
     rating VARCHAR(10),
     created_at TIMESTAMPTZ DEFAULT NOW(),
     updated_at TIMESTAMPTZ DEFAULT NOW(),
     PRIMARY KEY(id)
     );

Since the rest of the columns are not functionally dependent on book id, we create separate tables for each of them with unique primary keys for each of the tables.

  **2.2.a One-to-Many Relations:**

   A one-to-many relationship in a database occurs when each record in Table A may have many linked records in Table B, but each record in Table B may have only one corresponding record in Table A.
   In our case, one language (e.g. English or French) can have multiple books but one book will have only one language. Thus it is a one-to-many relationship. The same goes for genre, binding_type, publisher, read_unread, transaction_method and gender tables.

    CREATE TABLE language (id SERIAL,
    language VARCHAR(20) UNIQUE,
    PRIMARY KEY(id)
    );

    CREATE TABLE genre (id SERIAL,
     VARCHAR(25) UNIQUE,
     PRIMARY KEY(id)
     );

    CREATE TABLE binding_type (id SERIAL,
     binding_type VARCHAR(10) UNIQUE,
     PRIMARY KEY(id)
     );

    CREATE TABLE publisher (id SERIAL,
     publisher_name VARCHAR (150) UNIQUE,
     PRIMARY KEY(id)
     );

    CREATE TABLE transaction_method (id SERIAL,
     method VARCHAR(10) UNIQUE,
     PRIMARY KEY(id)
     );

    CREATE TABLE read_unread (id SERIAL,
    read_unread VARCHAR(15) UNIQUE,
    PRIMARY KEY(id)
    );

    CREATE TABLE gender (id SERIAL, 
     gender VARCHAR(20) UNIQUE,
     PRIMARY KEY(id)
     );

![leaf table 1](https://github.com/Arpita-deb/Books-Database-Normalization/assets/139372731/bbddad61-2dd0-45f7-a8f5-45edf7faed0e)

![leaf table 2](https://github.com/Arpita-deb/Books-Database-Normalization/assets/139372731/c81b1298-6868-41c1-af5e-6fa37aed0322)

The database now looks like this with all the tables joined together by the foreign keys.

![Screenshot (824)](https://github.com/Arpita-deb/Books-Database-Normalization/assets/139372731/0728c76e-908c-4a4b-a8e6-058881843585)
        
  **2.2.b Many-to-Many Relations:**
  
A many-to-many relationship occurs when multiple records in a table are related to multiple records in another table.This can be seen in case of book-writer relationship because a book have many writers, or a writer has many books. 

![m-t-m](https://github.com/Arpita-deb/Books-Database-Normalization/assets/139372731/bdf833ff-7866-4656-891e-dc42509c9057)

So, we create a separate writer table. We name it author table.
   
    CREATE TABLE author(
    id SERIAL,
    name VARCHAR(120),
    PRIMARY KEY(id)
    );
    
  To represent a many-to-many relationship, a third table (called a junction or join table) is needed, whose primary key is composed of the foreign keys from both related tables.
  
    CREATE TABLE author_book_junction(
    book_id INTEGER REFERENCES book_title(id) ON DELETE CASCADE,
    author_id INTEGER REFERENCES author(id) ON DELETE CASCADE,
    PRIMARY KEY(author_id, book_id)
    );

![leaf table junct](https://github.com/Arpita-deb/Books-Database-Normalization/assets/139372731/028c79dd-6efc-4157-91cb-7ae6b26a94c0)

![junc db](https://github.com/Arpita-deb/Books-Database-Normalization/assets/139372731/536ac6dc-f5bd-40d0-be37-a1f5eb09d49d)

  So far, we end up with these tables. They are all in second normal form. All the tables have their own primary keys or a set of primary keys (in case of author-book-junction table) and all the columns in each table are functionally dependent on their respective primary keys.
  
  ### 2.3 Third Normal Form:
  
The rule for Third Normal Form is:
* *It fulfils the requirements of second normal form.*
* *Has no transitive functional dependency which means that every attribute that is not the primary key must depend on the primary key and the primary key only.*

In our database, we have two such columns. The book_name (A) determines the author (B) column. It further determines the gender (C). So, we need to remove the gender table from book table. We create a different table and join it with the author table with a foreign key, gender_id.

      CREATE TABLE author (id SERIAL,
       name VARCHAR(120),
       gender_id INTEGER REFERENCES gender(id) ON DELETE CASCADE,
       PRIMARY KEY(id)
      );

The final database design after attaining the third normal form looks like this-

![Untitled design](https://github.com/Arpita-deb/Books-Database-Normalization/assets/139372731/734b4ce6-79b9-4ab3-a572-4fe5d1a7c8fe)

## STEP 3 - PERFORMING QUERIES

The important task for a database management system is to create/read/update/delete data from the database. So to make sure we have created a good database design, we'll perform some queries.

3.1 Inserting new data

Inserting data with attributes —

* Title of the Book — A Man’s Place 
* Author — Annie Ernaux
* Gender — Female
* Publisher — Seven Stories Press
* Price — 181
* Year — 2023
* Transaction method — online
* Read/unread — yes
* Genre — Nonfiction
* Binding — Paperback
* Original language — French
* Rating — Excellent.


      -- first need to enter a new publisher name in publisher table
        INSERT INTO publisher(publisher_name )
        VALUES ('Seven Stories Press');

      -- inserting the new book in the book_title
        INSERT INTO book_title(name, price,year, transaction_method_id , read_unread_id ,genre_id ,binding_id,language_id,rating_id)
        VALUES ('A Man''s Place',181, 2023, 3, 3, 3, 3, 3, 2);

      -- using subquery to update publisher_id in the book_title
        UPDATE book_title
        SET publisher_id = (SELECT id
                            FROM  publisher
                            WHERE publisher_name = 'Seven Stories Press')
        WHERE name = 'A Man''s Place';

      -- a new author name is added in the author table
        INSERT INTO author(name,gender_id)
        VALUES ('Annie Ernaux', 3);

      -- getting the book_id and author_id for inserting into the junction table
        SELECT id
        FROM book_title
        WHERE name = 'A Man''s Place';

        SELECT id
        FROM author
        WHERE name = 'Annie Ernaux';

      -- inserting the values in junction table
        INSERT INTO author_book_junction(book_id, author_id)
        VALUES (194,141);

3.2 Reading data

* Number of books for each ratings:

   ![count of books](https://github.com/Arpita-deb/Books-Database-Normalization/assets/139372731/839b4011-4a8d-493d-81d4-b89222fed6d5)

* 10 books written by female authors
   ![female writer](https://github.com/Arpita-deb/Books-Database-Normalization/assets/139372731/a74e6c51-8353-4708-bb73-e914167bb786)

* List of books by Lafcadio Hearn

   ![lafcadio query](https://github.com/Arpita-deb/Books-Database-Normalization/assets/139372731/7197971c-2cca-44b1-a2ce-4bcdae8a6fb2)

3.3 Updating data

    -- updating a column
       UPDATE book_title 
       SET comment = 'lent it to my friend in 2021, still have not received' 
       WHERE name = 'Pride & Prejudice';

3.4 Deleting a data 

I want to delete a book named 'The Alchemist' since i don't have it anymore. I can delete it from book_title table, but it'll only delete the name of the book, not the author. I have to delete the author from author table as well. Deleting entries from parent tables automatically deletes the record from the linking table
     
     DELETE FROM book_title 
     WHERE  name = 'The Alchemist';
     
     DELETE FROM author 
     WHERE name = 'Paulo Coelho';

Since deletion is made in the parent tables, it should reflect on the linking table too
     
     SELECT COUNT(*) 
     FROM author_book_junction;

It should return 0 rows.
    
    SELECT id 
    FROM book_title 
    WHERE id = 76;
    
    SELECT id 
    FROM author 
    WHERE id = 91;
 
# Summary:

Here's a quick summary of the tables I've created to manage different aspects of my collection of books:

**1. Book Titles (book_title):**

This table serves as the central hub of the database, containing essential details about each book, such as its name, price, publication year, and timestamp for when it was added or updated. It connects to other tables through foreign keys, linking the book to its genre, language, transaction method, publisher, read/unread status, and rating.

**2. Author-Book Relationship (author-book-junction):**

Since a book may have multiple authors, this junction table establishes a many-to-many relationship between authors and books. It links the book_title and author tables.

**3. Authors (author):**

This table contains details about authors, including their name and gender, and is linked to the gender table to maintain information on gender identity.

**4. Genre, Language, Rating, and Publisher Tables:**

Each of these tables holds specific attributes about a book:

  * genre: Lists different genres like fiction, non-fiction, etc.
  * language: Stores the language of the book.
  * rating: Captures the rating assigned to each book (e.g., out of 5 or 10).
  * publisher: Stores publisher information, including the name.

**5. Read/Unread Status (read_unread):**

This table allows tracking whether a book has been read or is yet to be read, helping organize the reading progress.

**6. Transaction Method (transaction_method):**

This table logs how the book was obtained—whether it was purchased, borrowed, or received as a gift.

**7. Binding Type (binding_type):**

It captures the physical binding of the book (e.g., hardcover, paperback, etc.).

The database effectively organizes and tracks books in a digital collection by normalizing various related attributes (e.g., genre, language, rating). It offers a structured way to manage large collections, ensuring easy retrieval of information, detailed data analysis, and better management of books through read/unread status, transaction history, and ratings. By maintaining relationships between authors, genres, publishers, and languages, the database supports flexibility and scalability, allowing future additions or updates without redundancy or data loss.

# References:

* PostgreSQL For Everybody Specialization
* [Database Normalization Wikipedia](https://en.wikipedia.org/wiki/Database_normalization)
* [Database Normalization](https://www.databasestar.com/database-normalization/)

# Appendix:

* A detailed Article about the Normalization and Denormalization process: [From Spreadsheets to Database - Creating A Normalized (and Denormalized) Database](https://medium.com/@arpita_deb/from-spreadsheets-to-database-c2e8dbeb6a76)

# License:

[Database Design and Normalization](https://github.com/Arpita-deb/Books-Database-Normalization.git) is licensed under the MIT License for code, and a Proprietary License for the included data.

You may use, modify, and distribute the code as per the MIT License, but the data contained within this repository is not to be replicated, reproduced, or distributed in any form without explicit permission from the author.
