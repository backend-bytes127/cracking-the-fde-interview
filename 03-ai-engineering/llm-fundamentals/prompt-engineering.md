# Prompt Engineering

Prompt engineering is the practice of crafting inputs to LLMs to reliably produce the desired output. It's often the fastest and cheapest way to improve model performance — before reaching for fine-tuning or RAG.

---

## Core Techniques

### Zero-Shot Prompting

Simply ask the model to perform a task with no examples.

```python
prompt = """
Classify the sentiment of this customer review as Positive, Negative, or Neutral.

Review: "The API was fast but the documentation was confusing."

Sentiment:
"""
```

**Works when:** The task is within the model's training distribution and the instruction is clear.

---

### Few-Shot Prompting

Provide examples of the desired input-output pattern.

```python
prompt = """
Classify the sentiment of customer reviews.

Review: "Amazing product, exactly what I needed."
Sentiment: Positive

Review: "Complete waste of money."
Sentiment: Negative

Review: "It does what it says, nothing more."
Sentiment: Neutral

Review: "The API was fast but the documentation was confusing."
Sentiment:
"""
```

**When to use:** When zero-shot isn't reliable. 3–5 examples usually suffices.

**Key insight:** Examples teach the model the *format* and *decision criteria*, not just the labels. Choose examples that cover edge cases.

---

### Chain-of-Thought (CoT)

Ask the model to reason step by step before answering.

```python
# Without CoT
prompt = "If a customer uses 1000 API calls/day at $0.002 each, what's the monthly cost?"

# With CoT
prompt = """
If a customer uses 1000 API calls/day at $0.002 each, what's the monthly cost?
Let's think step by step:
"""

# The model will reason: "1000 calls × $0.002 = $2/day × 30 days = $60/month"
# This is far more reliable than asking for the final number directly
```

**When to use:** Multi-step reasoning, math problems, complex logic. Significantly improves accuracy on reasoning tasks.

**Few-shot CoT:** Combine few-shot with chain-of-thought for maximum reliability.

---

### System Prompts

Define the model's persona, constraints, and behavior.

```python
system_prompt = """You are a technical support assistant for Acme Cloud Platform.

Guidelines:
- Only answer questions about Acme Cloud Platform
- If you don't know something, say "I don't have that information"
- Always provide relevant documentation links when available
- Keep responses concise — use bullet points for multi-step instructions
- Never suggest workarounds that bypass security controls"""
```

Good system prompts:
- Define role and expertise
- Set constraints (what NOT to do)
- Specify format expectations
- Handle edge cases explicitly

---

### Structured Output

Force the model to output structured data (JSON, XML).

```python
prompt = """
Extract the following information from the support ticket and return as JSON:
- customer_name
- severity (critical/high/medium/low)  
- product_area
- summary (one sentence)

Ticket:
"""Customer: Acme Corp. Our BigQuery jobs started failing at 2pm UTC.
All jobs in the `analytics` dataset return permission denied errors.
This is blocking our daily revenue reports."""

Return only valid JSON, no explanation.
"""

# Expected output:
# {
#   "customer_name": "Acme Corp",
#   "severity": "critical",
#   "product_area": "BigQuery",
#   "summary": "Permission denied errors on analytics dataset BigQuery jobs since 2pm UTC."
# }
```

**Tip:** For reliable JSON output, specify the exact schema. Use `response_format={"type": "json_object"}` with OpenAI API or equivalent.

---

### Role Prompting

Assign the model a specific role that activates relevant knowledge.

```python
system_prompt = "You are a senior Google Cloud Solutions Architect with 10 years of experience designing large-scale data platforms."
```

**Why it works:** Role assignment shifts the model's prior toward vocabulary, tone, and knowledge associated with that role.

---

## Prompt Engineering for FDE Scenarios

**Ticket classification:**

```python
system = """You are a support ticket classifier for a cloud platform.
Classify incoming tickets by:
- Priority: P0 (outage), P1 (degraded), P2 (question), P3 (feedback)
- Category: billing, authentication, performance, data, networking, other

Return JSON: {"priority": "P0", "category": "authentication"}"""
```

**Customer-facing explanation generator:**

```python
system = """You explain technical incidents to non-technical business stakeholders.
Rules:
- No jargon (replace API with "connection", database with "data storage", etc.)
- Focus on business impact, not technical cause
- Always end with what's being done and when it will be fixed"""
```

---

## Advanced Techniques

### Meta-Prompting

Use the model to generate or improve its own prompts.

```
"Generate 5 variations of this prompt that might produce more accurate results: [prompt]"
```

### Prompt Chaining

Break complex tasks into a chain of simpler prompts, passing outputs forward.

```
Step 1: Extract customer data from raw ticket text
Step 2: Classify the extracted data by severity  
Step 3: Generate a response using the classification
```

### Self-Consistency

Sample multiple responses and take the majority vote. Significantly improves accuracy for reasoning tasks at the cost of more API calls.

---

## Evaluation

Test prompts systematically before deploying.

```python
def evaluate_prompt(prompt_template, test_cases, expected_outputs, model):
    correct = 0
    for test_input, expected in zip(test_cases, expected_outputs):
        prompt = prompt_template.format(input=test_input)
        response = model.complete(prompt)
        if response.strip() == expected:
            correct += 1
    return correct / len(test_cases)
```

**Key principle:** Prompt engineering is empirical. Build a test set first. Measure accuracy. Iterate.

---

## What Interviewers Want to Hear

When asked about prompt engineering in an FDE interview:

1. "I'd start by defining the task clearly and building a small evaluation set — even 20 examples — so I can measure changes."
2. "I'd try zero-shot first. If it's not reliable, add few-shot examples. If reasoning is needed, add chain-of-thought."
3. "I'd use structured output (JSON) for any task that needs to integrate with downstream systems."
4. "I'd measure and not guess — prompt changes that feel better aren't always better."
