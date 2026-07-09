from pathlib import Path
import pandas as pd
from datetime import datetime
from etl.transform import standardise_ae_dataframe
from etl.validate import validate_dataframe



def read_ae_file(file_path: Path):
    """
    Read a single A&E CSV file, standardise it, validate it,
    and return a cleaned dataframe.
    """
    df = pd.read_csv(file_path)
    report_date = extract_reporting_date(file_path)

    df = standardise_ae_dataframe(df, report_date)

    validate_dataframe(df)

    return df



def get_ae_files(data_folder: Path):
    """
    Return A&E CSV files in chronological order.
    """

    files = list(data_folder.glob("*.csv"))

    return sorted(
        files,
        key=extract_reporting_date
    )


def extract_reporting_date(file_path: Path):
    """
    Convert a filename such as:
    April-2025-AE.csv

    into

    2025-04-30
    """

    month_name = file_path.stem.split("-")[0]
    year = int(file_path.stem.split("-")[1])

    first_day = datetime.strptime(
        f"{month_name} {year}",
        "%B %Y"
    )

    return pd.Timestamp(first_day) + pd.offsets.MonthEnd(0)





def read_all_ae_files(data_folder: Path) -> pd.DataFrame:
    """
    Read every monthly A&E CSV and combine into a single dataframe.
    """

    files = get_ae_files(data_folder)

    all_data = []

    for file in files:

        print(f"Reading {file.name}")

        df = read_ae_file(file)

        all_data.append(df)

    return pd.concat(
        all_data,
        ignore_index=True
    )