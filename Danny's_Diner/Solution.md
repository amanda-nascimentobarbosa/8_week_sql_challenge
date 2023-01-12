#  Case Study #1: Danny's Diner

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
**Comment:**
* Use `LEFT JOIN` to merge the tables *sales* and *menu* to find out the price for each item;
* Use `SUM` and `GROUP BY` to aggregate the total spent by customer.

**Result:**

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
**Comment:**
* Use `COUNT` and `DISTINCT`to find out the number of unique visits each customer made to the restaurant;
* Use `GROUP BY` to find out the number of visits by each customer.

**Result:**

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
**Comment:**
* Inside the `CTE`, we create a new column rank based on order_date using `RANK` and `OVER (PARTITION BY ORDER BY)`, so we can find out the order of each item was purchased;
* After that, we filtered the `CTE` using `WHERE` to find out the first order of each customer;
* And then, aggregate using `GROUP BY` by each customer and product.

**Result:**

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
**Comment:**
* Use the `LEFT JOIN` to merge the tables *sales* and *menu*, so we can have the name of each product;
* Use `COUNT` to count how many times the products were sold.

**Result:**

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
  **Comment:**
  * Inside the `CTE`, we `COUNT` the products and used the result to `RANK`, so we can find out how many times each client brought each item.
  * Then, we select the `CTE`and using `WHERE` we discovered what was the most popular item for each customer.

**Result:**

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
**Comment:**
* Inside the `CTE`, we create a `RANK`column to organize the records by the first to the last one, and using `WHERE` to filter only the order dates after the customer became a member. 
* In the same query we use `LEFT JOIN` to merge the tables *sales*, *members* and *menu*, so we can  extracted the order and join dates, also the product name;
* Then, we select the `CTE`and using `WHERE` we discovered what was the first purchase for each customer.

**Result:**

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
**Comment:**
* Inside the `CTE`, we create the `RANK`column by order date, using the `LEFT JOIN`merge the tables *sales*, *members* and *menu*, and filter the orders before the customer became a member;
* Then, using `WHERE`filtered the first purchase.

**Result:**

| customer_id | order_date | product_id | product_name | join_date  | rk |
|-------------|------------|------------|--------------|------------|----|
| A           | 2021-01-01 | 1          | sushi        | 2021-01-07 | 1  |
| A           | 2021-01-01 | 2          | curry        | 2021-01-07 | 1  |
| B           | 2021-01-04 | 1          | sushi        | 2021-01-09 | 1  |

**8. What is the total items and amount spent for each member before they became a member?**
```SQL
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
```
**Comment:**
* `COUNT`the number of items purchased by each customer and `SUM`their prices;
* `JOIN`the tables *sales*, *members* and *menu*;
* Using `WHERE`filter orders before the customer became a member;
* Then, `GROUP BY`customer.

**Result:**

| customer_id | total_itens | total_amount |
|-------------|-------------|--------------|
| A           | 2           | 25           |
| B           | 3           | 40           |

**9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?**
```SQL
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
```
**Comment:**
* Use the `CTE`and create the column points by using the `CASE WHEN`each sushi ordered is equal to 2X10xprice and the other items 10xprice;
* then, `SUM` the points of each customer.

**Result:**

| customer_id | points |
|-------------|--------|
| A           | 860    |
| B           | 940    |
| C           | 360    |

**10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?**
```SQL
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
```
**Comment:**
* In the first `CTE`, we create a column to find out the date after 7 days the customer became a member and another column for the last day of January;
* The second `CTE` creates the column points where sushi is always 2x10xprice, first week of membership for any item is 2x10xprice and after that 10xprice
* The select `SUM`every point;
* The customer C is not a member, this is why he's not in the answer.

**Result:**

| customer_id | total_points |
|-------------|--------------|
| A           | 1370         |
| B           | 820          |

## Bonus Questions

**Join All The Things**

The following questions are related creating basic data tables that Danny and his team can use to quickly derive insights without needing to join the underlying tables using SQL.
Create the table with the columns customer_id, order_date, product_name, price and member.
```SQLSELECT
	s.customer_id,
	s.order_date,
	m.product_name,
	m.price,
	CASE
		WHEN s.order_date < mb.join_date THEN 'N'
		WHEN s.order_date >= mb.join_date THEN 'Y'
		ELSE 'N'
	END member
FROM sales s
LEFT JOIN menu m
	ON s.product_id = m.product_id
LEFT JOIN members mb
	ON s.customer_id = mb.customer_id
```
**Comment:**
* Use the `CASE` statment to attribute the N for non-members and Y for members.

**Result:**

| customer_id | order_date | product_name | price | member |
|-------------|------------|--------------|-------|--------|
| A           | 2021-01-01 | sushi        | 10    | N      |
| A           | 2021-01-01 | curry        | 15    | N      |
| A           | 2021-01-07 | curry        | 15    | Y      |
| A           | 2021-01-10 | ramen        | 12    | Y      |
| A           | 2021-01-11 | ramen        | 12    | Y      |
| A           | 2021-01-11 | ramen        | 12    | Y      |
| B           | 2021-01-01 | curry        | 15    | N      |
| B           | 2021-01-02 | curry        | 15    | N      |
| B           | 2021-01-04 | sushi        | 10    | N      |
| B           | 2021-01-11 | sushi        | 10    | Y      |
| B           | 2021-01-16 | ramen        | 12    | Y      |
| B           | 2021-02-01 | ramen        | 12    | Y      |
| C           | 2021-01-01 | ramen        | 12    | N      |
| C           | 2021-01-01 | ramen        | 12    | N      |
| C           | 2021-01-07 | ramen        | 12    | N      |
	
**Rank All The Things**

Danny also requires further information about the ranking of customer products, but he purposely does not need the ranking for non-member purchases so he expects null ranking values for the records when customers are not yet part of the loyalty program.
```SQL
WITH cte AS
(
SELECT
	s.customer_id,
	s.order_date,
	m.product_name,
	m.price,
	CASE
		WHEN s.order_date < mb.join_date THEN 'N'
		WHEN s.order_date >= mb.join_date THEN 'Y'
		ELSE 'N'
	END member
FROM sales s
LEFT JOIN menu m
	ON s.product_id = m.product_id
LEFT JOIN members mb
	ON s.customer_id = mb.customer_id
)
SELECT
	*,
	CASE
		WHEN member = 'N' THEN NULL
		ELSE RANK() OVER (PARTITION BY customer_id, member ORDER BY order_date) 
	END	ranking
FROM cte
```
**Comment:**
* Use `CTE` to create the column member, where N is for non-members and Y for members;
* Then, `RANK`only the orders of the members.

**Result:**

| customer_id | order_date | product_name | price | member | ranking |
|-------------|------------|--------------|-------|--------|---------|
| A           | 2021-01-01 | sushi        | 10    | N      | NULL    |
| A           | 2021-01-01 | curry        | 15    | N      | NULL    |
| A           | 2021-01-07 | curry        | 15    | Y      | 1       |
| A           | 2021-01-10 | ramen        | 12    | Y      | 2       |
| A           | 2021-01-11 | ramen        | 12    | Y      | 3       |
| A           | 2021-01-11 | ramen        | 12    | Y      | 3       |
| B           | 2021-01-01 | curry        | 15    | N      | NULL    |
| B           | 2021-01-02 | curry        | 15    | N      | NULL    |
| B           | 2021-01-04 | sushi        | 10    | N      | NULL    |
| B           | 2021-01-11 | sushi        | 10    | Y      | 1       |
| B           | 2021-01-16 | ramen        | 12    | Y      | 2       |
| B           | 2021-02-01 | ramen        | 12    | Y      | 3       |
| C           | 2021-01-01 | ramen        | 12    | N      | NULL    |
| C           | 2021-01-01 | ramen        | 12    | N      | NULL    |
| C           | 2021-01-07 | ramen        | 12    | N      | NULL    |
