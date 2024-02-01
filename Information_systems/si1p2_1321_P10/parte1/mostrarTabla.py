from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy import Table, Column, Integer, String, MetaData, ForeignKey, text

db_engine = create_engine("postgresql://alumnodb:1234@localhost/si1", echo=False)
db_connect = db_engine.connect()

def db_getTopSales():
    try:
        db_connect = db_engine.connect()
        
        query = text("SELECT * FROM getTopSales("+"2015"+","+"2023"+") LIMIT 10;")
        db_result = db_connect.execute(query).fetchall()
        
        return db_result
    except Exception as e:
        print(f"Error: {e}")
        return []

resultados = db_getTopSales()
for res in resultados:
    print(res)