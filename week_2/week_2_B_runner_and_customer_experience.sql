--B. Runner and Customer Experience

--1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SELECT
	DATEPART(WEEK, registration_date) AS week_signup, 
	COUNT(runner_id) number_of_runners
FROM runners
GROUP BY DATEPART(WEEK, registration_date)

--2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
SELECT 
	r.runner_id,
	AVG(DATEDIFF(SECOND, CAST(c.order_time AS DATETIME ),CAST(r.pickup_time AS DATETIME ) ) / 60% 60) AS avg_minutos
FROM customer_orders c
LEFT JOIN runner_orders r
ON c.order_id = r.order_id
WHERE r.distance_Km != 0
GROUP BY r.runner_id

--3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
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

--4. What was the average distance travelled for each customer?
SELECT
	c.customer_id,
	ROUND(AVG(r.distance_Km),2) AS avg_distance_Km
FROM customer_orders c
LEFT JOIN runner_orders r
	ON c.order_id = r.order_id
WHERE r.distance_Km != 0
GROUP BY c.customer_id

--5. What was the difference between the longest and shortest delivery times for all orders?
SELECT 
	MAX(duration_minutes) AS max_delivery_time,
	MIN(duration_minutes) AS min_delivery_time,
	MAX(duration_minutes) - MIN(duration_minutes) AS time_difference
FROM runner_orders

--6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
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

--7. What is the successful delivery percentage for each runner?
SELECT 
  runner_id, 
  COUNT(order_id) AS total_orders,
  SUM(CASE WHEN distance_Km = 0 THEN 0 ELSE 1 END) AS total_order_delivered,
  (100 * SUM(CASE WHEN distance_Km = 0 THEN 0 ELSE 1 END) / COUNT(order_id)) AS success
FROM runner_orders
GROUP BY runner_id
