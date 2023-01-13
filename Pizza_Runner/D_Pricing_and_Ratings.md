<h3>D. Pricing and Ratings</h3>

**1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?**
```SQL
WITH cte AS(
SELECT
	pizza_name,
	COUNT(c.pizza_id) AS total_orders,
	r.order_id,
	CASE
		WHEN c.pizza_id = 1 THEN (COUNT(c.pizza_id) * 12)
		WHEN c.pizza_id = 2 THEN (COUNT(c.pizza_id) * 10)
		ELSE 0
	END total_price,
	r.cancellation
FROM customer_orders c
LEFT JOIN pizza_names p
	ON c.pizza_id = p.pizza_id
LEFT JOIN runner_orders r
	ON c.order_id = r.order_id
WHERE r.cancellation = ' '
GROUP BY pizza_name, c.pizza_id, r.order_id, r.cancellation
)
SELECT
	SUM(c.total_price) AS total_revenue
FROM cte c
```
**Result:**

| total_revenue |
|---------------|
| 138           |

**2. What if there was an additional $1 charge for any pizza extras? For exemple add cheese is $1 extra**
```SQL
WITH cte AS(
SELECT
	c.order_id,
	c.pizza_id,
	p.pizza_name,
	c.extras,
	r.cancellation,
	CASE
		WHEN c.pizza_id = 1 THEN 12
		WHEN c.pizza_id = 2 THEN 10
		ELSE 0
	END pizza_price,
	LEN(REPLACE(REPLACE(c.extras, ' ', ''), ',', '')) AS number_extras
FROM customer_orders c
LEFT JOIN pizza_names p
	ON c.pizza_id = p.pizza_id
LEFT JOIN runner_orders r
	ON c.order_id = r.order_id
WHERE r.cancellation = ' '
),
total AS(
SELECT
	*,
	(c.pizza_price + c.number_extras) AS total_price
FROM cte c
)
SELECT
	SUM(t.total_price) AS total_amount
FROM total t
```
**Result:**

| total_amount |
|--------------|
| 142          |

**3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.**
```SQL
CREATE TABLE ratings (
	order_id int,
	rating int
)

INSERT INTO ratings VALUES 
(1, 5), 
(2, 4), 
(3, 4), 
(4, 3), 
(5, 2), 
(7, 3),
(8, 5), 
(10, 5)
```
**Result:**

| order_id | rating |
|----------|--------|
| 1        | 5      |
| 2        | 4      |
| 3        | 4      |
| 4        | 3      |
| 5        | 2      |
| 7        | 3      |
| 8        | 5      |
| 10       | 5      |

**4. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?**
- customer_id
- order_id
- runner_id
- rating
- order_time
- pickup_time
- Time between order and pickup
- Delivery duration
- Average speed
```SQL
SELECT 
	c.customer_id,
	c.order_id,
	r.runner_id,
	ra.rating,
	c.order_time,
	r.pickup_time,
	CAST((r.pickup_time - c.order_time) as time(0)) AS time_between_order_pickup,
	r.duration_minutes,
	ROUND(60 * (r.distance_Km / r.duration_minutes),2) AS average_speed,
	COUNT(c.pizza_id) AS num_pizzas
FROM customer_orders c
LEFT JOIN runner_orders r
	ON c.order_id = r.order_id
LEFT JOIN ratings ra
	ON c.order_id = ra.order_id
WHERE rating IS NOT NULL
GROUP BY c.customer_id, c.order_id, r.runner_id, ra.rating, c.order_time, r.pickup_time, r.duration_minutes, r.distance_Km
ORDER BY c.customer_id
```
**Result:**

| customer_id | order_id | runner_id | rating | order_time              | pickup_time         | time_between_order_pickup | duration_minutes | average_speed | num_pizzas |
|-------------|----------|-----------|--------|-------------------------|---------------------|---------------------------|------------------|---------------|------------|
| 101         | 1        | 1         | 5      | 2020-01-01 18:05:02.000 | 2020-01-01 18:15:34 | 00:10:32                  | 32               | 37,5          | 1          |
| 101         | 2        | 1         | 4      | 2020-01-01 19:00:52.000 | 2020-01-01 19:10:54 | 00:10:02                  | 27               | 44,44         | 1          |
| 102         | 3        | 1         | 4      | 2020-02-01 23:51:23.000 | 2020-01-03 00:12:37 | 00:21:14                  | 20               | 40,2          | 2          |
| 102         | 8        | 2         | 5      | 2020-09-01 23:54:33.000 | 2020-01-10 00:15:02 | 00:20:29                  | 15               | 93,6          | 1          |
| 103         | 4        | 2         | 3      | 2020-04-01 13:23:46.000 | 2020-01-04 13:53:03 | 00:29:17                  | 40               | 35,1          | 3          |
| 104         | 5        | 3         | 2      | 2020-08-01 21:00:29.000 | 2020-01-08 21:10:57 | 00:10:28                  | 15               | 40            | 1          |
| 104         | 10       | 1         | 5      | 2020-11-01 18:34:49.000 | 2020-01-11 18:50:20 | 00:15:31                  | 10               | 60            | 2          |
| 105         | 7        | 2         | 3      | 2020-08-01 21:20:29.000 | 2020-01-08 21:30:45 | 00:10:16                  | 25               | 60            | 1          |

**5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?**
```SQL
WITH cte AS(
SELECT
	pizza_name,
	COUNT(c.pizza_id) AS total_orders,
	r.order_id,
	CASE
		WHEN c.pizza_id = 1 THEN (COUNT(c.pizza_id) * 12)
		WHEN c.pizza_id = 2 THEN (COUNT(c.pizza_id) * 10)
		ELSE 0
	END total_price,
	r.distance_Km * 0.30 AS fee_per_Km,
	r.distance_Km,
	r.cancellation
FROM customer_orders c
LEFT JOIN pizza_names p
	ON c.pizza_id = p.pizza_id
LEFT JOIN runner_orders r
	ON c.order_id = r.order_id
WHERE r.cancellation = ' '
GROUP BY pizza_name, c.pizza_id, r.order_id, r.distance_Km, r.cancellation
)
SELECT
	SUM(c.total_price) - SUM(c.fee_per_Km) AS total_revenue
FROM cte c
```
**Result:**

| total_revenue |
|---------------|
| 83,4          |

