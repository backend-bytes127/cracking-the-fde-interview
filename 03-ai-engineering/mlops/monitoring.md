# ML Monitoring

A model deployed to production is not done. Models degrade. Data distributions shift. Business requirements change. Monitoring is how you know before your customer does.

---

## Types of Drift

### Data Drift (Covariate Shift)

The distribution of input features changes. The model was trained on different data than it's seeing in production.

**Example:** A fraud detection model trained on 2024 transaction patterns. In 2026, new payment methods and merchant categories appear that weren't in training data.

```python
# Detect data drift using statistical tests
from scipy import stats

def detect_drift(training_dist: list[float], production_dist: list[float]) -> bool:
    # Kolmogorov-Smirnov test
    statistic, p_value = stats.ks_2samp(training_dist, production_dist)
    return p_value < 0.05  # significant drift if p < 0.05
```

### Concept Drift

The relationship between inputs and outputs changes. The model's learned mapping becomes invalid.

**Example:** A sentiment model trained before a product recall. After the recall, the same language patterns carry different sentiment.

### Prediction Drift

The distribution of model outputs shifts, even if inputs haven't changed dramatically. Often an early warning sign.

---

## Key Metrics to Monitor

**Model performance (requires ground truth):**
- Accuracy, precision, recall, F1 (classification)
- RMSE, MAE (regression)
- Rouge, BLEU, BERTScore (text generation)

**LLM-specific:**
- **Faithfulness:** Does the output accurately reflect context (no hallucination)?
- **Toxicity score:** Is the output appropriate?
- **Refusal rate:** Are legitimate requests being refused?
- **Response length distribution:** Has the model started truncating or padding?

**Infrastructure:**
- Latency (p50, p95, p99)
- Error rate and error types
- Throughput (requests/second)
- GPU utilization

---

## Monitoring Architecture

```
Production Traffic
      │
      ├── Log requests and responses → Data Warehouse (BigQuery)
      │
      ├── Real-time metrics → Monitoring (Cloud Monitoring / Prometheus)
      │
      └── Sampled outputs → Human review pipeline
              │
              ▼
         Alerting (PagerDuty, Cloud Monitoring alerts)
              │
              ▼
         Retraining trigger
```

---

## LLM Evaluation in Production

Ground truth for LLMs is hard to get. Use these approaches:

**LLM-as-judge:**
```python
def evaluate_with_llm(question: str, answer: str, context: str) -> dict:
    prompt = f"""
    Evaluate this answer on a scale of 1-5 for:
    1. Faithfulness (does it only use information from the context?)
    2. Relevance (does it answer the question?)
    3. Completeness (is the answer complete?)

    Question: {question}
    Context: {context}
    Answer: {answer}

    Return JSON: {{"faithfulness": int, "relevance": int, "completeness": int, "reasoning": str}}
    """
    # Call evaluation model (GPT-4 or Claude)
    return json.loads(eval_model.complete(prompt))
```

**Human sampling:** Randomly sample 1-5% of outputs for human review. Build a feedback loop.

**A/B testing:** Compare model versions on real traffic, measure downstream metrics (user engagement, task completion, escalation rate).

---

## Alerting Strategy

| Alert | Threshold | Action |
|-------|-----------|--------|
| P99 latency > 2s | 5 min sustained | Page on-call |
| Error rate > 1% | 10 min sustained | Page on-call |
| Accuracy drop > 5% | Daily evaluation | Trigger retraining |
| Data drift detected | Statistical test daily | Investigate + possible retrain |
| Refusal rate spike | > 2× baseline | Investigate + prompt audit |
