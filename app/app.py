import os

import pandas as pd
import plotly.express as px
import streamlit as st
from sqlalchemy import create_engine, text
from sqlalchemy.exc import SQLAlchemyError


st.set_page_config(
    page_title="Manufacturing Production & Quality Analytics",
    page_icon="🏭",
    layout="wide",
)


def get_database_url() -> str | None:
    """Resolve the database URL without storing credentials in source code."""

    database_url = os.getenv("DATABASE_URL")
    if database_url:
        return database_url

    try:
        return st.secrets.get("DATABASE_URL")
    except FileNotFoundError:
        return None


@st.cache_resource
def get_engine(database_url: str):
    return create_engine(database_url, pool_pre_ping=True)


@st.cache_data(ttl=300, show_spinner=False)
def load_query(query: str, params: dict[str, object] | None = None) -> pd.DataFrame:
    database_url = get_database_url()
    if not database_url:
        raise RuntimeError(
            "DATABASE_URL is not configured. Set it as an environment variable "
            "or in Streamlit secrets."
        )

    engine = get_engine(database_url)
    with engine.connect() as connection:
        return pd.read_sql_query(text(query), connection, params=params or {})


def load_dashboard_data(
    production_line: str | None = None,
    shift: str | None = None,
    product: str | None = None,
) -> dict[str, pd.DataFrame]:
    line_filter = "WHERE production_line = :production_line" if production_line else ""
    shift_filter = "WHERE shift = :shift" if shift else ""
    product_filter = "WHERE product = :product" if product else ""

    line_shift_filters = []
    line_shift_params: dict[str, object] = {}
    if production_line:
        line_shift_filters.append("production_line = :production_line")
        line_shift_params["production_line"] = production_line
    if shift:
        line_shift_filters.append("shift = :shift")
        line_shift_params["shift"] = shift
    line_shift_where = (
        f"WHERE {' AND '.join(line_shift_filters)}" if line_shift_filters else ""
    )
    base_filters = line_shift_filters.copy()
    base_params = line_shift_params.copy()
    if product:
        base_filters.append("product = :product")
        base_params["product"] = product
    base_where = f"WHERE {' AND '.join(base_filters)}" if base_filters else ""

    return {
        "kpis": load_query(
            f"""
            SELECT
                SUM(production_quantity) AS total_production,
                SUM(defective_units) AS total_defective_units,
                SUM(scrap_units) AS total_scrap_units,
                SUM(good_units) AS total_good_units,
                SUM(good_units)::numeric / NULLIF(SUM(production_quantity), 0)
                    AS yield_rate,
                SUM(defective_units)::numeric / NULLIF(SUM(production_quantity), 0)
                    AS defect_rate,
                SUM(scrap_units)::numeric / NULLIF(SUM(production_quantity), 0)
                    AS scrap_rate,
                SUM(downtime_minutes) AS total_downtime
            FROM v_production_base
            {base_where}
            """,
            base_params or None,
        ),
        "monthly": load_query(
            """
            SELECT *
            FROM v_monthly_production_quality
            ORDER BY month_start
            """
        ),
        "by_line": load_query(
            f"""
            SELECT *
            FROM v_production_by_line
            {line_filter}
            ORDER BY total_production DESC, production_line
            """,
            {"production_line": production_line} if production_line else None,
        ),
        "defect_by_line": load_query(
            f"""
            SELECT *
            FROM v_defect_rate_by_line
            {line_filter}
            ORDER BY defect_rate DESC NULLS LAST, production_line
            """,
            {"production_line": production_line} if production_line else None,
        ),
        "by_shift": load_query(
            f"""
            SELECT *
            FROM v_production_by_shift
            {shift_filter}
            ORDER BY shift_sort_order
            """,
            {"shift": shift} if shift else None,
        ),
        "defect_by_product": load_query(
            f"""
            SELECT *
            FROM v_defect_rate_by_product
            {product_filter}
            ORDER BY defect_rate DESC NULLS LAST, product
            """,
            {"product": product} if product else None,
        ),
        "scrap_by_product": load_query(
            f"""
            SELECT *
            FROM v_scrap_rate_by_product
            {product_filter}
            ORDER BY scrap_rate DESC NULLS LAST, product
            """,
            {"product": product} if product else None,
        ),
        "downtime": load_query(
            """
            SELECT *
            FROM v_downtime_by_reason
            ORDER BY total_downtime_minutes DESC, downtime_reason_clean
            """
        ),
        "line_shift": load_query(
            f"""
            SELECT *
            FROM v_line_shift_performance
            {line_shift_where}
            ORDER BY production_line, shift_sort_order
            """,
            line_shift_params or None,
        ),
    }


def format_rate(value: object) -> str:
    return "-" if pd.isna(value) else f"{float(value):.2%}"


def format_number(value: object, suffix: str = "") -> str:
    return "-" if pd.isna(value) else f"{float(value):,.0f}{suffix}"


def show_chart(title: str, figure) -> None:
    st.subheader(title)
    st.plotly_chart(figure, use_container_width=True)


st.title("Manufacturing Production & Quality Analytics")
st.caption("Production, quality, defects, scrap, and downtime analysis")

database_url = get_database_url()
if not database_url:
    st.error(
        "PostgreSQL is not configured. Set DATABASE_URL as an environment variable "
        "or in Streamlit secrets before starting the dashboard."
    )
    st.stop()

try:
    engine = get_engine(database_url)
    with engine.connect() as connection:
        connection.execute(text("SELECT 1"))
except (SQLAlchemyError, RuntimeError) as error:
    st.error(
        "The dashboard could not connect to PostgreSQL. Check DATABASE_URL and "
        "confirm that the analytical views have been created."
    )
    st.stop()

try:
    reference_data = {
        "lines": load_query(
            "SELECT DISTINCT production_line FROM v_production_by_line "
            "ORDER BY production_line"
        ),
        "shifts": load_query(
            "SELECT shift, shift_sort_order FROM v_production_by_shift "
            "ORDER BY shift_sort_order"
        ),
        "products": load_query(
            "SELECT DISTINCT product FROM v_production_by_product ORDER BY product"
        ),
    }

    with st.sidebar:
        st.header("Filters")
        selected_line = st.selectbox(
            "Production line",
            ["All"] + reference_data["lines"]["production_line"].tolist(),
        )
        selected_shift = st.selectbox(
            "Shift",
            ["All"] + reference_data["shifts"]["shift"].tolist(),
        )
        selected_product = st.selectbox(
            "Product",
            ["All"] + reference_data["products"]["product"].tolist(),
        )

    data = load_dashboard_data(
        production_line=None if selected_line == "All" else selected_line,
        shift=None if selected_shift == "All" else selected_shift,
        product=None if selected_product == "All" else selected_product,
    )

    if data["kpis"].empty:
        st.info("No data is available for the selected filters.")
        st.stop()

    kpis = data["kpis"].iloc[0]
    metric_rows = [
        ("Total Production", format_number(kpis["total_production"])),
        ("Total Defective Units", format_number(kpis["total_defective_units"])),
        ("Total Scrap Units", format_number(kpis["total_scrap_units"])),
        ("Yield Rate", format_rate(kpis["yield_rate"])),
        ("Defect Rate", format_rate(kpis["defect_rate"])),
        ("Scrap Rate", format_rate(kpis["scrap_rate"])),
        ("Total Downtime", format_number(kpis["total_downtime"], " min")),
    ]
    first_row = st.columns(4)
    second_row = st.columns(3)
    for column, (label, value) in zip(first_row + second_row, metric_rows):
        column.metric(label, value)

    monthly = data["monthly"]
    if not monthly.empty:
        monthly_long = monthly.melt(
            id_vars="month_start",
            value_vars=["total_production", "total_good_units", "total_defective_units", "total_scrap_units"],
            var_name="measure",
            value_name="units",
        )
        show_chart(
            "Monthly Production and Quality Trend",
            px.line(monthly_long, x="month_start", y="units", color="measure", markers=True),
        )

    left, right = st.columns(2)
    with left:
        by_line = data["by_line"]
        if not by_line.empty:
            show_chart(
                "Production by Line",
                px.bar(by_line, x="production_line", y="total_production", text_auto=True),
            )
    with right:
        defect_by_line = data["defect_by_line"]
        if not defect_by_line.empty:
            show_chart(
                "Defect Rate by Line",
                px.bar(defect_by_line, x="production_line", y="defect_rate", text_auto=".2%"),
            )

    left, right = st.columns(2)
    with left:
        by_shift = data["by_shift"]
        if not by_shift.empty:
            show_chart(
                "Production by Shift",
                px.bar(by_shift, x="shift", y="total_production", text_auto=True),
            )
    with right:
        defect_by_product = data["defect_by_product"]
        if not defect_by_product.empty:
            show_chart(
                "Defect Rate by Product",
                px.bar(defect_by_product, x="product", y="defect_rate", text_auto=".2%"),
            )

    left, right = st.columns(2)
    with left:
        scrap_by_product = data["scrap_by_product"]
        if not scrap_by_product.empty:
            show_chart(
                "Scrap Rate by Product",
                px.bar(scrap_by_product, x="product", y="scrap_rate", text_auto=".2%"),
            )
    with right:
        downtime = data["downtime"]
        if not downtime.empty:
            show_chart(
                "Downtime by Reason",
                px.bar(
                    downtime,
                    x="total_downtime_minutes",
                    y="downtime_reason_clean",
                    orientation="h",
                    text_auto=True,
                ),
            )

    st.subheader("Line × Shift Performance")
    if data["line_shift"].empty:
        st.info("No line × shift data is available for the selected filters.")
    else:
        st.dataframe(data["line_shift"], use_container_width=True, hide_index=True)
except (SQLAlchemyError, RuntimeError) as error:
    st.error(
        "A PostgreSQL query failed. Check the database connection and analytical "
        "view definitions."
    )
