-- Reusable analytical views for production and quality reporting.

CREATE OR REPLACE VIEW v_production_base AS
SELECT
    record_id,
    date,
    DATE_TRUNC('month', date)::date AS month_start,
    shift,
    CASE shift
        WHEN 'Morning' THEN 1
        WHEN 'Afternoon' THEN 2
        WHEN 'Night' THEN 3
        ELSE 99
    END AS shift_sort_order,
    production_line,
    product,
    production_quantity,
    good_units,
    defective_units,
    scrap_units,
    downtime_minutes,
    defect_category,
    downtime_reason,
    COALESCE(NULLIF(BTRIM(downtime_reason), ''), 'No Reason Recorded')
        AS downtime_reason_clean,
    defective_units::numeric / NULLIF(production_quantity, 0) AS row_defect_rate,
    scrap_units::numeric / NULLIF(production_quantity, 0) AS row_scrap_rate,
    good_units::numeric / NULLIF(production_quantity, 0) AS row_yield_rate,
    production_quantity - good_units - defective_units - scrap_units
        AS reconciliation_gap,
    CASE
        WHEN production_quantity - good_units - defective_units - scrap_units = 0
            THEN 'OK'
        ELSE 'Check Data'
    END AS reconciliation_status
FROM manufacturing_production;

CREATE OR REPLACE VIEW v_monthly_production_quality AS
SELECT
    month_start,
    SUM(production_quantity) AS total_production,
    SUM(good_units) AS total_good_units,
    SUM(defective_units) AS total_defective_units,
    SUM(scrap_units) AS total_scrap_units,
    SUM(good_units)::numeric / NULLIF(SUM(production_quantity), 0) AS yield_rate,
    SUM(defective_units)::numeric / NULLIF(SUM(production_quantity), 0) AS defect_rate,
    SUM(scrap_units)::numeric / NULLIF(SUM(production_quantity), 0) AS scrap_rate,
    SUM(downtime_minutes) AS total_downtime_minutes,
    SUM(production_quantity)
        - SUM(good_units)
        - SUM(defective_units)
        - SUM(scrap_units) AS reconciliation_gap
FROM v_production_base
GROUP BY month_start;

CREATE OR REPLACE VIEW v_production_by_line AS
SELECT
    production_line,
    SUM(production_quantity) AS total_production,
    SUM(good_units) AS total_good_units,
    SUM(defective_units) AS total_defective_units,
    SUM(scrap_units) AS total_scrap_units,
    SUM(good_units)::numeric / NULLIF(SUM(production_quantity), 0) AS yield_rate,
    SUM(defective_units)::numeric / NULLIF(SUM(production_quantity), 0) AS defect_rate,
    SUM(scrap_units)::numeric / NULLIF(SUM(production_quantity), 0) AS scrap_rate,
    SUM(downtime_minutes) AS total_downtime_minutes
FROM v_production_base
GROUP BY production_line;

CREATE OR REPLACE VIEW v_production_by_shift AS
SELECT
    shift,
    shift_sort_order,
    SUM(production_quantity) AS total_production,
    SUM(good_units) AS total_good_units,
    SUM(defective_units) AS total_defective_units,
    SUM(scrap_units) AS total_scrap_units,
    SUM(good_units)::numeric / NULLIF(SUM(production_quantity), 0) AS yield_rate,
    SUM(defective_units)::numeric / NULLIF(SUM(production_quantity), 0) AS defect_rate,
    SUM(scrap_units)::numeric / NULLIF(SUM(production_quantity), 0) AS scrap_rate,
    SUM(downtime_minutes) AS total_downtime_minutes
FROM v_production_base
GROUP BY shift, shift_sort_order;

CREATE OR REPLACE VIEW v_production_by_product AS
SELECT
    product,
    SUM(production_quantity) AS total_production,
    SUM(good_units) AS total_good_units,
    SUM(defective_units) AS total_defective_units,
    SUM(scrap_units) AS total_scrap_units,
    SUM(good_units)::numeric / NULLIF(SUM(production_quantity), 0) AS yield_rate,
    SUM(defective_units)::numeric / NULLIF(SUM(production_quantity), 0) AS defect_rate,
    SUM(scrap_units)::numeric / NULLIF(SUM(production_quantity), 0) AS scrap_rate,
    SUM(downtime_minutes) AS total_downtime_minutes
FROM v_production_base
GROUP BY product;

CREATE OR REPLACE VIEW v_defect_rate_by_line AS
SELECT
    production_line,
    SUM(production_quantity) AS total_production,
    SUM(defective_units) AS total_defective_units,
    SUM(defective_units)::numeric / NULLIF(SUM(production_quantity), 0)
        AS defect_rate
FROM v_production_base
GROUP BY production_line;

CREATE OR REPLACE VIEW v_defect_rate_by_product AS
SELECT
    product,
    SUM(production_quantity) AS total_production,
    SUM(defective_units) AS total_defective_units,
    SUM(defective_units)::numeric / NULLIF(SUM(production_quantity), 0)
        AS defect_rate
FROM v_production_base
GROUP BY product;

CREATE OR REPLACE VIEW v_scrap_rate_by_product AS
SELECT
    product,
    SUM(production_quantity) AS total_production,
    SUM(scrap_units) AS total_scrap_units,
    SUM(scrap_units)::numeric / NULLIF(SUM(production_quantity), 0)
        AS scrap_rate
FROM v_production_base
GROUP BY product;

CREATE OR REPLACE VIEW v_downtime_by_reason AS
SELECT
    downtime_reason_clean,
    SUM(downtime_minutes) AS total_downtime_minutes,
    COUNT(*) AS record_count
FROM v_production_base
GROUP BY downtime_reason_clean;

CREATE OR REPLACE VIEW v_line_shift_performance AS
SELECT
    production_line,
    shift,
    shift_sort_order,
    SUM(production_quantity) AS total_production,
    SUM(good_units) AS total_good_units,
    SUM(defective_units) AS total_defective_units,
    SUM(scrap_units) AS total_scrap_units,
    SUM(good_units)::numeric / NULLIF(SUM(production_quantity), 0) AS yield_rate,
    SUM(defective_units)::numeric / NULLIF(SUM(production_quantity), 0) AS defect_rate,
    SUM(scrap_units)::numeric / NULLIF(SUM(production_quantity), 0) AS scrap_rate,
    SUM(downtime_minutes) AS total_downtime_minutes,
    SUM(production_quantity)
        - SUM(good_units)
        - SUM(defective_units)
        - SUM(scrap_units) AS reconciliation_gap
FROM v_production_base
GROUP BY production_line, shift, shift_sort_order;

CREATE OR REPLACE VIEW v_monthly_quality_trends AS
SELECT
    month_start,
    SUM(good_units) AS total_good_units,
    SUM(defective_units) AS total_defective_units,
    SUM(scrap_units) AS total_scrap_units,
    SUM(production_quantity) AS total_production,
    SUM(good_units)::numeric / NULLIF(SUM(production_quantity), 0) AS yield_rate,
    SUM(defective_units)::numeric / NULLIF(SUM(production_quantity), 0) AS defect_rate,
    SUM(scrap_units)::numeric / NULLIF(SUM(production_quantity), 0) AS scrap_rate
FROM v_production_base
GROUP BY month_start;

CREATE OR REPLACE VIEW v_production_reconciliation AS
SELECT
    record_id,
    date,
    production_line,
    product,
    production_quantity,
    good_units,
    defective_units,
    scrap_units,
    reconciliation_gap,
    reconciliation_status
FROM v_production_base;