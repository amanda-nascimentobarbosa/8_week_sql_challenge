
## Questions

**1. What is the total amount each customer spent at the restaurant?**
```SQL
SELECT 
	customer_id,
	SUM(price) AS total_amount
FROM sales s
LEFT JOIN menu m
ON s.product_id = m.product_id
GROUP BY customer_id
```
| customer_id | total_spent |
| ----------- | ----------- |
| A           | 76          |
| B           | 74          |
| C           | 36          |

**2. How many days has each customer visited the restaurant?**
```SQL
SELECT
	customer_id,
	COUNT(DISTINCT order_date) AS num_visits
FROM sales
GROUP BY customer_id
```
| customer_id | num_visits |
|-------------|------------|
| A           | 4          |
| B           | 6          |
| C           | 2          |

**3. What was the first item from the menu purchased by each customer?**
```SQL
WITH rk_orders AS(
  SELECT
    s.customer_id,
    s.product_id,
    m.product_name,
    s.order_date,
    RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) rk
  FROM sales s
  LEFT JOIN menu m
  ON s.product_id = m.product_id
)
  SELECT
    rk.customer_id,
    rk.product_name
  FROM rk_orders rk
  WHERE rk = 1
  GROUP BY customer_id, product_name
```
| customer_id | product_name |
|-------------|--------------|
| A           | curry        |
| A           | sushi        |
| B           | curry        |
| C           | ramen        |

**4.What is the most purchased item on the menu and how many times was it purchased by all customers?**
```SQL
SELECT TOP 1
	m.product_name,
	COUNT(m.product_name) AS num_purchases
FROM sales s
LEFT JOIN menu m
ON s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY num_purchases DESC
```
| product_name | num_purchases |
|--------------|---------------|
| ramen        | 8             |

**5. Which item was the most popular for each customer?**
```SQL
WITH rk_orders AS(
	SELECT
		s.customer_id,
		m.product_name,
		COUNT(m.product_name) AS num_purchases,
		RANK() OVER (PARTITION BY s.customer_id ORDER BY COUNT(m.product_name) DESC) rk
	FROM sales s
	LEFT JOIN menu m
	ON s.product_id = m.product_id
	GROUP BY s.customer_id, m.product_name
)
	SELECT
		rk.customer_id,
		rk.product_name,
		rk.num_purchases
	FROM rk_orders rk
	WHERE rk = 1
  ```
  
| customer_id | product_name | num_purchases |
|-------------|--------------|---------------|
| A           | ramen        | 3             |
| B           | sushi        | 2             |
| B           | curry        | 2             |
| B           | ramen        | 2             |
| C           | ramen        | 3             |

**6. Which item was purchased first by the customer after they became a member?**
```SQL
WITH rk_orders AS
(
	SELECT
		s.customer_id,
		s.order_date,
		s.product_id,
		m.product_name,
		mb.join_date,
		RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) rk
	FROM sales s
	LEFT JOIN members mb
		ON s.customer_id = mb.customer_id
	LEFT JOIN menu m
		ON s.product_id = m.product_id
	WHERE s.order_date >= mb.join_date
)
	SELECT
		*		
	FROM rk_orders rk
	WHERE rk = 1
```
| customer_id | order_date | product_id | product_name | join_date  | rk |
|-------------|------------|------------|--------------|------------|----|
| A           | 2021-01-07 | 2          | curry        | 2021-01-07 | 1  |
| B           | 2021-01-11 | 1          | sushi        | 2021-01-09 | 1  |

**7. Which item was purchased just before the customer became a member?**
```SQL
WITH rk_orders AS
(
	SELECT
		s.customer_id,
		s.order_date,
		s.product_id,
		m.product_name,
		mb.join_date,
		RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date DESC) rk
	FROM sales s
	LEFT JOIN members mb
		ON s.customer_id = mb.customer_id
	LEFT JOIN menu m
		ON s.product_id = m.product_id
	WHERE s.order_date < mb.join_date
)
	SELECT
		*		
	FROM rk_orders rk
	WHERE rk = 1
```
| customer_id | order_date | product_id | product_name | join_date  | rk |
|-------------|------------|------------|--------------|------------|----|
| A           | 2021-01-01 | 1          | sushi        | 2021-01-07 | 1  |
| A           | 2021-01-01 | 2          | curry        | 2021-01-07 | 1  |
| B           | 2021-01-04 | 1          | sushi        | 2021-01-09 | 1  |

**8. What is the total items and amount spent for each member before they became a member?**
```SQL

```








