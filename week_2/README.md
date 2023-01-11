##  Case Study #2: Pizza Runner - Solution

<h3>A. Pizza Metrics</h3>
   
**1. How many pizzas were ordered?**
```SQL  
SELECT 
	COUNT(order_id) AS total_ordered
FROM customer_orders 
```  
 **Answer:** 
  
| total_ordered |
|---------------|
| 14            |
  
**2. How many unique customer orders were made?**
```SQL  
SELECT
	COUNT(DISTINCT order_id) AS unique_orders
FROM customer_orders 
``` 
**Answer:** 
  
| unique_orders |
|---------------|
| 10            |
  
**3. How many successful orders were delivered by each runner?**
```SQL  
SELECT
	runner_id,
	COUNT(order_id) AS total_deliveries
FROM runner_orders
WHERE cancellation = ' '
GROUP BY runner_id
``` 
**Answer:** 
  
| runner_id | total_deliveries |
|-----------|------------------|
| 1         | 4                |
| 2         | 3                |
| 3         | 1                |

**4. How many of each type of pizza was delivered?**
```SQL  
SELECT
	p.pizza_name,
	COUNT(r.order_id) AS total_delivered
FROM customer_orders c
LEFT JOIN runner_orders r
	ON c.order_id = r.order_id
LEFT JOIN pizza_names p
	ON c.pizza_id = p.pizza_id
WHERE r.distance_Km != 0
GROUP BY p.pizza_name
``` 
**Answer:** 
  
| pizza_name | total_delivered |
|------------|-----------------|
| Meatlovers | 9               |
| Vegetarian | 3               | 
  
**5. How many Vegetarian and Meatlovers were ordered by each customer?**
```SQL  
SELECT
	c.customer_id,
	p.pizza_name,
	COUNT(p.pizza_name) AS total_ordered
FROM customer_orders c
LEFT JOIN pizza_names p
	ON c.pizza_id = p.pizza_id
GROUP BY c.customer_id, p.pizza_name
ORDER BY c.customer_id
``` 
**Answer:** 
  
| customer_id | pizza_name | total_ordered |
|-------------|------------|---------------|
| 101         | Meatlovers | 2             |
| 101         | Vegetarian | 1             |
| 102         | Meatlovers | 2             |
| 102         | Vegetarian | 1             |
| 103         | Meatlovers | 3             |
| 103         | Vegetarian | 1             |
| 104         | Meatlovers | 3             |
| 105         | Vegetarian | 1             |
  
**6. What was the maximum number of pizzas delivered in a single order?**
```SQL  
SELECT
	r.order_id,
	COUNT(c.pizza_id) number_pizzas
FROM customer_orders c
LEFT JOIN runner_orders r
	ON c.order_id = r.order_id
WHERE r.distance_km != 0
GROUP BY r.order_id
ORDER BY number_pizzas DESC
``` 
**Answer:**
  
| order_id | number_pizzas |
|----------|---------------|
| 4        | 3             |
| 3        | 2             |
| 10       | 2             |
| 1        | 1             |
| 2        | 1             |
| 5        | 1             |
| 7        | 1             |
| 8        | 1             | 

**7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?**
```SQL  
SELECT
	c.customer_id,
	SUM(CASE
		WHEN c.exclusions <> '' OR c.extras <> '' THEN 1
		ELSE 0
		END) AS change,
	SUM(CASE
		WHEN c.exclusions = '' AND c.extras = '' THEN 1
		ELSE 0
		END) AS no_change
FROM customer_orders c
LEFT JOIN runner_orders r
	ON c.order_id = r.order_id
WHERE r.distance_km != 0
GROUP BY c.customer_id
``` 
**Answer:**

| customer_id | change | no_change |
|-------------|--------|-----------|
| 101         | 0      | 2         |
| 102         | 0      | 3         |
| 103         | 3      | 0         |
| 104         | 2      | 1         |
| 105         | 1      | 0         |

**8. How many pizzas were delivered that had both exclusions and extras?**
```SQL  
SELECT
	c.customer_id,
	SUM(CASE
		WHEN c.exclusions <> '' OR c.extras <> '' THEN 1
		ELSE 0
		END) AS change,
	SUM(CASE
		WHEN c.exclusions = '' AND c.extras = '' THEN 1
		ELSE 0
		END) AS no_change
FROM customer_orders c
LEFT JOIN runner_orders r
	ON c.order_id = r.order_id
WHERE r.distance_km != 0
GROUP BY c.customer_id
``` 
**Answer:**

| number_pizzas_delivered_with_changes |
|--------------------------------------|
| 1                                    |

**9. What was the total volume of pizzas ordered for each hour of the day?**
```SQL  
SELECT 
  DATEPART(HOUR, order_time) AS hour_of_day, 
  COUNT(order_id) AS number_pizzas
FROM customer_orders
GROUP BY DATEPART(HOUR, order_time)
``` 
**Answer:**

| hour_of_day | number_pizzas |
|-------------|---------------|
| 11          | 1             |
| 13          | 3             |
| 18          | 3             |
| 19          | 1             |
| 21          | 3             |
| 23          | 3             |

**10. What was the volume of orders for each day of the week?**
```SQL  
SELECT 
	FORMAT(order_time, 'dddd') as day_of_week,
	COUNT(pizza_id) as total_orders
FROM customer_orders
GROUP BY FORMAT(order_time, 'dddd')
ORDER BY total_orders DESC
``` 
**Answer:**

| day_of_week  | total_orders |
|--------------|--------------|
| quarta-feira | 5            |
| sábado       | 5            |
| domingo      | 2            |
| terça-feira  | 1            |
| quinta-feira | 1            |

<h3>B. Runner and Customer Experience</h3>

**1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)**
```SQL  
SELECT
	DATEPART(WEEK, registration_date) AS week_signup, 
	COUNT(runner_id) number_of_runners
FROM runners
GROUP BY DATEPART(WEEK, registration_date)
``` 
**Answer:**

| week_signup | number_of_runners |
|-------------|-------------------|
| 1           | 1                 |
| 2           | 2                 |
| 3           | 1                 |

**2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?**
```SQL  
SELECT 
	r.runner_id,
	AVG(DATEDIFF(SECOND, CAST(c.order_time AS DATETIME ),CAST(r.pickup_time AS DATETIME ) ) / 60% 60) AS avg_minutos
FROM customer_orders c
LEFT JOIN runner_orders r
ON c.order_id = r.order_id
WHERE r.distance_Km != 0
GROUP BY r.runner_id
``` 
**Answer:**

| runner_id | avg_minutos |
|-----------|-------------|
| 1         | 15          |
| 2         | 23          |
| 3         | 10          |

**3. Is there any relationship between the number of pizzas and how long the order takes to prepare?**
```SQL  
WITH cte AS (
	SELECT 
		c.order_id,
		COUNT(c.pizza_id) AS number_pizzas,
		DATEDIFF(SECOND, CAST(c.order_time AS DATETIME ),CAST(r.pickup_time AS DATETIME ) ) / 60% 60 AS minutos
	FROM customer_orders c
	LEFT JOIN runner_orders r
	ON c.order_id = r.order_id
	WHERE r.distance_Km != 0
	GROUP BY c.order_id, DATEDIFF(SECOND, CAST(c.order_time AS DATETIME ),CAST(r.pickup_time AS DATETIME ) ) / 60% 60
)
SELECT 
	cte.number_pizzas,
	AVG(cte.minutos) AS avg_minutes
FROM cte
GROUP BY cte.number_pizzas
``` 
**Answer:**

| number_pizzas | avg_minutes |
|---------------|-------------|
| 1             | 12          |
| 2             | 18          |
| 3             | 29          |

**4. What was the average distance travelled for each customer?**
```SQL  
SELECT
	c.customer_id,
	ROUND(AVG(r.distance_Km),2) AS avg_distance_Km
FROM customer_orders c
LEFT JOIN runner_orders r
	ON c.order_id = r.order_id
WHERE r.distance_Km != 0
GROUP BY c.customer_id
``` 
**Answer:**

| customer_id | avg_distance_Km |
|-------------|-----------------|
| 101         | 20              |
| 102         | 16,73           |
| 103         | 23,4            |
| 104         | 10              |
| 105         | 25              |

**5. What was the difference between the longest and shortest delivery times for all orders?**
```SQL  
SELECT 
	MAX(duration_minutes) AS max_delivery_time,
	MIN(duration_minutes) AS min_delivery_time,
	MAX(duration_minutes) - MIN(duration_minutes) AS time_difference
FROM runner_orders
``` 
**Answer:**

| max_delivery_time | min_delivery_time | time_difference |
|-------------------|-------------------|-----------------|
| 40                | 0                 | 40              |

**6. What was the average speed for each runner for each delivery and do you notice any trend for these values?**
```SQL  
SELECT
	r.runner_id,
	c.order_id,
	r.distance_Km,
	r.duration_minutes,
	ROUND((r.distance_Km / r.duration_minutes * 60),2) AS speed
FROM customer_orders c
LEFT JOIN runner_orders r
	ON c.order_id = r.order_id
WHERE r.distance_Km != 0
GROUP BY r.runner_id, c.order_id, r.distance_Km, r.duration_minutes
``` 
**Answer:**

| runner_id | order_id | distance_Km | duration_minutes | speed |
|-----------|----------|-------------|------------------|-------|
| 1         | 1        | 20          | 32               | 37,5  |
| 1         | 2        | 20          | 27               | 44,44 |
| 1         | 3        | 13,4        | 20               | 40,2  |
| 1         | 10       | 10          | 10               | 60    |
| 2         | 4        | 23,4        | 40               | 35,1  |
| 2         | 7        | 25          | 25               | 60    |
| 2         | 8        | 23,4        | 15               | 93,6  |
| 3         | 5        | 10          | 15               | 40    |

**7. What is the successful delivery percentage for each runner?**
```SQL  
SELECT 
  runner_id, 
  COUNT(order_id) AS total_orders,
  SUM(CASE 
  	WHEN distance_Km = 0 THEN 0 
	ELSE 1 END) AS total_order_delivered, 
  (100 * SUM(CASE WHEN distance_Km = 0 THEN 0 ELSE 1 END) / COUNT(order_id)) AS success
FROM runner_orders
GROUP BY runner_id
``` 
**Answer:**

| runner_id | total_orders | total_order_delivered | success |
|-----------|--------------|-----------------------|---------|
| 1         | 4            | 4                     | 100     |
| 2         | 4            | 3                     | 75      |
| 3         | 2            | 1                     | 50      |


<H3>C. Ingredient Optimisation</H3>

**1. What are the standard ingredients for each pizza?**
```SQL  
SELECT
	pn.pizza_name,
	pt.topping_name
FROM pizza_recipes pr
LEFT JOIN pizza_toppings pt
	ON pr.toppings = pt.topping_id
LEFT JOIN pizza_names pn
	ON pr.pizza_id = pn.pizza_id
``` 
**Answer:**

| pizza_name | topping_name |
|------------|--------------|
| Meatlovers | Bacon        |
| Meatlovers | BBQ Sauce    |
| Meatlovers | Beef         |
| Meatlovers | Cheese       |
| Meatlovers | Chicken      |
| Meatlovers | Mushrooms    |
| Meatlovers | Pepperoni    |
| Meatlovers | Salami       |
| Vegetarian | Cheese       |
| Vegetarian | Mushrooms    |
| Vegetarian | Onions       |
| Vegetarian | Peppers      |
| Vegetarian | Tomatoes     |
| Vegetarian | Tomato Sauce |

**2. What was the most commonly added extra?**
```SQL  
WITH extras AS(
SELECT
	pizza_id,
	SUBSTRING(extras, 1, 1) AS extras_2,
	SUBSTRING(extras, 3, 2) AS extras_3
FROM
	customer_orders c
),
extras_count AS
(
SELECT  --seleção sobre o resultado do union
	colunas AS extra_toppings_id,
    COUNT(colunas) AS extra_count
FROM
    (SELECT LOWER(extras_2) AS COLUNAS FROM extras
     UNION ALL
     SELECT LOWER(extras_3) AS COLUNAS FROM extras
    ) nomeDoSelect --necessário nomear o union para funcinonar
GROUP BY
    colunas
HAVING COUNT(colunas) > 0 AND colunas != '' --excluindo células vazias
)
SELECT
	topping_name,
	extra_toppings_id,
	extra_count
FROM extras_count ec
LEFT JOIN pizza_toppings pt
	ON ec.extra_toppings_id = pt.topping_id
ORDER BY extra_count DESC
``` 
**Answer:**

| topping_name | extra_toppings_id | extra_count |   |
|--------------|-------------------|-------------|---|
| Bacon        | 1                 | 4           |   |
| Cheese       | 4                 | 1           |   |
| Chicken      | 5                 | 1           |   |
