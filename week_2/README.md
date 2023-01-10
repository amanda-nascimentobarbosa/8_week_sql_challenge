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
