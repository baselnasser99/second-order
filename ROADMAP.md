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
| Transformation | dbt Core (latest **stable** 1.x, not the 2.0 alpha) | Cleans data, builds tables, runs data tests |
| Dashboard | Looker Studio | Charts for the findings; connects with your Google login, no keys |
| Automation | GitHub Actions | Lint and secret-scan every push; holds **no** cloud credentials |
| Project management | GitHub Issues + Projects board | One issue per increment, tracked To do → Done |

## 5. Ways of working

- One issue at a time, each on its own branch, merged into `main` through a reviewed pull request.
- Every issue follows the loop in Section 6 and passes the security checklist in Section 7.
- Decisions are recorded in Section 10 when they're made, not afterwards.
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
Test: `dbt build` passes (unique IDs, no empty keys, every order links to a customer). Reverse: drop all dbt tables, rebuild from nothing. Add dbt parse/compile check to GitHub Actions (still no credentials).

### Milestone 4 — Analytics & Dashboard (≈ 15 hours · target: late February 2027)
**Goal:** business metrics answering the question, shown in Looker Studio.
Test: hand-check 2–3 numbers against raw data. Reverse: rebuild dashboard using only mart tables. Every chart has a one-sentence caption.

### Milestone 5 — Insights & Delivery (≈ 10 hours · target: March 2027)
**Goal:** memo, README (finding first, setup last), architecture diagram, 2-minute demo video.
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

## 10. Decision log

| Date | Decision | Why |
|---|---|---|
| Oct 2026 | Google Cloud (BigQuery) over AWS | Permanent free tier with no credit card; AWS free plan closes after 6 months |
| Oct 2026 | No Cloud Storage bucket | Needs a billing account; data is small enough to load straight into BigQuery |
| Oct 2026 | Python setup script instead of Terraform | Terraform matters little for analyst/PM roles; script keeps reproducibility with less to learn |
| Oct 2026 | Looker Studio instead of Streamlit | No stored keys needed; no hosting to maintain |
| Oct 2026 | GitHub Actions with zero cloud credentials | Automated quality and secret checks without any credential exposure |
| Oct 2026 | dbt Core stable 1.x | 2.0 is still alpha; beginner needs stability |

## 11. Later (not in current scope)

- Cloud Storage raw bucket (needs billing + budget alert; free only in us-east1/us-west1/us-central1)
- Scheduled pipeline runs
- Azure exposure if Vancouver co-op postings call for it
