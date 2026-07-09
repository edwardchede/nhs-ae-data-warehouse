from config import REQUIRED_COLUMNS
import pandas as pd


def validate_dataframe(df: pd.DataFrame) -> bool:
    """
    Perform data quality checks on a standardised A&E dataframe.
    Raises ValueError on the first failed check.
    """

    missing_cols = [col for col in REQUIRED_COLUMNS if col not in df.columns]
    if missing_cols:
        raise ValueError(f"Missing columns: {missing_cols}")

    if len(df) == 0:
        raise ValueError("Dataset contains no rows.")

    if df["trust_code"].isna().any():
        raise ValueError("Missing trust codes detected.")

    duplicates = df["trust_code"].duplicated().sum()
    if duplicates > 0:
        raise ValueError(f"{duplicates} duplicate trust codes found.")

    return True
    