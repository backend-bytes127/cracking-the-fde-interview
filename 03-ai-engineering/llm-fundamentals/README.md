# LLM Fundamentals

The concepts every FDE candidate must understand deeply.

| File | Description |
|------|-------------|
| [transformers.md](transformers.md) | The transformer architecture — what it is and why it matters |
| [attention.md](attention.md) | Self-attention, multi-head attention, the math behind the magic |
| [rag.md](rag.md) | Retrieval-Augmented Generation — architecture, implementation, evaluation |
| [fine-tuning.md](fine-tuning.md) | When and how to fine-tune — full fine-tuning, LoRA, QLoRA |
| [prompt-engineering.md](prompt-engineering.md) | Systematic prompting — few-shot, chain-of-thought, structured output |

## The Key Decision Framework

The most common FDE question: *"How should we improve this LLM's performance on our use case?"*

```
Is the base model missing fundamental knowledge?
  → Fine-tuning (update weights with domain data)

Is the base model capable but lacks access to current/private data?
  → RAG (give the model relevant context at inference time)

Is the base model capable but not following instructions well?
  → Prompt engineering (system prompts, few-shot examples, chain-of-thought)

Is the model too slow or expensive?
  → Smaller model + fine-tuning, or quantization + caching
```

Interviewers want to hear this reasoning, not just "use RAG."
