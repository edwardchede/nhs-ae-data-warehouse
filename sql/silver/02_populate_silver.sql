-- ===========================================================
-- NHS A&E Data Warehouse
-- Layer : Silver
-- Script: 02_populate_silver.sql
--
-- Purpose
-- Populate the Silver layer from Bronze.
-- ===========================================================

TRUNCATE TABLE silver.ae_attendances;

INSERT INTO silver.ae_attendances
(
    trust_code,
    region,
    trust_name,

    att_type1,
    att_type2,
    att_type3,
    att_total,

    lt4_type1,
    lt4_type2,
    lt4_type3,
    lt4_total,

    pct_4h_type1,
    pct_4h_type2,
    pct_4h_type3,
    pct_4h_all,

    gt4_type1,
    gt4_type2,
    gt4_type3,
    gt4_total,

    adm_via_type1,
    adm_via_type2,
    adm_via_type3_4,
    adm_via_ae_total,

    adm_other,
    adm_total,

    dta_gt4h,
    dta_gt12h,

    report_date
)

SELECT

    TRIM(trust_code),
    TRIM(region),
    TRIM(trust_name),

    att_type1,
    att_type2,
    att_type3,
    att_total,

    lt4_type1,
    lt4_type2,
    lt4_type3,
    lt4_total,

    ROUND(pct_4h_type1,2),
    ROUND(pct_4h_type2,2),
    ROUND(pct_4h_type3,2),
    ROUND(pct_4h_all,2),

    gt4_type1,
    gt4_type2,
    gt4_type3,
    gt4_total,

    adm_via_type1,
    adm_via_type2,
    adm_via_type3_4,
    adm_via_ae_total,

    adm_other,
    adm_total,

    dta_gt4h,
    dta_gt12h,

    report_date

FROM bronze.ae_attendances;

-------------------------------------------------------------
-- System Mapping
-------------------------------------------------------------

TRUNCATE TABLE silver.system_mapping;

INSERT INTO silver.system_mapping
(
    code,
    organisation,
    icb_code,
    icb_name,
    region_name
)

SELECT DISTINCT

    TRIM(code),
    TRIM(organisation),
    TRIM(icb_code),
    TRIM(icb_name),
    TRIM(region_name)

FROM bronze.system_mapping;