# Retrieval-Augmented Generation (RAG)

RAG is one of the most important patterns in applied AI. If you're targeting any FDE or AI Engineering role, you need to understand it deeply — not just what it is, but when to use it, how to implement it, and how to evaluate it.

---

## What Is RAG and Why It Exists

Large language models are trained on a fixed dataset with a knowledge cutoff. They cannot:
- Access private enterprise data
- Know about events after their training cutoff
- Reliably cite sources

RAG solves this by retrieving relevant documents at inference time and providing them as context to the model. The model generates its response based on both its training and the retrieved context.

**The core insight:** Instead of baking knowledge into model weights (expensive, static), retrieve knowledge from an external store at runtime (cheap, dynamic, updatable).

---

## Architecture

```
User Query
    │
    ▼
┌─────────────────────────────┐
│         RETRIEVER           │
│                             │
│  1. Embed query             │
│     query → vector          │
│                             │
│  2. Vector search           │
│     find top-k similar docs │
│                             │
│  3. Return documents        │
└──────────────┬──────────────┘
               │
               ▼ top-k documents
┌─────────────────────────────┐
│         GENERATOR           │
│                             │
│  1. Build prompt:           │
│     system + docs + query   │
│                             │
│  2. Call LLM                │
│                             │
│  3. Return response         │
└──────────────┬──────────────┘
               │
               ▼
         Final Answer
```

---

## Components

### 1. Document Chunking

Before anything can be retrieved, documents must be chunked into manageable pieces.

```python
def chunk_document(text: str, chunk_size: int = 500, overlap: int = 50) -> list[str]:
    """Split text into overlapping chunks for better context preservation."""
    chunks = []
    start = 0
    while start < len(text):
        end = min(start + chunk_size, len(text))
        chunks.append(text[start:end])
        start += chunk_size - overlap  # overlap preserves context at boundaries
    return chunks
```

**Chunking strategies:**
| Strategy | When to use |
|----------|------------|
| Fixed size with overlap | General purpose, good default |
| Sentence-based | Conversational or Q&A content |
| Paragraph-based | Well-structured documents |
| Semantic | When coherence matters more than size |

### 2. Embedding

Convert text to vectors that capture semantic meaning.

```python
from openai import OpenAI  # or use sentence-transformers locally

client = OpenAI()

def embed(text: str) -> list[float]:
    response = client.embeddings.create(
        model="text-embedding-3-small",
        input=text
    )
    return response.data[0].embedding
```

**Embedding models:**
| Model | Dimensions | Use case |
|-------|-----------|---------|
| text-embedding-3-small | 1536 | Good default, low cost |
| text-embedding-3-large | 3072 | Higher accuracy |
| sentence-transformers (local) | 384–768 | No API cost, self-hosted |
| Vertex AI textembedding-gecko | 768 | GCP-native |

### 3. Vector Database

Store and search embeddings efficiently.

```python
import pinecone

# Index setup (one-time)
pc = pinecone.Pinecone(api_key="...")
index = pc.Index("my-index")

# Upsert documents
def index_documents(chunks: list[str]):
    vectors = [(f"chunk-{i}", embed(chunk), {"text": chunk})
               for i, chunk in enumerate(chunks)]
    index.upsert(vectors=vectors)

# Search
def retrieve(query: str, k: int = 5) -> list[str]:
    query_vector = embed(query)
    results = index.query(vector=query_vector, top_k=k, include_metadata=True)
    return [r.metadata["text"] for r in results.matches]
```

**Vector DB options:**
| DB | Hosted | Best for |
|----|--------|---------|
| Pinecone | Cloud | Production, easy setup |
| Weaviate | Self/Cloud | Rich filtering, open source |
| Qdrant | Self/Cloud | High performance, open source |
| pgvector | Self (Postgres) | If you already use Postgres |
| Vertex AI Vector Search | GCP | GCP-native, large scale |
| ChromaDB | Local | Prototyping, development |

### 4. Generation

```python
def generate_with_rag(query: str, context_docs: list[str]) -> str:
    context = "\n\n---\n\n".join(context_docs)

    response = client.chat.completions.create(
        model="gpt-4o",
        messages=[
            {
                "role": "system",
                "content": "You are a helpful assistant. Answer questions using only the provided context. If the context doesn't contain the answer, say so."
            },
            {
                "role": "user",
                "content": f"Context:\n{context}\n\nQuestion: {query}"
            }
        ]
    )
    return response.choices[0].message.content
```

---

## Simple RAG Pipeline

```python
class RAGPipeline:
    def __init__(self, index, embed_fn, llm_fn):
        self.index = index
        self.embed = embed_fn
        self.llm = llm_fn

    def ingest(self, documents: list[str]):
        for doc in documents:
            chunks = chunk_document(doc)
            for chunk in chunks:
                vector = self.embed(chunk)
                self.index.upsert(chunk, vector)

    def query(self, question: str, k: int = 5) -> str:
        # Retrieve
        q_vector = self.embed(question)
        relevant_chunks = self.index.search(q_vector, k)

        # Generate
        return self.llm(question, relevant_chunks)
```

---

## When to Use RAG vs Fine-Tuning vs Prompting

| Scenario | Best approach |
|----------|--------------|
| Need access to private/internal documents | RAG |
| Need up-to-date information | RAG |
| Model needs to learn a new writing style or format | Fine-tuning |
| Model needs specialized domain knowledge baked in | Fine-tuning |
| Need consistent structured output | Prompt engineering + fine-tuning |
| Need few-shot behavior | Prompt engineering (few-shot examples) |
| Need the model to follow a chain of reasoning | Prompt engineering (chain-of-thought) |
| Simple instruction following already works | Just prompting |

**The most important question:** Does the model already know what it needs to know to answer correctly, it just doesn't have the information? → RAG. Does it not know HOW to reason about the domain? → Fine-tuning.

---

## Evaluation Metrics

**Retrieval metrics:**
- **Recall@K:** Are the relevant documents in the top K results?
- **Precision@K:** Of the top K results, what fraction are relevant?
- **MRR (Mean Reciprocal Rank):** How highly ranked is the first relevant result?

**Generation metrics:**
- **Faithfulness:** Does the answer accurately reflect the context? (no hallucination)
- **Answer Relevance:** Does the answer address the question?
- **Context Relevance:** Was the retrieved context actually useful?

**Frameworks:** RAGAS is the standard evaluation framework for RAG systems.

```python
from ragas import evaluate
from ragas.metrics import faithfulness, answer_relevancy, context_recall

# Evaluate a RAG system
results = evaluate(
    dataset=eval_dataset,
    metrics=[faithfulness, answer_relevancy, context_recall]
)
```

---

## Common Failure Modes

| Problem | Cause | Fix |
|---------|-------|-----|
| Wrong documents retrieved | Embedding mismatch, poor chunking | Better chunking, hybrid search |
| Hallucination despite good retrieval | Model ignores context | Stricter system prompt, smaller model |
| Slow response time | Large k, slow embedding | Cache embeddings, reduce k, async retrieval |
| Outdated information | Stale index | Incremental indexing pipeline |
| Context too long for model | Too many chunks | Reranking to select top 2-3 from top 20 |

---

## Common Interview Questions

**"When would you choose RAG over fine-tuning?"**  
RAG when the data changes frequently or is private. Fine-tuning when you need the model to reason differently, not just know different facts.

**"How do you handle the case where relevant information spans multiple documents?"**  
Multi-hop retrieval: retrieve initial documents, extract key concepts, retrieve again. Or use a re-ranker that considers cross-document relevance.

**"How do you evaluate whether your RAG system is working?"**  
Build an evaluation set with known question-answer pairs. Measure retrieval metrics (Recall@K) separately from generation metrics (faithfulness, relevance). RAGAS automates this.

**"What's the biggest risk with RAG in production?"**  
Hallucination when the context is insufficient or the model ignores it. Also: retrieval latency, embedding costs, and index staleness.
