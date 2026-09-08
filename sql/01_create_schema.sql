CREATE TABLE IF NOT EXISTS manufacturing_production (
    record_id INTEGER PRIMARY KEY,
    date DATE NOT NULL,
    shift VARCHAR(20) NOT NULL,
    production_line VARCHAR(20) NOT NULL,
    product VARCHAR(50) NOT NULL,
    production_quantity INTEGER NOT NULL,
    defective_units INTEGER NOT NULL,
    scrap_units INTEGER NOT NULL,
    downtime_minutes NUMERIC(10,2) NOT NULL,
    defect_category VARCHAR(50),
    downtime_reason VARCHAR(100),
    good_units INTEGER,
    defect_rate NUMERIC(10,4),
    scrap_rate NUMERIC(10,4)
);
