# Retail Sales Analysis SQL Project

## Project Overview

Project Title: Retail Sales Analysis
Database: sql_project1

This project analyzes retail sales data using SQL. It focuses on data cleaning, exploration, and advanced business insights such as customer behavior, sales performance, category trends, and operational analysis.
By leveraging SQL queries, the project uncovers valuable patterns that can support marketing, operations, and revenue optimization strategies.

## Objectives

1. Perform data cleaning to ensure accuracy and consistency.
2. Explore sales data to understand volume, categories, and customer demographics.
3. Solve business-related questions using SQL (e.g., sales trends, customer loyalty, peak hours).
4. Apply advanced SQL techniques like window functions, CTEs, ranking, and aggregation.
5. Provide data-driven insights that help in decision-making for a retail business.

## Project Structure

1. Database Setup

• Data Creation: The project starts by creating a database named sql_project1.

```SQL
CREATE DATABASE sql_project1;
```

• Table Creation: A table named retail_sales is created to store the sales data. The structure includes:
  - Transaction details (transaction ID, sale date, sale time)
  - Customer demographics (customer ID, gender, age)
  - Product information (category, quantity sold, price per unit)
  - Sales metrics (cost of goods sold, total sale amount)

```SQL
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
```
• Initial Checks

```SQL
SELECT * FROM retail_sales
LIMIT 10;

SELECT COUNT(*) FROM retail_sales;
```

2. Data Cleaning

• Ensures the dataset is accurate and consistent before analysis.

Find NULL values in key columns:
```SQL
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
```

Remove rows with missing values:
```SQL
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
```

Validate calculation: total_sale = quantity * price_per_unit

```SQL
SELECT * FROM retail_sales
WHERE total_sale != quantity * price_per_unit;
```

3. Data Exploration

• Get a high-level understanding of the dataset.

How many sales do we have?
```SQL
SELECT COUNT(*) AS total_sales FROM retail_sales;
```

How many unique customers do we have?
```SQL
SELECT COUNT(DISTINCT customer_id) AS total_customers FROM retail_sales;
```

How many categories do we have?
```SQL
SELECT COUNT(DISTINCT category) AS total_categories FROM retail_sales;
```

4. Data Analysis & Insights

• Data Analysis & Business Key Problems & Answers


1. Write a SQL query to retrieve all columns from sales made on '2022-11-05'.

```SQL
SELECT * FROM retail_sales
WHERE sale_date = '2022-11-05';
```

2. Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 3 in the month of Nov-2022

```SQL
SELECT * FROM retail_sales
WHERE category = 'Clothing' AND TO_CHAR(sale_date, 'YYYY-MM') = '2022-11' AND quantity > 3;
```

3. Write a SQL query to calculate the total sales (total_sales) for each category.

```SQL
SELECT SUM(total_sale) AS total_sales, category FROM retail_sales
GROUP BY category;
```

4. Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.

```SQL
SELECT ROUND(AVG(age),2) AS avg_age FROM retail_sales
WHERE category = 'Beauty';
```

5. Write a SQL query to find all transactions where the total_sale is greater than 1000.

```SQL
SELECT * FROM retail_sales
WHERE total_sale > 1000;
```

6. Write a SQL query to find the total number of transactions made by each gender in each category.

```SQL
SELECT category, gender, COUNT(*) AS total_transaction FROM retail_sales
GROUP BY 1,2
ORDER BY 1;
```

7. Write a SQL query to calculate the average sale for each month. Find out best selling month in each year.
```SQL
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
```

8. Write a SQL query to find the top 5 customers based on the highest total sales

```SQL
SELECT customer_id, SUM(total_sale) AS high_sale FROM retail_sales
GROUP BY customer_id
ORDER BY high_sale DESC LIMIT 5; 
```

9. Write a SQL query to find the number of unique customers who purchased items from each category.

```SQL
SELECT category , COUNT(DISTINCT customer_id) AS unique_customers
FROM retail_sales
GROUP BY 1;
```

10. Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)

```SQL
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
```

## Customer Analysis
11. Find the top category each gender buys the most.

```SQL
WITH top_category AS
(
SELECT gender, category, SUM(quantity) AS total_qty,
	   RANK() OVER(PARTITION BY gender ORDER BY SUM(quantity) DESC) AS rnk	
FROM retail_sales
GROUP BY 1,2
)
SELECT gender, category, total_qty FROM top_category
WHERE rnk = 1;
```

12. Find repeat customers (those who made more than 5 purchases).

```SQL
SELECT customer_id, COUNT(*) AS total_orders
FROM retail_sales
GROUP BY 1
HAVING COUNT(*) >5;
```

13. Find the youngest and oldest customer in each category.

```SQL
SELECT category,
       MIN(age) AS youngest,
       MAX(age) AS oldest
FROM retail_sales
GROUP BY category;
```

## Sales & Revenue Insights
14. Find month-over-month sales growth.

```SQL
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
```

15. Find the most profitable category (highest average total_sale per transaction).

```SQL
SELECT category, AVG(total_sale) AS avg_sale 
FROM retail_sales
GROUP BY category
ORDER BY avg_sale DESC;
```

16. Find the busiest day of the week.

```SQL
SELECT TO_CHAR(sale_date, 'Day') AS weekday,
       COUNT(*) AS total_orders
FROM retail_sales
GROUP BY weekday
ORDER BY total_orders DESC;
```

## Operational Analysis
17. Find the peak shopping hour of the day.

```SQL
SELECT EXTRACT(HOUR FROM sale_time) AS hour,
	   COUNT(*) AS total_orders
FROM retail_sales
GROUP BY hour
ORDER BY total_orders DESC;
```

18. Identify top 5 customers with the highest average purchase value.

```SQL
SELECT customer_id, AVG(total_sale) AS avg_purchase
FROM retail_sales
GROUP BY customer_id
ORDER BY avg_purchase DESC
LIMIT 5;
```

19. Find the category with the highest contribution to overall revenue (% share).

```SQL
SELECT category, SUM(total_sale) AS revenue,
       ROUND((SUM(total_sale) * 100.0 / SUM(SUM(total_sale)) OVER()):: numeric, 2) AS revenue_share
FROM retail_sales
GROUP BY category
ORDER BY revenue_share DESC;
```

20. Find the favorite category of each customer.

```SQL
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
```

## Findings

• Data Quality:
- Some transactions had missing or inconsistent values, which were removed during the cleaning process.
- A few records had mismatched total_sale != quantity * price_per_unit, indicating errors in raw data entry.

• Sales Insights:
- Clothing and Electronics generated the highest total sales.
- Certain months (e.g., festive seasons) consistently showed peak sales volumes.
- Revenue share was not evenly distributed—one or two categories dominated.

• Customer Behavior:
- A small group of customers contributed disproportionately to total revenue (high-value customers).
- Repeat customers (more than 5 purchases) formed a loyal base.
- Gender-based analysis showed distinct category preferences.

• Operational Patterns:
- Peak shopping hours were in the afternoon and evening.
- Weekends recorded higher transaction volumes compared to weekdays.

## Reports

• Sales Reports:
-Total sales by category, month, and year.
-Month-over-month sales growth.
-Revenue contribution of each category.

• Customer Reports:
-Top 5 customers by sales.
-Loyal customers (repeat buyers).
-Average purchase value per customer.
-Favorite categories by gender.

• Operational Reports:
-Peak shopping hours and busiest days.
-Shift-wise sales distribution (Morning, Afternoon, Evening).

## Conclusion

• SQL can be effectively used to clean, explore, and analyze retail sales data.
• The analysis highlighted key drivers of sales performance, including top categories, loyal customers, and seasonal trends.
• Actionable insights such as identifying peak shopping hours, high-value customers, and underperforming categories can guide marketing campaigns and inventory management.
• With additional tools like Tableau, Power BI, or Python, these findings can be turned into interactive dashboards and predictive models for future sales forecasting.

## Tech Stack
- SQL (PostgreSQL)
- Data Analysis (Window Functions, CTEs, Aggregations)
- GitHub for version control

## How to Run
1. Clone this repo
2. Create database using: CREATE DATABASE sql_project1;
3. Create table with provided schema
4. Insert sample data
5. Run queries step by step for analysis

## Author - Bhavesh Vadnere
IT Engineering Student @ SCOE Pune | Data Enthusiast | SQL & Data Analytics Learner  
Open to Internships & Projects in Data Analytics, SQL, and Business Intelligence

## Stay connected
• Email: bhaveshvadnere8888@gmail.com
• LinkedIn: https://www.linkedin.com/in/bhavesh-vadnere
• GitHub: https://github.com/BhaveshV23

## END of project
