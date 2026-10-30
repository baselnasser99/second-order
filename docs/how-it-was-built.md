# How it was built

I built Second Order in five milestones in October to December 2026. Most steps were one GitHub issue, worked on its own branch and merged through a pull request after its checks passed. Where it made sense, I also undid the step or broke it on purpose to prove the checks catch problems. The original plan aimed to finish in March 2027. In October, after Milestone 3 finished three months early, I moved the Milestone 4 and 5 targets to December.

## The five milestones

**1. Foundation and guardrails.** Planned: November 30, 2026. Done: October 26, 2026.
I set up a protected repo, automatic checks for code style and leaked secrets, a project board, and a script that creates the BigQuery dataset, so every later change would pass the same checks. A commit holding a fake secret was blocked, a test pull request with a deliberate style error failed its checks, and the dataset was deleted and recreated with one command.

**2. Loading the data.** Planned: December 15, 2026. Done: October 26, 2026.
All 9 Olist CSV files load into BigQuery with one command, every column kept exactly as delivered. A script compares each file's row count with its table. I dropped every table, reloaded, and the counts still matched.

**3. Cleaning and modeling.** Planned: January 31, 2027. Done: October 28, 2026.
dbt turns the raw tables into clean, tested tables with one row per person, per order and per item. Every build runs data tests, such as "every order links to a customer". Everything rebuilt from an empty dataset in one command, and checks I broke on purpose failed as they should.

**4. Metrics and dashboard.** Planned (revised in October): December 20, 2026. Dashboard done: October 29, 2026.
I defined every dashboard number in plain words with its SQL, then built a two-page dashboard on the clean tables. I checked 3 numbers against the raw tables with direct SQL: 2,997 repeat customers, 6,535 late orders and 16,008,872.12 BRL in payments. It closes with the first rebuild before the free tables expire.

**5. Findings and delivery.** Planned (revised in October): December 31, 2026. First parts done in October 2026.
The numbers became a one-page memo for Olist's leadership, a README that leads with the finding, and a view-only dashboard link. It ends with a short demo video and a rebuild from a fresh copy of the repo, following only the README, to prove the instructions work.

## What I learned

- **Define a metric before counting it.** 897 of the 2,997 repeat customers placed their second order on the same day as their first, so I didn't count those as returns.
- **Give everyone the same chance.** Recent customers had less time to come back, so the return rate only counts people whose first order came at least 180 days before the data ends on 2018-08-21: 56,007 people.
- **Put the count next to the rate.** The highest late rates belong to small sellers, while one large seller at 9.71% has 172 late orders. Late orders come from several large sellers.
- **Use the column that covers every case.** 767 of the 1,234 canceled or unavailable orders have no items, so I used payments: 269,735.11 BRL of money at risk.
- **Keep rules in the repo, not in tool settings.** Dashboard settings are lost when a data source is re-added, so the 30-order ranking cut-off is a tested column in the tables.
- **Checks don't need secrets.** The automatic checks on GitHub hold no cloud credentials, so there's nothing to leak.

## More detail

- [ROADMAP.md](ROADMAP.md): the full plan, every issue's text and the decision log
- [README](../README.md): the findings and how to run it yourself
- [Memo](memo.md): the findings and recommendations for Olist's leadership
- [Closed issues](https://github.com/baselnasser99/second-order/issues?q=is%3Aissue+is%3Aclosed)
- [Merged pull requests](https://github.com/baselnasser99/second-order/pulls?q=is%3Apr+is%3Amerged)
