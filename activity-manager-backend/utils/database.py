import mysql.connector
from mysql.connector import Error
import os
from dotenv import load_dotenv

load_dotenv()

def get_db_connection():
    try:
        connection = mysql.connector.connect(
            host=os.getenv('DB_HOST'),
            user=os.getenv('DB_USER'),
            password=os.getenv('DB_PASSWORD'),
            database=os.getenv('DB_NAME'),
            port=int(os.getenv('DB_PORT'))  # ✅ MUST be int
        )

        if connection.is_connected():
            print("✅ Successfully connected to database")
            return connection

    except Error as e:
        print(f"❌ Database connection error: {e}")
        return None


def execute_query(query, params=None):
    connection = get_db_connection()

    if not connection:
        raise Exception("Database connection failed")

    cursor = connection.cursor(dictionary=True)

    try:
        if params:
            cursor.execute(query, params)
        else:
            cursor.execute(query)

        if query.strip().upper().startswith("SELECT"):
            result = cursor.fetchall()
        else:
            connection.commit()
            result = cursor.lastrowid

        return result

    except Error as e:
        print(f"❌ SQL Error: {e}")
        raise e

    finally:
        cursor.close()
        connection.close()
