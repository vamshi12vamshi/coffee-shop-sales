use coffee;
ALTER TABLE coffee-shop-sales-revenue TO cofee_sales;

SELECT COUNT(*) FROM coffee_sales;

DROP TABLE Transactions;
-- Divide the Table into Transaction,Product,store tables
CREATE TABLE Transactions (
    transaction_id INT,
    transaction_date TEXT,
    -- transaction_time TEXT,
    store_id INT,
    product_id INT,
    Revenue DOUBLE,
    time TIME,
    PRIMARY KEY (transaction_id)
);

CREATE TABLE Products (
    product_id INT,
    product_category TEXT,
    product_type TEXT,
    product_detail TEXT,
    unit_price DOUBLE,
    PRIMARY KEY (product_id)
);

-- Populate Transactions table
INSERT INTO Transactions (transaction_id, transaction_date,  store_id, product_id, Revenue, time)
SELECT transaction_id, transaction_date,  store_id, product_id, unit_price * transaction_qty AS Revenue, TIME(transaction_time) AS time
FROM coffee_sales;

-- Populate Products table
INSERT IGNORE INTO Products (product_id, product_category, product_type, product_detail, unit_price)
SELECT DISTINCT product_id, product_category, product_type, product_detail, unit_price
FROM coffee_sales;


SELECT COUNT(*) FROM transactions;
SELECT COUNT(*) FROM Products;
SELECT COUNT(*) FROM store;


-- 1 Find the average unit price of products.
SELECT
     ROUND(AVG(products.unit_price),2) AS avg_unit_price
FROM
    products;  
#store wise
-- 2 Identify the store location with the highest total revenue.
SELECT
   store.store_location
   , SUM(transactions.Revenue) AS Total_revenue
FROM 
    store
LEFT JOIN 
	transactions
ON   
    store.store_id=transactions.store_id
GROUP BY 
    store.store_location
ORDER BY
    Total_revenue DESC;
    
    
    
#product wise
-- 3.List the   best-selling product categories along with their total revenue.
SELECT 
   products.product_category,
   ROUND(SUM(transactions.Revenue),2) AS Total_revenue
FROM
    products
LEFT JOIN 
     transactions
ON
	products.product_id=transactions.product_id
GROUP BY
    products.product_category
ORDER BY
	Total_revenue DESC;

-- 4. Determine the average transaction revenue for each store location.
SELECT
    store.store_location,
    Round(AVG(transactions.Revenue),2) AS avg_revenue
FROM 
   transactions
RIGHT JOIN
    store
ON
   transactions.store_id=store.store_id
GROUP BY
  store.store_location
ORDER BY
   avg_revenue DESC;

-- 5.Find the day of the week with the highest average revenue.
SELECT 
     DAYNAME(transactions.transaction_date) AS day_name,
    DAYOFWEEK(transactions.transaction_date) AS Day_Of_Week,
    ROUND(AVG(transactions.Revenue),2) AS avg_revenue
FROM  
   transactions
GROUP BY 
   Day_Of_Week,
   day_name
ORDER BY 
   avg_revenue DESC;
   
# 6.analyze the sales per each hour
SELECT 
      HOUR(transactions.time) AS hour_Sales,
      COUNT(transactions.transaction_id) AS count_of_transactions
FROM 
      transactions
GROUP BY
     hour_Sales
ORDER BY 
     count_of_transactions DESC;
     
#7 Analyse the daily trends of sales
SELECT 
   DAYNAME(transactions.transaction_date) AS day_name,
   COUNT(transactions.transaction_id) AS count_of_transactiosn
FROM
   transactions
GROUP BY 
   day_name
ORDER BY  
    count_of_transactiosn DESC;
    
-- 7 Calculate the total revenue generated for each month.
SELECT 
    MONTHNAME(transaction_date) AS month_name,
	ROUND(SUM(transactions.Revenue),2) AS total_revenue
FROM 
    transactions
GROUP BY 
   month_name
ORDER BY  
   total_revenue DESC;

# find out the top3 best selling product categories in each store
	WITH cte AS(
	SELECT 
		store.store_location,
		products.product_category,
		COUNT(transactions.transaction_id) AS num_transactions,
		DENSE_RANK() OVER(PARTITION BY store.store_location ORDER BY COUNT(transactions.transaction_id)DESC) AS rn
	FROM 
		transactions
	INNER JOIN
		 products
	ON  
	  transactions.product_id=products.product_id
	INNER JOIN 
	   store
	ON 
	   transactions.store_id=store.store_id
	GROUP BY 
	   store.store_location,
	   products.product_category
	ORDER BY 
	   num_transactions DESC)
	SELECT 
		store_location,
		product_category,
		 num_transactions
	FROM 
	   cte
	WHERE
	   rn<=3;
# Find out the top 5 best selling products of all times
SELECT 
    products.product_category,
    products.product_detail,
    COUNT(transactions.transaction_id) AS no_of_transactions
FROM 
    products
LEFT JOIN
    transactions
ON
     products.product_id=transactions.product_id
GROUP BY 
    products.product_category,
    products.product_detail
ORDER BY 
    no_of_transactions DESC
LIMIT 5;


#Are there any product that has performed low  and need to be reevaluated
SELECT 
    products.product_category,
    products.product_detail,
    COUNT(transactions.transaction_id) AS no_of_transactions
FROM 
    products
LEFT JOIN
    transactions
ON
     products.product_id=transactions.product_id
GROUP BY 
    products.product_category,
    products.product_detail
ORDER BY 
    no_of_transactions ASC
LIMIT 5;


#product witl low sales that increase there business on there products
SELECT 
    products.product_category,
    products.product_detail,
    COUNT(transactions.transaction_id) AS no_of_transactions
FROM 
    products
LEFT JOIN
    transactions
ON
     products.product_id=transactions.product_id
GROUP BY 
    products.product_category,
    products.product_detail
ORDER BY 
    no_of_transactions ASC
LIMIT 5;

#Business Growth Analysis
#Creating view for storing monthly_level valus

CREATE VIEW revenue AS 
(SELECT 
    MONTHNAME(transactions.transaction_date) AS month_name,
    ROUND(SUM(transactions.Revenue)) AS Total_rev
FROM 
   transactions
GROUP BY month_name);


WITH avg_growth AS(
WITH cte AS(
SELECT 
    Total_rev AS curr_rev,
    LEAD(Total_rev) OVER(
    ORDER BY field(month_name,'january','febraury','march','april','may','june')) AS next_rev
FROM
    revenue)
SELECT 
  (next_rev-curr_rev)/(curr_rev)*100 AS growth_rate
FROM 
   cte)
SELECT 
   ROUND(AVG(growth_rate),2) AS avg_growth_rate
FROM
   avg_growth;
    
    
SELECT 
      month_name,
    Total_rev AS curr_rev,
    LEAD(Total_rev) OVER(
    ORDER BY field(month_name,'january','febraury','march','april','may','june')) AS next_rev
FROM
    revenue;
    
    
    
    
    





   

     




