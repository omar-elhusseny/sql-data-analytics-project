DO $$ 
BEGIN
    IF EXISTS (SELECT 1 FROM pg_database WHERE datname = 'DataWarehouseAnalytics') THEN
        EXECUTE 'DROP DATABASE DataWarehouseAnalytics';
    END IF;
END $$;

-- Create the 'DataWarehouseAnalytics' database
CREATE DATABASE "DataWarehouseAnalytics";

-- Create Schemas
CREATE SCHEMA gold;

-- Create Tables

CREATE TABLE gold.dim_customers (
    customer_key 	INT,
    customer_id 	INT,
    customer_number VARCHAR(50),
    first_name 		VARCHAR(50),
    last_name 		VARCHAR(50),
    country 		VARCHAR(50),
    marital_status 	VARCHAR(50),
    gender 			VARCHAR(50),
    birthdate 		DATE,
    create_date 	DATE
);

CREATE TABLE gold.dim_products (
    product_key 	INT,
    product_id 		INT,
    product_number 	VARCHAR(50),
    product_name 	VARCHAR(50),
    category_id 	VARCHAR(50),
    category 		VARCHAR(50),
    subcategory 	VARCHAR(50),
    maintenance 	VARCHAR(50),
    cost 			INT,
    product_line 	VARCHAR(50),
    start_date 		DATE
);

CREATE TABLE gold.fact_sales (
    order_number 	VARCHAR(50),
    product_key 	INT,
    customer_key 	INT,
    order_date 		DATE,
    shipping_date 	DATE,
    due_date 		DATE,
    sales_amount 	INT,
    quantity 		SMALLINT, -- PostgreSQL uses SMALLINT for tinyint
    price 			INT
);


\copy bronze.crm_cust_info FROM 'datasets/source_crm/cust_info.csv' CSV HEADER;

-- Truncate the tables (if needed)
TRUNCATE TABLE gold.dim_customers;
TRUNCATE TABLE gold.dim_products;
TRUNCATE TABLE gold.fact_sales;

-- Wrote down in PSQL Tool
\copy gold.dim_customers FROM '/Users/omarwalid/Downloads/sql-data-analytics-project/datasets/csv-files/gold.dim_customers.csv' CSV HEADER;

-- Wrote down in PSQL Tool
\copy gold.dim_products FROM '/Users/omarwalid/Downloads/sql-data-analytics-project/datasets/csv-files/gold.dim_products.csv' CSV HEADER;

-- Wrote down in PSQL Tool
\copy gold.fact_sales FROM '/Users/omarwalid/Downloads/sql-data-analytics-project/datasets/csv-files/gold.fact_sales.csv' CSV HEADER;




SELECT * FROM gold.dim_customers
SELECT * FROM gold.dim_products
SELECT * FROM gold.fact_sales
