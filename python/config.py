from pathlib import Path
from dotenv import load_dotenv
import os

# Project root
PROJECT_ROOT = Path(__file__).resolve().parent.parent

# Load environment variables from .env in the project root
load_dotenv(PROJECT_ROOT / ".env")

# Data folders
RAW_DATA = PROJECT_ROOT / "data" / "raw"
AE_FOLDER = RAW_DATA / "ae_attendances"
SYSTEM_MAPPING_FOLDER = RAW_DATA / "system_mapping"

# PostgreSQL settings (we'll use these later)
DB_NAME = "nhs_ae_project"
DB_HOST = "localhost"
DB_PORT = 5432
DB_USER = "postgres"
DB_PASSWORD = os.environ.get("NHS_AE_DB_PASSWORD", "")




COLUMN_MAPPING = {
  

    "Code": "trust_code",
    "Region": "region",
    "Name": "trust_name",

    "Type 1 Departments - Major A&E": "att_type1",
    "Type 2 Departments - Single Specialty": "att_type2",
    "Type 3 Departments - Other A&E/Minor Injury Unit": "att_type3",
    "Total attendances": "att_total",

    "Type 1 Departments - Major A&E.1": "lt4_type1",
    "Type 2 Departments - Single Specialty.1": "lt4_type2",
    "Type 3 Departments - Other A&E/Minor Injury Unit.1": "lt4_type3",
    "Total Attendances < 4 hours": "lt4_total",

    "Type 1 Departments - Major A&E.2": "gt4_type1",
    "Type 2 Departments - Single Specialty.2": "gt4_type2",
    "Type 3 Departments - Other A&E/Minor Injury Unit.2": "gt4_type3",
    "Total Attendances > 4 hours": "gt4_total",

    "Percentage in 4 hours or less (all)": "pct_4h_all",
    "Percentage in 4 hours or less (type 1)": "pct_4h_type1",
    "Percentage in 4 hours or less (type 2)": "pct_4h_type2",
    "Percentage in 4 hours or less (type 3)": "pct_4h_type3",

    "Emergency Admissions via Type 1 A&E": "adm_via_type1",
    "Emergency Admissions via Type 2 A&E": "adm_via_type2",
    "Emergency Admissions via Type 3 and 4 A&E": "adm_via_type3_4",
    "Total Emergency Admissions via A&E": "adm_via_ae_total",
    "Other Emergency admissions (i.e not via A&E)": "adm_other",
    "Total Emergency Admissions": "adm_total",

    "Number of patients spending >4 hours from decision to admit to admission": "dta_gt4h",
    "Number of patients spending >12 hours from decision to admit to admission": "dta_gt12h",

    
}

# config.py

REQUIRED_COLUMNS = [
    "trust_code",
    "trust_name",
    "att_total",
    "adm_total",
    "pct_4h_all",
    "report_date"
]