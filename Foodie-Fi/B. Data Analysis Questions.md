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

**6. What is the number and percentage of customer plans after their initial free trial?**
```SQL
WITH cte_next_plan AS(
SELECT
	*,
	LEAD(plan_id, 1) OVER(PARTITION BY customer_id ORDER BY plan_id) AS next_plan_id
FROM subscriptions
)
SELECT
	next_plan_id,
	COUNT(*) AS customers,
	COUNT(*) * 100 / (SELECT COUNT(DISTINCT customer_id) FROM subscriptions) AS next_plan_percentage
FROM cte_next_plan
WHERE next_plan_id IS NOT NULL AND plan_id = 0
GROUP BY next_plan_id
ORDER BY next_plan_id
```
**Result**

| next_plan_id | customers | next_plan_percentage |
|--------------|-----------|----------------------|
| 1            | 546       | 54                   |
| 2            | 325       | 32                   |
| 3            | 37        | 3                    |
| 4            | 92        | 9                    |

**7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?**
```SQL
WITH valid_subscriptions AS (
SELECT
	customer_id,
    s.plan_id,
	plan_name,
    start_date,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY start_date DESC) AS plan_rank
FROM subscriptions s
LEFT JOIN plans p
	ON s.plan_id = p.plan_id
WHERE start_date <= '2020-12-31'
)
SELECT
	plan_id,
	plan_name,
	COUNT(DISTINCT customer_id) AS customers,
	100.0 * COUNT(*) / SUM(COUNT(*)) OVER() AS percentage
FROM valid_subscriptions
WHERE plan_rank = 1
GROUP BY plan_id, plan_name
ORDER BY percentage
```
**Result**

| plan_id | plan_name     | customers | percentage      |
|---------|---------------|-----------|-----------------|
| 0       | trial         | 19        | 1.900000000000  |
| 3       | pro annual    | 195       | 19.500000000000 |
| 1       | basic monthly | 224       | 22.400000000000 |
| 4       | churn         | 236       | 23.600000000000 |
| 2       | pro monthly   | 326       | 32.600000000000 |

**8. How many customers have upgraded to an annual plan in 2020?**
```SQL
SELECT
	s.plan_id,
	plan_name,
	COUNT(customer_id) AS Total_customers
FROM subscriptions s
LEFT JOIN plans p
	ON s.plan_id = p.plan_id
WHERE DATEPART (YEAR, start_date) = 2020 AND p.plan_id = 3
GROUP BY s.plan_id, plan_name
```
**Result**

| plan_id | plan_name  | Total_customers |
|---------|------------|-----------------|
| 3       | pro annual | 195             |

**9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?**
```SQL
WITH trial_plan AS(
SELECT 
	*
FROM subscriptions 
WHERE plan_id=0
),
annual_plan AS (
SELECT 
	*
FROM subscriptions
WHERE plan_id=3
)
SELECT 
	AVG(DATEDIFF(DAY, tp.start_date, ap.start_date)*1.0) AS avg_conversion_days
FROM trial_plan tp
INNER JOIN annual_plan ap
	ON ap.customer_id = tp.customer_id;
```

**Result**

| avg_conversion_days |
|---------------------|
| 104.620155          |

**10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)**
```SQL
WITH trial_plan AS(
SELECT 
	customer_id,
    start_date AS join_date
FROM subscriptions 
WHERE plan_id=0
),
annual_plan AS (
SELECT 
	customer_id,
    start_date AS annual_start_date
FROM subscriptions
WHERE plan_id=3
),
interval AS(
SELECT
	tp.customer_id,
    join_date,
    annual_start_date,
    DATEDIFF(DAY, join_date, annual_start_date)/30 + 1 AS interval
FROM trial_plan tp
INNER JOIN annual_plan ap
	ON tp.customer_id = ap.customer_id
)
SELECT 
	CASE 
		WHEN interval = 1 THEN CONCAT(interval-1, ' - ', interval*30, ' days')
		ELSE CONCAT((interval-1)*30 + 1, ' - ', interval*30, ' days')
	END AS period,
COUNT(customer_id) AS total_customers,
CAST(AVG(DATEDIFF(DAY, join_date, annual_start_date)*1.0) AS decimal(5, 2)) AS average_days
FROM interval
GROUP BY interval;
```

**Result**

| period         | total_customers | average_days |
|----------------|-----------------|--------------|
| 0 - 30 days    | 48              | 9.54         |
| 31 - 60 days   | 25              | 41.84        |
| 61 - 90 days   | 33              | 70.88        |
| 91 - 120 days  | 35              | 99.83        |
| 121 - 150 days | 43              | 133.05       |
| 151 - 180 days | 35              | 161.54       |
| 181 - 210 days | 27              | 190.33       |
| 211 - 240 days | 4               | 224.25       |
| 241 - 270 days | 5               | 257.20       |
| 271 - 300 days | 1               | 285.00       |
| 301 - 330 days | 1               | 327.00       |
| 331 - 360 days | 1               | 346.00       |

**11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?**
```SQL
WITH downgraded AS(
SELECT
	CASE 
      WHEN 
        plan_id = 2  --pro monthly plan 
        AND
        LEAD(plan_id) OVER (PARTITION BY customer_id ORDER BY start_date) = 1  --basic monthly plan
      THEN 1
      ELSE 0
    END AS downgraded
  FROM subscriptions
)
SELECT 
	SUM(downgraded) AS total_downgrads
FROM downgraded;
```

**Result**

| total_downgrads |
|-----------------|
| 0               |
