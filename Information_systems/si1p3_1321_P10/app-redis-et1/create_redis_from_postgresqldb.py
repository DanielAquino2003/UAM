from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy import Table, Column, Integer, String, MetaData, ForeignKey, text
import random
import redis

db_engine = create_engine("postgresql://alumnodb:1234@localhost/si1", echo=False)
db_connect = db_engine.connect()
redis_conn = redis.StrictRedis(host='localhost', port=6379, decode_responses=True)


def main():
    db_connect = db_engine.connect()
        
    query = text("select email, firstname, lastname, phone from customers where country = 'Spain'")
    db_result = db_connect.execute(query).fetchall()


    for customer in db_result:
        visits= random.randint(1, 99)
        email= customer[0]
        name = f"{customer[1]} {customer[2]}"
        phone = customer[3]
        
        redis_key = f"customers:{email}"

        redis_conn.hset(redis_key, 'name', name)
        redis_conn.hset(redis_key, 'phone', phone)
        redis_conn.hset(redis_key, 'visits', visits)

def increment_by_email(email):
    redis_key = f"customers:{email}"

    if redis_conn.exists(redis_key):

        redis_conn.hincrby(redis_key, 'visits', 1)
        print(f"Visita incrementada para {email}")
    else:
        print(f"No se encontró el correo electrónico {email} en Redis")

def customer_most_visits():
    customer_keys = redis_conn.keys("customers:*")

    if not customer_keys or len(customer_keys) == 0:
        print("No hay clientes en Redis.")
        return None

    max_visits = -1
    max_visits_email = None

    for customer_key in customer_keys:
        customer_info = redis_conn.hgetall(customer_key)

        if 'visits' in customer_info:
            visits = int(customer_info['visits'])

            if visits > max_visits:
                max_visits = visits
                max_visits_email = customer_key.split(":")[1]

    return max_visits_email

def get_field_by_email(email):
    redis_key = f"customers:{email}"

    if not redis_conn.exists(redis_key):
        print(f"No se encontró el correo electrónico {email} en Redis.")
        return None

    customer_info = redis_conn.hgetall(redis_key)

    if not customer_info:
        print(f"No se encontró información para el correo electrónico {email}.")
        return None

    name = customer_info.get('name', 'Nombre no disponible')
    phone = customer_info.get('phone', 'Teléfono no disponible')
    visits = customer_info.get('visits', 'Número de visitas no disponible')

    return {
        'name': name,
        'phone': phone,
        'visits': visits,
    }

"""FUNCION DE COMPROBACION DE UNA CORRECTA INSERCION"""
""" 
def check_inserted_data(limit=5):
    customer_keys = redis_conn.keys("customers:*")

    if not customer_keys:
        print("No hay clientes en Redis.")
        return

    customer_keys = customer_keys[:limit]

    for customer_key in customer_keys:
        customer_info = redis_conn.hgetall(customer_key)

        print(f"{customer_key}")
        for field, value in customer_info.items():
            print(f"{field}: {value}")
        print("-" * 30)
 """


if __name__ == '__main__':
    """     
    main()
    check_inserted_data(limit=5)
    """
    """
    COMPROBACION C.a
    increment_by_email("binder.yarrow@mamoot.com")
    """

    """  
    COMPROBCION C.b
   
    most_visits_email = customer_most_visits()

    if most_visits_email:
        print(f"El cliente con más visitas tiene el correo electrónico: {most_visits_email}")
    else:
        print("No se encontraron clientes en Redis.")
    """

    """
    COMPROBACION C.c
    
    email_to_query = "binder.yarrow@mamoot.com"
    
    customer_data = get_field_by_email(email_to_query)

    if customer_data:
        print(f"Información para el correo electrónico {email_to_query}:")
        print(f"Nombre: {customer_data['name']}")
        print(f"Teléfono: {customer_data['phone']}")
        print(f"Número de visitas: {customer_data['visits']}")
    else:
        print("No se pudo obtener información.")
    """

