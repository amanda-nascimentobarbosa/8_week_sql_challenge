# 8 Week SQL Challenge

This is the free 8 week SQL challenge created by Danny Ma from Data with Danny. This repositories consists all of the answer for the challenge. If you are interesting to join the challenge check out [Danny's website.](https://8weeksqlchallenge.com)

##  Table of Contents

* [Case Study #1: Danny's Diner](#case1)
* Case Study #2: Pizza Runner
* Case Study #3: Foodie-Fi
* Case Study #4: Data Bank
* Case Study #5: Data Mart
* Case Study #6: Clique Bait
* Case Study #8: Fresh Segments

## <a name=“case1”><a/> Case Study #1 - Danny's Diner

<p align="center">
  <img width="300" height="300" src="https://8weeksqlchallenge.com/images/case-study-designs/1.png">
</p>

<details> 
  <summary><h3>Case Study 1 - Danny's Diner - Details</h3></summary>

<h3>Business Case</h3>
  
Danny wants to use the data to answer a few simple questions about his customers, especially about their **visiting patterns**, **how much money they’ve spent** and also **which menu items are their favourite**. Having this deeper connection with his customers will help him deliver a better and more personalised experience for his loyal customers.

He plans on using these insights to help him decide whether he should expand the existing customer loyalty program - additionally he needs help to generate some basic datasets so his team can easily inspect the data without needing to use SQL.

Danny has provided you with a sample of his overall customer data due to privacy issues - but he hopes that these examples are enough for you to write fully functioning SQL queries to help him answer his questions!

Danny has shared with you 3 key datasets for this case study:

* sales
* menu
* members

You can inspect the entity relationship diagram and example data below.

![](week_1/folder/2.png)

<h3>Case Study Questions</h3>
  
1. What is the total amount each customer spent at the restaurant?
2. How many days has each customer visited the restaurant?
3. What was the first item from the menu purchased by each customer?
4. What is the most purchased item on the menu and how many times was it purchased by all customers?
5. Which item was the most popular for each customer?
6. Which item was purchased first by the customer after they became a member?
7. Which item was purchased just before the customer became a member?
8. What is the total items and amount spent for each member before they became a member?
9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

**Bonus Questions**

1. Join All The Things - The following questions are related creating basic data tables that Danny and his team can use to quickly derive insights without needing to join the underlying tables using SQL. Create the table with the columns: customer_id, order_date,	product_name, price and	member

2. Rank All The Things - Danny also requires further information about the ranking of customer products, but he purposely does not need the ranking for non-member purchases so he expects null ranking values for the records when customers are not yet part of the loyalty program.

<h3>Solution</h3>

You can view the solution [here](/week_1/)

</details>
