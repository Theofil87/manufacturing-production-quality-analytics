-- Load the processed manufacturing data into PostgreSQL.
-- Execute from the repository root with psql, for example:
--   psql -d manufacturing -f sql/02_load_data.sql
-- The \copy command reads the CSV from the client machine.

BEGIN;

CREATE TEMP TABLE manufacturing_production_load (
    record_id INTEGER,
    date DATE,
    shift VARCHAR(20),
    production_line VARCHAR(20),
    product VARCHAR(50),
    production_quantity INTEGER,
    defective_units INTEGER,
    scrap_units INTEGER,
    downtime_minutes NUMERIC(10,2),
    defect_category VARCHAR(50),
    downtime_reason VARCHAR(100),
    good_units INTEGER,
    defect_rate NUMERIC(10,4),
    scrap_rate NUMERIC(10,4)
);

\copy manufacturing_production_load (record_id, date, shift, production_line, product, production_quantity, defective_units, scrap_units, downtime_minutes, defect_category, downtime_reason, good_units, defect_rate, scrap_rate) FROM 'data/processed/manufacturing_production_cleaned.csv' WITH (FORMAT csv, HEADER true, NULL '');

DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM manufacturing_production_load
        WHERE record_id IS NULL
           OR date IS NULL
           OR shift IS NULL
           OR production_line IS NULL
           OR product IS NULL
           OR production_quantity IS NULL
           OR defective_units IS NULL
           OR scrap_units IS NULL
           OR downtime_minutes IS NULL
           OR good_units IS NULL
    ) THEN
        RAISE EXCEPTION 'Required values are missing in the processed CSV';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM manufacturing_production_load
        WHERE production_quantity < 0
           OR defective_units < 0
           OR scrap_units < 0
           OR good_units < 0
           OR downtime_minutes < 0
    ) THEN
        RAISE EXCEPTION 'Negative production, quality, or downtime values found';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM manufacturing_production_load
        GROUP BY record_id
        HAVING COUNT(*) > 1
    ) THEN
        RAISE EXCEPTION 'Duplicate record_id values found in the processed CSV';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM manufacturing_production_load
        WHERE production_quantity <> good_units + defective_units + scrap_units
    ) THEN
        RAISE EXCEPTION 'Production reconciliation failed in the processed CSV';
    END IF;
END;
$$;

INSERT INTO manufacturing_production (
    record_id,
    date,
    shift,
    production_line,
    product,
    production_quantity,
    defective_units,
    scrap_units,
    downtime_minutes,
    defect_category,
    downtime_reason,
    good_units,
    defect_rate,
    scrap_rate
)
SELECT
    record_id,
    date,
    shift,
    production_line,
    product,
    production_quantity,
    defective_units,
    scrap_units,
    downtime_minutes,
    defect_category,
    downtime_reason,
    good_units,
    defect_rate,
    scrap_rate
FROM manufacturing_production_load
ON CONFLICT (record_id) DO UPDATE SET
    date = EXCLUDED.date,
    shift = EXCLUDED.shift,
    production_line = EXCLUDED.production_line,
    product = EXCLUDED.product,
    production_quantity = EXCLUDED.production_quantity,
    defective_units = EXCLUDED.defective_units,
    scrap_units = EXCLUDED.scrap_units,
    downtime_minutes = EXCLUDED.downtime_minutes,
    defect_category = EXCLUDED.defect_category,
    downtime_reason = EXCLUDED.downtime_reason,
    good_units = EXCLUDED.good_units,
    defect_rate = EXCLUDED.defect_rate,
    scrap_rate = EXCLUDED.scrap_rate;

COMMIT;