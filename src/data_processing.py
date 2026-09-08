"""Data cleaning and transformation utilities for the manufacturing analytics project."""

from pathlib import Path
import pandas as pd

RAW_DATA_PATH = Path("data/raw/manufacturing_production_raw.csv")
PROCESSED_DATA_PATH = Path("data/processed/manufacturing_production_cleaned.csv")


def clean_manufacturing_data(df: pd.DataFrame) -> pd.DataFrame:
    """Validate and prepare manufacturing data for analysis."""
    cleaned = df.copy()
    cleaned["date"] = pd.to_datetime(cleaned["date"])
    cleaned = cleaned.drop_duplicates()
    cleaned["good_units"] = cleaned["production_quantity"] - cleaned["defective_units"] - cleaned["scrap_units"]
    cleaned["defect_rate"] = (cleaned["defective_units"] / cleaned["production_quantity"]).round(4)
    cleaned["scrap_rate"] = (cleaned["scrap_units"] / cleaned["production_quantity"]).round(4)
    return cleaned


def main() -> None:
    df = pd.read_csv(RAW_DATA_PATH)
    cleaned = clean_manufacturing_data(df)
    PROCESSED_DATA_PATH.parent.mkdir(parents=True, exist_ok=True)
    cleaned.to_csv(PROCESSED_DATA_PATH, index=False)


if __name__ == "__main__":
    main()
