# MLOps

MLOps covers the operational side of machine learning: how models get served, monitored, and maintained in production.

FDE candidates don't need MLOps engineer depth, but you need to understand the key concepts — especially when advising customers on deploying AI systems.

| File | Description |
|------|-------------|
| [model-serving.md](model-serving.md) | Online vs batch prediction, endpoints, autoscaling |
| [monitoring.md](monitoring.md) | Drift detection, evaluation, alerting |
| [pipelines.md](pipelines.md) | Training pipelines, CI/CD for ML |

## Key Concepts to Know

- **Online prediction:** Real-time inference, low latency (< 200ms), stateless
- **Batch prediction:** Process large volumes offline, high throughput
- **Model registry:** Version control for models (MLflow, Vertex AI Model Registry)
- **Feature store:** Centralized feature computation and serving
- **Data drift:** When production data distribution shifts from training data
- **Model degradation:** When model performance degrades over time
