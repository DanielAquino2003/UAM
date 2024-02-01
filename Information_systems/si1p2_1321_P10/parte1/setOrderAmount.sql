-- setOrderAmount.sql
CREATE OR REPLACE FUNCTION setOrderAmount()
RETURNS void AS $$
DECLARE
BEGIN
  -- Actualiza netamount solo si es NULL
  UPDATE orders
  SET netamount = aux.suma
  FROM (
    SELECT orderid, SUM(price * quantity) AS suma
    FROM orders
    NATURAL JOIN orderdetail
    GROUP BY orderid
  ) AS aux
  WHERE orders.orderid = aux.orderid
  AND orders.netamount IS NULL;

  -- Actualiza totalamount solo si es NULL
  UPDATE orders
  SET totalamount = aux.suma
  FROM (
    SELECT orderid, netamount * (100 + tax) / 100 AS suma
    FROM orders
    NATURAL JOIN orderdetail
    GROUP BY orderid
  ) AS aux
  WHERE orders.orderid = aux.orderid
  AND orders.totalamount IS NULL;
END;
$$ LANGUAGE plpgsql;

