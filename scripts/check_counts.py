"""Compare the row count of each CSV in data/raw/ with its raw BigQuery table.

Exits with 0 if every count matches, or 1 if any table differs or is missing.

Usage:
    uv run --env-file .env scripts/check_counts.py
"""

import csv
import sys
from pathlib import Path

from google.api_core.exceptions import NotFound
from google.cloud import bigquery
from load import DATASET_NAME, FILES, RAW_DIR
from project_id import get_project_id


def count_csv_rows(csv_path: Path) -> int:
    # csv.reader keeps a quoted line break inside one row; minus 1 for the header
    with csv_path.open(newline="", encoding="utf-8-sig") as f:
        return sum(1 for _ in csv.reader(f)) - 1


def main() -> None:
    project_id = get_project_id()
    client = bigquery.Client(project=project_id)
    failed = False
    print(f"{'Table':<34}{'CSV':>10}{'BigQuery':>10}  Result")
    for table_name, file_name in FILES.items():
        csv_rows = count_csv_rows(RAW_DIR / file_name)
        try:
            # num_rows is stored table metadata, so reading it runs no query
            table = client.get_table(f"{project_id}.{DATASET_NAME}.{table_name}")
            bq_rows, result = table.num_rows, "OK"
        except NotFound:
            bq_rows, result = "-", "MISSING"
        if result == "OK" and bq_rows != csv_rows:
            result = "MISMATCH"
        failed = failed or result != "OK"
        print(f"{table_name:<34}{csv_rows:>10}{bq_rows:>10}  {result}")

    sys.exit(1 if failed else 0)


if __name__ == "__main__":
    main()
