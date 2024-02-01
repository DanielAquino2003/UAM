UPDATE orderdetail
SET price = subquery.new_price
FROM (
    SELECT 
        od.orderid,
        od.prod_id,
        p.price * POWER(1.02, 2023 - EXTRACT(YEAR FROM o.orderdate)) AS new_price
    FROM orderdetail od
    JOIN products p ON od.prod_id = p.prod_id
    JOIN orders o ON od.orderid = o.orderid
) AS subquery
WHERE orderdetail.orderid = subquery.orderid AND orderdetail.prod_id = subquery.prod_id;


--
-- COMPROBACION
--

/* SELECT
    od.orderid AS orderdetail_id,
    od.price AS orderdetail_price,
    o.orderdate AS order_date,
    p.price AS product_price
FROM
    orderdetail od
JOIN
    orders o ON od.orderid = o.orderid
JOIN
    products p ON od.prod_id = p.prod_id
limit 100; */