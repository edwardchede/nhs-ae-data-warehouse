from config import AE_FOLDER
from etl.extract import get_ae_files, read_all_ae_files 
from etl.extract import read_all_ae_files
import pandas as pd
from etl.load import get_engine, load_bronze




files = get_ae_files(AE_FOLDER)

#  Read every monthly A&E CSV and combine into a single dataframe.
df = read_all_ae_files(AE_FOLDER)
# check if row count per month is usually short(less than 150  instead of approx 198)
if len(df) < 150:
    raise ValueError(f"Unexpectedly low row count: {len(df)}")

print(df.head())

print(df.shape)

print(df["report_date"].value_counts().sort_index())

engine = get_engine()
load_bronze(df, engine)

