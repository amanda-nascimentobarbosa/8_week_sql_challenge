<h2>C. Ingredient Optimisation</h2>

<h3>1. First let's generate some temporary tables to help the data analysis</h3>

**1.1. Create a temporary table combining pizza_toppings and pizza_recipes tables**
```SQL
SELECT 
	pr.pizza_id,
	pt.topping_id,
	pt.topping_name
INTO #toppings
FROM pizza_toppings pt
JOIN pizza_recipes pr
	ON pt.topping_id = pr.toppings
```
**Result:**

| pizza_id | topping_id | topping_name |
|----------|------------|--------------|
| 1        | 1          | Bacon        |
| 1        | 2          | BBQ Sauce    |
| 1        | 3          | Beef         |
| 1        | 4          | Cheese       |
| 1        | 5          | Chicken      |
| 1        | 6          | Mushrooms    |
| 1        | 8          | Pepperoni    |
| 1        | 10         | Salami       |
| 2        | 4          | Cheese       |
| 2        | 6          | Mushrooms    |
| 2        | 7          | Onions       |
| 2        | 9          | Peppers      |
| 2        | 11         | Tomatoes     |
| 2        | 12         | Tomato Sauce |

**1.2. Some orders appers more than once, because they have more than one pizza. So, for the analysis we create a record_id column where each number appers only once**

```SQL
ALTER TABLE customer_orders
ADD record_id INT IDENTITY(1,1)
```
**Result:**

| order_id | customer_id | pizza_id | exclusions | extras | order_time              | record_id |
|----------|-------------|----------|------------|--------|-------------------------|-----------|
| 1        | 101         | 1        |            |        | 2020-01-01 18:05:02.000 | 1         |
| 2        | 101         | 1        |            |        | 2020-01-01 19:00:52.000 | 2         |
| 3        | 102         | 1        |            |        | 2020-02-01 23:51:23.000 | 3         |
| 3        | 102         | 2        |            |        | 2020-02-01 23:51:23.000 | 4         |
| 4        | 103         | 1        | 4          |        | 2020-04-01 13:23:46.000 | 5         |
| 4        | 103         | 1        | 4          |        | 2020-04-01 13:23:46.000 | 6         |
| 4        | 103         | 2        | 4          |        | 2020-04-01 13:23:46.000 | 7         |
| 5        | 104         | 1        |            | 1      | 2020-08-01 21:00:29.000 | 8         |
| 6        | 101         | 2        |            |        | 2020-08-01 21:03:13.000 | 9         |
| 7        | 105         | 2        |            | 1      | 2020-08-01 21:20:29.000 | 10        |
| 8        | 102         | 1        |            |        | 2020-09-01 23:54:33.000 | 11        |
| 9        | 103         | 1        | 4          | 1, 5   | 2020-10-01 11:22:59.000 | 12        |
| 10       | 104         | 1        |            |        | 2020-11-01 18:34:49.000 | 13        |
| 10       | 104         | 1        | 2, 6       | 1, 4   | 2020-11-01 18:34:49.000 | 14        |

**1.3. Create a temporary table wiht only the exclusions of each order**
```SQL
SELECT
	c.record_id,
	TRIM(e.value) AS topping_id
INTO #exclusions
FROM customer_orders c
CROSS APPLY STRING_SPLIT(c.exclusions, ',') AS e
```
**Results:**

| record_id | topping_id |
|-----------|------------|
| 1         |            |
| 2         |            |
| 3         |            |
| 4         |            |
| 5         | 4          |
| 6         | 4          |
| 7         | 4          |
| 8         |            |
| 9         |            |
| 10        |            |
| 11        |            |
| 12        | 4          |
| 13        |            |
| 14        | 2          |
| 14        | 6          |

**1.4 Create a temporary table wiht only the extras of each order**
```SQL
SELECT
	c.record_id,
	TRIM(e.value) AS topping_id
INTO #extras
FROM customer_orders c
CROSS APPLY STRING_SPLIT(c.extras, ',') AS e
```
**Results:**

| record_id | topping_id |
|-----------|------------|
| 1         |            |
| 2         |            |
| 3         |            |
| 4         |            |
| 5         |            |
| 6         |            |
| 7         |            |
| 8         | 1          |
| 9         |            |
| 10        | 1          |
| 11        |            |
| 12        | 1          |
| 12        | 5          |
| 13        |            |
| 14        | 1          |
| 14        | 4          |


<h3>2. Questions</h3>

**2.1. What are the standard ingredients for each pizza?**
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

**Result:**

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

**2.2 What was the most commonly added extra?**
```SQL
SELECT
	pt.topping_name,
	COUNT(e.topping_id) AS total
FROM #extras e
LEFT JOIN pizza_toppings pt
	ON e.topping_id = pt.topping_id
WHERE pt.topping_name IS NOT NULL
GROUP BY pt.topping_name
ORDER BY total DESC
```

**Result:**

| topping_name | total |
|--------------|-------|
| Bacon        | 4     |
| Cheese       | 1     |
| Chicken      | 1     |

**2.3. What was the most common exclusion?**
```SQL
SELECT
	pt.topping_name,
	COUNT(e.topping_id) AS total
FROM #exclusions e
LEFT JOIN pizza_toppings pt
	ON e.topping_id = pt.topping_id
WHERE pt.topping_name IS NOT NULL
GROUP BY pt.topping_name
ORDER BY total DESC
```

**Result:**

| topping_name | total |
|--------------|-------|
| Cheese       | 4     |
| Mushrooms    | 1     |
| BBQ Sauce    | 1     |

**2.4. Generate an order item for each record in the customers_orders table in the format of one of the following:** <br>

  - Meat Lovers - Exclude Beef  
  - Meat Lovers - Extra Bacon  
  - Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
  - Meat Lovers
  
```SQL
WITH extras_cte AS
(
	SELECT 
		record_id,
		'Extra ' + STRING_AGG(t.topping_name, ', ') AS record_options
	FROM
		#extras e,
		pizza_toppings t
	WHERE e.topping_id = t.topping_id
	GROUP BY record_id
),
exclusions_cte AS
(
	SELECT 
		record_id,
		'Exclude ' + STRING_AGG(t.topping_name, ', ') AS record_options
	FROM
		#exclusions e,
		pizza_toppings t
	WHERE e.topping_id = t.topping_id
	GROUP BY record_id
),
union_cte AS
(
	SELECT * FROM extras_cte
	UNION
	SELECT * FROM exclusions_cte
)
SELECT 
	c.record_id,
	CONCAT_WS(' - ', p.pizza_name, STRING_AGG(cte.record_options, ' - ')) AS orders
FROM 
	customer_orders c
	JOIN pizza_names p
	ON c.pizza_id = p.pizza_id
	LEFT JOIN union_cte cte
	ON c.record_id = cte.record_id
GROUP BY
	c.record_id,
	p.pizza_name
ORDER BY c.record_id
```

**Result:**

| record_id | orders                                                          |
|-----------|-----------------------------------------------------------------|
| 1         | Meatlovers                                                      |
| 2         | Meatlovers                                                      |
| 3         | Meatlovers                                                      |
| 4         | Vegetarian                                                      |
| 5         | Meatlovers - Exclude Cheese                                     |
| 6         | Meatlovers - Exclude Cheese                                     |
| 7         | Vegetarian - Exclude Cheese                                     |
| 8         | Meatlovers - Extra Bacon                                        |
| 9         | Vegetarian                                                      |
| 10        | Vegetarian - Extra Bacon                                        |
| 11        | Meatlovers                                                      |
| 12        | Meatlovers - Exclude Cheese - Extra Bacon, Chicken              |
| 13        | Meatlovers                                                      |
| 14        | Meatlovers - Exclude BBQ Sauce, Mushrooms - Extra Bacon, Cheese |

**2.5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients. For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"**
```SQL
WITH ingredients_cte AS
(
	SELECT
	c.record_id, 
	p.pizza_name,
	CASE
		WHEN t.topping_id 
		IN (select topping_id from #extras e where c.record_id = e.record_id)
		THEN '2x' + t.topping_name
		ELSE t.topping_name
	END as topping
	FROM 
		customer_orders c
		JOIN pizza_names p
			ON c.pizza_id = p.pizza_id
		JOIN #toppings t 
			ON c.pizza_id = t.pizza_id
	WHERE t.topping_id NOT IN (select topping_id from #exclusions e where c.record_id = e.record_id)
)

SELECT 
	record_id,
	CONCAT(pizza_name+': ',STRING_AGG(topping, ', ')) as ingredients_list
FROM ingredients_cte
GROUP BY 
	record_id,
	pizza_name
ORDER BY record_id 
```

**Result:**

| record_id | ingredients_list                                                                    |
|-----------|-------------------------------------------------------------------------------------|
| 1         | Meatlovers: Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami   |
| 2         | Meatlovers: Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami   |
| 3         | Meatlovers: Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami   |
| 4         | Vegetarian: Cheese, Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce              |
| 5         | Meatlovers: Bacon, BBQ Sauce, Beef, Chicken, Mushrooms, Pepperoni, Salami           |
| 6         | Meatlovers: Bacon, BBQ Sauce, Beef, Chicken, Mushrooms, Pepperoni, Salami           |
| 7         | Vegetarian: Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce                      |
| 8         | Meatlovers: 2xBacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami |
| 9         | Vegetarian: Cheese, Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce              |
| 10        | Vegetarian: Cheese, Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce              |
| 11        | Meatlovers: Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami   |
| 12        | Meatlovers: 2xBacon, BBQ Sauce, Beef, 2xChicken, Mushrooms, Pepperoni, Salami       |
| 13        | Meatlovers: Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami   |
| 14        | Meatlovers: 2xBacon, Beef, 2xCheese, Chicken, Pepperoni, Salami                     |

**2.6. What is the total quantity of each ingredient used in all ordered pizzas sorted by most frequent first?**
```SQL
WITH ingredients_cte AS
(
SELECT
	c.record_id, 
	p.pizza_name,
	CASE
		WHEN t.topping_id 
		IN (select topping_id from #extras e where c.record_id = e.record_id)
		THEN t.topping_name + ',' + t.topping_name
		ELSE t.topping_name
	END as topping
	FROM 
		customer_orders c
		JOIN pizza_names p
			ON c.pizza_id = p.pizza_id
		JOIN #toppings t 
			ON c.pizza_id = t.pizza_id
	WHERE t.topping_id NOT IN (select topping_id from #exclusions e where c.record_id = e.record_id)
),
ingredients_orders_cte AS
(
SELECT
	ic.record_id,
	ic.pizza_name,
	ic.topping,
	value
FROM ingredients_cte ic
	CROSS APPLY STRING_SPLIT(ic.topping, ',')
)
SELECT
	cte.value,
	COUNT (cte.value) total_toppings
FROM ingredients_orders_cte cte
GROUP BY cte.value
ORDER BY total_toppings DESC
```

**Result:**

| value        | total_toppings |
|--------------|----------------|
| Mushrooms    | 13             |
| Bacon        | 13             |
| Chicken      | 11             |
| Cheese       | 11             |
| Salami       | 10             |
| Beef         | 10             |
| Pepperoni    | 10             |
| BBQ Sauce    | 9              |
| Tomato Sauce | 4              |
| Tomatoes     | 4              |
| Onions       | 4              |
| Peppers      | 4              |
  
