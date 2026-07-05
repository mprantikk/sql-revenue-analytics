# 📈 Insights Summary

Findings from running `analysis_queries.sql` against the seeded dataset (120 customers, 24 products,
356 orders, Jan 2023–Dec 2024).

## 1. Revenue Trend
- **Total revenue:** ~$116,800 across 341 completed payments
- Revenue in the second half of the observed period was **~26% higher** than the first half,
  showing steady month-over-month growth rather than a one-off spike
- Monthly revenue ranged from ~$150 in the first month (small customer base) up to $2,000–$4,000+
  per month as the customer base matured

## 2. Customer Segmentation (RFM)
- Of 114 customers with completed purchases, the **top 20% (22 customers) generated ~41% of total revenue**
- This is a classic Pareto-adjacent pattern — it flags retention/loyalty programs for the top RFM
  tier as likely higher ROI than broad-based acquisition spend

## 3. Retention
- **Average month-1 retention across signup cohorts: ~40%** — meaning roughly 4 in 10 new customers
  place a second order within their first month
- This is a natural checkpoint for a "second purchase" nudge campaign (email/SMS) if this were a real business

## 4. Product & Category Performance
- **Home & Kitchen** and **Beauty** were the top two categories by revenue (~$23K each),
  narrowly ahead of Electronics (~$22K)
- **LED Lamp**, **Lip Balm**, and **Non-stick Pan** were the top three individual SKUs by revenue —
  worth prioritizing for inventory and promotional focus

## 5. Average Order Value (AOV)
- **Overall AOV: ~$343**
- AOV trended upward over the two-year window (from ~$150 in month one to ~$360 in the final month),
  suggesting either higher basket sizes over time or a shift toward higher-value products

## Takeaway

Even on a synthetic dataset, this mirrors a pattern I see in real operational data: **a small share of
customers drives a disproportionate share of revenue**, and **early retention is the biggest lever**
for lifetime value. In a live business setting, next steps would be to segment marketing spend by RFM
tier and set up automated month-1 retention triggers.
