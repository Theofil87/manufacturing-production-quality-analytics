-- Detailed production and quality analysis queries.

-- Defect rate by production line.
SELECT *
FROM v_defect_rate_by_line
ORDER BY defect_rate DESC NULLS LAST, production_line;

-- Defect rate by product.
SELECT *
FROM v_defect_rate_by_product
ORDER BY defect_rate DESC NULLS LAST, product;

-- Scrap rate by product.
SELECT *
FROM v_scrap_rate_by_product
ORDER BY scrap_rate DESC NULLS LAST, product;

-- Downtime by normalized reason.
SELECT *
FROM v_downtime_by_reason
ORDER BY total_downtime_minutes DESC, downtime_reason_clean;

-- Production and quality performance by line and shift.
SELECT *
FROM v_line_shift_performance
ORDER BY production_line, shift_sort_order;

-- Monthly quality trends.
SELECT *
FROM v_monthly_quality_trends
ORDER BY month_start;

-- Production reconciliation by record.
SELECT *
FROM v_production_reconciliation
ORDER BY reconciliation_status DESC, record_id;

-- Defect category analysis. NULL categories remain visible as unclassified.
SELECT
    COALESCE(NULLIF(BTRIM(defect_category), ''), 'Unclassified') AS defect_category_clean,
    SUM(production_quantity) AS total_production,
    SUM(defective_units) AS total_defective_units,
    SUM(defective_units)::numeric / NULLIF(SUM(production_quantity), 0)
        AS defect_rate
FROM v_production_base
GROUP BY COALESCE(NULLIF(BTRIM(defect_category), ''), 'Unclassified')
ORDER BY defect_rate DESC NULLS LAST, defect_category_clean;

-- Monthly production reconciliation detail.
SELECT
    month_start,
    SUM(production_quantity) AS total_production,
    SUM(good_units) AS total_good_units,
    SUM(defective_units) AS total_defective_units,
    SUM(scrap_units) AS total_scrap_units,
    SUM(production_quantity)
        - SUM(good_units)
        - SUM(defective_units)
        - SUM(scrap_units) AS reconciliation_gap
FROM v_production_base
GROUP BY month_start
ORDER BY month_start;