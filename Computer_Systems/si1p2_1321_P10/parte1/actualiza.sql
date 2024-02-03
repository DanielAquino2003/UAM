--
-- Name: orders orders_customerid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: alumnodb
--
ALTER TABLE public.orders
ADD CONSTRAINT orders_customerid_fkey
FOREIGN KEY (customerid) REFERENCES public.customers(customerid);

--
-- Name: imdb_actormovies imdb_actormovies_actorid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: alumnodb
--
ALTER TABLE public.imdb_actormovies
ADD CONSTRAINT imdb_actormovies_actorid_fkey
FOREIGN KEY (actorid) REFERENCES public.imdb_actors(actorid);

--
-- Name: imdb_actormovies imdb_actormovies_movieid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: alumnodb
--
ALTER TABLE public.imdb_actormovies
ADD CONSTRAINT imdb_actormovies_movieid_fkey
FOREIGN KEY (movieid) REFERENCES public.imdb_movies(movieid);

--
-- Name: orderdetail orderdetail_orderid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: alumnodb
--
ALTER TABLE public.orderdetail
ADD CONSTRAINT orderdetail_orderid_fkey
FOREIGN KEY (orderid) REFERENCES public.orders(orderid);

--
-- Name: orderdetail orderdetail_prod_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: alumnodb
--
ALTER TABLE public.orderdetail
ADD CONSTRAINT orderdetail_prod_id_fkey
FOREIGN KEY (prod_id) REFERENCES public.products(prod_id);

--
--CASCADE CHANGES (si borro una la otra debe borrarse también)
--
ALTER TABLE public.imdb_actormovies
ADD CONSTRAINT imdb_actormovies_movieid_fkey
FOREIGN KEY (movieid) REFERENCES public.imdb_movies(movieid)
ON DELETE CASCADE;


ALTER TABLE public.imdb_directormovies
ADD CONSTRAINT imdb_directormovies_directorid_fkey
FOREIGN KEY (directorid) REFERENCES public.imdb_directors(directorid)
ON DELETE CASCADE;

ALTER TABLE public.imdb_directormovies
ADD CONSTRAINT imdb_directormovies_movieid_fkey
FOREIGN KEY (movieid) REFERENCES public.imdb_movies(movieid)
ON DELETE CASCADE;

ALTER TABLE public.imdb_moviecountries
ADD CONSTRAINT imdb_moviecountries_movieid_fkey
FOREIGN KEY (movieid) REFERENCES public.imdb_movies(movieid)
ON DELETE CASCADE;

ALTER TABLE public.imdb_moviegenres
ADD CONSTRAINT imdb_moviegenres_movieid_fkey
FOREIGN KEY (movieid) REFERENCES public.imdb_movies(movieid)
ON DELETE CASCADE;

ALTER TABLE public.imdb_movielanguages
ADD CONSTRAINT imdb_movielanguages_movieid_fkey
FOREIGN KEY (movieid) REFERENCES public.imdb_movies(movieid)
ON DELETE CASCADE;


--
--TRIGGERS
--

--Verifica si el producto pedido existe en la tabla products antes de insertarlo.
CREATE OR REPLACE FUNCTION check_product_exists()
RETURNS TRIGGER AS $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM products WHERE prod_id = NEW.prod_id) THEN
    RAISE EXCEPTION 'Producto con ID % no existe', NEW.prod_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER verify_product_exists
BEFORE INSERT ON orderdetail
FOR EACH ROW
EXECUTE FUNCTION check_product_exists();

--Verifica si hay suficiente stock para hacer el pedido.
CREATE OR REPLACE FUNCTION check_stock()
RETURNS TRIGGER AS $$
BEGIN
  IF (SELECT stock FROM inventory WHERE prod_id = NEW.prod_id) < NEW.quantity THEN
    RAISE EXCEPTION 'Stock insuficiente para el producto con ID %', NEW.prod_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER control_stock
BEFORE INSERT ON orderdetail
FOR EACH ROW
EXECUTE FUNCTION check_stock();

--Verifica que la transición del pedido no se salta pasos o no retrocede.
CREATE OR REPLACE FUNCTION check_orderstatus_transition()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'Paid' AND (OLD.status IS NULL OR OLD.status = 'Paid') THEN
        RETURN NEW;
    ELSIF NEW.status IS NULL AND (OLD.status IS NULL) THEN
        RETURN NEW;
    ELSIF NEW.status = 'Processed' AND (OLD.status = 'Paid' OR OLD.status = 'Processed') THEN
        RETURN NEW;
    ELSIF NEW.status = 'Shipped' AND (OLD.status = 'Processed' OR OLD.status = 'Shipped') THEN
        RETURN NEW;
    ELSE
        RAISE EXCEPTION 'No se permite la transición de % a %', OLD.status, NEW.status;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER order_status_transition_check
BEFORE UPDATE ON orders
FOR EACH ROW
EXECUTE FUNCTION check_orderstatus_transition();

--
--FIN TRIGGERS
--

ALTER TABLE public.customers
ADD COLUMN balance numeric;

--
-- Name: ratings; Type: TABLE; Schema: public; Owner: alumnodb
--
CREATE TABLE public.ratings (
    ratingid serial PRIMARY KEY,
    customerid integer REFERENCES public.customers(customerid),
    movieid integer REFERENCES public.imdb_movies(movieid),
    rating numeric,
    CONSTRAINT unique_rating UNIQUE (customerid, movieid)
);

ALTER TABLE public.imdb_movies
ADD COLUMN ratingmean numeric,
ADD COLUMN ratingcount integer;

ALTER TABLE public.customers
ALTER COLUMN password TYPE character varying(96);

CREATE OR REPLACE FUNCTION setCustomersBalance(IN initialBalance bigint)
RETURNS void AS $$
DECLARE
    randomBalance bigint;
BEGIN
    randomBalance := floor(random() * (initialBalance + 1));
    UPDATE customers SET balance = randomBalance;
    RAISE NOTICE 'El campo "balance" de la tabla "customers" ha sido inicializado con el valor: %', randomBalance;
END;
$$ LANGUAGE plpgsql;

-- Llama al procedimiento setCustomersBalance con N = 200
SELECT setCustomersBalance(200);


--Añadimos TRIGGER DE TABLA RATINGS
--Las valoraciones en la tabla "ratings" deben estar entre 0 y 10.
CREATE OR REPLACE FUNCTION validate_rating()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.rating < 0 OR NEW.rating > 10 THEN
        RAISE EXCEPTION 'La valoración debe estar entre 0 y 10.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_rating
BEFORE INSERT OR UPDATE ON public.ratings
FOR EACH ROW
EXECUTE FUNCTION validate_rating();

--APARTADO F: Crear las tablas correspondientes y convertir los atributos multivaluados moviecountries, moviegenres y movielanguages en relaciones entre la tabla movies y las tablas creadas.
-- secuencia y la tabla para countries
CREATE TABLE countries (
  countryid SERIAL PRIMARY KEY,
  country VARCHAR(128) UNIQUE
);

-- Insert valores distintos en countries
INSERT INTO countries (country)
SELECT DISTINCT country FROM imdb_moviecountries;

-- Actualiza imdb_moviecountries
UPDATE imdb_moviecountries
SET countryid = countries.countryid
FROM countries
WHERE imdb_moviecountries.country = countries.country;

-- Borrar la columna ya existente en la nueva tabla
ALTER TABLE imdb_moviecountries
DROP COLUMN IF EXISTS country;

-- Repetir el proceso para genres y languages

-- genres
CREATE TABLE genres (
  genresid SERIAL PRIMARY KEY,
  genre VARCHAR(128) UNIQUE
);

INSERT INTO genres (genre)
SELECT DISTINCT genre FROM imdb_moviegenres;

UPDATE imdb_moviegenres
SET genreid = genres.genresid
FROM genres
WHERE imdb_moviegenres.genre = genres.genre;

ALTER TABLE imdb_moviegenres
DROP COLUMN IF EXISTS genre;

-- languages
CREATE TABLE languages (
  languageid SERIAL PRIMARY KEY,
  language VARCHAR(128) UNIQUE
);

INSERT INTO languages (language)
SELECT DISTINCT language FROM imdb_movielanguages;

UPDATE imdb_movielanguages
SET languageid = languages.languageid
FROM languages
WHERE imdb_movielanguages.language = languages.language;

ALTER TABLE imdb_movielanguages
DROP COLUMN IF EXISTS language;
