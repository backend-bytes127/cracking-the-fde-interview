# Transformers

Every modern LLM is a transformer. Understanding the architecture — not just as a buzzword, but conceptually — is table stakes for FDE interviews at Anthropic, Google, and Meta.

You don't need to implement one from scratch. You need to understand what each component does and why it matters.

---

## The Big Picture

Before transformers, sequence models used RNNs — they processed text word by word, left to right. The problem: by the time the model reached word 100, it had largely "forgotten" word 1. Long-range dependencies were hard.

**The transformer's key innovation:** Process all tokens in parallel, with every token attending to every other token simultaneously. No sequential bottleneck. No vanishing gradient across distance.

---

## Architecture Overview

```
Input Text: "The cat sat on"
      │
      ▼
Tokenization: [1432, 3921, 8210, 4729]
      │
      ▼
Token Embeddings: each token → dense vector
      │
      ▼
+ Positional Encodings: inject position information
      │
      ▼
[Transformer Block × N]
  ├── Multi-Head Self-Attention
  │     "which tokens should I attend to?"
  ├── Layer Normalization
  ├── Feed-Forward Network
  │     "process the attended information"
  └── Layer Normalization
      │
      ▼
Output logits → Softmax → Next token probability
      │
      ▼
Sample → "the"  (next token generated)
```

---

## Key Components

### Tokenization

Text is split into tokens (not words). Common tokenizers use Byte Pair Encoding (BPE):

```
"unbelievable" → ["un", "believ", "able"]  # 3 tokens, not 1 word
"GPT-4"        → ["G", "PT", "-", "4"]    # 4 tokens
```

**Why this matters for FDE:** Costs are billed per token, not per word. "Token count" is the key metric for LLM API pricing and context window limits.

### Embeddings

Tokens map to dense vectors in a high-dimensional space (~768 to 4096 dimensions). Semantically similar tokens have similar vectors.

```
embed("king") - embed("man") + embed("woman") ≈ embed("queen")
```

### Positional Encoding

Transformers process all tokens in parallel — they have no inherent sense of order. Positional encoding injects position information into each token's representation.

Modern LLMs use **RoPE (Rotary Position Embedding)** which handles long context windows better than the original fixed sinusoidal encoding.

### Self-Attention

The core mechanism. For each token, compute how much it should "attend to" every other token.

See [attention.md](attention.md) for the full math.

### Feed-Forward Network (FFN)

After attention, each token's representation is processed by an FFN independently:

```
FFN(x) = W₂ · ReLU(W₁ · x + b₁) + b₂
```

The FFN stores "factual knowledge" — this is where the model's memorized information lives.

### Layer Normalization

Normalizes activations across the embedding dimension for training stability.

---

## Decoder-Only vs Encoder-Decoder

| Architecture | Examples | Use case |
|-------------|---------|---------|
| Decoder-only | GPT-4, Claude, Llama | Text generation (autoregressive) |
| Encoder-only | BERT, RoBERTa | Classification, embedding |
| Encoder-decoder | T5, BART | Translation, summarization |

**Most LLMs you'll encounter in FDE work are decoder-only.** They generate text token by token, left to right, each token conditioned on all previous tokens.

---

## Key Parameters and What They Mean

| Parameter | What it controls | Why it matters |
|-----------|-----------------|----------------|
| Context window | Max tokens in one call | Limits document length; affects RAG design |
| Model size (parameters) | Capacity and quality | More params → slower, costlier, smarter |
| Temperature | Randomness of output | 0 = deterministic, 1 = varied, 2 = chaotic |
| Top-p (nucleus sampling) | Token selection pool | Alternative to temperature for controlling randomness |
| Max tokens | Output length limit | Cost and latency control |

---

## What You Should Know for Interviews

**Can explain:** What a transformer is and why it replaced RNNs.

**Can explain:** Tokens, embeddings, attention, FFN — what each does conceptually.

**Can explain:** Decoder-only vs encoder architecture and why it matters for generation.

**Can discuss:** Context windows — why they matter for RAG and API design.

**Can discuss:** Temperature and sampling — why you'd want deterministic vs varied output.

You don't need to derive the attention formula from scratch (though it helps). You need to be able to say "I understand why transformers work and can reason about their architectural choices."
