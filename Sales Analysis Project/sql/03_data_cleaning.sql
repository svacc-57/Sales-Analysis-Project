--Cleaning Process 1/3
--Starting off with the Orders table, I'll check if there are any negative variables as negative values are common to see.
SELECT * FROM orders WHERE quantity < 0;
SELECT * FROM orders WHERE discount < 0;
SELECT * FROM orders WHERE sales < 0;
--With these queries, I found that only quantity column has negative values. To clean this, I will update the quantity column to be the absolute value of the current quantity. This will ensure that all quantities are positive.
UPDATE orders SET quantity = ABS(quantity) WHERE quantity < 0;

--Next, I have to fix the missing variables in the sales column. When looking over the information, I found that the sales column has several missing values. The following query is used:
SELECT order_id, product_id, quantity, discount, sales FROM orders WHERE sales IS NULL;
--However, if we can use the following query to find all possible NULL variables in the orders table:
SELECT * FROM orders WHERE order_id IS NULL OR customer_id IS NULL OR product_id IS NULL OR quantity IS NULL OR discount IS NULL OR sales IS NULL OR profit IS NULL OR order_date IS NULL OR ship_date IS NULL OR ship_mode IS NULL;
--Now that we found all the NULL variables and their associated rows, we have to calculate the sales amount. This can be accomplished by joining the product table information and the orders table information. The sales amount can be calculated by multiplying the quantity by the unit price and then applying the discount. The formula for calculating the sales amount is as follows: Sales Amount = Quantity * Unit Price * (1 - Discount) (Note: we rounded to 2 decimal places). The following query will update the sales column with the calculated sales amount for all rows that have NULL values in the sales column.
UPDATE orders
JOIN products ON orders.product_id = products.product_id
SET orders.sales = ROUND(orders.quantity * products.unit_price * (1 - orders.discount), 2)
WHERE orders.sales IS NULL;

--With order_date column originally having MM/DD/YYYY format, we had to create the column order_date as a VARCHAR data type. But now we need to convert M/D/YYYY to YYYY/MM/DD format and change VARCHAR to DATE. Due to MySQL settings, if we originally would have craeted the column as DATE and tried to insert "3/9/2024', it would have failed. The following queries will convert the order_date column to the correct format and change the data type to DATE.
UPDATE orders SET order_date = STR_TO_DATE(order_date, '%m/%d/%Y');
ALTER TABLE orders MODIFY order_date DATE;

--Final step needed in this cleaning is checking for duplicate variables In this orders tables duplicates found in order_id raise a concern, however customer_id are expected to repeat since multiple customers can place multiple orders, produts and ship mode as well are others that can repeat. To check for duplicates especially under order_Id, we can use the following query:
SELECT order_id, COUNT(*) AS times_seen
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;
--With this query, we found that there are duplicate order_id values. Total rows before removing duplicates: 2201. To remove the duplicates, we can use the following query:
--Initially, I used a query to delete the duplicates, but the query technically worked but it said that 0 rows were affected. To fix this, I had to add a new column (row_id) with an auto incrementing primary key to the orders table. This allowed me to delete the duplicates based on the row_id column. The following queries will add the new column and delete the duplicates.
ALTER TABLE orders ADD COLUMN row_id INT AUTO_INCREMENT PRIMARY KEY;
--This gives every row a unique identifier. We can proceed with the deletion of the duplicates. The following query will delete the duplicates based on the row_id column.
DELETE o1 FROM orders o1
INNER JOIN orders o2
    ON o1.order_id = o2.order_id
   AND o1.customer_id = o2.customer_id
   AND o1.product_id = o2.product_id
   AND o1.quantity = o2.quantity
   AND o1.discount = o2.discount
   AND o1.sales = o2.sales
   AND o1.profit = o2.profit
   AND o1.ship_date = o2.ship_date
   AND o1.ship_mode = o2.ship_mode
WHERE o1.row_id > o2.row_id;
--After the removal, we're left with 2001 rows in the orders table. The cleaning process for the orders table is now complete.


--Cleaning Process 2/3
--Second table to check for potential cleaning will be the customers table. We'll start off by locating possible duplicate customer_id values. The following query will check for duplicates in the customer_id column:
SELECT customer_id, COUNT(*) AS times_seen  
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;
--When reviewing potential other duplicate candidates, segment,region,city and signup_date are all able to have duplicate results. However, customer_id should be unique. As for customer_name, there is a possibility that two customers have the same name. For an effective cleaning process, im going to check for any possibl duplicate customer_name values, and if there are duplicates, im going to compare them to eachother to verify if they are the same customer or not(by looking at the segment,region,state,etc). The following query will check for duplicates in the customer_name column:
SELECT customer_name, COUNT(*) AS times_seen
FROM customers
GROUP BY customer_name
HAVING COUNT(*) > 1;

--After the query, no duplicate customer_id were found and no duplicate customer_name were found. Next, we will check for any NULL values in the customers table. The following query will check for NULL values in all columns of the customers table:
SELECT * FROM customers WHERE customer_id IS NULL OR customer_name IS NULL OR segment IS NULL OR city IS NULL OR state IS NULL OR signup_date IS NULL;

--Next step is to try to find any empty strings in the customers table. The following query will check for empty strings in all columns of the customers table:
SELECT * FROM customers WHERE customer_id = '' OR customer_name = '' OR segment = '' OR city = '' OR state = '' OR signup_date = '';
--We've identified that there are 8 empty strings all found under city. The rest of the columns are filled with information. Since we know that there are no other duplicate names, we cant observe those possible entries and see if the missing information is there. In this case, we can fill the empty strings with NULL values. The following query will update the empty strings in the city column to NULL values:
UPDATE customers SET city = NULL WHERE city = '';   
--This recent step counteracts the previous step of checking for NULL values, however due to the situation, having NULL values in the missing city strings is better than having empty strings.

--Since are fields of segment, region and state are all categorical variables, we can check for any possible misspellings in these columns. The following queries will check for any possible misspellings in the segment, region and state columns:
SELECT DISTINCT segment FROM customers;
SELECT DISTINCT region FROM customers;
SELECT DISTINCT state FROM customers;   

--signup_date is in proper order therefore no cleaning is needed. The cleaning process for the customers table is now complete.


--Cleaning Process 3/3
--The final table to check for cleaning will be the products table. We'll start off by locating possible duplicate product_id values. The following query will check for duplicates in the product_id column:
SELECT product_id, COUNT(*) AS times_seen  
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;    
--Note:Only product_id was checked for duplicates since product_name, category, sub_category, unit_cost and unit_price are all able to have duplicate results. However, product_id should be unique.

--After the query, no duplicate product_id were found. Next, we will check for any NULL values in the products table. The following query will check for NULL values in all columns of the products table:
SELECT * FROM products WHERE product_id IS NULL OR product_name IS NULL OR category IS NULL OR sub_category IS NULL OR unit_cost IS NULL OR unit_price IS NULL;
--No null values were found.

--Next step is to try to find any empty strings in the products table. The following query will check for empty strings in all columns of the products table:
SELECT * FROM products WHERE product_id = '' OR product_name = '' OR category = '' OR sub_category = '' OR unit_cost = '' OR unit_price = '';
--No empty strings were found.

--Next we will check for spelling inconsistencies in the product_name, category and sub_category columns. The following queries will check for any possible misspellings in the category and sub_category columns:
SELECT DISTINCT product_name FROM products;
SELECT DISTINCT category FROM products;
SELECT DISTINCT sub_category FROM products;
--All spelling is consistent and no corrections are needed.

--Final step will be to check for any negative values in the unit_cost and unit_price columns. The following queries will check for any negative values in the unit_cost and unit_price columns:
SELECT * FROM products WHERE unit_cost < 0;
SELECT * FROM products WHERE unit_price < 0;
--No negative values were found.


--This concludes the SQL cleaning process for the three tables. 
--Note: Due to the small size of this dataset, I've also done a manual review in addition to SQL queries to confirm that there are no empty strings, NULL values, duplicate records or any spelling inconsistences.