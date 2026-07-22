# Vertex AI (Google Cloud)

Vertex AI is Google Cloud's unified ML platform. For Google FDE candidates, this is the most important service to know deeply.

---

## Key Components

| Component | What it does |
|-----------|-------------|
| Model Garden | Access to 100+ models: Gemini, open-source (Llama, Mistral), Google-trained |
| Vertex AI Endpoints | Deploy and serve models with autoscaling |
| Vertex AI Pipelines | Orchestrate ML workflows (Kubeflow-based) |
| Feature Store | Centralized feature computation and serving |
| Workbench | Managed Jupyter notebooks for development |
| Experiments | Track and compare training runs |
| Model Registry | Version and manage trained models |
| Vector Search | High-scale nearest-neighbor search for RAG |

---

## Gemini on Vertex AI

```python
import vertexai
from vertexai.generative_models import GenerativeModel

vertexai.init(project="my-project", location="us-central1")

model = GenerativeModel("gemini-1.5-pro")

response = model.generate_content(
    "Summarize the key benefits of using BigQuery for data analytics.",
    generation_config={
        "temperature": 0.2,
        "max_output_tokens": 1024,
        "top_p": 0.8,
    }
)
print(response.text)
```

---

## Building a RAG System on Vertex AI

**Complete pipeline:**

```python
import vertexai
from vertexai.language_models import TextEmbeddingModel
from google.cloud import aiplatform

# 1. Embed documents
embedding_model = TextEmbeddingModel.from_pretrained("textembedding-gecko@003")

def embed_texts(texts: list[str]) -> list[list[float]]:
    embeddings = embedding_model.get_embeddings(texts)
    return [e.values for e in embeddings]

# 2. Index in Vertex AI Vector Search
# (setup done via gcloud or Terraform — not shown here)
# index = aiplatform.MatchingEngineIndex(index_name="my-index")
# index_endpoint = aiplatform.MatchingEngineIndexEndpoint(index_endpoint_name="...")

# 3. Query and generate
def rag_query(question: str) -> str:
    # Embed the question
    query_embedding = embed_texts([question])[0]

    # Find similar documents (Vertex AI Vector Search)
    # response = index_endpoint.find_neighbors(queries=[query_embedding], num_neighbors=5)
    # docs = [match.metadata["text"] for match in response[0]]

    # Generate with context (using Gemini)
    context = "\n\n".join(docs)
    model = GenerativeModel("gemini-1.5-pro")
    return model.generate_content(
        f"Context:\n{context}\n\nQuestion: {question}\n\nAnswer based only on the context:"
    ).text
```

---

## Common Customer Scenarios

### "We want to migrate from OpenAI to Vertex AI"

**Approach:**
1. Assess: What models are they using? GPT-4 → Gemini 1.5 Pro, embeddings → textembedding-gecko
2. Compare: Run the same eval set on both models, measure quality difference
3. Migrate incrementally: Start with lower-risk, non-user-facing workloads
4. Retest: Any prompts that relied on GPT-4-specific behavior may need adjustment
5. Monitor: Track latency, cost, and quality in production

**Key risk:** Prompt compatibility. GPT-4 prompts often don't transfer perfectly. Plan for prompt re-engineering.

### "We want to build a customer support chatbot for our enterprise"

**Architecture recommendation:**
```
Customer message
      │
      ▼
Vertex AI Endpoints (Gemini 1.5 Flash for speed)
      ├── RAG against knowledge base (Vertex AI Vector Search)
      ├── Tool calling for CRM lookups
      └── Escalation classification
      │
      ▼
Response or escalate to human agent
```

**Why Gemini Flash vs Pro:** For support chatbots, latency matters more than maximum accuracy. Flash is 5× faster and 5× cheaper. Use Pro only for complex cases.

---

## Pricing Model (Approximate, 2026)

| Model | Input | Output |
|-------|-------|--------|
| Gemini 1.5 Flash | $0.075 / 1M tokens | $0.30 / 1M tokens |
| Gemini 1.5 Pro | $3.50 / 1M tokens | $10.50 / 1M tokens |
| Gemini 2.0 Pro | Check current pricing | |

**Context:** A typical RAG query with 5k tokens context + 500 token response costs ~$0.02 with Gemini Pro, ~$0.001 with Flash.

---

## Interview Scenarios You Should Prepare For

1. "Design a Vertex AI pipeline for a customer that wants to fine-tune Gemini on their support tickets."
2. "A customer's Vertex AI endpoint is timing out under peak load. How do you diagnose and fix this?"
3. "Compare Vertex AI Vector Search vs Pinecone for a customer's RAG use case."
4. "A customer wants to use Vertex AI but is worried about data leaving their VPC. What do you tell them?"

**For #4:** Vertex AI supports VPC Service Controls and Private Service Connect for data residency and network isolation. This is a common enterprise requirement.
