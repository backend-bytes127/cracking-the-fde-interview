# Model Serving

Model serving is how trained models become accessible to applications. Understanding the tradeoffs between serving patterns is essential for FDE customer conversations.

---

## Online vs Batch Prediction

| Dimension | Online (Real-time) | Batch |
|-----------|-------------------|-------|
| Latency | Low (< 200ms) | High (minutes to hours) |
| Throughput | Low-Medium | Very high |
| Cost | Higher (always-on compute) | Lower (spot instances) |
| Use cases | User-facing features, fraud detection | Reporting, bulk scoring, nightly jobs |
| Infrastructure | REST endpoint, autoscaling | Dataflow, Spark, scheduled jobs |

**Rule of thumb:** If a user is waiting for the result → online. If the result will be used later → batch.

---

## Online Serving Architecture

```
Client Request
      │
      ▼
Load Balancer
      │
      ▼
API Gateway (auth, rate limiting, logging)
      │
      ▼
Model Server (e.g., TorchServe, Triton, Vertex AI Endpoint)
  ├── Model v1 (80% traffic)  ← A/B test
  └── Model v2 (20% traffic)
      │
      ▼
Response + Logging
```

**Key components:**

**Model server:** Hosts the model artifact, handles batching of concurrent requests, manages GPU/CPU allocation.

**Autoscaling:** Scale replicas based on request volume. Vertex AI and SageMaker handle this automatically.

**A/B testing / Canary:** Route a percentage of traffic to a new model version. Essential for safe rollouts.

---

## Latency Budget

For real-time inference, understand where time is spent:

```
Total latency = preprocessing + model inference + postprocessing

Preprocessing: tokenization, feature extraction (1-10ms)
Model inference: depends heavily on model size and hardware
  - 7B model, 1 GPU: ~50-200ms for 500 tokens
  - GPT-4: ~1-3s for typical responses
  - Smaller BERT: ~5-20ms
Postprocessing: decoding, formatting (1-5ms)
```

**Optimization techniques:**
- **Quantization:** Reduce model precision (fp32 → fp16 → int8 → int4). Trade slight accuracy for 2-4× speedup.
- **Batching:** Process multiple requests together. Increases throughput; can increase latency.
- **Caching:** Cache outputs for identical or near-identical inputs.
- **Model distillation:** Train a smaller model to mimic a larger one.
- **KV cache:** Cache key-value pairs in transformer attention (standard for autoregressive generation).

---

## GCP: Vertex AI Endpoints

```python
from google.cloud import aiplatform

# Deploy a model to an endpoint
aiplatform.init(project="my-project", location="us-central1")

model = aiplatform.Model("projects/my-project/locations/us-central1/models/my-model")

endpoint = model.deploy(
    machine_type="n1-standard-4",
    accelerator_type="NVIDIA_TESLA_T4",
    accelerator_count=1,
    min_replica_count=1,
    max_replica_count=10,  # autoscaling
    traffic_split={"0": 100}  # 100% to this model version
)

# Predict
response = endpoint.predict(instances=[{"text": "classify this..."}])
```

---

## Common Interview Scenario

*"A customer wants to deploy a fraud detection model. They process 10 million transactions per day, with 90% occurring between 9am-6pm. What architecture do you recommend?"*

**Good answer:**
- Online endpoint for real-time transaction scoring (response time < 100ms)
- Autoscaling to handle the 9am-6pm peak (scale in/out based on request rate)
- Minimum 2 replicas for availability (no single point of failure)
- Batch job for daily retraining on the previous day's labeled data
- Shadow mode deployment when introducing a new model version: run both, compare results before switching traffic

*This shows you understand real-world operational requirements, not just ML theory.*
