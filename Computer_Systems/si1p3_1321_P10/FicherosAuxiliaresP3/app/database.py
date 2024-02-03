# -*- coding: utf-8 -*-

import os
import sys, traceback, time

from sqlalchemy import create_engine, text
from pymongo import MongoClient
from time import sleep

from sqlalchemy import Table, Column, Integer, String, MetaData, ForeignKey, text
from sqlalchemy.sql import select, delete

# configurar el motor de sqlalchemy
db_engine = create_engine("postgresql://alumnodb:1234@localhost/si1", echo=False, execution_options={"autocommit":False})

# Crea la conexión con MongoDB
mongo_client = MongoClient()

def getMongoCollection(mongoDB_client):
    mongo_db = mongoDB_client.si1
    return mongo_db.topUK

def mongoDBCloseConnect(mongoDB_client):
    mongoDB_client.close()

def dbConnect():
    return db_engine.connect()

def dbCloseConnect(db_conn):
    db_conn.close()
  
import time

def delState(state, bFallo, bSQL, duerme, bCommit):
    dbr = []

    # TODO: Ejecutar consultas de borrado
    # - ordenar consultas según se desee provocar un error (bFallo True) o no
    # - usar sentencias SQL ('BEGIN', 'COMMIT', ...) si bSQL es True
    # - suspender la ejecución 'duerme' segundos en el punto adecuado para forzar deadlock
    # - ir guardando trazas mediante dbr.append()
    db_conn = dbConnect()
    try:
        # TODO: ejecutar consultas
        if bSQL == True:
            dbr.append("Se utilizan sentencias SQL")
            query = text(f"BEGIN;")
            db_conn.execute(query)

            if bFallo == False:
                query = text(f"DELETE FROM orderdetail od USING orders o, customers c WHERE od.orderid = o.orderid AND o.customerid = c.customerid AND c.state = '{state}'")
                db_conn.execute(query)
                dbr.append("Customer borrado correctamente de la tabla orderdetail")

                query = text(f"DELETE FROM orders USING customers c WHERE orders.customerid = c.customerid AND c.state = '{state}'")
                db_conn.execute(query)
                dbr.append("Customer borrado correctamente de la tabla orders")

                if bCommit:
                    dbr.append("Commit final antes de finalizar la transacción.")
                    time.sleep(duerme)  # Insert sleep before final commit
                    query = text(f"COMMIT;")
                    db_conn.execute(query)
                    query = text(f"BEGIN;")
                    db_conn.execute(query)

                query = text(f"DELETE FROM customers WHERE state = '{state}'")
                db_conn.execute(query)
                dbr.append("Customer borrado correctamente de la tabla customers")

            if bFallo == True:
                dbr.append("Se provoca un fallo de restricción de foreign key.")

                query = text(f"DELETE FROM orderdetail od USING orders o, customers c WHERE od.orderid = o.orderid AND o.customerid = c.customerid AND c.state = '{state}'")
                db_conn.execute(query)
                dbr.append("Customer borrado correctamente de la tabla orderdetail")

                if bCommit:
                    dbr.append("Commit final antes de finalizar la transacción.")
                    time.sleep(duerme)  # Insert sleep before final commit
                    query = text(f"COMMIT;")
                    db_conn.execute(query)
                    query = text(f"BEGIN;")
                    db_conn.execute(query)

                query = text(f"DELETE FROM customers WHERE state = '{state}'")
                db_conn.execute(query)
                dbr.append("Customer borrado correctamente de la tabla customers")

                query = text(f"DELETE FROM orders USING customers c WHERE orders.customerid = c.customerid AND c.state = '{state}'")
                db_conn.execute(query)
                dbr.append("Customer borrado correctamente de la tabla orders")

        else:
            dbr.append("No se utilizan sentencias SQL")
            transaction = db_conn.begin()

            if bFallo == False:
                query = text(f"DELETE FROM orderdetail od USING orders o, customers c WHERE od.orderid = o.orderid AND o.customerid = c.customerid AND c.state = '{state}'")
                db_conn.execute(query)
                dbr.append("Customer borrado correctamente de la tabla orderdetail")

                query = text(f"DELETE FROM orders USING customers c WHERE orders.customerid = c.customerid AND c.state = '{state}'")
                db_conn.execute(query)
                dbr.append("Customer borrado correctamente de la tabla orders")

                if bCommit == True:
                    dbr.append("Commit final antes de finalizar la transacción.")
                    time.sleep(duerme)  # Insert sleep before final commit
                    transaction.commit()
                    query = text(f"BEGIN;")
                    db_conn.execute(query)

                query = text(f"DELETE FROM customers c WHERE c.state = '{state}'")
                db_conn.execute(query)
                dbr.append("Customer borrado correctamente de la tabla customers")

            if bFallo == True:
                dbr.append("Se provoca un fallo de restricción de foreign key.")

                query = text(f"DELETE FROM orderdetail od USING orders o, customers c WHERE od.orderid = o.orderid AND o.customerid = c.customerid AND c.state = '{state}'")
                db_conn.execute(query)
                dbr.append("Customer borrado correctamente de la tabla orderdetail")

                if bCommit == True:
                    dbr.append("Commit final antes de finalizar la transacción.")
                    time.sleep(duerme)  # Insert sleep before final commit
                    transaction.commit()
                    query = text(f"BEGIN;")
                    db_conn.execute(query)

                query = text(f"DELETE FROM customers c WHERE c.state = '{state}'")
                db_conn.execute(query)
                dbr.append("Customer borrado correctamente de la tabla customers")

                query = text(f"DELETE FROM orders USING customers c WHERE orders.customerid = c.customerid AND c.state = '{state}'")
                db_conn.execute(query)
                dbr.append("Customer borrado correctamente de la tabla orders")

    except Exception as e:
        # TODO: deshacer en caso de error
        dbr.append("Error en la transacción, ejecutamos rollback.")
        if bSQL == True:
            query = text(f"ROLLBACK;")
            db_conn.execute(query)
        else:
            transaction.rollback()
        dbCloseConnect(db_conn)

    else:
        # TODO: confirmar cambios si todo va bien
        if bSQL == True:
            query = text(f"COMMIT;")
            db_conn.execute(query)
        else:
            transaction.commit()
        dbr.append("La transacción es correcta.")
        dbCloseConnect(db_conn)

    return dbr