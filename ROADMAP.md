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

Olist's raw sales data (CSV files) gets loaded by a Python script into BigQuery, Google's cloud database. dbt then cleans and reshapes that data into tidy tables, checking it with automated tests. Data Studio reads those tidy tables and shows the results as a dashboard. A written memo explains what the numbers mean and what Olist should do. GitHub stores all the code, checks it automatically on every change, and tracks the work on a project board.

## 3. Architecture

```
Olist CSV files (Kaggle)
        │  Python loader (Milestone 2)
        ▼
BigQuery dataset ecommerce_analytics: raw tables
        │  dbt (Milestone 3)
        ▼
BigQuery dataset ecommerce_dbt: staging views ──dbt──► mart tables
        │
        ▼
Data Studio dashboard (Milestone 4)
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
| Dashboard | Data Studio | Charts for the findings; connects with your Google login, no keys |
| Automation | GitHub Actions | Lint and secret-scan every push; holds **no** cloud credentials |
| Project management | GitHub Issues + Projects board | One issue per increment, tracked To do → Done |

## 5. Ways of working

- One issue at a time, each on its own branch, merged into `main` through a reviewed pull request.
- Every issue follows the loop in Section 6 and passes the security checklist in Section 7.
- Decisions are recorded in Section 14 when they're made, not afterwards.
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
**Goal:** business metrics answering the question, shown in Data Studio.
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

## 13. Milestone 5 issues (copy each into GitHub Issues)

Each issue uses the same checklist as Section 9.

**M5-01 · Recommendation memo**
`docs/memo.md`, one page, written for Olist's leadership: the finding, the evidence, what to fix first, and the limits of the data. Findings: only 3.12% of people ever order twice; about 2% return within 180 days whatever their first experience (late 1.69% vs on time 2.02%; review scores 1–5 all between 1.5% and 2.2%); the highest late rates belong to small sellers, while one large seller at 9.71% has 172 late orders, more than the 10 highest-rate sellers combined (140); 269,735.11 BRL was paid on 1,234 canceled or unavailable orders. Wording rules: don't claim late deliveries cause customers to leave (the data shows they leave either way); call the 269,735.11 BRL money at risk, not a loss (the data has no refunds); explain why payments (16,008,872.12) are higher than order value (13,591,643.70), mainly freight. Limits: data covers 2016 to 2018-08-21, shows patterns rather than causes, and has no refunds or seller names.
Test: every number in the memo appears in `docs/metrics.md` with the same value; tick each one off. Reverse: n/a.

**M5-02 · Architecture diagram**
A Mermaid diagram in the README (GitHub draws it from text, so there's no image file to keep up to date), matching Section 3: CSVs → Python loader → raw tables → dbt staging → dbt marts → Data Studio, with GitHub Actions and the project board around it.
Test: the diagram displays on the repo's GitHub page and matches Section 3. Reverse: n/a.

**M5-03 · README, finding first, setup last**
Order: the headline finding and one dashboard screenshot; the business question; the main findings (from the memo); the dashboard link (added in M5-04) and video link (added in M5-05); the architecture diagram; how it's built and the key decisions; known limits; setup from a fresh clone; data credit (Olist, CC BY-NC-SA 4.0) and license. Rename "Looker Studio" to "Data Studio" in the README and in ROADMAP.md Sections 2–4 and 8. The M4 issue texts (Section 12) and the decision log (Section 14) stay as written, since they record what was true at the time. Screenshots show only the report canvas, with no account email, avatar or project ID. Merged before December 18, so M5-06 can test it.
Test: a non-technical friend reads the README and explains the finding back in their own words; note anything they misread and fix it. Reverse: done in M5-06.

**M5-04 · Share the dashboard view-only**
Change the report from Restricted to "anyone with the link can view". Never give edit access. Turn off downloading, copying and printing for viewers. Add the link to the README. Record the sharing settings in the decision log, including that viewers' chart queries count against the owner's free 1 TB a month.
Test: open the link in a private browser window while logged out; every chart shows data, there's no edit button, and your email doesn't appear anywhere on the page. Reverse: n/a.

**M5-05 · Two-minute demo video**
Write the script first: the finding (20 seconds), a walk through both dashboard pages (60 seconds), how the pipeline works (25 seconds), and what Olist should do next (15 seconds). Record on the live tables, hosted unlisted (for example on YouTube) and linked from the README, never committed to the repo. No email, avatar, project ID or terminal history on screen.
Test: the video is under 2:00; watch it through once only to check for personal details. Reverse: n/a.

**M5-06 · Fresh-clone rebuild from the README (December 18, also the first M4-07 rebuild)**
First, check every table's expiration date in the BigQuery console and write them down. Then clone the repo into a new folder outside `second-order` and follow only the README to set up and rebuild: environment, `.env`, `profiles.yml` from the example, load raw with `scripts/load.py`, `dbt build`, `scripts/check_counts.py`. This is also the first real run of `load.py` with the M3-10 project ID check. Write down every step where you had to guess or use something the README doesn't say. Fix the README from your usual `second-order` folder, not the fresh clone, because the clone has no local excludes or `commit-msg` hook. Delete the fresh clone afterwards, since it holds a `.env`. Check the expiration dates again: if replacing a table's data didn't reset its expiry, find another way before the old date passes (raw around December 25, dbt a day later). Set a calendar reminder for the next rebuild, about 55 days later (around February 11, 2027). Close M4-07 and M5-06 together.
Test: expiry dates noted before the rebuild; counts 9/9; `dbt build` passes; the dashboard headline is unchanged; the new expiry dates are in late February 2027. Reverse: this issue is itself the M5 Reverse step.

**M5-07 · Tidy the decision log**
Group the decision log (Section 14) by milestone instead of by date, merge decisions that took several rows into one row showing where they ended up, and cut each reason to one or two plain sentences, keeping the numbers that matter and pointing to `docs/metrics.md` or `docs/data-notes.md` for detail. No decision is removed and no number changes; the full history stays in git.
Test: every row of the old log is in the new one, alone or merged, and every number matches; every "decision log" reference in the repo still finds its decision. Reverse: n/a.

---

## 14. Decision log

Grouped by the milestone each decision was made in, oldest first within each group. A decision that changed along the way has one row saying where it ended up. The earlier versions are in git history.

### M1 Foundation

| Decision | Why |
|---|---|
| Google Cloud (BigQuery), not AWS. | BigQuery has a permanent free tier with no credit card. The AWS free plan closes after 6 months. |
| No Cloud Storage bucket. | It needs a billing account, and the data is small enough to load straight into BigQuery. |
| A Python setup script instead of Terraform. | Terraform is built for managing large cloud setups, and this is one dataset. A script still rebuilds everything, with less to learn. |
| Looker Studio for the dashboard, not Streamlit. | No stored keys and no hosting to maintain. |
| GitHub Actions holds no cloud credentials. | Quality and secret checks run on every change, with no credential that could leak. |
| The first commits went straight to `main`. | There was nothing to open a pull request against yet. The pull request rule applies from M1-02. |
| `main` is protected by a ruleset, not classic branch protection. | A ruleset applies to admins too, because nobody is allowed to bypass it. |
| Pull requests need 0 approvals. | It's a solo project, and GitHub doesn't let you approve your own pull request. |
| Milestone due dates are the last day of each target period. | Section 8 gives rough targets like "late November", and GitHub needs an exact date. |
| The project board is public. | Anyone can see how the work is tracked. It holds only issue titles and statuses. |
| Python is pinned to 3.13 in `pyproject.toml`. | It's the newest version that dbt-core, dbt-bigquery and google-cloud-bigquery support. The pin can't live in `.python-version`, because `.gitignore` ignores that file. |
| No service account key files. | Logins go through gcloud application-default login, so the repo has no key to leak. |
| Dependabot security updates on from M1-05, when the first libraries arrived. | Off before that, since there was nothing to update. Dependabot only opens pull requests for known security holes, and those still go through protected `main`. |
| pre-commit hooks are pinned to commit SHAs, not tags. | A tag can be moved to point at different code. A SHA, a commit's fixed ID, can't. The release version stays in a comment so a person can read it. |
| GitHub Actions runs pre-commit itself, with its actions pinned to commit SHAs. | Local and CI checks share one setup, so they can't disagree. The SHAs are pinned for the same reason as the hooks. |
| CI also runs a `gitleaks-history` hook that scans the full history. | The standard gitleaks hook scans only staged changes, and in CI there are none. This one runs only when called by name, with the same pinned version. |
| `pre-commit` is a required check before anything merges into `main`. | Without it a red check is only a warning. Only the GitHub Actions app can report a pass. "Branch must be up to date" is off, since it's a solo project. |
| Stay on the BigQuery sandbox, where tables expire after 60 days. | It's free with no billing. One command rebuilds everything, so a rebuild before any demo is enough. |
| `.env` is read by `uv run --env-file`, not the python-dotenv library. | uv already reads env files, so that's one less library to pin and check. dbt-core 1.12 has installed python-dotenv since M3-01, but our code doesn't use it. |
| The dataset delete asks first, and refuses if the dataset still holds tables. | It protects loaded data. BigQuery itself also refuses to delete a dataset that still has tables. |

### M2 Ingestion

| Decision | Why |
|---|---|
| Raw tables load every column as text (STRING). | The data stays exactly as delivered, leading zeros in zip codes included. Types are fixed in dbt staging. |
| The loader replaces each raw table on every run. | Running it twice gives the same table, not duplicate rows. |
| Olist data is never committed. | Its license is CC BY-NC-SA 4.0, and `data/` is gitignored. It was downloaded Oct 26, 2026. |

### M3 Modeling

| Decision | Why |
|---|---|
| dbt 1.12.x, with dbt-core and dbt-bigquery both pinned. | First planned as stable 1.x in M1. Version 2 is new, while 1.12 is supported until July 2027, past the project's end. Both package names now have v2 releases, so an unpinned install could pull it. |
| No dbt packages, and every model is rebuilt in full. | The built-in tests are enough. The sandbox can't update tables in place, so there's no adding just the new rows. |
| CI runs `dbt parse`, not `compile`. | `parse` checks the project without connecting to BigQuery, so CI needs no credentials. |
| The sandbox's 10 GiB of storage is a lifetime budget. | Deleted data isn't refunded. So staging models are views, Reverse steps rebuild only what an issue touched, and raw data is reloaded only when needed. |
| `profiles.yml` stays outside the repo, and `profiles.example.yml` is committed. | No connection details go into git, but a fresh clone can still be set up. |
| All dbt models build into one dataset, `ecommerce_dbt` (US), separate from the raw data. | First planned as several dbt datasets, but one is enough at this size. It's in the same location as the raw data so joins work, and dropping it can never touch raw tables. |
| `dim_customers.number_of_orders` counts orders of every status. | The mart stays a plain record of what people ordered. The dashboard can filter by status. |
| `dim_customers.customer_state` is the state on the person's most recent order. | A person can order from more than one state, and the latest is where they are now. Ties go to `order_id`, so the result never changes between runs. |
| `fct_orders` keeps item value, freight and payment total as separate columns. | They don't always add up, because of vouchers and installment fees. Combining them would hide real differences. |
| An order with no items or no payments gets NULL, not 0. | A 0 would drag averages down. NULL means "no data" and is left out of averages. |
| `fct_orders.review_score` is the order's most recent review. | 547 orders have more than one review. Keeping one per order stops duplicate rows, and ties go to `review_id` so the result stays the same between runs. |
| `delivery_days` counts calendar days from purchase to delivery. | It's NULL when there's no delivery date, meaning "not delivered yet". 8 orders are marked delivered but have no delivery date, so they get NULL too. |
| `is_late` means delivered after the estimated date. | It's also NULL with no delivery date, so an order with no delivery date counts as neither late nor on time. |
| Reverse steps drop a single dbt table with `scripts/drop_table.py`. | It works only in `ecommerce_dbt`, refuses views and names with dots, and asks for the table name before deleting. It can't touch raw data or staging. |
| `fct_order_items.product_category` falls back to the Portuguese name, then `'unknown'`. | Some categories have no English name and some products have no category at all (`docs/data-notes.md`, question 7). This way no item drops out of category totals. |
| `fct_order_items` repeats the order's `is_late` and `review_score` on every item. | Item and seller analysis can filter by them. Averaged per item, multi-item orders would count more, so M4 averages them per order. |
| Mart column descriptions are copied into BigQuery, for marts only. | They show in the BigQuery console and Looker Studio's field list, and use no storage. Staging views don't need them, since Looker Studio reads only marts. |
| Full rebuilds delete the whole `ecommerce_dbt` dataset with `scripts/drop_dbt_dataset.py`. | The other delete scripts can't remove views or the dbt dataset. This one has several locks: it only deletes `ecommerce_dbt`, refuses anything not named `stg_`, `dim_` or `fct_`, and asks you to type the dataset name first. |
| M3-08's Test and Reverse were one drop-and-rebuild. | Both are the same action, a build from an empty dataset, and deleted storage isn't refunded. Raw row counts before and after showed the raw data was untouched. |
| Every script checks the project ID with `scripts/project_id.py` before connecting. | Google's library puts the ID into the web address as is, so a `/` or `?` could aim a delete at another table. One shared check means no script can skip it. |
| `dbt parse` and the two script self-checks run as pre-commit hooks. | Local and CI checks share one setup. The required `pre-commit` check already covers them, so the rules protecting `main` didn't change. |
| A placeholder dbt profile, `dbt/ci/profiles.yml`, is committed. | `dbt parse` needs a profile but never connects. This one holds only the made-up project ID `ci-dummy-project`, and `.gitignore` makes an exception for that one file. |
| The real profile has no fallback project ID. | If `GCP_PROJECT_ID` is missing, dbt stops instead of guessing. No source or model reads it, so CI doesn't need it. |
| CI Reverse test pull requests are made in the GitHub web editor. | The local hooks block committing a deliberate break, and hooks are never skipped. Web-editor commits don't run local hooks. |

### M4 Dashboard

| Decision | Why |
|---|---|
| Milestone 4 and 5 targets moved to December 2026. | M3 finished in late October, three months early. Finishing before the MS starts in January 2027, with a rebuild before tables expire around December 25, leaves slack. GitHub due dates are now December 20 and 31. |
| The data ends 2018-08-21, so full follow-up means a first order by 2018-02-22. | Daily orders fall from about 277 to 1 in late August. A later end date would count people as followed up after the data stops recording them. 56,007 people have full follow-up. |
| A return is a later order, within 180 days, that wasn't canceled or unavailable. | 897 of the 2,997 repeat customers placed their second order the same day as their first, and 66 only had canceled or unavailable later orders. Neither is a customer coming back. With these rules, 1,116 of 56,007 people returned (1.99%). |
| People whose first order was canceled or unavailable stay in the comparison. | They're 900 people Olist lost at the first try. Leaving them out would only move the rate from 1.99% to 2.00%. |
| Order value is the sum of item prices (`items_value`), without freight. | Page 2 splits value by category and seller, and only item prices can be split that way. Both pages then add up to the same total, 13,591,643.70. |
| Money on canceled and unavailable orders uses `payment_total`, as one total. | 767 of the 1,234 orders (62.2%) have no items, so item prices would miss most of them and there's no category or seller to split by. Payments cover all of them: 269,735.11 BRL. Details in `docs/metrics.md`. |
| The report uses the owner's data credentials and stays private until M5. | Viewers won't have BigQuery access, so their own credentials would show blank charts. The data is public and small, and queries stay well inside the sandbox's free 1 TB a month. |
| Third-party chart plug-ins are off in the report. | No outside plug-in can read the data. |
| Review scores and `delivery_days` default to Average. | Adding up scores or days means nothing. Re-adding a data source resets this and the plug-in setting, so both are redone each time. |
| M4-07 repeats every ~55 days while the dashboard is shared, first around December 20. | Sandbox tables expire 60 days after they're written, so a shared dashboard goes blank 60 days after the last rebuild. Rebuilding early only moves that date by a few days. |
| The demo video doesn't wait for M4-07, and the project ends when M5 merges. | The tables are live now, so the video can be recorded on them. Milestone due dates stay at December 20 and 31, since they're deadlines. |
| Page 1 shows return rates as tables, with cross-filtering off. | A table puts each rate next to its group size, as M4-04 asks. With cross-filtering on, one click filtered the whole page to a single person. |
| Data Studio calculated fields are written down in `docs/metrics.md` section 5. | They live inside the report's data source and are lost when it's re-added. The repo keeps the only permanent copy. |
| Page 2 reads two summary models, `fct_category_summary` and `fct_seller_summary`. | Data Studio can't average review scores once per order from item rows. The models store counts and sums, so each rate is worked out from totals and stays right in any grouping. |
| The 30-order cut-off is an `in_rankings` column in the models. | Report settings are lost when a data source is re-added. A rule in the repo is tested and survives rebuilds. |
| Category `unknown` is left out of rankings but kept in totals. | It's 610 unlabeled products mixed together, not a category Olist can act on. The caption gives its order count. |
| Page 2 tables show the late-order count next to the late-order rate. | The highest rates belong to small sellers, like one with 14 late orders. A seller with 1,806 orders at 9.71% has 172. The count shows size, and the ranking stays by rate. |
| The report reads four marts: `dim_customers`, `fct_orders` and the two summary models. | M4-03 started with three, including `fct_order_items`. The summary models made five, then `fct_order_items` was removed because no chart used it. Each source is stored inside the report, so the report copies and rebuilds as one unit. |

### M5 Delivery

| Decision | Why |
|---|---|
| The M5-06 fresh-clone rebuild is also the first M4-07 rebuild, on December 18. | Both reload raw data and run `dbt build`, so one run covers both and saves storage. It leaves a week before raw tables expire around December 25, so the known commands can still finish if the README fails. |
| Page 2 adds a top-10 "Sellers by late orders" table. | The caption's evidence, the large seller with 172 late orders, was pages down the rate ranking. Readers couldn't check it. |
| The memo, README and headline say late orders come from several large sellers, not one. | The new table showed several large sellers with many late orders (172, 124, 118 and more). "Concentrated in one large seller" overstated it. |
| The README and ROADMAP Sections 2, 3, 4 and 8 now say "Data Studio". | Google renamed Looker Studio during M4, and one pass in M5-03 changed the name. Older issue texts and this log keep "Looker Studio", since they record what was true then. |

## 15. Later (not in current scope)

- Cloud Storage raw bucket (needs billing + budget alert; free only in us-east1/us-west1/us-central1)
- Scheduled pipeline runs
- Azure exposure
