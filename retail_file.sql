## EXPLORATORY DATA ANALYSIS
CREATE SCHEMA retail;
# Upload files

---- 1. write a query to find the top 5 customers by revenue 
SELECT 
customers.customer_id, 
first_name, 
last_name,
ROUND(SUM(quantity*list_price),2) AS revenue, 
SUM(quantity) AS quantity_bought
FROM customers 
JOIN orders 
ON customers.customer_id=orders.customer_id
JOIN order_items
ON  orders.order_id=order_items.order_id
GROUP BY customers.customer_id, first_name, last_name
ORDER BY SUM(quantity*list_price)DESC
LIMIT 5;

--- 2. write a query to find the revenue generated by each brand
SELECT 
DISTINCT( brand_name),
ROUND(SUM(order_items.list_price*quantity),2) AS revenue,
brands.brand_id
FROM brands		
LEFT JOIN products
ON brands.brand_id=products.brand_id
RIGHT JOIN order_items
ON products.product_id=order_items.product_id
GROUP BY brand_name,
brands.brand_id
ORDER BY  ROUND(SUM(order_items.list_price*quantity),2) DESC;

--- 3.  write a query to find the total quantity and sales for each category
SELECT 
DISTINCT(category_name),
SUM(quantity) AS total_quantity,
ROUND(SUM(products.list_price*quantity),2) AS total_sales
FROM categories  
RIGHT JOIN products
ON categories.category_id = products.category_id
INNER JOIN order_items
ON products.product_id=order_items.product_id
GROUP BY category_name
ORDER BY SUM(products.list_price*quantity) DESC;

------- 4. using a cte, calculate the total quantity sold per store
WITH CTE_STORE AS
(
SELECT 
		store_name,
        SUM(quantity) AS total_quantity_sold
FROM stores
JOIN stocks
ON stores.store_id=stocks.store_id
GROUP BY store_name
)
SELECT *
FROM CTE_STORE;

------ 5. write a query to find the top selling products
SELECT products.product_id,
 brand_id,product_name, 
 SUM(quantity) AS quantity,
 ROUND(SUM(discount),1) AS discount
FROM products
RIGHT JOIN order_items
ON products.product_id=order_items.product_id
GROUP BY products.product_id, product_name, brand_id
ORDER BY SUM(quantity) DESC
LIMIT 10;

---- 6. Write a query to find the most active staff
WITH STAFF_CTE (staff_id, first_name, total, quantity_sold, revenue, staff_remark) AS
 (
SELECT staffs.staff_id,first_name, COUNT(staffs.staff_id), SUM(quantity), ROUND(SUM(list_price),2),
CASE
	WHEN ROUND(SUM(list_price),2) > 1000000 THEN 'Excellent'
    WHEN ROUND(SUM(list_price),2) BETWEEN 500000 AND 1000000 THEN 'SATISFACTORY'
    ELSE 'PROBATION'
END	
FROM staffs
LEFT JOIN orders
ON staffs.staff_id=orders.staff_id
LEFT JOIN order_items
ON orders.order_id=order_items.order_id
GROUP BY staff_id, first_name,last_name
ORDER BY ROUND(SUM(list_price),2)  DESC
)
SELECT *
FROM STAFF_CTE;

--- 7. Write a query to calculate the total quantity and revenue per year
SELECT YEAR(`shipped_date`)AS YEAR, SUM(quantity) AS total_quantity_sold, 
ROUND(SUM(quantity*list_price),2) AS total_revenue
FROM orders
JOIN order_items
ON orders.order_id=order_items.order_id
WHERE YEAR(`shipped_date`) IS NOT NULL 
GROUP BY YEAR(`shipped_date`);

SELECT SUBSTRING(`shipped_date`,6,2) AS MONTH,SUM(quantity), ROUND(SUM(quantity*list_price),2)
FROM orders
JOIN order_items
ON orders.order_id=order_items.order_id 
WHERE SUBSTRING(`shipped_date`,6,2) IS NOT NULL
GROUP BY SUBSTRING(`shipped_date`,6,2);

SELECT SUBSTRING(`shipped_date`,1,7) AS MONTH,SUM(quantity), ROUND(SUM(quantity*list_price),2)
FROM orders
JOIN order_items
ON orders.order_id=order_items.order_id 
WHERE SUBSTRING(`shipped_date`,1,7) IS NOT NULL
GROUP BY SUBSTRING(`shipped_date`,1,7)
ORDER BY 1 ASC;
 
---- 8. Write a query to calculate the total revenue for each
 ---- month using a CTE to calculate the running total
WITH rolling_total AS
( 
SELECT SUBSTRING(`shipped_date`,1,7) AS MONTH,
ROUND(SUM(quantity*list_price),2) AS total_revenue
FROM orders
JOIN order_items
ON orders.order_id=order_items.order_id 
WHERE SUBSTRING(`shipped_date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT MONTH, total_revenue, 
ROUND(SUM(total_revenue) OVER(ORDER BY `MONTH`),2) AS rolling_total
FROM rolling_total;   