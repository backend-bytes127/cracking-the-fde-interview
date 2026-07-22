# Customer Scenario Frameworks

When you get a customer scenario in an FDE interview, you need a structured way to answer it. Here are the frameworks that work.

---

## The 5-Step Framework

**1. Clarify**
Ask questions before proposing solutions. This is not stalling — it's how good engineers work.

Questions to ask:
- Who are the end users? (internal teams, external customers, developers)
- What's the scale? (requests per day, data volume, team size)
- What's the latency requirement?
- What's the budget constraint?
- What does success look like in 6 months?
- What have they already tried?

**2. Identify the core problem**
Restate your understanding: "So if I understand correctly, the core challenge is X, which is causing Y business impact."

This confirms you understood the problem and shows you can synthesize.

**3. Propose a solution with tradeoffs**
Don't present one perfect answer. Present 2-3 options with clear tradeoffs:

> "There are three approaches here:
> Option A is simpler to implement and can be done in 2 weeks, but has limitations at scale.
> Option B requires more initial investment but will scale to 10× their current load.
> I'd recommend Option A as a starting point, with a clear migration path to Option B when they hit these specific triggers."

**4. Identify risks**
What could go wrong? How do you monitor it?

- "The biggest risk is X. We'd detect it by monitoring Y metric and alerting when it exceeds Z threshold."

**5. Tie back to business value**
Why does this matter? Don't end on the technical solution — end on the outcome.

- "This approach reduces their monthly infrastructure cost by ~30% while improving p99 latency by 2×. More importantly, it unblocks the product team from shipping their Q3 roadmap."

---

## Example Scenarios and Strong Answers

### Scenario 1: "A fintech startup wants to build a fraud detection system."

**Clarifying questions:**
- What transaction volume? (affects latency requirements)
- What's the acceptable false positive rate? (block legitimate transaction vs. miss fraud)
- Do they have labeled historical fraud data? (determines if supervised ML is viable)
- What's their current tech stack?

**Strong answer structure:**
- Current state: simple rule-based system (threshold checks)
- Why it's failing: brittle rules, high false positives, new fraud patterns
- Proposed approach:
  - Phase 1: ML-based classifier trained on labeled historical transactions (GBM or neural net)
  - Phase 2: Real-time feature store for low-latency feature serving
  - Phase 3: Streaming anomaly detection for pattern shifts
- Tradeoffs: ML model needs labeled data (bootstrapping challenge), more complex to operate
- Monitoring: fraud rate, false positive rate, model latency, data drift alerts
- Business outcome: estimated 40% reduction in fraud losses, improved customer experience

---

### Scenario 2: "An enterprise customer wants to deploy an LLM-powered document Q&A system."

**Clarifying questions:**
- What types of documents? (PDFs, Word, structured/unstructured?)
- How many documents? How often do they change?
- Who are the users? (employees, customers)
- What's the acceptable latency for a response? (real-time vs. a few seconds)
- Security and data residency requirements?

**Strong answer:**
- Architecture: RAG system — embed documents, store in vector DB, retrieve at query time
- Components: document ingestion pipeline (GCS → Cloud Run → Vertex AI Embedding → Vector Search)
- Generation: Gemini 1.5 Pro with retrieved context
- Security: VPC Service Controls, no data leaves their GCP project
- Monitoring: faithfulness score (RAGAS), user feedback, response latency
- Tradeoffs: RAG vs fine-tuning — RAG chosen because documents change frequently and we need source citations

---

### Scenario 3: "A customer's ML model performance has degraded significantly."

**Clarifying questions:**
- What metric is degraded? (accuracy, latency, cost)
- When did it start? What changed around that time?
- What changed in production? (new data, code deployment, infrastructure change)

**Diagnostic framework:**
1. Is it a data problem? (input distribution shifted → data drift)
2. Is it a model problem? (the model itself is behaving differently → check for silent bugs in preprocessing)
3. Is it an infrastructure problem? (latency spike → check compute resources, dependent services)

**Strong answer:**
- Hypothesis: data drift — production data distribution shifted from training distribution
- Evidence: check input feature statistics vs. training statistics
- Fix: retrain on recent data; add data drift monitoring going forward
- Prevention: set up Vertex AI Model Monitoring with drift thresholds and auto-retraining pipeline

---

## What Interviewers Are Scoring

| Dimension | What they're looking for |
|-----------|--------------------------|
| Structured thinking | Did you clarify before proposing? Did you present tradeoffs? |
| Technical depth | Do you know the actual services and why? |
| Customer empathy | Do you understand why this matters to the business? |
| Risk awareness | Do you identify what could go wrong? |
| Communication | Can you explain this to a non-technical stakeholder? |
