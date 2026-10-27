"""Read GCP_PROJECT_ID from the environment and refuse an ID that breaks Google's rules.

Every script calls get_project_id() before creating the BigQuery client.

Usage:
    uv run scripts/project_id.py   (runs the self-check; no BigQuery connection)
"""

import os
import re
import sys

# Google's project ID rules: 6-30 characters, lowercase letters, digits and hyphens,
# starts with a letter, doesn't end with a hyphen.
PROJECT_ID_PATTERN = re.compile(r"[a-z][a-z0-9-]{4,28}[a-z0-9]")


def is_valid_project_id(project_id: str) -> bool:
    """The library puts the ID into the request address unescaped, so / or ? could redirect it."""
    return PROJECT_ID_PATTERN.fullmatch(project_id) is not None


def get_project_id() -> str:
    """Return GCP_PROJECT_ID, or exit with code 1 if it's missing or invalid."""
    project_id = os.environ.get("GCP_PROJECT_ID")
    if not project_id:
        sys.exit("GCP_PROJECT_ID is not set. Copy .env.example to .env and fill it in.")
    if not is_valid_project_id(project_id):
        sys.exit(
            f"Refusing: '{project_id}' is not a valid Google Cloud project ID. Nothing was changed."
        )
    return project_id


def self_check() -> None:
    """Test the ID check only. Makes no BigQuery connection."""
    assert is_valid_project_id("example-project-123")
    assert not is_valid_project_id("myproj/datasets/ecommerce_analytics")
    assert not is_valid_project_id("myproj/datasets")
    assert not is_valid_project_id("myproj?x=")
    assert not is_valid_project_id("myproj?abc")
    assert not is_valid_project_id("abc")
    print("Self-check passed.")


if __name__ == "__main__":
    self_check()
