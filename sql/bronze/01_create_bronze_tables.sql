-- ===========================================================
-- NHS A&E Data Warehouse
-- Layer : Bronze
-- Script: 01_create_bronze_tables.sql
--
-- Purpose
-- Raw landing tables that closely mirror the NHS CSV files.
-- ===========================================================

CREATE SCHEMA IF NOT EXISTS bronze;

--============================================================
-- A&E Attendances
--============================================================

DROP TABLE IF EXISTS bronze.ae_attendances;

CREATE TABLE bronze.ae_attendances
(
    trust_code          VARCHAR(10),
    region              VARCHAR(100),
    trust_name          VARCHAR(255),

    att_type1           INTEGER,
    att_type2           INTEGER,
    att_type3           INTEGER,
    att_total           INTEGER,

    lt4_type1           INTEGER,
    lt4_type2           INTEGER,
    lt4_type3           INTEGER,
    lt4_total           INTEGER,

    pct_4h_type1        NUMERIC(5,2),
    pct_4h_type2        NUMERIC(5,2),
    pct_4h_type3        NUMERIC(5,2),
    pct_4h_all          NUMERIC(5,2),

    gt4_type1           INTEGER,
    gt4_type2           INTEGER,
    gt4_type3           INTEGER,
    gt4_total           INTEGER,

    adm_via_type1       INTEGER,
    adm_via_type2       INTEGER,
    adm_via_type3_4     INTEGER,
    adm_via_ae_total    INTEGER,

    adm_other           INTEGER,
    adm_total           INTEGER,

    dta_gt4h            INTEGER,
    dta_gt12h           INTEGER,

    report_date         DATE
);

--============================================================
-- NHS System Mapping
--============================================================

DROP TABLE IF EXISTS bronze.system_mapping;

CREATE TABLE bronze.system_mapping
(
    code            VARCHAR(10),
    organisation     VARCHAR(255),
    icb_code         VARCHAR(20),
    icb_name         VARCHAR(255),
    region_name      VARCHAR(255)
);