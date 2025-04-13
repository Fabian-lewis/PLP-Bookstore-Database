-- START BY CREATING THE DATABASE

CREATE DATABASE bookStore;

-- CREATE THE TABLES
-- SOME TABLES HAVE FOREIGN KEYS THAT REFERENCE OTHER TABLES, SO WHEN CREATING THE TABLES START WITH THE TABLES THAT HAVE NO FOREIGN KEYS
-- AND END WITH THE TABLES THAT HAVE FOREIGN KEYS
CREATE TABLE author (
	author_id SERIAL PRIMARY KEY,
	first_name VARCHAR (100) NOT NULL,
	last_name VARCHAR (100) NOT NULL,
	bio TEXT
);

CREATE TABLE book_language (
	language_id SERIAL PRIMARY KEY,
	language_name VARCHAR(100) NOT NULL
);

CREATE TABLE publisher (
	publisher_id SERIAL PRIMARY KEY,
	publisher_name VARCHAR(255) NOT NULL,
	contact_info TEXT
);

CREATE TABLE book (
	book_id SERIAL PRIMARY KEY,
	title VARCHAR (255) NOT NULL,
	publication_year INT,
	language_id INT,
	publisher_id INT,
	price DECIMAL(10,2),
	FOREIGN KEY (language_id) REFERENCES book_language(language_id),
	FOREIGN KEY (publisher_id) REFERENCES publisher(publisher_id)
);

CREATE TABLE book_author (
	book_id INT NOT NULL,
	author_id INT NOT NULL,
	PRIMARY KEY (book_id, author_id),
	FOREIGN KEY (book_id) REFERENCES book(book_id) ON DELETE CASCADE,
	FOREIGN KEY (author_id) REFERENCES author(author_id) ON DELETE CASCADE
);


CREATE TABLE customer (
	customer_id SERIAL PRIMARY KEY,
	first_name VARCHAR(100) NOT NULL,
	last_name VARCHAR(100) NOT NULL,
	email VARCHAR(255) UNIQUE NOT NULL,
	phone_number VARCHAR (15),
	date_of_birth DATE
);

CREATE TABLE address_status (
	status_id SERIAL PRIMARY KEY,
	status_name VARCHAR(50) NOT NULL
);

CREATE TABLE country (
	country_id SERIAL PRIMARY KEY,
	country_name VARCHAR(100) NOT NULL
);

CREATE TABLE address (
	address_id SERIAL PRIMARY KEY,
	street_address VARCHAR(255) NOT NULL,
	city VARCHAR (255) NOT NULL,
	country_id INT,
	FOREIGN KEY (country_id) REFERENCES country(country_id)
);

CREATE TABLE customer_address (
	customer_id INT NOT NULL,
	address_id INT NOT NULL,
	PRIMARY KEY (customer_id, address_id),
	FOREIGN KEY (customer_id) REFERENCES customer(customer_id) ON DELETE CASCADE,
	FOREIGN KEY (address_id) REFERENCES address(address_id) ON DELETE CASCADE
);

CREATE TABLE order_status (
	order_status_id SERIAL PRIMARY KEY,
	status_name VARCHAR(50) NOT NULL
);

CREATE TABLE order_line (
	order_line_id SERIAL PRIMARY KEY,
	order_id INT NOT NULL,
	book_id INT NOT NULL,
	quantity INT DEFAULT 1,
	price DECIMAL (10,2)
	
);

CREATE TABLE shipping_method(
	shipping_method_id SERIAL PRIMARY KEY,
	method_name VARCHAR (100) NOT NULL,
	description TEXT
);

CREATE TABLE cust_order (
	order_id SERIAL PRIMARY KEY,
	customer_id INT NOT NULL,
	order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	shipping_method_id INT,
	order_status_id INT,
	total_price DECIMAL(10,2),
	FOREIGN KEY (customer_id) REFERENCES customer(customer_id) ON DELETE CASCADE,
	FOREIGN KEY (shipping_method_id) REFERENCES shipping_method(shipping_method_id),
	FOREIGN KEY (order_status_id) REFERENCES order_status(order_status_id)
);


CREATE TABLE order_history (
	history_id SERIAL PRIMARY KEY,
	order_id INT NOT NULL,
	status_id INT NOT NULL,
	change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (order_id) REFERENCES cust_order(order_id) ON DELETE CASCADE,
	FOREIGN KEY (status_id) REFERENCES order_status(order_status_id)
);



-- CREATING ACCESS ROLES (YAAHH 😂😂)
-- CREATE TABLE users (
-- 	user_id SERIAL PRIMARY KEY,
-- 	username VARCHAR (100) UNIQUE NOT NULL,
-- 	email VARCHAR (255) UNIQUE NOT NULL,
-- 	password_hash TEXT NOT NULL,
-- 	role VARCHAR (50) NOT NULL CHECK (role IN ('admin','staff','customer','programmer')),
-- 	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
-- );


-- PROGRAMMERS HAVE ALL PRIVILEGES ON THE DATABASE
CREATE ROLE programmer WITH LOGIN PASSWORD 'rootpass';
GRANT ALL PRIVILEGES ON DATABASE bookStore TO programmer;
ALTER ROLE programmer CREATEDB CREATEROLE SUPERUSER;


-- ADMINISTRATORS HAVE ALL PRIVILEGES ON THE DATABASE EXCEPT FOR CREATING DATABASES AND ROLES
CREATE ROLE admin WITH LOGIN PASSWORD 'adminpass';
GRANT CONNECT ON DATABASE bookStore TO admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO admin;
GRANT USAGE, SELECT, UPDATE ON ALL SEQUENCES IN SCHEMA public TO admin;




-- STAFF HAVE SELECT, INSERT, UPDATE ON MOST TABLES
-- THEY CAN'T DELETE ANYTHING
CREATE ROLE staff WITH LOGIN PASSWORD 'staffpass';
GRANT SELECT, INSERT, UPDATE ON
	book,book_author, author, book_language, publisher,
	customer, cust_order, order_line, shipping_method, order_status
TO staff;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO staff;


-- CUSTOMERS CAN ONLY SELECT FROM SOME TABLES AND INSERT INTO SOME TABLES
CREATE ROLE customer_user WITH LOGIN PASSWORD 'custpass';
GRANT SELECT ON 
    book, book_language, publisher, shipping_method 
TO customer_user;

GRANT SELECT, INSERT ON 
    customer, cust_order, order_line 
TO customer_user;

--Prevent customer from seeing all customer data
REVOKE SELECT ON customer FROM customer_user;


-- Create users and assign them the roles
CREATE USER alice_admin WITH PASSWORD 'adminsecurepass';  
GRANT admin TO alice_admin;

CREATE USER bob_staff WITH PASSWORD 'staffsecurepass';   
GRANT staff TO bob_staff;

CREATE USER charlie_cust WITH PASSWORD 'custsecurepass'; 
GRANT customer_user TO charlie_cust;


