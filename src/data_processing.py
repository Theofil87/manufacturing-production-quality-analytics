"""Data cleaning and transformation utilities for the manufacturing analytics project."""

from pathlib import Path
import pandas as pd


RAW_DATA_PATH = Path("data/raw/manufacturing_production_raw.csv")
PROCESSED_DATA_PATH = Path(
    "data/processed/manufacturing_production_cleaned.csv"
)


def validate_manufacturing_data(df: pd.DataFrame) -> None:
    """Validate the manufacturing data for required columns and data types."""

    required_columns = [
        "date",
        "production_quantity",
        "defective_units",
        "scrap_units",
        "downtime_minutes",
    ]   

    # Check required columns
    for col in required_columns:
        if col not in df.columns:
            raise ValueError(f"Missing required column: {col}")

    # Check missing values
    if df[required_columns].isna().any().any():
        raise ValueError("Missing values found in required columns.")

    # Check numeric data types
    if not pd.api.types.is_numeric_dtype(df["production_quantity"]):
        raise TypeError("Column 'production_quantity' must be numeric.")

    if not pd.api.types.is_numeric_dtype(df["defective_units"]):
        raise TypeError("Column 'defective_units' must be numeric.")

    if not pd.api.types.is_numeric_dtype(df["scrap_units"]):
        raise TypeError("Column 'scrap_units' must be numeric.")

    if not pd.api.types.is_numeric_dtype(df["downtime_minutes"]):
        raise TypeError("Column 'downtime_minutes' must be numeric.")

    # Business rule validation

    if (df["production_quantity"] <= 0).any():
        raise ValueError(
            "Production quantity must be greater than zero."
        )

    if (df["defective_units"] < 0).any():
        raise ValueError(
            "Defective units cannot be negative."
        )

    if (df["scrap_units"] < 0).any():
        raise ValueError(
            "Scrap units cannot be negative."
        )

    if (
        df["defective_units"] + df["scrap_units"]
        > df["production_quantity"]
    ).any():
        raise ValueError(
            "Defective units and scrap units cannot exceed production quantity."
        )
    if (df["downtime_minutes"] < 0).any():
        raise ValueError(
            "Downtime minutes cannot be negative."
        )
    


def clean_manufacturing_data(df: pd.DataFrame) -> pd.DataFrame:
    """Validate and prepare manufacturing data for analysis."""

    validate_manufacturing_data(df)

    cleaned = df.copy()

    cleaned["date"] = pd.to_datetime(cleaned["date"])

    cleaned = cleaned.drop_duplicates()

    cleaned["good_units"] = (
        cleaned["production_quantity"]
        - cleaned["defective_units"]
        - cleaned["scrap_units"]
    )

    cleaned["defect_rate"] = (
        cleaned["defective_units"]
        / cleaned["production_quantity"]
    ).round(4)

    cleaned["scrap_rate"] = (
        cleaned["scrap_units"]
        / cleaned["production_quantity"]
    ).round(4)

    return cleaned


def main() -> None:
    """Run the manufacturing data processing pipeline."""

    df = pd.read_csv(RAW_DATA_PATH)

    cleaned = clean_manufacturing_data(df)

    PROCESSED_DATA_PATH.parent.mkdir(
        parents=True,
        exist_ok=True
    )

    cleaned.to_csv(
        PROCESSED_DATA_PATH,
        index=False
    )

    print("Data processing completed successfully.")
    print(f"Records read: {len(df)}")
    print(f"Records processed: {len(cleaned)}")
    print(f"Output file: {PROCESSED_DATA_PATH}")


if __name__ == "__main__":
    main()
