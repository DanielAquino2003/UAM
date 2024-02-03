MATCH (a:Actor)-[:ACTED_IN]->(m:Movie)<-[:ACTED_IN]-(commonActor)
WHERE a.name <> 'Winston, Hattie'
WITH a, commonActor
MATCH (commonActor)-[:ACTED_IN]->(movieWithThirdActor)<-[:ACTED_IN]-(thirdActor)
RETURN DISTINCT a.actorid, a.name
ORDER BY a.name
LIMIT 10;
