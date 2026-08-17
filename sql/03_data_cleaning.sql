--Cleaning Process
--Starting off with the Orders table, I'll check if there are any negative variables as negative values are common to see.
SELECT * FROM orders WHERE quantity < 0;
SELECT * FROM orders WHERE discount < 0;
SELECT * FROM orders WHERE sales < 0;
--With these queries, I found that only quantity column has negative values. To clean this, I will update the quantity column to be the absolute value of the current quantity. This will ensure that all quantities are positive.
UPDATE orders SET quantity = ABS(quantity) WHERE quantity < 0;

--Next, I have to fix the missing variables in the sales column. When looking over the information, I found that the sales column has several missing values. To identify all the rows associated with the missing values, the following query is used:
SELECT order_id, product_id, quantity, discount, sales FROM orders WHERE sales IS NULL;
--Now that we found all the NULL variables and their associated rows, we have to calculate the sales amount. This can be accomplished by joining the product table information and the orders table information. The sales amount can be calculated by multiplying the quantity by the unit price and then applying the discount. The formula for calculating the sales amount is as follows: Sales Amount = Quantity * Unit Price * (1 - Discount) (Note: we rounded to 2 decimal places). The following query will update the sales column with the calculated sales amount for all rows that have NULL values in the sales column.
UPDATE orders
JOIN products ON orders.product_id = products.product_id
SET orders.sales = ROUND(orders.quantity * products.unit_price * (1 - orders.discount), 2)
WHERE orders.sales IS NULL;

--With order_date column originally having MM/DD/YYYY format, we had to create the column order_date as a VARCHAR data type. But now we need to convert M/D/YYYY to YYYY/MM/DD format and change VARCHAR to DATE. Due to MySQL settings, if we originally would have craeted the column as DATE and tried to insert "3/9/2024', it would have failed. The following queries will convert the order_date column to the correct format and change the data type to DATE.
UPDATE orders SET order_date = STR_TO_DATE(order_date, '%m/%d/%Y');
ALTER TABLE orders MODIFY order_date DATE;

--Final step needed in this cleaning is checking for duplicate variables. To check for duplicates, we can use the following query:
SELECT order_id, COUNT(*) AS times_seen
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;
--With this query, we found that there are duplicate order_id values. Total rows before removing duplicates: 2201. After removal should be 2001. To remove the duplicates, we can use the following query:
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