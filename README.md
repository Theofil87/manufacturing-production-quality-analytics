# Manufacturing Production & Quality Analytics

An end-to-end manufacturing data analytics portfolio project focused on production performance, product quality, defects, scrap, downtime, and operational performance.

The project demonstrates a complete analytics workflow from raw manufacturing data through data cleaning, validation, exploratory analysis, SQL analytics, Power BI reporting, and an interactive Streamlit application.

---

## Project Overview

Manufacturing operations generate large amounts of production and quality data. This project demonstrates how these data can be transformed into actionable analytical insights.

The analysis focuses on:

- Production volume
- Production quality
- Defect rates
- Scrap rates
- Yield
- Downtime
- Production line performance
- Shift performance
- Product performance
- Line × Shift interactions
- Trends over time
- Data reconciliation and validation

The project is designed as a portfolio example for manufacturing data analytics and operational intelligence.

---

## Business Questions

The project addresses the following business questions:

### Production

- How much is being produced?
- How does production volume change over time?
- Which production lines have the highest production volume?
- Which products contribute most to production?

### Quality

- What is the overall defect rate?
- How does defect rate differ between production lines?
- How does defect rate differ between products and shifts?
- What are the major defect categories?

### Scrap

- What is the overall scrap rate?
- How does scrap rate vary by product and shift?
- Which products generate higher scrap levels?

### Downtime

- How much production downtime is recorded?
- What are the main downtime reasons?
- How does downtime change over time?
- How does downtime vary across production lines and shifts?

### Operational Performance

- How does performance differ between production lines?
- How does shift performance vary?
- Are there meaningful differences between Line × Shift combinations?

---

## Technology Stack

- Python
- Pandas
- NumPy
- SciPy
- Jupyter Notebook
- SQL
- PostgreSQL
- Power BI
- DAX
- Power Query
- Streamlit
- GitHub
- VS Code

---

## Data Pipeline

```text
Raw Manufacturing Data
        |
        v
Python Data Cleaning
        |
        v
Data Validation
        |
        v
Processed Manufacturing Dataset
        |
        +----------------------+
        |                      |
        v                      v
   Jupyter / EDA          PostgreSQL / SQL
        |                      |
        +----------+-----------+
                   |
                   v
              Analytics
                   |
          +--------+--------+
          |                 |
          v                 v
      Power BI          Streamlit
      Dashboard         Application

Dataset

The processed dataset contains 3,285 manufacturing production records.

Key fields include:

- record_id
- date
- shift
- production_line
- product
- production_quantity
- defective_units
- scrap_units
- downtime_minutes
- defect_category
- downtime_reason
- good_units
- defect_rate
- scrap_rate

The raw and processed datasets are stored separately to maintain a clear data-processing workflow.

Data Cleaning & Validation

The Python data-processing pipeline performs several validation steps before the dataset is used for analytics.

Validation includes:

- Required column validation
- Missing-value checks
- Numeric data type validation
- Production quantity validation
- Defective unit validation
- Scrap unit validation
- Downtime validation
- Good unit calculation
- Defect rate calculation
- Scrap rate calculation
- Production reconciliation

The processing pipeline reports successful completion only after the validation checks pass.

Data Reconciliation

Good Units, Defective Units, and Scrap Units are treated as mutually exclusive categories.

Therefore:

Production Quantity
=
Good Units
+
Defective Units
+
Scrap Units

The reconciliation gap is calculated as:

Production
- Good Units
- Defective Units
- Scrap Units

A reconciliation gap of zero indicates that production quantities are fully reconciled.

This validation is implemented in Power BI using:

- Reconciliation Gap
- Reconciliation Status

These measures are used as data-quality controls rather than primary business KPIs.

Downtime Business Rule

The source data contains records where downtime_reason is missing.

The analysis identified that these records correspond to downtime below 15 minutes.

Therefore, missing downtime reasons are intentionally represented in the analytical layer as:

No Reason Recorded

This preserves the distinction between:

- a recorded downtime reason
- downtime where no reason was recorded

The transformation is implemented through the downtime_reason_clean field.

Key KPIs

The Power BI semantic model contains the following core KPIs:

- Total Production
- Total Defective Units
- Total Scrap Units
- Defect Rate
- Scrap Rate
- Yield Rate
- Total Downtime Minutes
- KPI Definitions

Defect Rate

        Total Defective Units / Total Production

Scrap Rate

        Total Scrap Units / Total Production

Yield Rate

        Good Units / Total Production

Total Downtime

        SUM(Downtime Minutes)

Rates are calculated from aggregated quantities rather than averaging row-level percentages.

Exploratory Data Analysis

The Jupyter Notebook contains exploratory analysis covering:

- Dataset structure
- Missing values
- Production volume
- Production line performance
- Defect rates
- Shift performance
- Normalized downtime analysis
- Defect category Pareto analysis
- Downtime reason analysis
- Product performance
- Line × Shift analysis
- Time-based trends
- Data-driven observations and limitations

The EDA is descriptive and focuses on identifying patterns rather than making unsupported causal claims.

Power BI Dashboard

The Power BI report contains four analytical pages.

1. Executive Overview

Provides a high-level view of manufacturing performance.

Includes:

Total Production
Total Defective Units
Total Scrap Units
Defect Rate
Scrap Rate
Yield Rate
Production Trend over Time
Product slicer
Production Line slicer
Shift slicer
Date range slicer

2. Production & Quality

Focuses on production, quality, product performance, and downtime.

Includes:

Production by Production Line
Defect Rate by Production Line
Total Downtime Minutes by Reason
Defect Rate by Product
Scrap Rate by Product

3. Line × Shift Performance

Analyzes the interaction between production lines and shifts.

Includes:

Production by Line and Shift
Defect Rate by Line and Shift
Scrap Rate by Line and Shift
Defect Rate Trend over Time
Scrap Rate Trend over Time
Total Downtime Trend over Time

4. Shift Performance

Provides a focused comparison of manufacturing shifts.

Includes:

Production by Shift
Defect Rate by Shift
Scrap Rate by Shift

Shift order is explicitly controlled using:

Morning
Afternoon
Night

Power BI Data Model

The Power BI model uses a simple structure centered around the processed manufacturing production table.

Key characteristics:

- Import mode
- Single primary manufacturing fact table
- Power BI date table
- Date relationship
- Explicit DAX measures
- Power Query transformations
- Dedicated shift sorting column

The model intentionally remains relatively simple because the current dataset does not require a complex dimensional model.


