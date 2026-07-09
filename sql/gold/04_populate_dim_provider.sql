-- ===========================================================
-- Populate Provider Dimension
-- ===========================================================

TRUNCATE TABLE gold.dim_provider
RESTART IDENTITY CASCADE;

INSERT INTO gold.dim_provider
(
    trust_code,
    trust_name,
    icb_key,
    provider_type
)

SELECT DISTINCT

    a.trust_code,

    TRIM(a.trust_name),

    i.icb_key,

    CASE

        WHEN a.att_type1 > 0
            THEN 'Major Emergency Department'

        WHEN a.att_type2 > 0
            THEN 'Single Specialty A&E'

        WHEN a.att_type3 > 0
            THEN 'Minor Injury Unit / UTC'

        WHEN a.att_total = 0
            THEN 'Specialist Provider'

        ELSE 'Other'

    END

FROM silver.ae_attendances a

LEFT JOIN silver.system_mapping m
    ON a.trust_code = m.code

LEFT JOIN gold.dim_icb i
    ON m.icb_code = i.icb_code

ORDER BY trust_name;