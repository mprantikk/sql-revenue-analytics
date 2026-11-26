# E-Commerce Revenue & Customer Analytics

[![CI](https://github.com/mprantikk/sql-revenue-analytics/actions/workflows/ci.yml/badge.svg)](https://github.com/mprantikk/sql-revenue-analytics/actions/workflows/ci.yml)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-4169E1?logo=postgresql&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-green)

A PostgreSQL analytics project that answers one question for an e-commerce business: **which customers actually make us money, and do they come back?**

It covers RFM segmentation, cohort retention, product performance, AOV trends and customer lifetime value, plus a data-quality suite that runs in CI. All data is synthetic.

## Results on the sample dataset

120 customers, 24 products, 356 orders, Jan 2023 to Dec 2024.

| Metric | Result |
|---|---:|
| Net revenue (completed orders) | $107,948 |
| Refunds excluded | $8,854 (26 orders) |
| Average order value | $343 |
| Revenue share of top 20% of buyers (23 customers) | 43.7% |
| Buyers with 2+ orders | 72.8% |
| Average month-1 cohort retention | 40.4% |
| Revenue growth, 2024 vs 2023 | +27% |
| Top categories | Beauty $23.6K · Home & Kitchen $23.3K · Electronics $22.4K |

### What the data says

- **Revenue is concentrated.** Nearly half of it comes from one buyer in five, so retention spend on the top RFM tier is likely to pay back faster than broad acquisition.
- **The second order is the moment that matters.** About 4 in 10 customers in a signup cohort order again in month one; a "second purchase" nudge in that window is the clearest lever.
- **Growth is steady, not a spike.** 2024 revenue grew 27% on 2023, with AOV rising over the period.

More detail in [insights.md](insights.md).

## What's inside

| File | Purpose |
|---|---|
| `schema.sql` | Normalised schema (customers, products, orders, order_items, payments) with constraints and indexes |
| `seed_data.sql` | Synthetic dataset |
| `analysis_queries.sql` | Six analyses: monthly revenue, RFM (`NTILE`), cohort retention, top products (`RANK`), AOV trend (`LAG`), CLV |
| `data_quality_checks.sql` | Eight assertions: completeness, validity, consistency, timeliness, integrity and a reconciliation to the headline revenue figure |

SQL techniques: CTEs, window functions (`NTILE`, `RANK`, `LAG`), date bucketing, conditional aggregation, PL/pgSQL assertions.

## Run it

```bash
git clone https://github.com/mprantikk/sql-revenue-analytics.git
cd sql-revenue-analytics
docker compose up -d                                   # Postgres 16 with schema + data loaded
export PGHOST=localhost PGUSER=postgres PGPASSWORD=postgres PGDATABASE=revenue_analytics
psql -v ON_ERROR_STOP=1 -f data_quality_checks.sql     # every check prints "passed"
psql -f analysis_queries.sql
```

## CI

On every push, GitHub Actions starts Postgres 16, loads the data, runs the data-quality suite (any failed check fails the build) and executes every analysis query.

## License

MIT. Built by [Masud Parvej](https://mprantikk.github.io/).
