**Scenario Choice and Rationale**



For this project, I chose to model a database for the Babson Bean Café, a fictional coffee shop that sells drinks, pastries, and snacks. The goal was to create a system that helps the café manage sales, promotions, and customer loyalty. I wanted a scenario that felt realistic and easy to connect to daily operations, so I could clearly see how data flows from customers and baristas to orders and products.



This scenario also reflects a small business setting where data-driven decisions can make a big impact—such as identifying best-selling products, understanding customer behavior, and rewarding loyal buyers.



**ERD (Entity Relationship Diagram)**



<i>The database includes seven entities connected through logical relationships:</i>



Customer: stores customer details and loyalty points.

Barista: employees who prepare the orders.

Product: menu items with price and cost information.

Promotion: discount or coupon codes applied to orders.

Order: each transaction linking customer, barista, and (optional) promotion.

Order\_Line\_Item: junction table connecting orders and products (resolves M:N relationship).

Loyalty\_Transaction: records when customers earn or redeem loyalty points.



*Each relationship follows proper cardinality rules:*



* One customer can have many orders and loyalty transactions.
* One order can have many line items, but each line item belongs to one order.
* One product can appear in many orders through the line item table.
* One barista can prepare many orders.
* Promotions can apply to multiple orders.



**Database Design Assumptions and Decisions**



Primary Keys: Every table uses an integer primary key (e.g., customer\_id, order\_id).

Foreign Keys: Proper constraints enforce referential integrity (e.g., Order.customer\_id → Customer.customer\_id).

Order\_Line\_Item: Serves as the bridge table between Order and Product, including fields like quantity, unit\_price, and unit\_cost.

Loyalty\_Transaction: Tracks points earned and redeemed, referencing both Customer and optionally Order.

Date Fields: Stored as TEXT in YYYY-MM-DD format for SQLite compatibility.

Points and Prices: Represented as REAL to handle decimals.



**Data Generation Process**

Data was generated using Mockaroo to simulate realistic café operations.

Each table includes the following number of rows:



Table	                Rows	         Purpose

Customer                50	         Base of active customers

Barista	                10	         Employees preparing orders

Product	                25	         Menu items

Promotion               10	         Active and expired campaigns

Order	                100	         Individual transactions

Order\_Line\_Item	        300	         Multiple products per order

Loyalty\_Transaction	200	         Points earned/redeemed per customer



After generating the data, each CSV was imported into DBeaver in the following order to respect foreign key dependencies:



1. Customer
2. Barista
3. Product
4. Promotion
5. Order
6. Order\_Line\_Item
7. Loyalty\_Transaction



All imports were verified using: SELECT COUNT(\*) FROM TableName;

to confirm the expected number of rows.



**Steps Followed**

Phase 1: ERD Design



Created entities and relationships based on the café operations.

Defined cardinalities (1–M and M:N)



Phase 2: Schema Creation

Wrote CREATE TABLE statements with primary and foreign keys.

Set PRAGMA foreign\_keys = ON; at the top of schema.sql.



Phase 3: Data Generation and Import

Used Mockaroo to create data with matching keys and realistic values.

Imported data in parent -> child order using DBeaver.



Phase 4: Business Analysis (SQL Queries)

Developed 8 queries addressing real business questions:



* Best-selling products
* High-value customers
* Product margins
* Loyalty re-engagement
* Payment method distribution
* Basket size by order channel
* Barista performance leaderboard
* Promotion effectiveness
* Each query included a clear comment block and a practical business use case.



**Screenshots were saved in the evidence folder**

ERD Diagram

Table imports with row counts

Query outputs (at least one per query type)

