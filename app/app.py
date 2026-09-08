import streamlit as st
import pandas as pd

st.set_page_config(page_title="Manufacturing Production & Quality Analytics", layout="wide")

st.title("🏭 Manufacturing Production & Quality Analytics")
st.caption("Interactive dashboard for production, quality, defects and downtime analysis")

@st.cache_data
def load_data():
    return pd.read_csv("data/processed/manufacturing_production_cleaned.csv", parse_dates=["date"])

try:
    df = load_data()
    total_production = int(df["production_quantity"].sum())
    defect_rate = df["defective_units"].sum() / df["production_quantity"].sum()
    downtime = float(df["downtime_minutes"].sum())

    col1, col2, col3 = st.columns(3)
    col1.metric("Total Production", f"{total_production:,}")
    col2.metric("Defect Rate", f"{defect_rate:.2%}")
    col3.metric("Total Downtime", f"{downtime:,.0f} min")

    st.line_chart(df.groupby("date")["production_quantity"].sum())
except FileNotFoundError:
    st.info("Processed dataset not available yet. Run the data processing pipeline first.")
