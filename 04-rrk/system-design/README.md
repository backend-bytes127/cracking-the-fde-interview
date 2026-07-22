# System Design for FDE

System design in FDE interviews differs from SWE system design in one key way: the answer always needs to map back to customer value.

A SWE system design answer ends with a working architecture.
An FDE system design answer ends with a working architecture AND an explanation of the business tradeoffs.

| File | Description |
|------|-------------|
| [rate-limiter.md](rate-limiter.md) | Design a rate limiter — token bucket, sliding window |
| [url-shortener.md](url-shortener.md) | Design a URL shortener — classic, scales well |
| [design-patterns.md](design-patterns.md) | Recurring patterns: caching, sharding, pub-sub |

## The System Design Framework (FDE Version)

1. **Clarify requirements** — functional AND non-functional (scale, latency, availability)
2. **Estimate scale** — QPS, data size, storage, bandwidth
3. **High-level architecture** — draw the main components
4. **Deep dive** — pick the hardest component and go deep
5. **Tradeoffs** — what did you sacrifice? Why is that the right call?
6. **Failure modes** — what happens when X fails? How do you recover?
7. **Customer framing** — why would a customer care about this design?
