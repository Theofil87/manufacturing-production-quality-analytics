# Manufacturing Production & Quality Analytics

End-to-end **manufacturing data analytics** project focused on production performance, quality, defects, scrap, downtime and operational KPIs.

The project demonstrates a complete workflow from raw production data through **Python data preparation, PostgreSQL/SQL analytics, Power BI reporting and Streamlit visualization**.

## 🚀 Live Demo

**Streamlit dashboard:**  
https://manufacturing-quality-analytics.streamlit.app

**Repository:**  
https://github.com/Theofil87/manufacturing-production-quality-analytics

## 🎯 Business Questions

The project explores questions such as:

- How does production volume change over time?
- Which lines, shifts and products contribute most to production?
- What are the defect and scrap rates?
- Which defect categories occur most frequently?
- Where is downtime concentrated?
- How does performance differ across lines and shifts?
- Are production and quality KPIs internally reconciled?

## 🔧 What I Built

### Data preparation
- Python / Pandas cleaning pipeline
- Required-column and data-type validation
- Missing-value checks
- Production reconciliation
- Derived quality and production metrics

### SQL analytics
- PostgreSQL analytical layer
- Reusable SQL views
- KPI calculations
- Production, quality, scrap and downtime analysis
- Line × Shift analysis

### Business Intelligence
- Power BI semantic model
- DAX measures
- Power Query transformations
- Executive and operational dashboards
- Consistent KPI definitions across reporting layers

### Interactive analytics
- PostgreSQL-backed Streamlit application
- Interactive filters
- KPI cards
- Production and quality trends
- Defect and downtime analysis
- Plotly visualizations

## 🏗️ Architecture

```text
Raw Manufacturing CSV
        │
        ▼
Python / Pandas
Cleaning & Validation
        │
        ▼
Processed Data
        │
        ▼
PostgreSQL / SQL
Analytical Views
        │
   ┌────┴─────┐
   ▼          ▼
Power BI   Streamlit
   │          │
   └────┬─────┘
        ▼
Manufacturing KPIs
& Operational Insights
```

## 📊 Key KPIs

- Total Production
- Total Defective Units
- Total Scrap Units
- Defect Rate
- Scrap Rate
- Yield Rate
- Total Downtime

Rates are calculated from aggregated quantities rather than averaging row-level percentages.

### Data reconciliation

```text
Production Quantity
=
Good Units
+
Defective Units
+
Scrap Units
```

A reconciliation gap of zero indicates that the production quantities are internally reconciled.

## 🛠️ Technology Stack

- Python
- Pandas
- NumPy
- SciPy
- Jupyter Notebook
- SQL
- PostgreSQL
- SQLAlchemy
- Power BI
- DAX
- Power Query
- Plotly
- Streamlit
- Git / GitHub

## 📁 Project Structure

```text
manufacturing-production-quality-analytics/
├── app/
├── data/
│   ├── raw/
│   └── processed/
├── notebooks/
├── powerbi/
├── sql/
├── src/
├── tests/
├── requirements.txt
└── README.md
```

## 🔍 Why This Project Matters

The project demonstrates more than dashboard creation. It shows an end-to-end analytical workflow:

```text
Data
 ↓
Cleaning
 ↓
Validation
 ↓
Exploration
 ↓
SQL Analytics
 ↓
Semantic Modeling
 ↓
DAX
 ↓
Visualization
 ↓
Operational Insights
```

It is designed to demonstrate practical skills relevant to **Data Analyst, Manufacturing Data Analyst, Operations Data Analyst and BI Analyst** roles.

## 📌 Data & Limitations

The dataset is synthetic and designed for portfolio demonstration.

The analysis is primarily descriptive and does not establish causal relationships. Deeper predictive or root-cause analysis would require additional machine-, process-, material- and event-level data.

## 🚧 Project Status

🟢 Python cleaning and EDA completed  
🟢 PostgreSQL analytics completed  
🟢 Power BI dashboard completed  
🟢 Streamlit PostgreSQL integration completed  
🟢 Data reconciliation and validation implemented

## 🔮 Future Extensions

- Statistical Process Control
- Automated control-chart monitoring
- Predictive quality analytics
- Anomaly detection
- OEE when the required inputs are available
- Automated data pipelines
- CI/CD and automated testing

## 👤 Author

**Béla Páger**

Materials Engineer · Data Analyst · Manufacturing & Quality Analytics

GitHub: https://github.com/Theofil87
