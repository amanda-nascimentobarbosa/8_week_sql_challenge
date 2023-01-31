### B. Data Analysis Questions

**1. How many customers has Foodie-Fi ever had?**
```SQL
SELECT
	COUNT(DISTINCT customer_id) AS number_customers
FROM subscriptions
```
**Result**

| number_customers |
|------------------|
| 1000             |

**2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value**
```SQL
SELECT 
	COUNT(customer_id) AS total_customers,
	MONTH(start_date) AS start_month
FROM subscriptions s
LEFT JOIN plans p
	ON s.plan_id = p.plan_id
WHERE s.plan_id = 0
GROUP BY MONTH(start_date)
ORDER BY MONTH(start_date)
```
**Result**

| total_customers | start_month |
|-----------------|-------------|
| 88              | 1           |
| 68              | 2           |
| 94              | 3           |
| 81              | 4           |
| 88              | 5           |
| 79              | 6           |
| 89              | 7           |
| 88              | 8           |
| 87              | 9           |
| 79              | 10          |
| 75              | 11          |
| 84              | 12          |

**3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name**
```SQL
SELECT 
	plan_name,
	COUNT(plan_name) AS total
FROM subscriptions s
LEFT JOIN plans p
	ON s.plan_id = p.plan_id
WHERE YEAR(start_date) > 2020
GROUP BY plan_name
ORDER BY total
```
**Result**

| plan_name     | total |
|---------------|-------|
| basic monthly | 8     |
| pro monthly   | 60    |
| pro annual    | 63    |
| churn         | 71    |

**4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?**
```SQL
DECLARE @total_custumers FLOAT = (SELECT COUNT(DISTINCT customer_id) FROM subscriptions)

SELECT
	plan_name,
  COUNT(customer_id) as customers_churned,
  (COUNT(customer_id) / @total_custumers) * 100 as churned_perct
FROM subscriptions s
LEFT JOIN plans p
	ON s.plan_id = p.plan_id
WHERE s.plan_id = 4
GROUP BY plan_name
```
**Result**

| plan_name | customers_churned | churned_perct |
|-----------|-------------------|---------------|
| churn     | 307               | 30,7          |

**5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?**
```SQL
WITH cte_churn AS(
SELECT
	*,
	LAG(plan_id, 1) OVER(PARTITION BY customer_id ORDER BY plan_id) AS previous_plan_id
FROM subscriptions
)
SELECT
	COUNT(previous_plan_id) AS customers_churned,
	COUNT(previous_plan_id) * 100 / (SELECT COUNT(DISTINCT customer_id) FROM subscriptions) AS churn_percentage
FROM cte_churn
WHERE plan_id = 4 AND previous_plan_id = 0
```
**Result**

| customers_churned | churn_percentage |
|-------------------|------------------|
| 92                | 9                |













































































