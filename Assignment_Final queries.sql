---Accuracy Checks--

select count(customer_id),count(distinct customer_id) from dbo.Customer

select * from dbo.Customer where customer_id is null

---

select count(Order_ID),count(distinct Order_ID) from dbo.Orders

select * from dbo.Orders where order_id is null

select count(customer_id),count(distinct customer_id) from dbo.Orders

---

select count(shipping_id),count(distinct shipping_id)  from dbo.Shipping

select count(customer_id),count(distinct customer_id)  from dbo.Shipping

select * from dbo.Shipping where shipping_id is null

--

---the total amount spent and the country for the Pending delivery status for each country.

SELECT 
    c.country,
    SUM(o.amount) AS total_amount_spent
FROM dbo.Orders o
JOIN dbo.Customer c ON o.customer_id = c.customer_id
JOIN dbo.Shipping s ON o.shipping_id = s.shipping_id
WHERE s.status = 'Pending'
GROUP BY c.country;


-----the total number of transactions, total quantity sold, and total amount spent for each customer, along with the product details.

SELECT 
    c.customer_id,
    p.product_id,
    p.product_name,
    COUNT(o.order_id) AS total_transactions
FROM dbo.Orders o
JOIN dbo.Customer c ON o.customer_id = c.customer_id
JOIN dbo.Products p ON o.product_id = p.product_id
GROUP BY c.customer_id, p.product_id, p.product_name;

-----the total quantity sold, and total amount spent for each customer, along with the product details.

SELECT 
    c.customer_id,
    p.product_id,
    p.product_name,
    SUM(o.quantity) AS total_quantity_sold
FROM dbo.Orders o
JOIN dbo.Customer c ON o.customer_id = c.customer_id
JOIN Products p ON o.product_id = p.product_id
GROUP BY c.customer_id, p.product_id, p.product_name;


---------the total amount spent for each customer, along with the product details.

SELECT 
    c.customer_id,
    p.product_id,
    p.product_name,
    SUM(o.amount) AS total_amount_sold
FROM dbo.Orders o
JOIN dbo.Customer c ON o.customer_id = c.customer_id
JOIN Products p ON o.product_id = p.product_id
GROUP BY c.customer_id, p.product_id, p.product_name;


----- the maximum product purchased for each country.

SELECT 
    country,
    product_id,
    product_name,
    total_purchases
FROM (
    SELECT 
        c.country,
        p.product_id,
        p.product_name,
        COUNT(o.order_id) AS total_purchases,
        RANK() OVER (PARTITION BY c.country ORDER BY COUNT(o.order_id) DESC) AS rank_per_country
    FROM dbo.Orders o
    JOIN dbo.Customer c ON o.customer_id = c.customer_id
    JOIN Products p ON o.product_id = p.product_id
    GROUP BY c.country, p.product_id, p.product_name
) ranked_products
WHERE rank_per_country = 1;


-----the most purchased product based on the age category less than 30 and above 30.

SELECT 
    age_category,
    product_id,
    product_name,
    total_purchases
FROM (
    SELECT 
        CASE 
            WHEN c.age < 30 THEN 'Under 30'
            ELSE '30 and above'
        END AS age_category,
        p.product_id,
        p.product_name,
        COUNT(o.order_id) AS total_purchases,
        RANK() OVER (
            PARTITION BY 
                CASE WHEN c.age < 30 THEN 'Under 30' ELSE '30 and above' END
            ORDER BY COUNT(o.order_id) DESC
        ) AS rank_within_age_group
    FROM Orders o
    JOIN Customers c ON o.customer_id = c.customer_id
    JOIN Products p ON o.product_id = p.product_id
    GROUP BY 
        CASE WHEN c.age < 30 THEN 'Under 30' ELSE '30 and above' END,
        p.product_id,
        p.product_name
) ranked_products
WHERE rank_within_age_group = 1;


-------the country that had minimum transactions and sales amount.

SELECT country, num_transactions, total_sales
FROM (
    SELECT 
        c.country,
        COUNT(o.order_id) AS num_transactions,
        SUM(o.amount) AS total_sales,
        RANK() OVER (ORDER BY COUNT(o.order_id), SUM(o.amount)) AS rnk
    FROM dbo.Orders o
    JOIN dbo.Customer c ON o.customer_id = c.customer_id
    GROUP BY c.country
) ranked
WHERE rnk = 1;


----

SELECT country,total_sales
FROM (
    SELECT 
        c.country,
        SUM(o.amount) AS total_sales,
        RANK() OVER (ORDER BY SUM(o.amount)) AS rnk
    FROM dbo.Orders o
    JOIN dbo.Customer c ON o.customer_id = c.customer_id
    GROUP BY c.country
) ranked
WHERE rnk = 1;











