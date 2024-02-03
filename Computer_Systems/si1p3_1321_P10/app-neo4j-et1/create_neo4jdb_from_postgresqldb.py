from sqlalchemy import create_engine, text
from neo4j import GraphDatabase

# Configuración de la conexión a PostgreSQL
postgres_uri = "postgresql://alumnodb:1234@localhost:5432/si1"
engine = create_engine(postgres_uri)

# Configuración de la conexión a Neo4j
neo4j_uri = "bolt://localhost:7687"
neo4j_username = "neo4j"
neo4j_password = "si1-password"

# Consulta SQL para obtener datos
sql_query = """
    SELECT
        sub.movieid,
        sub.movietitle,
        sub.ventas,
        ARRAY_AGG(DISTINCT a.actorid) AS actor_ids,
        ARRAY_AGG(DISTINCT a.actorname) AS actor_names,
        ARRAY_AGG(DISTINCT d.directorid) AS director_ids,
        ARRAY_AGG(DISTINCT d.directorname) AS director_names
    FROM (
        SELECT
            m.movieid,
            m.movietitle,
            SUM(i.sales) as ventas,
            mc.country
        FROM
            imdb_movies m
        JOIN
            imdb_moviecountries mc ON m.movieid = mc.movieid
        JOIN
            products p ON m.movieid = p.movieid
        JOIN
            inventory i ON p.prod_id = i.prod_id
        WHERE
            mc.country = 'USA'
        GROUP BY
            m.movieid, mc.country
        ORDER BY
            ventas DESC
        LIMIT 20
    ) AS sub
    JOIN
        imdb_actormovies am ON sub.movieid = am.movieid
    JOIN
        imdb_actors a ON am.actorid = a.actorid
    JOIN
        imdb_directormovies dm ON sub.movieid = dm.movieid
    JOIN
        imdb_directors d ON dm.directorid = d.directorid
    GROUP BY
        sub.movieid, sub.movietitle, sub.ventas;
"""

# Conexión a PostgreSQL
with engine.connect() as connection:
    result = connection.execute(text(sql_query))
    movies_data = result.fetchall()

# Conexión a Neo4j y creación del grafo
with GraphDatabase.driver(neo4j_uri, auth=(neo4j_username, neo4j_password)) as driver:
    with driver.session() as session:
        # Función para crear nodos y relaciones en Neo4j
        def create_graph(tx, movie_data):
            # Crear nodo de la película
            tx.run("""
                MERGE (m:Movie {movieid: $movieid})
                SET m.title = $movietitle
            """, **dict(zip(["movieid", "movietitle"], movie_data[:2])))

            # Crear nodo y relación del actor
            for actor_id, actor_name in zip(movie_data[3], movie_data[4]):
                tx.run("""
                    MERGE (a:Person:Actor {actorid: $actorid})
                    SET a.name = $actorname
                """, **{"actorid": actor_id, "actorname": actor_name, "movieid": movie_data[0], "movietitle": movie_data[1]})
                print("actorid: {} actorname: {} movieid:{}  moviename:{} ".format(actor_id, actor_name,movie_data[0], movie_data[1]))

                # Crear relación entre Person y Movie (ACTED_IN)
                tx.run("""
                    MATCH (a:Actor {actorid: $actorid}), (m:Movie {movieid: $movieid})
                    MERGE (a)-[:ACTED_IN]->(m)
                """, **{"actorid": actor_id, "movieid": movie_data[0]})
                print("actorid: {}, movieid: {}".format(actor_id, movie_data[0]))

            # Crear nodo y relación del director
            for director_id, director_name in zip(movie_data[5], movie_data[6]):
                tx.run("""
                    MERGE (d:Person:Director {directorid: $directorid})
                    SET d.name = $directorname
                """, **{"directorid": director_id, "directorname": director_name, "movieid": movie_data[0], "movietitle": movie_data[1]})
                print("directorid: {} directorname: {}".format(director_id, director_name))

                # Crear relación entre Person y Movie (DIRECTED)
                tx.run("""
                    MATCH (d:Director {directorid: $directorid}), (m:Movie {movieid: $movieid})
                    MERGE (d)-[:DIRECTED]->(m)
                """, **{"directorid": director_id, "movieid": movie_data[0]})
                print("directorid: {}, movieid: {}".format(director_id,movie_data[0]))

        # Ejecutar la función para crear nodos y relaciones en Neo4j para cada película
        for movie_data in movies_data:
            session.write_transaction(create_graph, movie_data)

print("Grafo creado exitosamente en Neo4j.")
