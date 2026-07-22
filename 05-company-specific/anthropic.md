# Anthropic Interview Guide

## Why Anthropic Is Different

Anthropic is a safety-focused AI company. The interview process reflects this: they genuinely care whether you understand AI — not just whether you can use AI APIs.

The technical bar is high. The culture values intellectual honesty: if you don't know something, say so. If you disagree, say so. Pretending to know things is noticed and penalized.

---

## Role Overview

Anthropic does not have a role called "FDE." The equivalent roles are:

- **Software Engineer** — product engineering teams
- **AI Engineer** — building Claude products and infrastructure
- **Field AI Engineer** / **Customer Engineering** — customer-facing technical roles (growing team)
- **Research Engineer** — research and model development

For FDE-background engineers, the most relevant roles are Field AI Engineer and Customer Engineering.

---

## What Anthropic Looks For

**AI depth, not width.** You need to genuinely understand LLMs — not just call APIs. Interviewers will probe:
- Do you know how transformers work?
- Can you explain the tradeoffs between RAG and fine-tuning?
- What is Constitutional AI and why does it matter?
- Have you built and evaluated LLM systems in production?

**Intellectual honesty.** Anthropic's culture is built around finding and acknowledging uncertainty. "I'm not sure, but my best guess is X because Y" is a better answer than a confidently wrong one.

**Mission alignment.** Anthropic is building AI that is safe and beneficial. Interviewers genuinely care whether you've thought about AI safety, not as a checkbox but as a real concern. Read Anthropic's research papers, especially the Constitutional AI paper.

---

## Technical Topics to Know Deeply

| Topic | Depth required |
|-------|---------------|
| Transformer architecture | Conceptual (attention, FFN, decoder-only) |
| Constitutional AI | What it is, why it exists, how it differs from RLHF |
| Claude API | Models (Haiku, Sonnet, Opus), context windows, tool use |
| RAG | Architecture, when to use, evaluation |
| Fine-tuning | LoRA, QLoRA, RLHF — conceptual depth |
| Prompt engineering | Chain-of-thought, few-shot, structured output |
| LLM evaluation | RAGAS, LLM-as-judge, human evaluation |
| AI safety basics | Alignment, hallucination, bias — be able to discuss |

---

## Constitutional AI — Know This Cold

**What it is:** A training method where an AI model is given a set of "constitutional principles" and trained to critique and revise its own outputs according to those principles. Rather than relying solely on human feedback, a language model provides feedback using the constitution.

**Why it matters:**
- Scales alignment supervision beyond what humans alone can provide
- Produces models that can explain their behavior in terms of principles
- Core to how Claude is trained

**What to say in an interview:** "Constitutional AI uses an AI system to provide alignment signal at scale — the model is given principles and trained to critique its own outputs against them, then revised outputs become training data. This allows Anthropic to scale human oversight without requiring human feedback on every example."

---

## Claude API — Know This

```python
import anthropic

client = anthropic.Anthropic(api_key="...")

# Basic completion
message = client.messages.create(
    model="claude-opus-4-8",  # or claude-sonnet-4-6, claude-haiku-4-5
    max_tokens=1024,
    messages=[
        {"role": "user", "content": "Explain RLHF in one paragraph."}
    ]
)
print(message.content[0].text)

# Tool use (function calling)
tools = [{
    "name": "get_customer_info",
    "description": "Retrieve customer information by ID",
    "input_schema": {
        "type": "object",
        "properties": {
            "customer_id": {"type": "string", "description": "Customer ID"}
        },
        "required": ["customer_id"]
    }
}]

response = client.messages.create(
    model="claude-sonnet-4-6",
    max_tokens=1024,
    tools=tools,
    messages=[{"role": "user", "content": "Look up customer 12345"}]
)
```

---

## Preparation Strategy for Anthropic

1. **Read the Constitutional AI paper** — genuinely read it, understand it
2. **Build something with the Claude API** — tool use, multi-turn conversations, streaming
3. **Prepare to discuss AI safety** — not as a checkbox, but genuinely
4. **Practice intellectual honesty** — "I don't know exactly, but here's my reasoning..." is valued
5. **Know RAG cold** — it's the most common customer use case
