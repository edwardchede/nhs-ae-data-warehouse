TRUNCATE TABLE gold.dim_date;

INSERT INTO gold.dim_date
(
    date_key,
    report_date,
    calendar_year,
    calendar_month,
    month_name,
    calendar_quarter,
    financial_year,
    financial_month,
    financial_quarter
)

SELECT

    TO_CHAR(d,'YYYYMMDD')::INTEGER,

    d,

    EXTRACT(YEAR FROM d)::INTEGER,

    EXTRACT(MONTH FROM d)::INTEGER,

    TRIM(TO_CHAR(d,'Month')),

    EXTRACT(QUARTER FROM d)::INTEGER,

    CASE

        WHEN EXTRACT(MONTH FROM d) >= 4 THEN

            EXTRACT(YEAR FROM d)::TEXT
            || '/'
            || RIGHT((EXTRACT(YEAR FROM d)+1)::TEXT,2)

        ELSE

            (EXTRACT(YEAR FROM d)-1)::TEXT
            || '/'
            || RIGHT(EXTRACT(YEAR FROM d)::TEXT,2)

    END,

    CASE

        WHEN EXTRACT(MONTH FROM d) >=4

            THEN EXTRACT(MONTH FROM d)-3

        ELSE

            EXTRACT(MONTH FROM d)+9

    END,

    CASE

        WHEN EXTRACT(MONTH FROM d) BETWEEN 4 AND 6 THEN 1

        WHEN EXTRACT(MONTH FROM d) BETWEEN 7 AND 9 THEN 2

        WHEN EXTRACT(MONTH FROM d) BETWEEN 10 AND 12 THEN 3

        ELSE 4

    END

FROM generate_series(

    '2023-04-01'::DATE,

    '2027-03-31'::DATE,

    INTERVAL '1 day'

) d;