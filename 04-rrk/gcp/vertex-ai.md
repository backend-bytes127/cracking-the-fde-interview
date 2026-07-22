# Vertex AI

Vertex AI is Google Cloud's unified ML platform. It's the most important GCP service for FDE candidates to know.

See [03-ai-engineering/genai-on-cloud/vertex-ai.md](../../03-ai-engineering/genai-on-cloud/vertex-ai.md) for the full Vertex AI guide including code examples, customer scenarios, and pricing.

---

## Key Vertex AI Interview Topics

### Online vs Batch Prediction

| Prediction type | Latency | Use case |
|----------------|---------|---------|
| Online endpoint | < 200ms | User-facing, real-time scoring |
| Batch prediction | Minutes to hours | Bulk scoring, reporting, offline jobs |

### Vertex AI Model Garden

Access 100+ models: Gemini (Google's flagship), Llama (Meta open source), Mistral, Stable Diffusion, and specialized Google models.

**Interview answer:** "For a customer who wants to experiment with multiple models before committing, I'd recommend starting in Model Garden — they can test Gemini, Llama, and Mistral in the same environment with the same tooling, then standardize on whichever performs best for their use case."

### Vertex AI Pipelines

ML workflow orchestration (Kubeflow/KFP under the hood):

```
Data validation → Feature engineering → Training → Evaluation → Conditional deployment
```

**When a customer asks about MLOps:** "Vertex AI Pipelines lets you define the full ML workflow as code — from data validation through deployment. It integrates with your CI/CD system so model retraining can be triggered automatically when new data arrives or performance degrades."

### Vertex AI Vector Search

Managed nearest-neighbor search — core infrastructure for RAG at GCP:

- Supports billions of vectors
- Filtering by metadata during search
- Integrates with Vertex AI Workbench and Gemini

**vs Pinecone:** Vector Search is better for high-scale, GCP-native workloads. Pinecone has a simpler API and is cloud-agnostic.

---

## Common Interview Questions

**"A customer wants to deploy a Gemini-based chatbot for internal knowledge management. Walk me through the architecture."**

```
User query → Cloud Run (API layer)
          → Vertex AI Embedding (textembedding-gecko)
          → Vertex AI Vector Search (find relevant docs)
          → Vertex AI (Gemini 1.5 Pro with RAG prompt)
          → Response

Data pipeline:
  Docs (GCS) → Cloud Run (chunking + embedding) → Vector Search index
```

Cost estimate, latency estimate, and monitoring strategy would complete a strong answer.

**"How do you handle the case where a customer's model performance degrades over time?"**

1. Monitoring with Vertex AI Model Monitoring (data drift detection)
2. Alerting when drift exceeds threshold
3. Automated retraining pipeline triggered by the alert
4. Evaluation gate before deployment (model must beat baseline)
5. A/B test before full rollout
