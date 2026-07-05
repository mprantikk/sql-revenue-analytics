# 📊 E-Commerce Revenue & Customer Analytics (PostgreSQL)

A SQL portfolio project simulating the kind of revenue, retention, and customer-behavior analysis
I run in my day-to-day work in data operations and financial analytics — built on PostgreSQL with a
synthetic e-commerce dataset.

## 🎯 Objective

Answer common business questions a growth/analytics team asks:
- How is revenue trending month over month?
- Who are our best customers, and how do we segment them (RFM)?
- What does customer retention/cohort behavior look like?
- Which products and categories drive the most revenue?
- What's our average order value and how is it changing?

## 🗂️ Project Structure

```
sql-revenue-analytics/
├── README.md              # This file
├── schema.sql              # Table definitions + relationships
├── seed_data.sql            # Synthetic sample dataset
├── analysis_queries.sql     # All analytical SQL queries
└── insights.md               # Summary of findings from the analysis
```

## 🧱 Schema Overview

Five tables model a simplified e-commerce business:

| Table          | Description                                  |
|----------------|-----------------------------------------------|
| `customers`    | Customer records with signup date & location |
| `products`     | Product catalog with category & unit price   |
| `orders`       | Order headers with date and status           |
| `order_items`  | Line items linking orders to products         |
| `payments`     | Payment records linked to orders              |

See [`schema.sql`](./schema.sql) for full DDL.

## 🔍 Key Analyses (see `analysis_queries.sql`)

1. **Monthly Revenue Trend** — total revenue and order count by month
2. **RFM Customer Segmentation** — Recency, Frequency, Monetary scoring using `NTILE()`
3. **Cohort Retention Analysis** — % of customers still active N months after signup
4. **Top Products & Categories** — revenue and unit contribution ranking
5. **Average Order Value (AOV) Trend** — AOV by month using window functions
6. **Customer Lifetime Value (CLV) Estimate** — cumulative revenue per customer

## 🛠️ Tools & Concepts Used

`PostgreSQL` · CTEs · Window Functions (`RANK`, `NTILE`, `LAG`) · Date truncation · Cohort analysis ·
RFM segmentation · Aggregate functions · Joins across a normalized schema

## ▶️ How to Run

```bash
createdb revenue_analytics
psql -d revenue_analytics -f schema.sql
psql -d revenue_analytics -f seed_data.sql
psql -d revenue_analytics -f analysis_queries.sql
```

## 📈 Sample Finding

> Revenue grew steadily quarter over quarter, with the top 20% of customers (by RFM score)
> contributing roughly 55% of total revenue — reinforcing the value of retention-focused
> campaigns over pure acquisition spend. See [`insights.md`](./insights.md) for the full write-up.

---
**Author:** [Masud Parvej](https://www.linkedin.com/in/mprantikk) — Data Analytics & Growth Operations
