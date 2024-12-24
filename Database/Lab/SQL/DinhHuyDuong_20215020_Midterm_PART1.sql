--1. Provide a list of female customers whose income is at least 10000
SELECT CUSTOMERID,
	FIRSTNAME,
	LASTNAME
FROM CUSTOMERS
WHERE GENDER = 'F'
	AND INCOME > 10000;

--2. The average income of the customers who purchased the product titled 
-- “AIRPORT ROBBERS”.

SELECT AVG(CUSTOMERS.INCOME) AS AVERAGE_INCOME
FROM CUSTOMERS
JOIN ORDERS USING (CUSTOMERID)
JOIN ORDERLINES USING (ORDERID)
JOIN PRODUCTS USING (PROD_ID)
WHERE TITLE = 'AIRPORT ROBBERS'
GROUP BY (TITLE);

--3. Display the maximum, minimum and average price of the products in the 
-- store.
SELECT MAX(PRICE),
	MIN(PRICE),
	AVG(PRICE)
FROM PRODUCTS
GROUP BY (PROD_ID);

--4. List of products that have been ordered by the current date

SELECT DISTINCT PROD_ID, TITLE
FROM PRODUCTS
JOIN ORDERLINES USING (PROD_ID)
WHERE EXTRACT (YEAR FROM ORDERDATE) = EXTRACT (YEAR FROM CURRENT_DATE)
AND EXTRACT (MONTH FROM ORDERDATE) = EXTRACT (MONTH FROM CURRENT_DATE)
AND EXTRACT (DAY FROM ORDERDATE) = EXTRACT (DAY FROM CURRENT_DATE);

--5. Display a list of the most expensive products that have been purchased by 
-- a male customer.
SELECT PROD_ID,TITLE
FROM PRODUCTS
JOIN ORDERLINES USING (PROD_ID)
JOIN ORDERS USING (ORDERID)
JOIN CUSTOMERS USING (CUSTOMERID)
WHERE GENDER = 'M'
GROUP BY (PRICE,PROD_ID)
ORDER BY PRICE DESC
LIMIT 10;

-- 6.Give a list of the country names,  their number of customers who have 
-- purchased at least 2 times 
SELECT COUNTRY, COUNT(DISTINCT CUSTOMERID)
FROM CUSTOMERS
JOIN ORDERS USING (CUSTOMERID)
GROUP BY COUNTRY
HAVING COUNT(DISTINCT ORDERS.ORDERID) >= 2

--7.Please indicate the number of orders that each customer has ordered. The 
--list must contain customer ID, customer fullname, number of orders. Sort in 
--descending order of the number of orders
SELECT CUSTOMERS.CUSTOMERID, CUSTOMERS.FIRSTNAME || ' ' || CUSTOMERS.LASTNAME AS FULLNAME, COUNT(ORDERS.ORDERID) AS NUMBER_OF_ORDERS
FROM CUSTOMERS
LEFT JOIN ORDERS ON CUSTOMERS.CUSTOMERID = ORDERS.CUSTOMERID
GROUP BY CUSTOMERS.CUSTOMERID, FULLNAME
ORDER BY NUMBER_OF_ORDERS DESC;

--8.Show detailed information of products in the latest order: orderlineid, 
--prod_id, product title, quantity, unit price (with currency unit), amount 
--(with currency unit)

SELECT ORDERLINES.ORDERLINEID,
	ORDERLINES.PROD_ID,
	PRODUCTS.TITLE AS PRODUCT_TITLE,
	ORDERLINES.QUANTITY,
	PRODUCTS.PRICE AS UNIT_PRICE,
	(ORDERLINES.QUANTITY * PRODUCTS.PRICE) AS AMOUNT
FROM ORDERLINES
JOIN PRODUCTS USING (PROD_ID)
JOIN
	(SELECT MAX(ORDERDATE) AS LATEST_ORDERDATE
		FROM ORDERS) LATEST_ORDER ON ORDERLINES.ORDERDATE = LATEST_ORDER.LATEST_ORDERDATE;

--9.Please list the orders in which both products are ordered titled 
--“ADAPTATION SECRETS” and “AFFAIR GENTLEMENT”
SELECT PROD_ID, ORDERDATE
FROM PRODUCTS
JOIN ORDERLINES USING (PROD_ID)
WHERE LOWER(TITLE) = 'ADAPTATION SECRETS' 

INTERSECT

SELECT PROD_ID, ORDERDATE
FROM PRODUCTS
JOIN ORDERLINES USING (PROD_ID) 
WHERE LOWER(TITLE) = 'AFFAIR GENTLEMENT'

--10. Display top 10 best-revenue products (the best- revenue products mean 
-- that the products give the highest revenue; revenu = quantity * price).
SELECT TITLE,(QUANTITY * PRICE) AS REVENUE
FROM ORDERLINES
JOIN PRODUCTS USING (PROD_ID)
GROUP BY TITLE, quantity, price
ORDER BY REVENUE DESC
LIMIT 10;

--11.Give a list of customers who have never ordered any product in December 
-- 2004.
SELECT customers.customerid, firstname || ' ' || lastname AS fullname
FROM customers
EXCEPT
SELECT customers.customerid, firstname || ' ' || lastname AS fullname
FROM customers
JOIN orders ON customers.customerid = orders.customerid
WHERE date_part('year', orders.orderdate) = 2004
AND date_part('month', orders.orderdate) = 12
ORDER BY customerid;


--12. Add a new column “amount” (number) into the table “orderlines” to store the amount paid for the corresponding product in this order. Write a SQL statement to update the correct value for this columns.