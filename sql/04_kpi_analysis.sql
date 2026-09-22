-- Core KPI queries.
-- Rates are calculated from aggregated unit totals, matching Power BI measures.

-- Overall KPI summary.
SELECT
    SUM(production_quantity) AS total_production,
    SUM(defective_units) AS total_defective_units,
    SUM(scrap_units) AS total_scrap_units,
    SUM(good_units) AS total_good_units,
    SUM(good_units)::numeric / NULLIF(SUM(production_quantity), 0) AS yield_rate,
    SUM(defective_units)::numeric / NULLIF(SUM(production_quantity), 0) AS defect_rate,
    SUM(scrap_units)::numeric / NULLIF(SUM(production_quantity), 0) AS scrap_rate,
    SUM(downtime_minutes) AS total_downtime_minutes
FROM v_production_base;

-- Production by production line.
SELECT *
FROM v_production_by_line
ORDER BY total_production DESC, production_line;

-- Production by shift, using the Power BI shift sort order.
SELECT *
FROM v_production_by_shift
ORDER BY shift_sort_order;

-- Production by product.
SELECT *
FROM v_production_by_product
ORDER BY total_production DESC, product;

-- Monthly production trends.
SELECT *
FROM v_monthly_production_quality
ORDER BY month_start;

-- Production reconciliation summary.
SELECT
    SUM(production_quantity) AS total_production,
    SUM(good_units) AS total_good_units,
    SUM(defective_units) AS total_defective_units,
    SUM(scrap_units) AS total_scrap_units,
    SUM(production_quantity)
        - SUM(good_units)
        - SUM(defective_units)
        - SUM(scrap_units) AS reconciliation_gap,
    CASE
        WHEN SUM(production_quantity)
             - SUM(good_units)
             - SUM(defective_units)
             - SUM(scrap_units) = 0
            THEN 'OK'
        ELSE 'Check Data'
    END AS reconciliation_status
FROM v_production_base;