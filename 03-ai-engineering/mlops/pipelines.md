# ML Pipelines

A production ML system is not just a model. It's a pipeline: data ingestion, preprocessing, training, evaluation, deployment, and monitoring — all automated and reproducible.

---

## Pipeline Components

```
Data Source (BigQuery, GCS, Kafka)
      │
      ▼
Data Validation (Great Expectations / TFX)
  - Schema validation
  - Anomaly detection
  - Data quality checks
      │
      ▼
Feature Engineering
  - Transformations
  - Feature store write
      │
      ▼
Model Training
  - Hyperparameter tuning
  - Distributed training
      │
      ▼
Model Evaluation
  - Performance metrics
  - Bias analysis
  - Comparison to baseline
      │
      ▼
Model Registry (store if better than current prod)
      │
      ▼
Deployment (staged rollout)
      │
      ▼
Monitoring → trigger retraining if degraded
```

---

## Vertex AI Pipelines

```python
from kfp import dsl
from kfp.v2 import compiler
from google.cloud import aiplatform

@dsl.component(base_image="python:3.9")
def train_model(data_path: str, model_output: dsl.Output[dsl.Model]):
    # Training logic here
    import joblib
    from sklearn.ensemble import RandomForestClassifier
    # ... train model ...
    joblib.dump(model, model_output.path)

@dsl.component(base_image="python:3.9")
def evaluate_model(
    model: dsl.Input[dsl.Model],
    test_data: str,
    metrics: dsl.Output[dsl.Metrics]
):
    # Evaluation logic
    metrics.log_metric("accuracy", 0.95)

@dsl.pipeline(name="training-pipeline")
def training_pipeline(data_path: str):
    train_task = train_model(data_path=data_path)
    evaluate_model(
        model=train_task.outputs["model_output"],
        test_data=data_path
    )

# Compile and run
compiler.Compiler().compile(
    pipeline_func=training_pipeline,
    package_path="pipeline.json"
)

aiplatform.init(project="my-project", location="us-central1")
job = aiplatform.PipelineJob(
    display_name="training-pipeline",
    template_path="pipeline.json",
    parameter_values={"data_path": "gs://my-bucket/data"}
)
job.run()
```

---

## CI/CD for ML

ML systems need the same software engineering rigor as regular software:

**Continuous Integration:**
- Unit tests for data preprocessing functions
- Integration tests against a sample dataset
- Model performance regression tests
- Data schema validation

**Continuous Deployment:**
- Automated evaluation against a holdout set
- A/B test new model before full rollout
- Automatic rollback if metrics degrade
- Environment parity (same preprocessing in training and serving)

**The training-serving skew problem:** When the preprocessing logic used during training differs from what runs in production. This is one of the most common and hardest-to-debug production issues in ML.

```python
# WRONG: different preprocessing in training and serving
# Training:
def preprocess_training(x):
    return (x - training_mean) / training_std  # uses training stats

# Serving:
def preprocess_serving(x):
    return (x - 100) / 50  # hardcoded — will drift!

# RIGHT: same preprocessing function everywhere, stats stored alongside model
def preprocess(x, mean, std):
    return (x - mean) / std

# Save mean/std with the model at training time
# Load them at serving time
```
