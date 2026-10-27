"""Create or delete the ecommerce_analytics BigQuery dataset.

Usage:
    uv run --env-file .env scripts/dataset.py create
    uv run --env-file .env scripts/dataset.py delete
"""

import argparse
import sys

from google.api_core.exceptions import Conflict, NotFound
from google.cloud import bigquery
from project_id import get_project_id

DATASET_NAME = "ecommerce_analytics"
LOCATION = "US"


def create(client: bigquery.Client, dataset_id: str) -> None:
    dataset = bigquery.Dataset(dataset_id)
    dataset.location = LOCATION
    try:
        client.create_dataset(dataset)
        print(f"Created dataset {dataset_id} in {LOCATION}.")
    except Conflict:
        print(f"Dataset {dataset_id} already exists. Nothing to do.")


def delete(client: bigquery.Client, dataset_id: str) -> None:
    try:
        tables = list(client.list_tables(dataset_id))
    except NotFound:
        print(f"Dataset {dataset_id} does not exist. Nothing to do.")
        return
    if tables:
        print(f"Refusing to delete {dataset_id}: it still has {len(tables)} table(s).")
        sys.exit(1)
    answer = input(f"Delete dataset {dataset_id}? Type 'yes' to confirm: ")
    if answer.strip().lower() != "yes":
        sys.exit("Cancelled. Nothing was deleted.")
    # delete_contents=False makes BigQuery itself refuse if a table appeared since the check above
    client.delete_dataset(dataset_id, delete_contents=False)
    print(f"Deleted dataset {dataset_id}.")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("command", choices=["create", "delete"])
    args = parser.parse_args()

    project_id = get_project_id()
    client = bigquery.Client(project=project_id)
    dataset_id = f"{project_id}.{DATASET_NAME}"
    if args.command == "create":
        create(client, dataset_id)
    else:
        delete(client, dataset_id)


if __name__ == "__main__":
    main()
