from pymongo import MongoClient

def query_sci_fi_movies_between_years(db):
        genre="Sci-Fi"
        result = db.france.find({
            "genres": {"$in": [genre]},
            "year": {"$gte": 1994, "$lte": 1998}
        })
        return result
    
def query_dramas_starting_with_the_in_1998(db):
    genre="Drama"
    result = db.france.find({
        "genres": {"$in": [genre]},
        "year": 1998,
        "title": {"$regex": "The$"}
    })
    return result

def query_movies_with_faye_dunaway_and_viggo_mortensen(db):
    result = db.france.find({
        "actors": "Dunaway, Faye"
    })
    movies_with_dunaway = [movie["title"] for movie in result]
    result = db.france.find({
        "title": {"$in": movies_with_dunaway},
        "actors": "Mortensen, Viggo"
    })
    return result

def print_query_results(results):
    for movie in results:
        print("Title:", movie.get("title", "N/A"))
        print("Genres:", movie.get("genres", "N/A"))
        print("Year:", movie.get("year", "N/A"))
        print("Directors:", movie.get("directors", "N/A"))
        print("Actors:", movie.get("actors", "N/A"))
        print("Most Related Movies:", [related.get("title", "N/A") for related in movie.get("most_related_movies", [])])
        print("Related Movies:", [related.get("title", "N/A") for related in movie.get("related_movies", [])])
        print("------------------------")

def main():
    mongoClient = MongoClient("localhost", 27017)
    db = mongoClient.si1

    print("Consulta A: Películas de ciencia ficción entre 1994 y 1998")
    results_a = query_sci_fi_movies_between_years(db)
    print_query_results(results_a)
    print()
    print()

    print("Consulta B: Dramas del año 1998 que empiezan por 'The'")
    results_b = query_dramas_starting_with_the_in_1998(db)
    print_query_results(results_b)
    print()
    print()

    print("Consulta C: Películas con Faye Dunaway y Viggo Mortensen en el reparto")
    results_c = query_movies_with_faye_dunaway_and_viggo_mortensen(db)
    print_query_results(results_c)

    mongoClient.close()

if __name__ == "__main__":
    main()
