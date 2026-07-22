# FDE Interview Structure

The FDE interview at most top companies has two core technical rounds:

1. **DSA Round** — algorithmic problem solving
2. **RRK Round** — Role Related Knowledge

Understanding what each round actually tests — and how it differs from a standard SWE interview — is the first step to preparing correctly.

---

## The DSA Round

### What it tests

The DSA round tests your ability to solve algorithmic problems under time pressure while communicating your thinking clearly.

This sounds identical to a SWE DSA round. Here's what's different.

**In a SWE DSA round**, the goal is to arrive at the optimal solution. Communication matters, but the code is primary.

**In an FDE DSA round**, communication and pattern recognition are weighted more heavily. Interviewers care about:
- Can you identify the right approach quickly?
- Can you explain your reasoning out loud as you code?
- Do you handle edge cases and ambiguity naturally?
- Does your code work? (Yes, this still matters.)

FDE DSA problems are also frequently framed with real-world context. Instead of "find the shortest path in a graph," you might get "a customer has a microservices architecture — what's the fastest way to route a request from service A to service B given these latency constraints?"

The algorithm is the same (Dijkstra / BFS). The framing requires you to extract the algorithm from the problem description, which is a different skill.

### How to approach problems you haven't seen

1. **Read the entire problem.** Take 60 seconds. Don't start coding on line 5.
2. **Identify constraints.** Sorted? Large n? Repeated queries?
3. **Map the trigger to a pattern.** Say it out loud: "The fact that it's asking for a subarray with a sum equal to k — that's prefix sum with a hash map."
4. **Start with the naive approach.** State it. Then optimize.
5. **Code while talking.** Every variable you write, explain why.
6. **Handle edge cases explicitly.** Empty input, single element, cycles, negative numbers — mention them unprompted.

### Time pressure

Most FDE DSA rounds are 45–60 minutes for one or two problems. The pace is faster than you think. Practice solving medium-difficulty problems in 25 minutes — including explanation — before your interview.

---

## The RRK Round

### What "Role Related Knowledge" means

RRK is the round that separates FDE prep from SWE prep. It tests your depth in the specific technical domain that FDE work sits in.

At Google FDE, RRK primarily means **GCP architecture and AI/ML systems.**

At Anthropic, RRK means **LLM fundamentals, Claude API, AI evaluation, and deployment.**

At Meta, RRK means **advertising infrastructure, Llama ecosystem, and ML systems.**

The core question the interviewer is asking: *"Can this person walk into a customer's architecture meeting on their first week and contribute something real?"*

### What topics come up at Google FDE

- Vertex AI — model deployment, pipeline creation, online/batch prediction
- BigQuery — schema design, performance optimization, cost management
- Cloud Run / GKE — container deployment, autoscaling
- Pub/Sub — event-driven architectures
- Data pipeline design — Dataflow, Cloud Composer, ETL patterns
- AI/ML system design — how to build a production RAG system, recommendation engine, etc.
- Customer scenarios — "a customer wants to migrate from on-prem ML to GCP, how do you approach it?"

### What good answers look like

The difference between a passing RRK answer and a great one:

**Passing:** "I would use Vertex AI for model deployment and BigQuery for data storage."

**Great:** "Given the customer's scale and the fact they have existing Spark pipelines, I'd start by assessing whether they can migrate incrementally using Dataflow for the ETL, land data in BigQuery, and use Vertex AI pipelines for the model training. The key risk is data gravity — moving petabytes is expensive and slow, so I'd do a crawl-walk-run: start with one use case, prove the pattern, then migrate at scale. For the model deployment specifically, I'd push for online prediction endpoints with A/B testing baked in from day one, not bolted on later."

The difference is specificity, awareness of real constraints, and sequencing.

### Customer scenario frameworks

When you get a customer scenario ("a fintech startup wants to build an LLM-powered document review system"), use this structure:

1. **Clarify:** Who are the users? What's the scale? What's the latency requirement? What's the budget?
2. **Identify the core technical problem:** Is this retrieval? Generation? Classification? Evaluation?
3. **Propose a solution with tradeoffs:** Start simple, acknowledge complexity, explain why you'd start with approach A before considering B.
4. **Identify risks:** What could go wrong? How do you monitor it? How do you handle failures?
5. **Tie it back to business value:** Why does this matter to the customer?

See [04-rrk/customer-scenarios](../04-rrk/customer-scenarios/) for detailed frameworks.

---

## How the Two Rounds Are Scored

Most companies use a holistic rubric with dimensions like:

| Dimension | DSA Round | RRK Round |
|-----------|-----------|-----------|
| Problem solving | Primary | Secondary |
| Communication | High weight | Primary |
| Technical depth | Medium | Primary |
| Domain knowledge | Low-medium | Primary |
| Code quality | Primary | Secondary |
| Ambiguity handling | High weight | High weight |

**The critical insight:** FDE interviews weight communication much more than most candidates expect. You can write a perfect solution in silence and fail. You can struggle with an algorithm while clearly explaining your thinking and pass.

Practice talking while you code. It feels unnatural. Do it anyway.
