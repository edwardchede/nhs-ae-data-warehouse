-- ===========================================================
-- Populate Monthly Fact Table
-- ===========================================================

TRUNCATE TABLE gold.fact_ae_monthly
RESTART IDENTITY;

INSERT INTO gold.fact_ae_monthly
(
    provider_key,
    date_key,
    att_total,
    adm_total,
    pct_4h_all,
    dta_gt4h,
    dta_gt12h
)

SELECT

    p.provider_key,

    d.date_key,

    s.att_total,

    s.adm_total,

    s.pct_4h_all,

    s.dta_gt4h,

    s.dta_gt12h

FROM silver.ae_attendances s

INNER JOIN gold.dim_provider p

    ON s.trust_code = p.trust_code

INNER JOIN gold.dim_date d

    ON s.report_date = d.report_date;