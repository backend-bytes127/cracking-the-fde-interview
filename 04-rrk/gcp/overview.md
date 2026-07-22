# GCP Core Services Overview

Quick reference for the GCP services that come up most in FDE interviews.

---

## Compute

| Service | What it is | When to use |
|---------|-----------|------------|
| Cloud Run | Serverless containers, HTTP-triggered | Stateless APIs, event-driven workloads, pay-per-request |
| GKE | Managed Kubernetes | Long-running workloads, complex microservices, stateful apps |
| Cloud Functions | Serverless functions, event-triggered | Simple automation, event handling, lightweight triggers |
| Compute Engine | Virtual machines | Full control needed, legacy lift-and-shift |
| App Engine | PaaS | Simple web apps, rapid deployment without infra management |

**FDE rule of thumb for compute:**
- Default to Cloud Run for new stateless workloads
- Use GKE when you need more control, stateful workloads, or GPU inference
- Cloud Functions for simple event handlers (GCS trigger, Pub/Sub consumer)

---

## Storage

| Service | What it is | When to use |
|---------|-----------|------------|
| Cloud Storage (GCS) | Object storage | Files, ML data, backups, static assets |
| BigQuery | Serverless data warehouse | Analytics, large-scale SQL queries, ML data |
| Cloud SQL | Managed relational DB | PostgreSQL / MySQL for applications |
| Firestore | NoSQL document DB | Real-time apps, user data, hierarchical data |
| Bigtable | Wide-column NoSQL | High-throughput, low-latency time series |
| Memorystore | Managed Redis | Caching, session storage |

---

## Networking

| Service | What it is |
|---------|-----------|
| VPC | Virtual private cloud — isolated network for your resources |
| VPC Service Controls | Perimeter around GCP APIs — prevents data exfiltration |
| Cloud Load Balancing | Global/regional load balancing for Cloud Run, GKE |
| Cloud CDN | Content delivery network for static assets |
| Private Service Connect | Access GCP services from VPC without public internet |
| Cloud Armor | DDoS protection and WAF |

**Enterprise customers always ask:** How do I ensure my data doesn't leave my network? Answer: VPC Service Controls + Private Service Connect.

---

## IAM and Security

```
Principal (who)     Action (what)       Resource (on what)
User/Group/SA  →    Role/Permission  →  Project/Folder/Resource
```

**Key IAM concepts:**

- **Service Account:** Identity for a GCP service (e.g., Cloud Run instance accessing BigQuery)
- **Workload Identity:** Allow Kubernetes pods to act as service accounts without key files
- **Principle of least privilege:** Always grant minimum required permissions

**Common FDE scenario:** Customer's Cloud Run service needs to read from BigQuery.

Correct: Create a service account with `BigQuery Data Viewer` role, attach it to the Cloud Run service. No key files needed.

Wrong: Use the project-level default service account (over-permissioned), or use a key file (security risk).

---

## Observability

| Service | What it does |
|---------|-------------|
| Cloud Monitoring | Metrics, dashboards, alerting |
| Cloud Logging | Centralized log ingestion and search |
| Cloud Trace | Distributed tracing for latency analysis |
| Error Reporting | Automatic error aggregation and alerting |

**For FDE customer conversations:** When a customer has a performance issue, start with Cloud Trace to see the latency breakdown, then Cloud Monitoring to check resource utilization, then Cloud Logging to examine errors.
