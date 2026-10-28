# Second Order — Blueprint & Roadmap

*Why Olist customers never come back: a cloud data pipeline on BigQuery and dbt.*

**Owner:** Basel Nasser · **Started:** October 2026 · **Target finish:** March 2027 (before co-op applications)
**Time budget:** ~4 hours/week · **Estimated total:** ~65 hours

This file is the single source of truth for the project and lives in the GitHub repo. All work follows it. If something changes, update this file first.

---

## 1. The business question

> Olist, a Brazilian online marketplace, wants to know **where it is losing customers and money**, and what to fix first.

If a task doesn't help answer that question, it's out of scope.

## 2. How it works, in one paragraph

Olist's raw sales data (CSV files) gets loaded by a Python script into BigQuery, Google's cloud database. dbt then cleans and reshapes that data into tidy tables, checking it with automated tests. Looker Studio reads those tidy tables and shows the results as a dashboard. A written memo explains what the numbers mean and what Olist should do. GitHub stores all the code, checks it automatically on every change, and tracks the work on a project board.

## 3. Architecture

```
Olist CSV files (Kaggle)
        │  Python loader (Milestone 2)
        ▼
BigQuery dataset: ecommerce_analytics
   raw tables ──dbt──► staging tables ──dbt──► mart tables   (Milestone 3)
        │
        ▼
Looker Studio dashboard (Milestone 4)
        │
        ▼
Recommendation memo + README + demo video (Milestone 5)

Around everything: GitHub repo · GitHub Actions checks · GitHub Projects board (Milestone 1)
```

## 4. Stack

| Layer | Tool | Job |
|---|---|---|
| Warehouse | BigQuery sandbox (US multi-region) | Stores data, runs SQL. Free, no billing account |
| Setup | Python setup script | Creates/deletes the dataset, so it can be rebuilt any time |
| Ingestion | Python + `google-cloud-bigquery` | Loads CSVs into raw tables |
| Transformation | dbt Core **1.12.x** (dbt-core and dbt-bigquery pinned; not v2) | Cleans data, builds tables, runs data tests |
| Dashboard | Looker Studio | Charts for the findings; connects with your Google login, no keys |
| Automation | GitHub Actions | Lint and secret-scan every push; holds **no** cloud credentials |
| Project management | GitHub Issues + Projects board | One issue per increment, tracked To do → Done |

## 5. Ways of working

- One issue at a time, each on its own branch, merged into `main` through a reviewed pull request.
- Every issue follows the loop in Section 6 and passes the security checklist in Section 7.
- Decisions are recorded in Section 13 when they're made, not afterwards.
- The owner handles all logins and credentials personally and reviews every change before merging.

## 6. The working loop: Build → Test → Reverse → Refactor

1. **Build** — make the smallest piece that could work.
2. **Test** — prove it works with a check you can see.
3. **Reverse** — undo it and rebuild it from the repo (or break it on purpose and confirm the safety check catches it).
4. **Refactor** — clean up, pass the security checklist, update docs, merge the pull request.

A step is **done** only when all four stages are complete and merged into `main`.

## 7. Security checklist (every cycle, at Refactor)

- [ ] No key files, tokens or passwords anywhere in the change
- [ ] Secret scan passes locally (pre-commit) and in GitHub Actions
- [ ] Any new library has a pinned version
- [ ] Change went through a pull request into a protected `main` branch
- [ ] Any new access follows least privilege (read-only unless writing is required)
- [ ] `.gitignore` still covers credentials, `.env`, and local data files
- [ ] Commit messages and PR descriptions contain only the change description (no automated tool footers)

---

## 8. Milestones

### Milestone 1 — Foundation & Guardrails (≈ 10 hours · target: late November 2026)
**Goal:** an organized, protected repo with automatic checks, a project board, and an empty BigQuery dataset created by a script.
**Done when:** a pull request with a lint error or a fake secret is blocked automatically, and the dataset can be deleted and recreated with one command.

### Milestone 2 — Data Ingestion (≈ 10 hours · target: mid-December 2026)
**Goal:** all Olist CSVs loaded into BigQuery raw tables by one command.
Test: row counts in BigQuery match the CSVs. Reverse: drop all raw tables, reload, counts still match.

### Milestone 3 — Transformation & Data Modeling (≈ 20 hours · target: late January 2027)
**Goal:** dbt staging and mart models with passing data tests.
Test: `dbt build` passes (unique IDs, no empty keys, every order links to a customer). Reverse: drop all dbt tables, rebuild from nothing. Add dbt parse check to GitHub Actions (still no credentials).

### Milestone 4 — Analytics & Dashboard (≈ 15 hours · target: mid-December 2026)
**Goal:** business metrics answering the question, shown in Looker Studio.
Closes with M4-07, the first rebuild before the sandbox expiry around December 20; the rebuild then repeats every ~55 days while the dashboard is shared (see M4-07).
Test: hand-check 2–3 numbers against raw data. Reverse: rebuild dashboard using only mart tables. Every chart has a one-sentence caption.

### Milestone 5 — Insights & Delivery (≈ 10 hours · target: late December 2026)
**Goal:** memo, README (finding first, setup last), architecture diagram, 2-minute demo video.
The demo video can be recorded any time the tables are live; it doesn't wait for M4-07. The project counts as finished when M5 is merged; later rebuilds are maintenance.
Test: a non-technical friend reads the README and explains the finding back. Reverse: follow your own README on a fresh clone and rebuild everything.

---

## 9. Milestone 1 issues (copy each into GitHub Issues)

Each issue uses this checklist:
```
- [ ] Build
- [ ] Test
- [ ] Reverse
- [ ] Refactor (incl. security checklist)
```

**M1-01 · Create the repository**
Public repo `second-order` with README stub, MIT license, Python `.gitignore`, and this ROADMAP.md.
Test: repo visible on your profile. Reverse: clone it to a fresh folder; everything is there.

**M1-02 · Lock down repo settings**
Secret scanning and push protection, Dependabot alerts, branch protection on `main` (pull request required).
Test: a direct push to `main` is rejected. Reverse: n/a; note the settings in the decision log.

**M1-03 · Set up the project board**
GitHub Projects board (To do / In progress / Done), five milestones, an issue template with the loop checklist, all M1 issues added.
Test: every M1 issue appears on the board. Reverse: n/a.

**M1-04 · Local environment**
Python, `uv` (package manager) and gcloud CLI; project environment with pinned versions.
Test: `python --version` and `gcloud --version` work. Reverse: delete the environment folder and recreate it with one command.

**M1-05 · Local safety checks (pre-commit)**
pre-commit hooks for `ruff` (Python lint) and `gitleaks` (secret scan).
Test: clean code commits fine. Reverse: on a throwaway branch, try committing a fake placeholder secret; it's blocked. Delete the branch.

**M1-06 · GitHub Actions check**
Workflow running ruff and gitleaks on every push and pull request. No cloud credentials.
Test: open a PR; checks go green. Reverse: push a deliberate lint error in a test PR; checks go red; close it.

**M1-07 · Google Cloud project + sandbox**
Create GCP project, open BigQuery in sandbox mode (no billing). Run `gcloud auth application-default login` yourself.
Test: BigQuery console shows the sandbox notice. Reverse: n/a.

**M1-08 · Dataset setup script**
Python script with two commands: create `ecommerce_analytics` (US) if missing, and delete it. Project ID comes from a gitignored `.env`; commit only `.env.example`.
Test: dataset appears in BigQuery. Reverse: delete it, recreate it, confirm it's back.

---

## 10. Milestone 2 issues (copy each into GitHub Issues)

Each issue uses the same checklist as Section 9.

**M2-01 · Download the Olist data**
From Kaggle into `data/raw/` (gitignored).
Test: all 9 CSVs present and `git status` shows nothing new. Reverse: n/a.

**M2-02 · Fix the delete script's exit code**
Cancelling a delete exits with code 1, not success.
Test: cancel a delete and check the exit code. Reverse: n/a.

**M2-03 · Load one table**
Loader script for `olist_orders_dataset.csv` into a raw table, all columns as STRING.
Test: BigQuery row count matches the CSV, counted with a CSV reader rather than line counts. Reverse: drop the table and reload.

**M2-04 · Load all tables with one command**
All 9 files.
Test: every row count matches. Reverse: drop all raw tables, reload, counts still match.

**M2-05 · Row-count check**
A script that compares CSV and BigQuery row counts and fails on any mismatch.
Test: passes on real data. Reverse: break one count on purpose and it fails.

---

## 11. Milestone 3 issues (copy each into GitHub Issues)

Each issue uses the same checklist as Section 9.

**M3-01 · Install dbt and connect to BigQuery**
dbt-core and dbt-bigquery each pinned explicitly to a 1.12.x version (both the `dbt` and `dbt-core` package names now have v2 releases, so an unpinned install can pull v2); dbt project created in `dbt/`; `profiles.yml` kept outside the repo, using gcloud login (no keys) and the project ID from an environment variable; dbt builds into its own datasets, never into the raw one; `target/`, `logs/` and `dbt_packages/` gitignored.
Test: `dbt --version` shows Core 1.12.x and the bigquery plugin 1.12.x; `dbt debug` passes. Reverse: delete the environment, recreate it with one command, `dbt --version` and `dbt debug` still pass.

**M3-02 · Investigate the raw data**
One-off queries, results written to `docs/data-notes.md`: for each column, are blanks NULL or empty text; date formats; duplicate `review_id`s; geolocation duplicates; `customer_id` vs `customer_unique_id`.
Test: every question in the notes has an answer and the query that produced it. Reverse: n/a.

**M3-03 · Sources and the first staging model**
Declare the 9 raw tables as dbt sources. Build `stg_orders`: real timestamp types, blanks handled per M3-02, tests on `order_id` (unique, not null).
Test: `dbt build --select stg_orders` passes. Reverse: drop the dbt datasets, rebuild, passes again.

**M3-04 · Remaining staging models**
The other 8 staging models, same pattern. Includes the test that every order links to a customer.
Test: `dbt build` passes for all staging. Reverse: break one rule on purpose (e.g. test a non-unique column as unique); the build fails.

**M3-05 · Customer mart: `dim_customers`**
One row per real person (`customer_unique_id`): first and last order date, number of orders, repeat-customer flag, state.
Test: unique key test passes; hand-check the repeat-customer count with one direct SQL query. Reverse: drop and rebuild.

**M3-06 · Order mart: `fct_orders`**
One row per order: status, order value, payment total, delivery days, late flag, review score.
Test: row count equals `stg_orders` (a custom test, to catch row duplication from joins). Reverse: drop and rebuild.

**M3-07 · Item mart: `fct_order_items`**
One row per item, with English product category and seller, for "which products and sellers cost us money."
Test: row count equals `stg_order_items`. Reverse: drop and rebuild.

**M3-08 · Full rebuild and documentation**
Descriptions for every mart model and column; `dbt docs generate` works locally (output not committed).
Test: `dbt build` from empty datasets passes in one command. Reverse: drop all dbt datasets, rebuild from the repo.

**M3-09 · dbt and script checks in GitHub Actions**
Add three pre-commit hooks, which the existing CI job runs: `dbt parse` with a placeholder profile and no cloud credentials, the `scripts/project_id.py` self-check, and the `scripts/drop_dbt_dataset.py --self-check`. `parse` checks the project without connecting to BigQuery; `compile` would need a connection, so it's left out. The placeholder profile is `dbt/ci/profiles.yml`, with the made-up project ID `ci-dummy-project`.
Test: each hook passes locally; open a PR and the checks go green. Reverse: locally, break each check on purpose (a bad `ref()`, a pattern that allows `/`, a prefix list that allows `raw_`); each hook fails, then restore. In a test PR made in the GitHub web editor, break a `ref()`; checks go red; close it and delete the branch.

**M3-10 · Validate the project ID in every script**
`drop_table.py`, `dataset.py`, `load.py` and `check_counts.py` build BigQuery IDs from `GCP_PROJECT_ID` without checking it. The Google library puts the ID into the request address unescaped, so a malformed value containing `/` or `?` could point a delete or a table replace at another dataset or table (found in the M3-08 security review). Move the check from `drop_dbt_dataset.py` into one shared file in `scripts/` that every script imports, and switch `drop_dbt_dataset.py` to it. Every script refuses a project ID that breaks Google's rules (6 to 30 characters, lowercase letters, digits and hyphens, starts with a letter, doesn't end with a hyphen) before the BigQuery client is created. The shared file has a self-check with cases for a valid ID, a slash, a question mark and a too-short ID.
Test: every script runs normally with the real project ID; each refuses `myproj/datasets/ecommerce_analytics?x=` with exit code 1 before connecting. Reverse: on a throwaway branch, loosen the pattern to allow `/`; the self-check fails. Delete the branch.

---

## 12. Milestone 4 issues (copy each into GitHub Issues)

Each issue uses the same checklist as Section 9.

**M4-01 · First-order columns in `dim_customers`**
Add `first_order_id`, `first_order_is_late` and `first_order_review_score` (from `fct_orders`), plus `has_full_followup` and `returned_within_180_days`. `has_full_followup`: true when the first order was placed at least 180 days before the end of the data, so everyone compared had the same chance to come back. `returned_within_180_days`: true when the person placed another order that isn't canceled or unavailable, on a later calendar day and at most 180 calendar days after the first order's date; NULL without full follow-up. A same-day order isn't a return (897 of the 2,997 repeat customers placed their second order on the same day as their first). `is_repeat_customer` stays as it is. The first order is the earliest by purchase time, any status, with `order_id` as tie-break (the same rule as `customer_state`). Check the last months of purchases first: if the data tails off, choose the end date deliberately and record it in the decision log. Tests: `first_order_id` not null and related to `fct_orders`; `returned_within_180_days` not null when `has_full_followup` is true, and NULL when `has_full_followup` is false. Descriptions for the new columns.
Test: `dbt build --select dim_customers` passes; hand-check 3 people (a repeat customer whose only other order was on the same day, one with a late first order, one without full follow-up) with direct SQL; report how many people have full follow-up and their 180-day return rate. Reverse: drop `dim_customers` with `scripts/drop_table.py`, rebuild, same counts.

**M4-02 · Metric definitions**
`docs/metrics.md`: each dashboard number in plain words, the mart and columns it uses, and its SQL. Covers people, repeat customers and repeat rate (all people), 180-day return rate (full follow-up only), late-order rate, average review per order, order value and payment totals, and the value of canceled and unavailable orders. Rates count orders or people, never items.
Test: hand-check 3 numbers against the raw tables with direct SQL (repeat customers 2,997, late orders 6,535, payment total 16,008,872.12); each matches. Reverse: n/a.

**M4-03 · Connect Looker Studio to the marts**
Done by hand in the browser. A new report with BigQuery data sources for `dim_customers`, `fct_orders` and `fct_order_items` only; nothing reads raw or staging. Decide the data credentials (owner's or viewer's) and who can open the report; it stays private until M5. Record both in the decision log.
Test: each data source's field list shows the mart descriptions; a test table shows 96,096 people. Reverse: remove one data source, add it again, and the test table works again.

**M4-04 · Dashboard page 1: customers**
Scorecards for people, repeat customers and repeat rate. Charts: 180-day return rate for people whose first order was late vs on time, and by first-order review score (1–5), using full-follow-up people only, with the group size shown next to each rate. Definitions from `docs/metrics.md`.
Test: hand-check 2 chart numbers with direct SQL on the marts. Reverse: n/a (the rebuild check is in M4-06).

**M4-05 · Dashboard page 2: money**
Which product categories and sellers lose the most: late-order rate, average review per order and order value per category and per seller, plus the value of canceled and unavailable orders. Rates count each order once, even when it has several items; if Looker Studio can't do that correctly from `fct_order_items`, add a small summary model instead, named `fct_…` (`drop_dbt_dataset.py` only accepts `stg_`, `dim_` and `fct_`). Categories and sellers with fewer than 30 orders are left out of rankings, so one seller with 2 bad orders can't top the list.
Test: hand-check one category's and one seller's numbers with direct SQL. Reverse: if a summary model was added, drop it with `drop_table.py` and rebuild; otherwise n/a.

**M4-06 · Captions and data-source check**
A one-sentence caption on every chart: what it shows and the main takeaway. Every data source is a mart table.
Test: every chart has a caption; the report's data source list shows only mart tables. Reverse: make a copy of the report, remove its data sources, add back only the mart tables; every chart still works. Delete the copy.

**M4-07 · Rebuild before each sandbox expiry (first around December 20)**
Raw tables expire around December 25 and dbt tables about a day later. Check each table's expiration date in the BigQuery console first. Then reload raw with `scripts/load.py`, run `dbt build` and run `scripts/check_counts.py`. Check the expiration dates again: if replacing a table's data doesn't reset its expiry, find another way before the old date passes. This is also the first real run of `load.py` with the M3-10 project ID check. After the first run, repeat this every ~55 days for as long as the dashboard is shared (co-op applications run through about August 2027), and set a calendar reminder for the next date each time. The issue closes after the first run; later runs need no new issue unless something breaks.
Test: counts 9/9, `dbt build` passes, the dashboard headline is unchanged, and the new expiry dates are in late February 2027. Reverse: n/a.

---

## 13. Decision log

| Date | Decision | Why |
|---|---|---|
| Oct 2026 | Google Cloud (BigQuery) over AWS | Permanent free tier with no credit card; AWS free plan closes after 6 months |
| Oct 2026 | No Cloud Storage bucket | Needs a billing account; data is small enough to load straight into BigQuery |
| Oct 2026 | Python setup script instead of Terraform | Terraform matters little for analyst/PM roles; script keeps reproducibility with less to learn |
| Oct 2026 | Looker Studio instead of Streamlit | No stored keys needed; no hosting to maintain |
| Oct 2026 | GitHub Actions with zero cloud credentials | Automated quality and secret checks without any credential exposure |
| Oct 2026 | dbt Core stable 1.x | 2.0 is still alpha; beginner needs stability (superseded below) |
| Oct 2026 | Early commits pushed directly to main | Nothing to open a PR against yet; PR rule applies from M1-02 |
| Oct 2026 | Ruleset instead of classic branch protection | Applies to admins too, through an empty bypass list |
| Oct 2026 | Pull requests need 0 approvals | Solo project; GitHub doesn't allow approving your own PR |
| Oct 2026 | Dependabot security updates off for now | No dependencies yet; revisit in M1-04 |
| Oct 2026 | Milestone due dates set to the last day of each target period | Section 8 gives rough targets ("late November"); GitHub needs an exact date |
| Oct 2026 | Project board is public | Lets reviewers and recruiters see how the work is tracked; it holds only issue titles and statuses |
| Oct 2026 | Python pinned to 3.13 (`requires-python = "==3.13.*"`) | Newest version supported by dbt-core, dbt-bigquery and google-cloud-bigquery; pinned in `pyproject.toml` because `.gitignore` ignores `.python-version` |
| Oct 2026 | Dependabot security updates stay off until M1-05 | M1-04 adds no libraries; turn on when the first one arrives |
| Oct 2026 | No service account key files | Log in with gcloud application-default login instead; nothing to leak from the repo |
| Oct 2026 | Dependabot security updates on | First libraries (pre-commit, ruff) arrived in M1-05; Dependabot only opens PRs for known vulnerabilities, and they still go through protected `main` |
| Oct 2026 | pre-commit hooks pinned to commit SHAs, not tags | A tag can be moved to point at different code; a SHA cannot. Release version kept in a comment for readability |
| Oct 2026 | GitHub Actions runs pre-commit itself, actions pinned to commit SHAs | One config for local and CI checks, so they can't disagree; SHAs for the same reason as the hooks |
| Oct 2026 | Extra manual-stage `gitleaks-history` hook for CI | The standard gitleaks hook scans only staged changes, which are empty in CI; this one scans the full history with the same pinned version |
| Oct 2026 | `pre-commit` is a required status check in "Protect main" | Without it a red check is only a warning; tied to the GitHub Actions app so nothing else can report a pass. "Branch must be up to date" left off (solo project) |
| Oct 2026 | Stay on BigQuery sandbox; tables expire after 60 days | Free with no billing; the pipeline rebuilds everything with one command, so rebuild before any demo |
| Oct 2026 | `.env` loaded with `uv run --env-file`, no python-dotenv | uv already reads env files; one less library to pin and audit (dbt-core 1.12 installs python-dotenv as a dependency since M3-01; our code still doesn't use it) |
| Oct 2026 | Dataset delete refuses if any tables exist and asks for confirmation | Protects loaded data; BigQuery also enforces it (`delete_contents=False`) |
| Oct 2026 | Raw tables load every column as STRING | Keeps data exactly as delivered (e.g. leading zeros in zip codes); types are fixed in dbt staging |
| Oct 2026 | Loader replaces each raw table on every run (`WRITE_TRUNCATE`) | Running it twice gives the same table instead of duplicate rows |
| Oct 2026 | Olist data never committed | CC BY-NC-SA 4.0 license; downloaded Oct 26, 2026; `data/` is gitignored |
| Oct 2026 | dbt v1.12, with dbt-core and dbt-bigquery pinned explicitly to 1.12.x | v2 went GA Sept 2026 but is new; v1.12 is maintained until July 2027, past project end, and most learning material targets v1. Both the `dbt` and `dbt-core` package names have v2 releases, so an unpinned install can pull v2 |
| Oct 2026 | dbt builds into its own datasets, separate from raw | "Drop all dbt tables" can never touch the loaded data |
| Oct 2026 | No dbt packages; views and tables only | Built-in tests are enough; sandbox doesn't allow MERGE, so no incremental models |
| Oct 2026 | CI runs `dbt parse`, not `compile` | `parse` needs no warehouse connection, keeping CI credential-free |
| Oct 2026 | dbt models build into dataset `ecommerce_dbt` (US) | Same location as the raw dataset so joins work; dropping it can't touch raw data |
| Oct 2026 | Sandbox storage is a 10 GiB lifetime budget | Deleted data isn't refunded, so staging models will be views, Reverse steps rebuild only what an issue touched, and raw data is reloaded only when needed |
| Oct 2026 | profiles.yml outside the repo, profiles.example.yml committed | No connection details in git, but a fresh clone can still be set up |
| Oct 2026 | Staging views and mart tables both build into `ecommerce_dbt`; no custom schema per folder | One dbt dataset to drop and rebuild in Reverse steps; a `+schema` setting would add a second dataset (`ecommerce_dbt_staging`) for no gain at this size |
| Oct 2026 | `dim_customers` counts orders of every status in `number_of_orders` | Keeps the mart a plain record of what people ordered; the dashboard can filter by status later |
| Oct 2026 | `dim_customers.customer_state` is the state on the person's most recent order | A person can order from more than one state; the latest one is where they are now. Ties on purchase time are broken by `order_id` so the result never changes between runs |
| Oct 2026 | `fct_orders` keeps `items_value`, `freight_value` and `payment_total` as separate columns | They don't always add up (vouchers, installment fees), so combining them would hide real differences |
| Oct 2026 | `fct_orders` orders with no items or no payments get NULL, not 0 | A 0 would drag averages down; NULL means "no data" and is left out of averages |
| Oct 2026 | `fct_orders.review_score` is the order's most recent review (by `review_creation_date`, `review_id` as tie-break) | 547 orders have more than one review; keeping one per order stops row duplication, and the tie-break keeps the result the same between runs |
| Oct 2026 | `delivery_days` = calendar days from purchase to delivery to the customer; `is_late` = delivered date after the estimated date; both NULL with no delivery date | NULL means "not delivered yet". 8 orders are marked `delivered` but have no delivery date, so they get NULL too |
| Oct 2026 | Reverse steps drop one dbt table with `scripts/drop_table.py` | Works only in `ecommerce_dbt`, refuses views and names with dots, and asks for the table name before deleting, so it can't touch raw data or staging |
| Oct 2026 | `fct_order_items.product_category` = English name, else Portuguese name, else `'unknown'` | 2 categories (13 products) have no translation and 610 products have no category (docs/data-notes.md question 7); every item keeps a category, so none drop out of per-category totals |
| Oct 2026 | `fct_order_items` repeats the order-level `is_late` and `review_score` on every item | Lets item and seller analysis filter by them; averaging them per item weights multi-item orders more, so M4 averages them per order |
| Oct 2026 | Mart descriptions copied into BigQuery with `persist_docs`, for marts only | Descriptions show in the BigQuery console and Looker Studio's field list; it writes only table metadata, so it uses no storage. Staging views have no descriptions and Looker Studio reads only marts |
| Oct 2026 | Full rebuilds delete the whole `ecommerce_dbt` dataset with `scripts/drop_dbt_dataset.py` | `drop_table.py` refuses views and `dataset.py` handles only the raw dataset. The dataset name is fixed in the code; the script refuses an invalid project ID (see M3-10 below), refuses if any object isn't named `stg_`, `dim_` or `fct_` (raw tables are `raw_`), and deletes only when the dataset name is typed; a wrong name, no input or Ctrl+C cancels with exit code 1 |
| Oct 2026 | M3-08's Test and Reverse done as one drop-and-rebuild | Both are the same action (build from an empty dataset), and every build rewrites the mart tables while deleted storage isn't refunded. Raw row counts checked before and after show the raw data was untouched |
| Oct 2026 | Every script gets its project ID from `scripts/project_id.py`, which refuses an ID that breaks Google's rules before the BigQuery client is created | The library puts the ID into the request address unescaped, so a `/` or `?` could redirect a delete or table replace to another dataset or table. One shared check means no script can skip it, and the scripts' repeated "is it set" lines became one call |
| Oct 2026 | `dbt parse` and the two script self-checks run as local pre-commit hooks, inside the existing CI job | One config for local and CI checks; the required `pre-commit` check already covers them, so the "Protect main" ruleset is unchanged |
| Oct 2026 | Placeholder dbt profile `dbt/ci/profiles.yml` committed, with a `.gitignore` exception for that one path | `dbt parse` needs a profile but never connects; it holds only the made-up project ID `ci-dummy-project`. No source or model reads `GCP_PROJECT_ID`, so CI needs no environment variable, and the real profile keeps `env_var('GCP_PROJECT_ID')` with no default so a missing variable still fails |
| Oct 2026 | CI Reverse test PRs are made in the GitHub web editor | The local hooks block committing a deliberate break, and hooks are never skipped; web-editor commits don't run local hooks |
| Oct 2026 | Milestone 4 and 5 targets moved to December 2026 | M3 finished in late October, three months early. Finishing before the MS starts in January 2027, with the M4-07 rebuild before the sandbox tables expire around December 25, leaves slack. GitHub milestone due dates updated to match (December 20 and December 31) |
| Oct 2026 | End of data is 2018-08-21; full follow-up = first order on or before 2018-02-22 | Daily orders fall from about 277 to 1 between Aug 22 and Aug 31, and Sept–Oct 2018 hold only 20 orders, so a later end date would count people as fully followed up when the data stops recording their orders. 56,007 people have full follow-up |
| Oct 2026 | `returned_within_180_days` counts only a non-canceled, non-unavailable order on a later calendar day, at most 180 calendar days after the first order's date; people whose first order was canceled or unavailable stay in the comparison | 897 of 2,997 repeat customers' second order was on the same day as their first, and 66 repeat customers' other orders were all canceled or unavailable; neither is a customer coming back. With the 2018-08-21 end date, 1,116 of 56,007 full-follow-up people returned (1.99%). 900 of them had a canceled or unavailable first order (16 returned); they are people Olist lost at the first attempt, so they stay. Leaving them out would change the rate only to 2.00%, and all but 6 have a NULL `first_order_is_late` (no delivery date), so they drop out of the late vs on-time chart on their own |
| Oct 2026 | Order value = `items_value` (sum of item prices, freight not included), on page 1 and page 2 | Page 2 splits value by category and seller, and only item prices can be split that way (`fct_order_items.price`). `items_value` is the sum of those same prices, so both pages add up to the same total (13,591,643.70). Payment total stays a separate metric (M3-06) |
| Oct 2026 | "Payments on canceled and unavailable orders" uses `payment_total`, not `items_value`, and is one total, not split by category or seller | 767 of the 1,234 canceled and unavailable orders (62.2%) have no items: 164 of 625 canceled and 603 of 609 unavailable. That is above the 10% limit set for this choice. Orders with no items have no category or seller, so they can't be split that way. 0 orders have neither items nor payment, so `payment_total` covers all of them: 269,735.11 BRL, against 97,242.96 from `items_value` |
| Oct 2026 | Data Studio report uses owner's credentials and stays private (Restricted, owner only) until M5 | Recruiters won't have BigQuery access, so viewer's credentials would show blank charts. The data is public and small, and queries stay well inside the sandbox's free 1 TB a month. Sharing waits until the dashboard is finished |
| Oct 2026 | One embedded data source per mart (`dim_customers`, `fct_orders`, `fct_order_items`), community visualizations off, review scores and `delivery_days` default to Average | Embedded keeps everything inside the one report, so it copies and rebuilds as a unit (M4-06 Reverse). No third-party chart plug-ins means none can read the data (least privilege). Summing scores or days means nothing, so Average is the safe default. Re-adding a source resets these settings, so they're redone each time |
| Oct 2026 | Google renamed Looker Studio to Data Studio; existing text keeps "Looker Studio" until the M5 README pass | One rename pass at the end instead of editing every issue now |
| Oct 2026 | M4-07 becomes a recurring rebuild (first around December 20, then every ~55 days while the dashboard is shared); the demo video no longer waits for it; the project counts as finished when M5 is merged | Sandbox tables expire 60 days after they're written, so rebuilding early only moves the date by days, and a shared dashboard goes blank 60 days after the last rebuild. The tables are live now, so the video can be recorded on them. Milestone due dates stay as they are (December 20 and 31): they're deadlines, and finishing earlier needs no change |
| Oct 2026 | Page 1 return-rate charts are tables (group, rate, people), with cross-filtering off | A table shows each rate next to its group size, as M4-04 asks, which a bar chart can't do clearly. Cross-filtering let one click filter the whole page to a single person |
| Oct 2026 | Data Studio calculated fields are written down in docs/metrics.md section 5 | They live inside the embedded data source and are lost when it is removed and re-added, so the repo keeps the only permanent copy |
| Oct 2026 | Page 2 reads two summary models, `fct_category_summary` and `fct_seller_summary` | Data Studio can't average review scores one per order from `fct_order_items`, because every item repeats its order's score. The models copy the tested queries in docs/metrics.md section 3 and store counts and sums, not finished rates, so Data Studio computes each rate as SUM / SUM and it stays correct in any grouping. The report now reads five mart tables |
| Oct 2026 | The 30-order cut-off is an `in_rankings` column in the models | Data Studio settings are lost when a data source is re-added; a rule in the repo is tested and survives rebuilds |
| Oct 2026 | Category `unknown` is left out of rankings (`in_rankings` = false) but kept in totals | It is 610 unlabeled products mixed together, not a category Olist can act on; the caption will give its order count |
| Oct 2026 | Page 2 tables show `late_orders` (the count) next to the late-order rate | The highest rates belong to small sellers near the 30-order cut-off (for example 14 late orders, 32.56% of the 43 with a delivery date), while a seller with 1,806 orders at 9.71% has 172. Showing the count lets readers judge size; the ranking stays by rate, as M4-05 specifies |
| Oct 2026 | `fct_order_items` removed from the report | No chart uses it, and it's one less source to rebuild. The summary models are built from it, and `docs/metrics.md` section 3 still queries it as the definition. Supersedes the M4-03 data-source row and 'the report now reads five mart tables' |

## 14. Later (not in current scope)

- Cloud Storage raw bucket (needs billing + budget alert; free only in us-east1/us-west1/us-central1)
- Scheduled pipeline runs
- Azure exposure
