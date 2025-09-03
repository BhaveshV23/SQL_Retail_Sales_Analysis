-- SQL Retail Sales Analysis - P1

-- Create Table
CREATE TABLE retail_sales
(
	transaction_id INT PRIMARY KEY,
	sale_date DATE,
	sale_time TIME,
	customer_id INT,
	gender VARCHAR(15),
	age INT,
	category VARCHAR(20),
	quantity INT,
	price_per_unit FLOAT,
	cogs FLOAT,
	total_sale FLOAT
);


SELECT * FROM retail_sales
LIMIT 10;

SELECT COUNT(*) FROM retail_sales;


-- Data Cleaning
SELECT * FROM retail_sales
WHERE transaction_id IS NULL;

SELECT * FROM retail_sales
WHERE sale_date IS NULL;

SELECT * FROM retail_sales
WHERE sale_time IS NULL;


SELECT * FROM retail_sales
WHERE 
	transaction_id IS NULL
	OR
	sale_date IS NULL
	OR
	sale_time IS NULL
	OR
	customer_id IS NULL
	OR
	quantity IS NULL
	OR
	gender IS NULL
	OR
	price_per_unit IS NULL
	OR
	cogs IS NULL
	OR
	total_sale IS NULL;

--
DELETE FROM retail_sales
WHERE 
	transaction_id IS NULL
	OR
	sale_date IS NULL
	OR
	sale_time IS NULL
	OR
	customer_id IS NULL
	OR
	quantity IS NULL
	OR
	gender IS NULL
	OR
	price_per_unit IS NULL
	OR
	cogs IS NULL
	OR
	total_sale IS NULL;

--
SELECT * FROM retail_sales
WHERE total_sale != quantity * price_per_unit;


-- Data Exploration

-- How many sales we have?
SELECT COUNT(*) AS total_sales FROM retail_sales;

-- How many unique customers we have?
SELECT COUNT(DISTINCT customer_id) AS total_customers FROM retail_sales;

-- How many categories we have?
SELECT DISTINCT category AS total_categories FROM retail_sales;


-- Data Analysis & Business Key Problems & Answers

--Q.1 Write a SQL query to retrieve all columns from sales made on '2022-11-05'.

SELECT * FROM retail_sales
WHERE sale_date = '2022-11-05';

--Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 3 in the month of Nov-2022

SELECT * FROM retail_sales
WHERE category = 'Clothing' AND TO_CHAR(sale_date, 'YYYY-MM') = '2022-11' AND quantity > 3;

--Q.3 Write a SQL query every to calculate the total sales (total_sales) for each category.

SELECT SUM(total_sale) AS total_sales, category FROM retail_sales
GROUP BY category;

--Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.

SELECT ROUND(AVG(age),2) AS avg_age FROM retail_sales
WHERE category = 'Beauty';

--Q.5 Write a SQL query to find all transactions where the total_sale is greater then 1000.

SELECT * FROM retail_sales
WHERE total_sale > 1000;

--Q.6 Write a SQL query to find the total number of transaction (transaction_id) made by each gender in each category.
SELECT category, gender, COUNT(*) AS total_transaction FROM retail_sales
GROUP BY 1,2
ORDER BY 1;

--Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year.

SELECT year, month, avg_sale
FROM
(
	SELECT 
		EXTRACT(YEAR FROM sale_date) AS year,
		EXTRACT(MONTH FROM sale_date) AS month,
		AVG(total_sale) AS avg_sale ,
		RANK() OVER(PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY AVG(total_sale) DESC) AS rank
	FROM retail_sales
	GROUP BY 1,2
) AS t1
WHERE rank = 1;

--Q.8 Write a SQL query to find the top 5 customers based on the highest total sales

SELECT customer_id, SUM(total_sale) AS high_sale FROM retail_sales
GROUP BY customer_id
ORDER BY high_sale DESC LIMIT 5; 

--Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.

SELECT category , COUNT(DISTINCT customer_id) AS unique_customers
FROM retail_sales
GROUP BY 1;

--Q.10 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12& 17, Evening >17)

WITH hourly_sale AS
(
	SELECT *,
		CASE
			WHEN EXTRACT(HOUR FROM sale_time) <12 THEN 'Morning'
			WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
			ELSE 'Evening'
		END AS shift
	FROM retail_sales
)
SELECT shift,COUNT(*) AS total_orders 
FROM hourly_sale
GROUP BY shift;

--Customer Analysis
--Q.11 Find the top category each gender buys the most.

WITH top_category AS
(
SELECT gender, category, SUM(quantity) AS total_qty,
	   RANK() OVER(PARTITION BY gender ORDER BY SUM(quantity) DESC) AS rnk	
FROM retail_sales
GROUP BY 1,2
)
SELECT gender, category, total_qty FROM top_category
WHERE rnk = 1;

--Q.12 Find repeat customers (those who made more than 5 purchases).

SELECT customer_id, COUNT(*) AS total_orders
FROM retail_sales
GROUP BY 1
HAVING COUNT(*) >5;

--Q.13 Find the youngest and oldest customer in each category.

SELECT category,
       MIN(age) AS youngest,
       MAX(age) AS oldest
FROM retail_sales
GROUP BY category;

--Sales & Revenue Insights
--Q.14 Find month-over-month sales growth.

WITH sales_growth AS 
(
SELECT TO_CHAR(sale_date, 'YYYY-MM') AS month,
	   SUM(total_sale) AS monthly_sales,
	   LAG(SUM(total_sale)) OVER(ORDER BY TO_CHAR(sale_date, 'YYYY-MM')) AS prev_month
FROM retail_sales
GROUP BY month
)
SELECT month, monthly_sales, prev_month,
	   ((monthly_sales - prev_month)/ NULLIF(prev_month,0))*100 AS growth_percent
FROM sales_growth
ORDER BY month;

--Q.15 Find the most profitable category (highest average total_sale per transaction).

SELECT category, AVG(total_sale) AS avg_sale 
FROM retail_sales
GROUP BY category
ORDER BY avg_sale DESC;

--Q.16 Find the busiest day of the week.

SELECT TO_CHAR(sale_date, 'Day') AS weekday,
       COUNT(*) AS total_orders
FROM retail_sales
GROUP BY weekday
ORDER BY total_orders DESC;

--Operational Analysis
--Q.17 Find the peak shopping hour of the day.

SELECT EXTRACT(HOUR FROM sale_time) AS hour,
	   COUNT(*) AS total_orders
FROM retail_sales
GROUP BY hour
ORDER BY total_orders DESC;

--Q.18 Identify top 5 customers with the highest average purchase value.

SELECT customer_id, AVG(total_sale) AS avg_purchase
FROM retail_sales
GROUP BY customer_id
ORDER BY avg_purchase DESC
LIMIT 5;

--Q.19 Find the category with the highest contribution to overall revenue (% share).


SELECT category, SUM(total_sale) AS revenue,
       ROUND((SUM(total_sale) * 100.0 / SUM(SUM(total_sale)) OVER()):: numeric, 2) AS revenue_share
FROM retail_sales
GROUP BY category
ORDER BY revenue_share DESC;

--Q.20 Find the favorite category of each customer.

WITH customer_category_sales AS (
    SELECT 
        customer_id,
        category,
        SUM(total_sale) AS category_sales,
        RANK() OVER (PARTITION BY customer_id ORDER BY SUM(total_sale) DESC) AS rnk
    FROM retail_sales
    GROUP BY customer_id, category
)
SELECT customer_id, category, category_sales
FROM customer_category_sales
WHERE rnk = 1
ORDER BY customer_id, category_sales DESC;


--END of project
