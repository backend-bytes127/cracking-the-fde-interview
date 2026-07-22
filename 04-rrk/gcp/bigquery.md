# BigQuery

BigQuery is Google Cloud's serverless data warehouse. For Google FDE candidates, knowing BigQuery well is essential — it appears in nearly every enterprise customer engagement.

---

## What BigQuery Is

BigQuery is a fully managed, serverless analytical database:
- Handles petabyte-scale queries in seconds
- No infrastructure to manage — pay per query (on-demand) or per slot (capacity)
- Columnar storage optimized for analytics (not OLTP)
- Built-in ML (BigQuery ML), geospatial analysis, and BI integration

---

## Key Concepts

### Partitioning

Split a table into segments to reduce query cost and improve performance.

```sql
-- Create a partitioned table
CREATE TABLE `my_project.analytics.events`
PARTITION BY DATE(event_timestamp)
OPTIONS (
  partition_expiration_days = 365
) AS
SELECT * FROM `my_project.raw.events`;

-- Query only 1 day's partition — BigQuery skips the rest
SELECT COUNT(*) 
FROM `my_project.analytics.events`
WHERE DATE(event_timestamp) = '2026-07-22';
```

**Types:** Date/timestamp partitioning (most common), integer range partitioning.

**Key FDE talking point:** "Partition pruning means you only pay for the data you actually scan. For a customer with 3 years of event data, querying one day's data should cost ~1/1000th of a full table scan."

### Clustering

Further organize data within partitions by one or more columns.

```sql
CREATE TABLE `my_project.analytics.events`
PARTITION BY DATE(event_timestamp)
CLUSTER BY customer_id, event_type
AS SELECT * FROM raw_table;
```

**Rule:** Partition first (coarse), cluster second (fine). Good candidates for clustering: columns frequently used in WHERE, GROUP BY, or JOIN.

### Slots

BigQuery queries run on "slots" — units of computational capacity.

- **On-demand pricing:** $6.25 per TB scanned. No commitment.
- **Capacity pricing:** Reserve a fixed number of slots. Better for predictable, high-volume workloads.

---

## BigQuery ML

Train and run ML models directly in BigQuery SQL:

```sql
-- Train a linear regression model
CREATE OR REPLACE MODEL `my_project.models.customer_ltv`
OPTIONS (model_type = 'LINEAR_REG', input_label_cols = ['lifetime_value'])
AS
SELECT
  account_age_days,
  num_products,
  avg_order_value,
  region,
  lifetime_value
FROM `my_project.analytics.customers`;

-- Make predictions
SELECT
  customer_id,
  predicted_lifetime_value
FROM ML.PREDICT(
  MODEL `my_project.models.customer_ltv`,
  (SELECT * FROM `my_project.analytics.new_customers`)
);
```

**When to recommend BigQuery ML:**
- Customer's data is already in BigQuery
- Need a quick baseline model without MLOps overhead
- Business analysts need to run predictions without leaving SQL

**When not to:**
- Complex deep learning models → Vertex AI
- Real-time inference → Vertex AI Endpoints
- Need custom training infrastructure → Vertex AI Custom Training

---

## Common Performance Issues and Solutions

| Problem | Cause | Fix |
|---------|-------|-----|
| Slow queries | Full table scan | Add partitioning, clustering |
| High query cost | Too much data scanned | Partition pruning, column selection |
| Query timeout | Too complex, too much data | Break into steps, use materialized views |
| Slot contention | Competing queries | Reservation pricing, workload management |
| Data skew in joins | Uneven data distribution | Use BigQuery hints, broadcast smaller table |

---

## Customer Scenarios

**"A customer runs daily analytics queries that take 3 hours. Their data is 5TB."**

1. Diagnose with INFORMATION_SCHEMA: check which tables are scanned, how many bytes
2. Add date partitioning if the queries filter by date (very likely)
3. Add clustering on the most common filter columns
4. Identify if the same queries repeat → materialized views
5. Expected outcome: 10-100× cost reduction, query time drops to minutes

**"A customer wants to run ML on their BigQuery data but doesn't have an ML team."**

Recommend BigQuery ML for simple models (regression, classification, clustering) or Vertex AI AutoML for more complex needs. Both require zero MLOps infrastructure to start.
