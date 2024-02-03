--ANEXO 2 PARTE 1
EXPLAIN
select count(*)
from orders
where status is null;

EXPLAIN
select count(*)
from orders
where status = 'Shipped';

-- CREAR INDEX PARA LA COLUMNA STATUS EN ORDERS
CREATE INDEX idx_orders_status ON orders(status);
-- BORRAR INDEX SOBRE LA COLUMNA STATUS EN ORDERS
DROP INDEX IF EXISTS idx_orders_status;


ANALYZE orders;

--ANEXO 2 PARTE 2
EXPLAIN
select count(*)
from orders
where status ='Paid';

EXPLAIN
select count(*)
from orders
where status ='Processed';