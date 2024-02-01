CREATE OR REPLACE FUNCTION getTopSales(year1 INT, year2 INT, OUT Year INT, OUT Film CHAR, OUT Sales BIGINT)
RETURNS SETOF RECORD AS $$
DECLARE
    a ALIAS FOR $1;
    max_each RECORD;
    movie_max RECORD;
    temp_row RECORD;
BEGIN
    -- Crear una tabla temporal para almacenar los resultados
    CREATE TEMP TABLE temp_results (
        year INT,
        film CHAR(40),
        sales BIGINT
    );

    FOR max_each IN (
        SELECT año, MAX(Total) AS maxim
        FROM (
            SELECT
                CAST(date_part('year', O.orderdate) AS INT) AS año,
                M.movietitle,
                COUNT(M.movieid) AS Total
            FROM
                orders AS O
                JOIN orderdetail AS OD ON O.orderid = OD.orderid
                JOIN products AS P ON OD.prod_id = P.prod_id
                JOIN imdb_movies AS M ON P.movieid = M.movieid
            WHERE
                date_part('year', O.orderdate) >= a
                AND date_part('year', O.orderdate) BETWEEN year1 AND year2  -- Restricción por año
            GROUP BY
                año, M.movietitle
        ) AS mov
        GROUP BY
            año
    ) LOOP
        FOR movie_max IN (
            SELECT
                M.movietitle
            FROM
                orders AS O
                JOIN orderdetail AS OD ON O.orderid = OD.orderid
                JOIN products AS P ON OD.prod_id = P.prod_id
                JOIN imdb_movies AS M ON P.movieid = M.movieid
            WHERE
                date_part('year', O.orderdate) = max_each.año
                AND date_part('year', O.orderdate) BETWEEN year1 AND year2  -- Restricción por año
            GROUP BY
                M.movietitle
            ORDER BY
                COUNT(M.movieid) DESC
            LIMIT 1
        ) LOOP
            -- Insertar en la tabla temporal
            INSERT INTO temp_results VALUES (max_each.año, movie_max.movietitle, max_each.maxim);
        END LOOP;
    END LOOP;

    -- Devolver fila a fila desde la tabla temporal ordenada por 'sales'
    FOR temp_row IN (
        SELECT * FROM temp_results
        ORDER BY sales DESC
    ) LOOP
        Year := temp_row.year;
        Film := temp_row.film;
        Sales := temp_row.sales;
        RETURN NEXT;
    END LOOP;

    -- Eliminar la tabla temporal al final
    DROP TABLE IF EXISTS temp_results;
END;
$$ LANGUAGE plpgsql;

select * FROM getTopSales(2013, 2023)

select * FROM getTopSales(2012, 2017)
