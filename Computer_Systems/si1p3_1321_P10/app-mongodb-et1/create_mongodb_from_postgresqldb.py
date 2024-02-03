from pymongo import MongoClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy import Table, Column, Integer, String, MetaData, ForeignKey, text

db_engine = create_engine("postgresql://alumnodb:1234@localhost/si1", echo=False)
db_connect = db_engine.connect()

def clean_year_title(title):
    ntitle = title[:-7]
    return ntitle

def main():
    db_connect = db_engine.connect()
        
    query = text("Select M.movieid from imdb_movies AS M JOIN imdb_moviecountries AS MC ON M.movieid = MC.movieid WHERE MC.country = 'France'")
    db_result = db_connect.execute(query).fetchall()

    mc = MongoClient("localhost", 27017)
    db = mc.si1

    for ids in db_result:
        query = text(f"SELECT movietitle FROM imdb_movies WHERE movieid = {ids[0]}")
        title = db_connect.execute(query).fetchall()
        ntitle = clean_year_title(title[0][0])

        query = text(f"SELECT DISTINCT MG.genre FROM imdb_moviegenres AS MG WHERE MG.movieid = {ids[0]}")
        genres = db_connect.execute(query).fetchall()
        query = text(f"SELECT imdb_movies.year FROM imdb_movies WHERE movieid = {ids[0]}")
        year = db_connect.execute(query).fetchall()
        query = text(f"SELECT directorname FROM imdb_directors D JOIN imdb_directormovies DM ON D.directorid = DM.directorid WHERE DM.movieid = {ids[0]}")
        directors = db_connect.execute(query).fetchall()
        query = text(f"SELECT actorname FROM imdb_actors A JOIN imdb_actormovies AM ON A.actorid = AM.actorid WHERE AM.movieid = {ids[0]}")
        actors = db_connect.execute(query).fetchall()
        query = text(f"SELECT M2.movieid, M2.movietitle, M2.year FROM imdb_moviegenres MG1 JOIN imdb_movies M1 ON MG1.movieid = M1.movieid JOIN imdb_moviegenres MG2 ON MG1.genre = MG2.genre AND MG2.movieid <> M1.movieid JOIN imdb_movies M2 ON MG2.movieid = M2.movieid WHERE M1.movieid = {ids[0]} GROUP BY M2.movieid, M2.movietitle HAVING COUNT(DISTINCT MG1.genre) = (SELECT COUNT(DISTINCT genre) FROM imdb_moviegenres WHERE movieid = {ids[0]} ) ORDER BY M2.year DESC LIMIT 10")
        most_related = db_connect.execute(query).fetchall()
        query = text(f"SELECT M2.movieid, M2.movietitle, M2.year FROM imdb_moviegenres MG1 JOIN imdb_movies M1 ON MG1.movieid = M1.movieid JOIN imdb_moviegenres MG2 ON MG1.genre = MG2.genre AND MG2.movieid <> M1.movieid JOIN imdb_movies M2 ON MG2.movieid = M2.movieid WHERE M1.movieid = {ids[0]} GROUP BY M2.movieid, M2.movietitle HAVING COUNT(DISTINCT MG1.genre) < ( SELECT COUNT(DISTINCT genre) FROM imdb_moviegenres WHERE movieid = {ids[0]}) AND COUNT(DISTINCT MG1.genre) >= 0.5 * ( SELECT COUNT(DISTINCT genre) FROM imdb_moviegenres WHERE movieid = {ids[0]} ) ORDER BY M2.year DESC LIMIT 10")
        related = db_connect.execute(query).fetchall()

        pelicula = {
            "title": str(ntitle),
            "genres": [str(genre[0]) for genre in genres],
            "year": int(year[0][0]),
            "directors": [str(director[0]) for director in directors],
            "actors": [str(actor[0]) for actor in actors],
            "most_related_movies": [{"title": clean_year_title(movie[1]), "year": int(movie[2])} for movie in most_related],
            "related_movies": [{"title": clean_year_title(movie[1]), "year": int(movie[2])} for movie in related]
        }

        result=db.france.insert_one(pelicula)
    

    mc.close()

if __name__ == '__main__':
    main()
