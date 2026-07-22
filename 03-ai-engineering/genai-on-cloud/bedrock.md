# Amazon Bedrock

Amazon Bedrock is AWS's managed GenAI service. It provides access to foundation models from multiple providers through a single API.

---

## Key Models Available

| Provider | Models | Use case |
|----------|--------|---------|
| Anthropic | Claude 3 (Haiku, Sonnet, Opus) | General purpose, enterprise |
| Meta | Llama 3 | Open source, cost-effective |
| Mistral AI | Mistral 7B, Mixtral | Efficient, good for structured tasks |
| Amazon | Titan Text, Titan Embeddings | AWS-native, lowest latency on AWS |
| Cohere | Command, Embed | Enterprise search and retrieval |
| Stability AI | SDXL | Image generation |

---

## Quick Start

```python
import boto3
import json

bedrock = boto3.client("bedrock-runtime", region_name="us-east-1")

# Call Claude via Bedrock
response = bedrock.invoke_model(
    modelId="anthropic.claude-3-sonnet-20240229-v1:0",
    contentType="application/json",
    accept="application/json",
    body=json.dumps({
        "anthropic_version": "bedrock-2023-05-31",
        "max_tokens": 1024,
        "messages": [
            {"role": "user", "content": "Explain RAG in one paragraph."}
        ]
    })
)

result = json.loads(response["body"].read())
print(result["content"][0]["text"])
```

---

## Bedrock Knowledge Bases (Managed RAG)

Bedrock provides a managed RAG service:

```python
# Query a knowledge base
bedrock_agent = boto3.client("bedrock-agent-runtime", region_name="us-east-1")

response = bedrock_agent.retrieve_and_generate(
    input={"text": "What is our refund policy?"},
    retrieveAndGenerateConfiguration={
        "type": "KNOWLEDGE_BASE",
        "knowledgeBaseConfiguration": {
            "knowledgeBaseId": "KB12345",
            "modelArn": "arn:aws:bedrock:us-east-1::foundation-model/anthropic.claude-3-sonnet-20240229-v1:0"
        }
    }
)
print(response["output"]["text"])
```

**When to recommend Bedrock KB vs custom RAG:**
- Bedrock KB: Faster to production, AWS-managed, good for standard use cases
- Custom RAG: More control over chunking, retrieval strategy, evaluation

---

## Bedrock Agents

Agentic AI that can take actions — call APIs, query databases, run code:

```python
# Invoke an agent
response = bedrock_agent.invoke_agent(
    agentId="AGENT123",
    agentAliasId="ALIAS123",
    sessionId="user-session-id",
    inputText="Check the status of order #12345 and send a summary to the customer"
)
```

---

## When to Recommend Bedrock

- Customer is already on AWS and doesn't want to leave
- They want to use Claude but through AWS (IAM-based auth, no Anthropic account)
- They need multiple model options under one API
- They want to use Bedrock Guardrails for content filtering
