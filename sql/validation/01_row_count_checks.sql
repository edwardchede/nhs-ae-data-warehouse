-- =============================================================
-- NHS A&E Data Warehouse — Validation Suite
-- =============================================================
-- Purpose: confirm data integrity across Bronze, Silver, and
-- Gold after every load. Run this after main.py and the
-- silver/gold refresh scripts, before trusting the warehouse
-- for analysis.
--
-- A healthy run looks like:
--   - All three row counts match
--   - Duplicate checks return zero rows
--   - Orphan checks return zero rows
--   - Monthly counts fall in the expected ~197-201 range
-- =============================================================


-- -------------------------------------------------------------
-- 1. Row counts across all three layers should match
-- -------------------------------------------------------------
-- Bronze, Silver, and the fact table should all report the same
-- total. A mismatch means a join is fanning out (too many rows)
-- or silently dropping records (too few).

SELECT 'bronze.ae_attendances' AS layer, COUNT(*) AS row_count
FROM bronze.ae_attendances
UNION ALL
SELECT 'silver.ae_attendances', COUNT(*)
FROM silver.ae_attendances
UNION ALL
SELECT 'gold.fact_ae_monthly', COUNT(*)
FROM gold.fact_ae_monthly;


-- -------------------------------------------------------------
-- 2. Row counts per reporting month
-- -------------------------------------------------------------
-- NHS provider counts drift slightly month to month as units
-- open and close. Expect roughly 197-201 rows per month, not
-- an exact fixed number. A count far outside that range
-- (e.g. under 150) suggests a failed or partial file read.

SELECT report_date, COUNT(*) AS providers_reported
FROM silver.ae_attendances
GROUP BY report_date
ORDER BY report_date;


-- -------------------------------------------------------------
-- 3. Duplicate trust codes within a single month (Silver)
-- -------------------------------------------------------------
-- Each provider should appear exactly once per reporting month.
-- Anything returned here indicates a join fan-out from Silver's
-- system_mapping join.

SELECT trust_code, report_date, COUNT(*) AS occurrences
FROM silver.ae_attendances
GROUP BY trust_code, report_date
HAVING COUNT(*) > 1
ORDER BY trust_code, report_date;


-- -------------------------------------------------------------
-- 4. Duplicate codes in the system_mapping reference table
-- -------------------------------------------------------------
-- system_mapping should have exactly one row per provider code.
-- Duplicates here are the single most common cause of Silver
-- row-count inflation.

SELECT code, COUNT(*) AS occurrences
FROM silver.system_mapping
GROUP BY code
HAVING COUNT(*) > 1
ORDER BY code;


-- -------------------------------------------------------------
-- 5. Duplicate trust codes in dim_provider
-- -------------------------------------------------------------
-- dim_provider is a lookup table; each provider should have
-- exactly one surrogate key. Duplicates here cause fan-out
-- when joining into the fact table.

SELECT trust_code, COUNT(*) AS occurrences
FROM gold.dim_provider
GROUP BY trust_code
HAVING COUNT(*) > 1
ORDER BY trust_code;


-- -------------------------------------------------------------
-- 6. Providers present in Silver but missing from dim_provider
-- -------------------------------------------------------------
-- Any row returned here represents data that will be silently
-- excluded from fact_ae_monthly. Usually caused by a new
-- provider appearing in a monthly file that hasn't been added
-- to system_mapping / dim_provider yet.

SELECT DISTINCT s.trust_code, s.trust_name, s.report_date
FROM silver.ae_attendances s
LEFT JOIN gold.dim_provider p ON s.trust_code = p.trust_code
WHERE p.provider_key IS NULL
ORDER BY s.trust_code, s.report_date;


-- -------------------------------------------------------------
-- 7. Providers flagged under the UNMAPPED placeholder ICB
-- -------------------------------------------------------------
-- These are providers with no match in the official
-- system_mapping reference data. Not an error, but worth
-- reviewing periodically in case a proper ICB/region mapping
-- becomes available for them.

SELECT p.trust_code, p.trust_name, p.provider_type
FROM gold.dim_provider p
JOIN gold.dim_icb i ON p.icb_key = i.icb_key
WHERE i.icb_code = 'UNMAPPED'
ORDER BY p.trust_code;


-- -------------------------------------------------------------
-- 8. Missing required fields in Silver
-- -------------------------------------------------------------
-- trust_code, trust_name, and report_date should never be null.
-- Numeric totals being null is sometimes legitimate (a provider
-- with no Type 3 department has no Type 3 percentage), but
-- these three fields should always be populated.

SELECT trust_code, trust_name, report_date
FROM silver.ae_attendances
WHERE trust_code IS NULL
   OR trust_name IS NULL
   OR report_date IS NULL;


-- -------------------------------------------------------------
-- 9. Orphaned fact rows (should be structurally impossible
--    given foreign key constraints, but worth confirming)
-- -------------------------------------------------------------

SELECT f.*
FROM gold.fact_ae_monthly f
LEFT JOIN gold.dim_provider p ON f.provider_key = p.provider_key
WHERE p.provider_key IS NULL;

SELECT f.*
FROM gold.fact_ae_monthly f
LEFT JOIN gold.dim_date d ON f.date_key = d.date_key
WHERE d.date_key IS NULL;


-- -------------------------------------------------------------
-- 10. Sense-check on percentage fields
-- -------------------------------------------------------------
-- pct_4h_all should always fall between 0 and 100. Anything
-- outside that range indicates a numeric cleaning bug (e.g. a
-- stray '%' or thousands separator that wasn't stripped).

SELECT trust_code, report_date, pct_4h_all
FROM silver.ae_attendances
WHERE pct_4h_all IS NOT NULL
  AND (pct_4h_all < 0 OR pct_4h_all > 100);