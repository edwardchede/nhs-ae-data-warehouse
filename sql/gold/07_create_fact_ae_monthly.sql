-- ===========================================================
-- Monthly A&E Fact Table
-- ===========================================================

DROP TABLE IF EXISTS gold.fact_ae_monthly;

CREATE TABLE gold.fact_ae_monthly
(
    fact_key            INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    provider_key        INTEGER NOT NULL,

    date_key            INTEGER NOT NULL,

    att_total           INTEGER,

    adm_total           INTEGER,

    pct_4h_all          NUMERIC(5,2),

    dta_gt4h            INTEGER,

    dta_gt12h           INTEGER,

    CONSTRAINT fk_provider

        FOREIGN KEY (provider_key)

        REFERENCES gold.dim_provider(provider_key),

    CONSTRAINT fk_date

        FOREIGN KEY (date_key)

        REFERENCES gold.dim_date(date_key)
);