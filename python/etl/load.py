from sqlalchemy import create_engine
from sqlalchemy.engine import URL
import pandas as pd

from config import DB_NAME, DB_HOST, DB_PORT, DB_USER, DB_PASSWORD


def get_engine():
    """
    Create a SQLAlchemy engine for the NHS A&E PostgreSQL database.
    """
    url = URL.create(
        drivername="postgresql+psycopg2",
        username=DB_USER,
        password=DB_PASSWORD,
        host=DB_HOST,
        port=DB_PORT,
        database=DB_NAME,
    )
    return create_engine(url)


def truncate_table(engine, schema: str, table: str):
    """
    Empty a table before a full reload.
    """
    with engine.begin() as conn:
        conn.exec_driver_sql(f"TRUNCATE TABLE {schema}.{table};")


def load_bronze(df: pd.DataFrame, engine, truncate_first: bool = True):
    """
    Load the combined, standardised A&E dataframe into
    bronze.ae_attendances.
    """
    if truncate_first:
        truncate_table(engine, "bronze", "ae_attendances")

    df.to_sql(
        "ae_attendances",
        engine,
        schema="bronze",
        if_exists="append",
        index=False,
    )

    print(f"Loaded {len(df)} rows into bronze.ae_attendances")