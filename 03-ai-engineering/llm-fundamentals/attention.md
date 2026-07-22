# Attention Mechanism

Attention is the core innovation that makes transformers work. This guide covers the intuition, the math, and what you need to know for FDE interviews.

---

## The Intuition

When processing the sentence *"The animal didn't cross the street because it was too tired"*, a human instantly knows that "it" refers to "animal," not "street."

Self-attention allows the model to learn this kind of dependency. Each token looks at all other tokens and decides which ones are most relevant to its own meaning.

In the word "it":
- High attention to "animal" (it = animal)
- Low attention to "street"
- Medium attention to "cross" and "tired"

---

## The Math (Query, Key, Value)

Self-attention uses three learned linear projections of each token's embedding:

- **Query (Q):** What am I looking for?
- **Key (K):** What do I offer to be looked for?
- **Value (V):** What information do I contribute?

**Attention score computation:**

```
Attention(Q, K, V) = softmax(QKᵀ / √d_k) · V
```

Step by step:
1. `QKᵀ` — dot product of queries and keys → raw similarity scores
2. `/ √d_k` — scale to prevent vanishing gradients (d_k = key dimension)
3. `softmax(...)` — convert to probabilities (attention weights that sum to 1)
4. `· V` — weighted sum of values

**In Python:**

```python
import torch
import torch.nn.functional as F
import math

def scaled_dot_product_attention(Q, K, V, mask=None):
    d_k = Q.size(-1)

    # Compute attention scores
    scores = torch.matmul(Q, K.transpose(-2, -1)) / math.sqrt(d_k)

    # Optional causal mask (decoder: prevent attending to future tokens)
    if mask is not None:
        scores = scores.masked_fill(mask == 0, float('-inf'))

    # Convert to probabilities
    attention_weights = F.softmax(scores, dim=-1)

    # Weighted sum of values
    output = torch.matmul(attention_weights, V)
    return output, attention_weights
```

---

## Multi-Head Attention

Instead of one attention operation, run H parallel attention heads with different learned projections:

```
MultiHead(Q, K, V) = Concat(head₁, ..., headₕ) · Wᴼ

where headᵢ = Attention(Q·Wᵢᴼ, K·Wᵢᴷ, V·Wᵢᵛ)
```

**Why multiple heads?** Each head can specialize:
- Head 1: syntactic dependencies (subject-verb agreement)
- Head 2: semantic relationships (co-reference)
- Head 3: positional patterns (nearby words)

Different heads learn different types of relationships simultaneously.

---

## Causal (Masked) Self-Attention

Decoder-only models (GPT, Claude, Llama) use causal masking: each token can only attend to itself and previous tokens — not future tokens.

```
Token 1: attends to [1]
Token 2: attends to [1, 2]
Token 3: attends to [1, 2, 3]
Token 4: attends to [1, 2, 3, 4]
```

This enables autoregressive generation: the model generates one token at a time, conditioned on all previous tokens.

---

## Cross-Attention (Encoder-Decoder)

In encoder-decoder models (T5, BART), the decoder uses cross-attention:
- Queries come from the decoder's current state
- Keys and Values come from the encoder's output

This lets the decoder "attend to" the full input while generating output — critical for translation, summarization.

---

## KV Cache

During inference, the model computes Key and Value matrices for each token. With KV caching, these are stored and reused rather than recomputed for each new token.

**Why it matters for FDE:** KV cache size scales linearly with sequence length and quadratically with model size. For long-context applications (document analysis, long conversations), KV cache memory is often the limiting factor — not just the context window tokens.

---

## What to Know for Interviews

**Conceptual understanding** (must know):
- What Q, K, V represent intuitively
- Why attention solves the long-range dependency problem
- Why multiple heads help
- What causal masking does and why decoders need it

**Operational understanding** (should know):
- Attention is O(n²) in sequence length — this is why long contexts are expensive
- KV cache trades memory for computation savings at inference
- Flash Attention is an optimized implementation that reduces memory without changing outputs

**Do not need to:**
- Derive the backpropagation through attention
- Memorize specific head configurations of specific models
