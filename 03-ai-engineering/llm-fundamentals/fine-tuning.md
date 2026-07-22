# Fine-Tuning

Fine-tuning adapts a pretrained model's weights to a specific task or domain. It's one of three core strategies (alongside RAG and prompt engineering) for improving LLM performance.

---

## When to Fine-Tune

Fine-tune when:
- The model needs to learn a new **format or style** (structured JSON output, specific tone)
- The model needs **domain-specific reasoning** (not just domain knowledge — that's RAG)
- You need consistent behavior that prompting alone can't achieve reliably
- Inference cost matters: a fine-tuned small model can outperform a large general model

Do NOT fine-tune when:
- You just need to inject facts or documents → use RAG
- Prompt engineering works → use prompt engineering (much cheaper)
- You need to frequently update the model's knowledge → RAG is more flexible

---

## Full Fine-Tuning

Update all model weights on a training dataset.

```python
from transformers import AutoModelForCausalLM, AutoTokenizer, Trainer, TrainingArguments

model = AutoModelForCausalLM.from_pretrained("meta-llama/Llama-2-7b-hf")
tokenizer = AutoTokenizer.from_pretrained("meta-llama/Llama-2-7b-hf")

training_args = TrainingArguments(
    output_dir="./fine-tuned-model",
    num_train_epochs=3,
    per_device_train_batch_size=4,
    gradient_accumulation_steps=4,
    warmup_steps=100,
    learning_rate=2e-5,
    fp16=True,  # mixed precision
    logging_steps=10,
)

trainer = Trainer(
    model=model,
    args=training_args,
    train_dataset=train_dataset,
    eval_dataset=eval_dataset,
)
trainer.train()
```

**Downsides:** Requires significant compute, GPU memory (7B model needs ~28GB in fp32), and can cause catastrophic forgetting.

---

## LoRA (Low-Rank Adaptation)

Fine-tune efficiently by only updating small low-rank adapter matrices instead of all weights.

**The math:** Instead of updating W (full weight matrix), represent the update as:
```
W' = W + ΔW = W + B × A
```
Where A is (d × r) and B is (r × d), with r << d. Only A and B are trained.

```python
from peft import LoraConfig, get_peft_model

lora_config = LoraConfig(
    r=16,              # rank — lower means fewer params
    lora_alpha=32,     # scaling factor
    target_modules=["q_proj", "v_proj"],  # which layers to adapt
    lora_dropout=0.05,
    bias="none",
    task_type="CAUSAL_LM"
)

model = get_peft_model(model, lora_config)
model.print_trainable_parameters()
# trainable params: 4,194,304 || all params: 6,742,609,920 (0.06%)
```

**Advantages:**
- 10-100× fewer trainable parameters
- Can run on consumer GPUs (7B model fits on 24GB GPU)
- Multiple LoRA adapters can be swapped at runtime

---

## QLoRA (Quantized LoRA)

4-bit quantization of the base model + LoRA adapters. Enables fine-tuning 7B models on a single 16GB GPU.

```python
from transformers import BitsAndBytesConfig

bnb_config = BitsAndBytesConfig(
    load_in_4bit=True,
    bnb_4bit_use_double_quant=True,
    bnb_4bit_quant_type="nf4",
    bnb_4bit_compute_dtype=torch.bfloat16
)

model = AutoModelForCausalLM.from_pretrained(
    "meta-llama/Llama-2-7b-hf",
    quantization_config=bnb_config,
    device_map="auto"
)
```

---

## RLHF (Reinforcement Learning from Human Feedback)

How models like Claude and ChatGPT are trained to be helpful, harmless, and honest.

**Three stages:**
1. **SFT (Supervised Fine-Tuning):** Fine-tune on high-quality demonstration data
2. **Reward Model:** Train a model to score outputs based on human preferences
3. **RL (PPO):** Use the reward model to optimize the LLM via RL

```
Human raters rank model outputs:
Response A > Response B > Response C

→ Train reward model on these preferences

→ Use reward model to score LLM outputs during RL training

→ LLM learns to generate outputs that score highly
```

**Why this matters for Anthropic interviews:** Anthropic uses Constitutional AI (CAI) — a variant where the "reward" comes from an AI model applying a set of principles, rather than only human raters. Know what Constitutional AI is and why it's useful at scale.

---

## Fine-Tuning Decision Framework

```
Task: improve LLM performance

Does the model need to KNOW different facts?
  Yes → RAG (inject facts at inference time)
  No  ↓

Does the model need to REASON differently?
  Yes → Fine-tuning
  No  ↓

Does prompting work reliably?
  Yes → Keep prompting (cheapest)
  No  → Fine-tuning for consistent format/style
```

---

## Comparison Table

| Method | Compute | Memory | Updates | Best for |
|--------|---------|--------|---------|---------|
| Full fine-tuning | High | Very high | All weights | Maximum task adaptation |
| LoRA | Low-Medium | Medium | Adapters only | Efficient, swappable |
| QLoRA | Low | Low | Adapters + quantized base | Single GPU, consumer hardware |
| Prompt tuning | Very low | Very low | Prompt embeddings | Very limited compute |
| RAG | Inference only | DB storage | Index (not weights) | Dynamic knowledge |
