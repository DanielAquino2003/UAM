MATCH (p1:Person)-[:ACTED_IN|DIRECTED]-(m:Movie)-[:ACTED_IN|DIRECTED]-(p2:Person)
WHERE p1 < p2
WITH p1, p2, COLLECT(DISTINCT m) AS movies
WHERE SIZE(movies) > 1
RETURN p1.name AS person1, p2.name AS person2, movies;
