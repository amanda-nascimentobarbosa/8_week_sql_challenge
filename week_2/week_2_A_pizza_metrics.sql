--A. Pizza Metrics

--1. How many pizzas were ordered?
SELECT 
	COUNT(order_id) AS total_ordered
FROM customer_orders

--2. How many unique customer orders were made?
SELECT
	COUNT(DISTINCT order_id) AS unique_orders
FROM customer_orders

--3. How many successful orders were delivered by each runner?
SELECT
	runner_id,
	COUNT(order_id) AS total_deliveries
FROM runner_orders
WHERE cancellation = ' '
GROUP BY runner_id

--4. How many of each type of pizza was delivered?
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


--5. How many Vegetarian and Meatlovers were ordered by each customer?
SELECT
	c.customer_id,
	p.pizza_name,
	COUNT(p.pizza_name) AS total_ordered
FROM customer_orders c
LEFT JOIN pizza_names p
	ON c.pizza_id = p.pizza_id
GROUP BY c.customer_id, p.pizza_name
ORDER BY c.customer_id


--6. What was the maximum number of pizzas delivered in a single order?
SELECT
	r.order_id,
	COUNT(c.pizza_id) number_pizzas
FROM customer_orders c
LEFT JOIN runner_orders r
	ON c.order_id = r.order_id
WHERE r.distance_km != 0
GROUP BY r.order_id
ORDER BY number_pizzas DESC

--7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
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

--8. How many pizzas were delivered that had both exclusions and extras?
SELECT
	SUM(CASE
			WHEN c.exclusions != '' AND c.extras != '' THEN 1
			ELSE 0
			END) AS number_pizzas_delivered_with_changes
FROM customer_orders c
LEFT JOIN runner_orders r
	ON c.order_id = r.order_id
WHERE r.distance_km != 0

--9. What was the total volume of pizzas ordered for each hour of the day?
SELECT 
  DATEPART(HOUR, order_time) AS hour_of_day, 
  COUNT(order_id) AS number_pizzas
FROM customer_orders
GROUP BY DATEPART(HOUR, order_time)

--10. What was the volume of orders for each day of the week?
SELECT 
	FORMAT(order_time, 'dddd') as day_of_week,
	COUNT(pizza_id) as total_orders
FROM customer_orders
GROUP BY FORMAT(order_time, 'dddd')
ORDER BY total_orders DESC
