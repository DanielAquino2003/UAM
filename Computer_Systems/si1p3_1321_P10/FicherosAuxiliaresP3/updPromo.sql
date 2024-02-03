-- B)
-- Crear la columna de promo

ALTER TABLE customers
ADD COLUMN promo INTEGER DEFAULT 0;

-- C)

--HEMOS CREADO TAMBIEN UNA SERIE DE INDICES PARA MEJORAR LA EFICIENCIA Y ACTUALIZAR LOS VALORES DE PROMO, PRICE MAS EFICIENTEMENTE
CREATE INDEX idx_customers_customerid ON public.customers (customerid);


CREATE INDEX idx_customers_promo ON public.customers (promo);


CREATE INDEX idx_orders_customerid ON public.orders (customerid);


CREATE INDEX idx_orders_orderid ON public.orders (orderid);


CREATE INDEX idx_orderdetail_orderid ON public.orderdetail (orderid);


CREATE INDEX idx_orderdetail_price ON public.orderdetail (price);

ANALYZE public.customers;
ANALYZE public.orders;
ANALYZE public.orderdetail;


-- Borrar el trigger si existe
DROP TRIGGER IF EXISTS update_orderdetail_price ON public.customers;

CREATE OR REPLACE FUNCTION update_orderdetail_price()
RETURNS TRIGGER AS $$
BEGIN

    DECLARE
        old_promo_value numeric;
        new_promo_value numeric;
    BEGIN
        old_promo_value := COALESCE(OLD.promo, 0);
        new_promo_value := COALESCE(NEW.promo, 0);


        IF old_promo_value <> new_promo_value THEN
            UPDATE public.orderdetail
            SET price = price * (1 - new_promo_value / 100.0)
            WHERE orderid IN (SELECT orderid FROM public.orders WHERE customerid = NEW.customerid);
            
        END IF;
    END;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- Crear el trigger de sobre la funcion update_orderdetail_price
CREATE TRIGGER update_orderdetail_price
AFTER UPDATE OF promo ON public.customers
FOR EACH ROW
EXECUTE FUNCTION update_orderdetail_price();
--Para probocar un cambio en la columna prices de la tabla orderdetail, se debera modificar algun valor de la tabla customers columna promo

-- D)
-- Crear la función con pg_sleep
CREATE OR REPLACE FUNCTION update_orderdetail_price()
RETURNS TRIGGER AS $$
BEGIN

    DECLARE
        old_promo_value numeric;
        new_promo_value numeric;
    BEGIN
        old_promo_value := COALESCE(OLD.promo, 0);
        new_promo_value := COALESCE(NEW.promo, 0);


        IF old_promo_value <> new_promo_value THEN
            PERFORM pg_sleep(5);

            UPDATE public.orderdetail
            SET price = price * (1 - new_promo_value / 100.0)
            WHERE orderid IN (SELECT orderid FROM public.orders WHERE customerid = NEW.customerid);
            
        END IF;
    END;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;