import pandas as pd
from config import COLUMN_MAPPING


INTEGER_COLUMNS = [
    "att_type1", "att_type2", "att_type3", "att_total",
    "lt4_type1", "lt4_type2", "lt4_type3", "lt4_total",
    "gt4_type1", "gt4_type2", "gt4_type3", "gt4_total",
    "adm_via_type1", "adm_via_type2", "adm_via_type3_4",
    "adm_via_ae_total", "adm_other", "adm_total",
    "dta_gt4h", "dta_gt12h",
]

PERCENT_COLUMNS = [
    "pct_4h_all", "pct_4h_type1", "pct_4h_type2", "pct_4h_type3",
]


def _clean_numeric_value(value, is_percent: bool):
    """
    Normalise a single numeric-looking value that may arrive as:
    - a proper int/float
    - a string with thousands separators, e.g. '16,670'
    - a percentage string, e.g. '94.60%'
    - a placeholder for missing data, e.g. '-'
    """
    if pd.isna(value):
        return None

    if isinstance(value, (int, float)):
        return value

    text = str(value).strip()

    if text in ("-", "", "N/A", "n/a"):
        return None

    text = text.replace(",", "")

    if is_percent:
        text = text.replace("%", "")

    try:
        number = float(text)
    except ValueError:
        return None

    return number


def clean_numeric_columns(df: pd.DataFrame) -> pd.DataFrame:
    """
    Clean numeric fields that may contain thousands separators,
    percentage signs, or '-' placeholders for missing data.
    """
    df = df.copy()

    for col in INTEGER_COLUMNS:
        if col in df.columns:
            df[col] = df[col].apply(lambda v: _clean_numeric_value(v, is_percent=False))
            df[col] = df[col].astype("Int64")  # nullable integer type

    for col in PERCENT_COLUMNS:
        if col in df.columns:
            df[col] = df[col].apply(lambda v: _clean_numeric_value(v, is_percent=True))
            df[col] = df[col].astype("Float64")  # nullable float type

    return df


def normalise_column_names(df: pd.DataFrame) -> pd.DataFrame:
    """
    Standardise NHS column names before renaming.
    Some monthly files have hyphens corrupted into '0'
    (e.g. Excel encoding quirks), so we normalise back to hyphens.
    """
    df = df.copy()
    df.columns = (
        df.columns
          .str.replace(" 0 ", " - ", regex=False)
          .str.strip()
    )
    return df


def standardise_ae_dataframe(df: pd.DataFrame, report_date) -> pd.DataFrame:
    """
    Standardise a monthly NHS A&E dataframe.
    """
    df = df.copy()
    df = normalise_column_names(df)
    df.rename(columns=COLUMN_MAPPING, inplace=True)
    df = clean_numeric_columns(df)
    df = clean_trust_name(df)
    df["report_date"] = report_date
    return df

def clean_trust_name(df: pd.DataFrame) -> pd.DataFrame:
    """
    Fix hyphen corruption in trust_name (Excel/encoding artifact
    where '-' becomes '0'), matching the same issue we handle
    in column headers.
    """
    df = df.copy()
    if "trust_name" in df.columns:
        df["trust_name"] = (
            df["trust_name"]
              .str.replace("0In0", "-In-", regex=False)
              .str.replace(" 0 ", " - ", regex=False)
              .str.strip()
        )
    return df