# Introduction

Spreadsheets are the first go-to tool for all sort of businesses to collect and maintain data. Its easy to just fill in the cells, as long as the quantity of data is either small or medium. As soon as we're dealing with millions or billions data which are created, updated or deleted each day, spreadsheets start to perform less efficiently. In these scenarios, large businesses opt for a database management system, which as its name suggests, manages data in large quantity and in a faster way.  

when we're using spreadsheets data is stored in a single space on the computer. As entries into that spreadsheet increases, the chances of data replication also increases. This repetition of data may result in:
* Making relations/tables very large.
* Difficulty maintaining and updating data as it invloves searching many records in a table.
* Wastage and poor utilization of disk space.
* Increased likelihood of errors and inconsistencies.

To handle these problems, we need to get rid of the replicated data and create tables that are smaller, simpler, well - structured and easy to search/update/delete. This is where we need to normalize a database by either creating a new database design (synthesis) or improving an existing database design (decomposition).

# What is Database Normalization?

According to Wikipedia "Database normalization is the process of structuring a relational database in accordance with a series of normal forms in order to reduce data redundancy and improve data integrity." In short, it is the process of organizing the data in the database. It is used to minimize the redundancy from a relation or set of relations. It is also used to eliminate undesirable characteristics like Insertion, Update, and Deletion Anomalies. Normalization divides the larger table into smaller and links them using relationships.

The normal form is used to reduce redundancy from the database table.

## Why do we need Normalization? 

The main reason for normalizing the relations is removing Insertion, Update, and Deletion Anomalies. Failure to eliminate anomalies leads to data redundancy and can cause data integrity and other problems as the database grows. Normalization consists of a series of guidelines that helps to guide you in creating a good database structure.

Data modification anomalies can be categorized into three types:

* **Insertion Anomaly**: Insertion Anomaly refers to when one cannot insert a new tuple into a relationship due to lack of data.

* **Deletion Anomaly**: The delete anomaly refers to the situation where the deletion of data results in the unintended loss of some other important data.

* **Updatation Anomaly**: The update anomaly is when an update of a single data value requires multiple rows of data to be updated.

## Advantages of Normalization:

* Reduced redundancy, which means less data duplication and more efficient storage usage.
* Increased integrity and consistency, which means the data is always accurate and unambiguous.
* Improved query performance and organization, which means the data is easier to find and use.
* Increased security and connection, which means the data is protected and can be linked to other systems.
* Cost reduction, which means less storage and maintenance expenses.

## Disadvantages of Normalization:

* Multiple leaf tables that needs to be linked together with sophisticated JOINs which results in slower read times.
* As number of tables increases maintenance level also increases.
* The performance degrades when normalizing the relations to higher normal forms, i.e., 4NF, 5NF.
* It is very time-consuming and difficult to normalize relations of a higher degree.
* Careless decomposition may lead to a bad database design, leading to serious problems.

# Overview of the Project:

The goal of this project is to -

1. load a csv file into a database table using PostgreSQL.
2. Create a database design for my personal collection of books by normalizing the table upto 3NF (Third Normal Form)
3. Insert, Update and delete data from the database.
    
# Dataset Used:

For this project I've used a csv file named Books_Management which consists of data on 184 books.

# Tools used:

For the purpose of this project I've used PostgreSQL SQL Shell to run all the queries. 

# Steps taken:
## STEP - 1 LOADING THE DATA INTO THE DATABASE

  To load the data into the database a table named books_raw is created with all the columns that is in the csv file along with some extra id columns that'll later be used as foreign keys.

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
     
Using the copy command the data is loaded into the database table.
   
    \copy books_raw(name,writer,original_language,genre,binding,publication,price,transaction_method,year,read_unread,rating,writer_gender ) FROM 'C:\Users\Dell\Desktop\Projects\Do i read all the books i buy\Books_Management.csv' WITH DELIMITER ',' CSV HEADER;

![after copy](https://github.com/Arpita-deb/Books-Database-Normalization/assets/139372731/bd372642-7ddd-41dc-b9e5-78274ea786e3)


## STEP 2 - START NORMALIZING THE DATA
    
  ### 2.1 First Normal Form:
    
  In the first normal form each field contains a single value. A field may not contain a set of values or a nested record.

  In order to identify a unique row, a primary key(id) is added into the table.
         
      ALTER TABLE books_raw ADD COLUMN id SERIAL;
      ALTER TABLE books_raw ADD CONSTRAINT books_id PRIMARY KEY (id);

![first db](https://github.com/Arpita-deb/Books-Database-Normalization/assets/139372731/3745e2ad-1d94-460a-976a-0f23ab3f5adc)

![first query](https://github.com/Arpita-deb/Books-Database-Normalization/assets/139372731/64cf71c4-4778-491d-a6ef-8d58dbb9594d)
    
   ### 2.2 Second Normal Form:
   
The rules for second normal form are -

* Fulfil the requirements of first normal form.
* Each non-key attribute must be functionally dependent on the primary key which means each field that is not the primary key is determined by that primary key, so it is specific to that record.

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

![second db with links](https://github.com/Arpita-deb/Books-Database-Normalization/assets/139372731/aee8db7f-ada8-4878-90e5-2ef40808abd7)
        
  **2.2.b Many-to-Many Relations:**
  
A many-to-many relationship occurs when multiple records in a table are related to multiple records in another table.
This can be seen in case of book-writer relationship because a book have many writers, or a writer has many books. 

![m-t-m](https://github.com/Arpita-deb/Books-Database-Normalization/assets/139372731/bdf833ff-7866-4656-891e-dc42509c9057)

So we create a separate writer table. We name it author table.
   
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
* It fulfils the requirements of second normal form.
* Has no transitive functional dependency which means that every attribute that is not the primary key must depend on the primary key and the primary key only.

In our database, we have two such columns. The book_name (A) determines the author (B) column. It further determines the gender (C). So, we need to remove the gender table from book table. We create a different table and join it with the author table with a foreign key, gender_id.

      CREATE TABLE author (id SERIAL,
       name VARCHAR(120),
       gender_id INTEGER REFERENCES gender(id) ON DELETE CASCADE,
       PRIMARY KEY(id)
      );
![Final Database](https://github.com/Arpita-deb/Books-Database-Normalization/assets/139372731/a8613bce-6202-4558-850a-15e05a9f2f47)


## STEP 3 - PERFORMING QUERIES
![count of books](https://github.com/Arpita-deb/Books-Database-Normalization/assets/139372731/839b4011-4a8d-493d-81d4-b89222fed6d5)

![female writer](https://github.com/Arpita-deb/Books-Database-Normalization/assets/139372731/a74e6c51-8353-4708-bb73-e914167bb786)

![lafcadio query](https://github.com/Arpita-deb/Books-Database-Normalization/assets/139372731/7197971c-2cca-44b1-a2ce-4bcdae8a6fb2)


# References:
* PostgreSQL For Everybody Specialization
* [Database Normalization Wikipedia](https://en.wikipedia.org/wiki/Database_normalization)
* [Database Normalization](https://www.databasestar.com/database-normalization/)
