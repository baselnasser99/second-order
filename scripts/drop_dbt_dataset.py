"""Delete the whole ecommerce_dbt dataset (views and tables), for full-rebuild Reverse steps.

dbt recreates the dataset on the next `dbt build`.

Usage:
    uv run --env-file .env scripts/drop_dbt_dataset.py
    uv run scripts/drop_dbt_dataset.py --self-check
"""

import argparse
import sys

from google.api_core.exceptions import NotFound
from google.cloud import bigquery
from project_id import get_project_id

# Fixed name with no argument to change it: this script can never touch ecommerce_analytics.
DATASET_NAME = "ecommerce_dbt"
# Every dbt model starts with one of these; raw tables start with raw_.
DBT_PREFIXES = ("stg_", "dim_", "fct_")


def non_dbt_names(names: list[str]) -> list[str]:
    """Return the names that don't look like dbt models."""
    return [name for name in names if not name.startswith(DBT_PREFIXES)]


def self_check() -> None:
    """Test the name check only. Makes no BigQuery connection."""
    assert non_dbt_names([]) == []
    assert non_dbt_names(["stg_orders", "dim_customers", "fct_orders"]) == []
    assert non_dbt_names(["fct_orders", "raw_orders"]) == ["raw_orders"]
    assert non_dbt_names(["orders", "STG_orders", "stgorders"]) == [
        "orders",
        "STG_orders",
        "stgorders",
    ]
    print("Self-check passed.")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--self-check",
        action="store_true",
        help="test the name check only; no BigQuery connection",
    )
    args = parser.parse_args()
    if args.self_check:
        self_check()
        return

    project_id = get_project_id()
    client = bigquery.Client(project=project_id)
    dataset_id = f"{project_id}.{DATASET_NAME}"
    try:
        names = sorted(t.table_id for t in client.list_tables(dataset_id))
    except NotFound:
        print(f"Dataset {dataset_id} does not exist. Nothing to delete.")
        return
    bad = non_dbt_names(names)
    if bad:
        sys.exit(
            f"Refusing: {dataset_id} holds objects that aren't dbt models: {', '.join(bad)}. Nothing was deleted."
        )

    print(f"{dataset_id} holds {len(names)} object(s): {', '.join(names) or 'none'}")
    try:
        answer = input(
            f"Delete dataset {dataset_id} and everything in it? Type '{DATASET_NAME}' to confirm: "
        )
    except (EOFError, KeyboardInterrupt):
        # no input (piped or closed stdin) or Ctrl+C counts as a cancel
        answer = ""
    if answer.strip() != DATASET_NAME:
        sys.exit("Cancelled. Nothing was deleted.")
    client.delete_dataset(dataset_id, delete_contents=True)
    print(f"Deleted dataset {dataset_id}. Run dbt build to recreate it.")


if __name__ == "__main__":
    main()
