CREATE OR REPLACE FUNCTION updateInventoryAndCustomer()
RETURNS TRIGGER AS $$
BEGIN
    -- Verifica si el pedido ha pasado a estado "Paid"
    IF NEW.status = 'Paid' AND (OLD.status IS NULL OR OLD.status <> 'Paid') THEN
        -- Actualiza la tabla inventory
        UPDATE inventory
        SET stock = stock - (
            SELECT COALESCE(SUM(od.quantity), 0)
            FROM orderdetail od
            WHERE od.orderid = NEW.orderid
        ),
        sales = sales + (
            SELECT COALESCE(SUM(od.quantity), 0)
            FROM orderdetail od
            WHERE od.orderid = NEW.orderid
        )
        WHERE prod_id IN (
            SELECT prod_id
            FROM orderdetail
            WHERE orderid = NEW.orderid
        );

        -- Descuenta el precio total de la compra en la tabla customers
        UPDATE customers
        SET balance = balance - (
            SELECT COALESCE(SUM(od.quantity * p.price), 0)
            FROM orderdetail od
            JOIN products p ON od.prod_id = p.prod_id
            WHERE od.orderid = NEW.orderid
        )
        WHERE customerid = NEW.customerid;
    END IF;


    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER updInventoryAndCustomer
AFTER UPDATE ON orders
FOR EACH ROW
EXECUTE FUNCTION updateInventoryAndCustomer();