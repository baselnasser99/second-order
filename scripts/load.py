"""Load Olist CSV files from data/raw/ into raw BigQuery tables.

Every column is loaded as STRING. Each run replaces the table, so running it twice is safe.

Usage:
    uv run --env-file .env scripts/load.py
"""

import csv
import os
import sys
from pathlib import Path

from google.cloud import bigquery

DATASET_NAME = "ecommerce_analytics"
RAW_DIR = Path("data/raw")

# Table name -> CSV file. Add the other Olist files here in M2-04.
FILES = {
    "raw_orders": "olist_orders_dataset.csv",
}


def load_csv(client: bigquery.Client, csv_path: Path, table_id: str) -> None:
    # utf-8-sig drops an invisible byte-order mark, if present, from the first column name
    with csv_path.open(newline="", encoding="utf-8-sig") as f:
        header = next(csv.reader(f))

    job_config = bigquery.LoadJobConfig(
        schema=[bigquery.SchemaField(name, "STRING") for name in header],
        source_format=bigquery.SourceFormat.CSV,
        skip_leading_rows=1,
        allow_quoted_newlines=True,
        write_disposition=bigquery.WriteDisposition.WRITE_TRUNCATE,
    )
    with csv_path.open("rb") as f:
        job = client.load_table_from_file(f, table_id, job_config=job_config)
    job.result()
    print(f"Loaded {job.output_rows} rows from {csv_path.name} into {table_id}.")


def main() -> None:
    project_id = os.environ.get("GCP_PROJECT_ID")
    if not project_id:
        sys.exit("GCP_PROJECT_ID is not set. Copy .env.example to .env and fill it in.")

    client = bigquery.Client(project=project_id)
    for table_name, file_name in FILES.items():
        load_csv(
            client, RAW_DIR / file_name, f"{project_id}.{DATASET_NAME}.{table_name}"
        )


if __name__ == "__main__":
    main()
