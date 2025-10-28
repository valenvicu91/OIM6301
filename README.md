\## ERD

The Babson Bean Café database models the café’s sales and loyalty system through seven entities: Customer, Product, Barista, Promotion, Order, Order\_Line\_Item, and Loyalty\_Transaction. Each Customer can place multiple Orders prepared by a Barista and optionally linked to a Promotion. An Order consists of one or more Order\_Line\_Items, each referencing a Product. The Loyalty\_Transaction table records customers’ point activities, which may or may not be tied to a specific order. This structure enables analysis of sales performance, promotional effectiveness, and customer loyalty, maintaining data integrity through one-to-many and junction relationships.



\## Data Generation

Sample datasets for each entity were generated using Mockaroo with realistic parameters. 

Parent entities (Customer, Product, Barista, Promotion) were created first, followed by child entities (Order, Order\_Line\_Item, Loyalty\_Transaction) using matching ID ranges to maintain foreign key consistency. 

Each file contains 20–300 rows and is stored in the `/seed/` folder in CSV format.

