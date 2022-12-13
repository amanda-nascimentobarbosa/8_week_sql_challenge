--Bonus Questions

--Join All The Things
--The following questions are related creating basic data tables that Danny and his team can use to quickly derive insights without needing to join the underlying tables using SQL.

--Recreate the following table output using the available data:
--Columns: customer_id, order_date,	product_name, price and	member

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

--Rank All The Things
--Danny also requires further information about the ranking of customer products, 
--but he purposely does not need the ranking for non-member purchases so he expects null ranking values 
--for the records when customers are not yet part of the loyalty program.
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
