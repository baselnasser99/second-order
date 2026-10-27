"""Drop one dbt table from the ecommerce_dbt dataset, for Reverse steps.

Usage:
    uv run --env-file .env scripts/drop_table.py fct_orders
"""

import argparse
import sys

from google.api_core.exceptions import NotFound
from google.cloud import bigquery
from project_id import get_project_id

# Only the dbt dataset: this script can never touch the raw data in ecommerce_analytics.
DATASET_NAME = "ecommerce_dbt"


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("table", help="exact table name, e.g. fct_orders")
    args = parser.parse_args()
    # a plain name only, so a dot can't point the script at another dataset
    if not (args.table.isascii() and args.table.replace("_", "").isalnum()):
        sys.exit(f"Refusing: '{args.table}' is not a plain table name.")

    project_id = get_project_id()
    client = bigquery.Client(project=project_id)
    table_id = f"{project_id}.{DATASET_NAME}.{args.table}"
    try:
        table = client.get_table(table_id)
    except NotFound:
        sys.exit(f"{table_id} does not exist. Nothing was deleted.")
    # Views (staging models) are refused; only real tables are dropped.
    if table.table_type != "TABLE":
        sys.exit(f"Refusing: {table_id} is a {table.table_type}, not a TABLE.")

    answer = input(
        f"Delete table {table_id} ({table.num_rows} rows)? Type the table name to confirm: "
    )
    if answer.strip() != args.table:
        sys.exit("Cancelled. Nothing was deleted.")
    client.delete_table(table_id)
    print(f"Deleted table {table_id}.")


if __name__ == "__main__":
    main()
