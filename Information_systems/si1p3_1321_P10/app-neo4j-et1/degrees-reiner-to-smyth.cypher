MATCH p = shortestPath(
  (director:Director {name: 'Reiner, Carl'})-[*]-(actress:Actor {name: 'Smyth, Lisa (I)'})
)
RETURN p;
