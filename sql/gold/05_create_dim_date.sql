-- ===========================================================
-- Date Dimension
-- ===========================================================

DROP TABLE IF EXISTS gold.dim_date CASCADE;

CREATE TABLE gold.dim_date
(
    date_key            INTEGER PRIMARY KEY,

    report_date         DATE NOT NULL UNIQUE,

    calendar_year       INTEGER,

    calendar_month      INTEGER,

    month_name          VARCHAR(20),

    calendar_quarter    INTEGER,

    financial_year      VARCHAR(7),

    financial_month     INTEGER,

    financial_quarter   INTEGER
);