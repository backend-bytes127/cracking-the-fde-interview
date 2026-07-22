# Cloud Run

Cloud Run is Google Cloud's serverless container platform. It runs any container, scales to zero, and charges only for requests. The go-to compute option for most FDE customer architectures.

---

## What Makes Cloud Run Different

| Feature | Cloud Run | GKE |
|---------|-----------|-----|
| Infra management | None | Significant |
| Scaling | Automatic, including to zero | Manual or HPA configuration |
| Cold start | Yes (can mitigate) | No |
| Cost | Pay per request | Pay per node |
| Best for | Stateless HTTP services, event handlers | Complex microservices, stateful, GPU inference |

---

## Key Concepts

### Request-Based vs Always-On

```
Min instances = 0 (default): scale to zero, cold starts possible
Min instances = 1: always warm, no cold starts, higher cost
```

For customer-facing APIs where latency matters: `--min-instances=1`  
For internal or batch workloads: `--min-instances=0`

### Concurrency

```
Concurrency = max simultaneous requests per instance
Default = 80
```

Higher concurrency = fewer instances needed = lower cost. Works well for I/O-bound services (most API servers). For CPU-heavy tasks, lower concurrency per instance.

---

## Deploying to Cloud Run

```bash
# Build and push container
gcloud builds submit --tag gcr.io/my-project/my-service

# Deploy
gcloud run deploy my-service \
  --image gcr.io/my-project/my-service \
  --region us-central1 \
  --platform managed \
  --memory 2Gi \
  --cpu 2 \
  --min-instances 1 \
  --max-instances 100 \
  --concurrency 80 \
  --set-env-vars "ENV=production,PROJECT_ID=my-project" \
  --service-account my-sa@my-project.iam.gserviceaccount.com \
  --allow-unauthenticated  # or --no-allow-unauthenticated for private
```

---

## Common Architecture Patterns

### API Gateway Pattern

```
Internet → Cloud Load Balancer → Cloud Run (API)
                                    ├── Cloud SQL (user data)
                                    ├── Firestore (session/cache)
                                    └── Vertex AI (ML inference)
```

### Event-Driven Pattern

```
GCS file upload → Pub/Sub → Cloud Run (processor)
                                → BigQuery (results)
                                → Notification (Pub/Sub)
```

### Scheduled Jobs

```
Cloud Scheduler → Pub/Sub → Cloud Run (job)
   (cron)
```

---

## Troubleshooting Cold Starts

Cold start = time to spin up a new instance from scratch.

**Reducing cold start time:**
1. Set `--min-instances 1` (eliminates cold starts at cost of always-on instances)
2. Reduce container image size (use multi-stage builds, distroless base)
3. Lazy-load heavy dependencies (don't load ML models at import time)
4. Use startup probe with Cloud Run's startup CPU boost

```python
# Lazy load pattern
model = None

def get_model():
    global model
    if model is None:
        model = load_model("gs://my-bucket/model")
    return model

@app.route("/predict")
def predict():
    m = get_model()  # only loads on first request
    return m.predict(request.json)
```

---

## FDE Interview Scenarios

**"A customer wants to expose their BigQuery ML model as a REST API."**

```
Cloud Run → load model (or call BigQuery ML API) → return predictions
```

Simplest: Call BigQuery ML.PREDICT via the BigQuery API from Cloud Run.
Better for high QPS: Export model to Vertex AI endpoint, call that from Cloud Run.

**"A customer's Cloud Run service is slow under load."**

Diagnose:
1. Cloud Trace: where is time being spent?
2. Is it cold start? Check instance count and startup time.
3. Is it database? Check Cloud SQL connection pool, query time.
4. Is it upstream API? Check dependency latency.
5. Is it CPU-bound? Increase CPU allocation or reduce concurrency.
