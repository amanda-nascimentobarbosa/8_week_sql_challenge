--Queries created by Amanda Barbosa
--December 2022
--SQL Server

--1. What is the total amount each customer spent at the restaurant?

SELECT 
	customer_id,
	SUM(price) AS total_amount
FROM sales s
LEFT JOIN menu m
	ON s.product_id = m.product_id
GROUP BY customer_id

--2. How many days has each customer visited the restaurant?
SELECT
	customer_id,
	COUNT(DISTINCT order_date) AS num_visits
FROM sales
GROUP BY customer_id

--3. What was the first item from the menu purchased by each customer?
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

--4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT TOP 1
	m.product_name,
	COUNT(m.product_name) AS num_purchases
FROM sales s
LEFT JOIN menu m
	ON s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY num_purchases DESC

--5. Which item was the most popular for each customer?
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

--6. Which item was purchased first by the customer after they became a member?
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

--7. Which item was purchased just before the customer became a member?
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

--8. What is the total items and amount spent for each member before they became a member?
SELECT
	s.customer_id,
	COUNT(m.product_id) AS total_itens,
	SUM(m.price) AS total_amount
FROM sales s
LEFT JOIN members mb
	ON s.customer_id = mb.customer_id
LEFT JOIN menu m
	ON s.product_id = m.product_id
WHERE s.order_date < mb.join_date
GROUP BY s.customer_id

--9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
WITH points AS
(
	SELECT
		s.customer_id,
		s.product_id,
		m.product_name,
		m.price,
		CASE
			WHEN m.product_name = 'sushi' THEN 2 * 10* m.price
			ELSE 10 * m.price 
		END AS points
	FROM sales s
	LEFT JOIN menu m
		ON s.product_id = m.product_id
)
	SELECT
		p.customer_id,
		SUM(points) AS points
	FROM points p
	GROUP BY p.customer_id

 --10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
WITH dates AS 
(
SELECT 
	*, 
	DATEADD(DAY, 6, join_date) AS first_week, 
	EOMONTH('2021-01-31') AS first_month
FROM members
),
points_dist AS
(
SELECT 
	d.customer_id, 
	s.order_date, 
	d.join_date, 
	d.first_week, 
	d.first_month, 
	m.product_name, 
	m.price,
	SUM(CASE
	  WHEN m.product_name = 'sushi' THEN 2 * 10 * m.price
	  WHEN s.order_date BETWEEN d.join_date AND d.first_week THEN 2 * 10 * m.price
	  ELSE 10 * m.price
	  END) AS points
FROM dates d
JOIN sales s
ON d.customer_id = s.customer_id
JOIN menu m
ON s.product_id = m.product_id
WHERE s.order_date < d.first_month
GROUP BY d.customer_id, s.order_date, d.join_date, d.first_week, d.first_month, m.product_name, m.price
)
SELECT
	pd.customer_id,
	SUM(pd.points) AS total_points
FROM points_dist pd
GROUP BY pd.customer_id
