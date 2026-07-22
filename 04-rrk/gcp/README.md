# GCP for FDE Interviews

Google Cloud Platform is the core technical domain for Google FDE. You need to know it well enough to advise enterprise customers on real architectural decisions.

## Services You Must Know

| Service | Category | Priority |
|---------|----------|---------|
| [Vertex AI](vertex-ai.md) | AI/ML | Critical |
| [BigQuery](bigquery.md) | Data Warehouse | Critical |
| [Cloud Run](cloud-run.md) | Serverless Compute | High |
| [Pub/Sub](pubsub.md) | Messaging | High |
| [GKE](overview.md) | Container Orchestration | High |
| [Cloud Storage](overview.md) | Object Storage | High |
| [Cloud Functions](overview.md) | Serverless Functions | Medium |
| [Dataflow](overview.md) | Streaming/Batch ETL | Medium |
| [Cloud SQL](overview.md) | Relational DB | Medium |
| [Firestore](overview.md) | NoSQL DB | Medium |

## The GCP Mental Map

```
Data Ingestion:    Pub/Sub → Dataflow → BigQuery / GCS
Model Training:    Vertex AI Training Jobs (custom or AutoML)
Model Serving:     Vertex AI Endpoints (online) / Batch Prediction (offline)
Application:       Cloud Run / GKE / App Engine
Auth:              IAM / Service Accounts / Workload Identity
Networking:        VPC / VPC SC / Private Service Connect
Observability:     Cloud Monitoring / Cloud Logging / Cloud Trace
```

## What Good GCP Answers Look Like

Shallow: "I would use BigQuery for the data."

Deep: "Given the customer's pattern of daily batch ingestion from their on-prem data warehouse, I'd use Dataflow for the ETL — it handles exactly-once semantics and scales automatically. Land the data in BigQuery partitioned by date and clustered by customer_id, since those are the most common filter dimensions. For the ML workloads, I'd read directly from BigQuery into Vertex AI pipelines rather than copying data to GCS — fewer moving parts, less cost."
