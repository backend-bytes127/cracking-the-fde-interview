# Azure OpenAI Service

Azure OpenAI gives enterprise customers access to OpenAI models (GPT-4, o-series) through Azure infrastructure — with Azure's compliance certifications, private networking, and Microsoft enterprise agreements.

---

## Why Customers Choose Azure OpenAI Over OpenAI Directly

- **Compliance:** SOC 2 Type II, ISO 27001, HIPAA, FedRAMP — critical for regulated industries
- **Network isolation:** Private endpoints — traffic never leaves their VPC
- **Microsoft EA:** Bundle with existing Microsoft spending
- **Provisioned throughput:** Guaranteed TPM (tokens per minute) — no rate limiting surprises
- **Data residency:** Content processed in specified Azure region

---

## Quick Start

```python
from openai import AzureOpenAI

client = AzureOpenAI(
    azure_endpoint="https://my-company.openai.azure.com/",
    api_key="my-api-key",
    api_version="2024-02-01"
)

response = client.chat.completions.create(
    model="gpt-4o",  # deployment name in Azure
    messages=[
        {"role": "system", "content": "You are a helpful assistant."},
        {"role": "user", "content": "Summarize this contract..."}
    ]
)
```

**Note:** The API is identical to OpenAI's API — the only difference is the endpoint and model deployment names.

---

## Azure AI Studio

Microsoft's unified platform for AI development:
- Prompt Flow: visual pipeline builder for LLM workflows
- Model Catalog: Azure OpenAI + open-source models (Llama, Mistral, Phi)
- Azure AI Search: Vector search for RAG (replaces Pinecone etc. in Azure)
- Content Safety: Built-in content moderation

---

## When to Recommend Azure OpenAI

- Customer is Microsoft-first (M365, Teams, Azure DevOps)
- Regulated industry requiring Azure compliance certs
- Wants GPT-4 with private networking
- Already has Microsoft Enterprise Agreement
- Wants Copilot integration (Microsoft 365 Copilot uses Azure OpenAI)

## When Not to Recommend

- Customer is GCP-first → Vertex AI + Gemini
- Customer wants Claude → Anthropic API or Bedrock
- Customer needs cutting-edge models before Azure gets them (Azure has a lag)
