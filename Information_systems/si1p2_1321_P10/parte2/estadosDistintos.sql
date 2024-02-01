--QUERY PRINCIPAL
SELECT COUNT(DISTINCT c.state) AS num_estados
FROM customers c
JOIN orders o ON c.customerid = o.customerid
WHERE EXTRACT(YEAR FROM o.orderdate) = 2017
  AND c.country = 'Peru';

--PLAN DE EJECUCION
EXPLAIN SELECT COUNT(DISTINCT c.state) AS num_estados
FROM customers c
JOIN orders o ON c.customerid = o.customerid
WHERE EXTRACT(YEAR FROM o.orderdate) = 2017
  AND c.country = 'Peru';

-- TIEMPO DE EJECUCION
EXPLAIN ANALYZE
SELECT COUNT(DISTINCT c.state) AS num_estados
FROM customers c
JOIN orders o ON c.customerid = o.customerid
WHERE EXTRACT(YEAR FROM o.orderdate) = '2017'
  AND c.country = 'Peru';

--BORRADO DE INDICE IDX_ORDERS_ORDERDATE
DROP INDEX IF EXISTS idx_orders_orderdate;
--CREACION DE INDICE IDX_ORDERS_ORDERDATE
CREATE INDEX idx_orders_orderdate ON public.orders(orderdate);

--BORRADO DE INDICE IDX_ORDERS_CUSTOMERID
DROP INDEX IF EXISTS idx_orders_customerid;
--CREACION DE INDICE IDX_ORDERS_CUSTOMERID
CREATE INDEX idx_orders_customerid ON public.orders(customerid);

--BORRADO DE INDICE IDX_CUSTOMERS_COUNTRY
DROP INDEX IF EXISTS idx_customers_country;
--CREACION DE INDICE IDX_CUSTOMERS_COUNTRY
CREATE INDEX idx_customers_country ON public.customers(country);

--BORRADO DE INDICE IDX_ORDERS_ORDERDATE_CUSTOMERID
DROP INDEX IF EXISTS idx_orders_orderdate_customerid;
--CREACION DE INDICE IDX_ORDERS_ORDERDATE_CUSTOMERID
CREATE INDEX idx_orders_orderdate_customerid ON public.orders(orderdate, customerid);

--BORRADO DE INDICE IDX_ORDERS_ORDERDATE_YEAR
DROP INDEX IF EXISTS idx_orders_orderdate_year;
--INDEX + FUNCION
CREATE INDEX idx_orders_orderdate_year ON orders (EXTRACT(year FROM orderdate));



