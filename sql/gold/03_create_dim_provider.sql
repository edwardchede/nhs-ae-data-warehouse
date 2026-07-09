-- ===========================================================
-- Provider Dimension
-- ===========================================================

DROP TABLE IF EXISTS gold.dim_provider CASCADE;

CREATE TABLE gold.dim_provider
(
    provider_key    INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    trust_code      VARCHAR(10) UNIQUE NOT NULL,

    trust_name      VARCHAR(255) NOT NULL,

    icb_key         INTEGER,

    provider_type   VARCHAR(50),

    CONSTRAINT fk_provider_icb
        FOREIGN KEY (icb_key)
        REFERENCES gold.dim_icb(icb_key)
);