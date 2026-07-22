# Design a Rate Limiter

A classic system design question that appears in FDE interviews because rate limiting is a real-world API concern customers deal with constantly.

---

## Requirements Clarification

**Functional:**
- Limit API requests per user per time window
- Return HTTP 429 Too Many Requests when limit exceeded
- Support different limits for different users/tiers

**Non-functional:**
- Low latency (< 5ms overhead per request)
- High availability (rate limiter can't be the single point of failure)
- Distributed (multiple API servers, limits must be consistent)

---

## Algorithms

### Token Bucket (Recommended)

A bucket holds up to N tokens. Tokens refill at rate R per second. Each request consumes one token. If bucket is empty, request is rejected.

**Properties:**
- Allows bursts up to N requests
- Smooth average rate of R requests/second
- Simple and intuitive

```python
import time

class TokenBucket:
    def __init__(self, capacity: int, refill_rate: float):
        self.capacity = capacity
        self.tokens = capacity
        self.refill_rate = refill_rate  # tokens per second
        self.last_refill = time.time()

    def allow_request(self) -> bool:
        now = time.time()
        elapsed = now - self.last_refill

        # Add tokens based on elapsed time
        self.tokens = min(
            self.capacity,
            self.tokens + elapsed * self.refill_rate
        )
        self.last_refill = now

        if self.tokens >= 1:
            self.tokens -= 1
            return True
        return False  # rate limited
```

**Distributed token bucket with Redis:**

```python
import redis
import time

r = redis.Redis()

def allow_request(user_id: str, capacity: int = 100, refill_rate: float = 10) -> bool:
    key = f"rate_limit:{user_id}"
    now = time.time()
    pipe = r.pipeline()

    # Use Lua script for atomicity
    script = """
    local tokens = tonumber(redis.call('get', KEYS[1]) or ARGV[1])
    local last_refill = tonumber(redis.call('get', KEYS[2]) or ARGV[3])
    local elapsed = tonumber(ARGV[3]) - last_refill
    tokens = math.min(tonumber(ARGV[1]), tokens + elapsed * tonumber(ARGV[2]))
    redis.call('set', KEYS[2], ARGV[3])
    if tokens >= 1 then
        redis.call('set', KEYS[1], tokens - 1)
        return 1
    end
    redis.call('set', KEYS[1], tokens)
    return 0
    """
    result = r.eval(script, 2, f"{key}:tokens", f"{key}:time",
                    capacity, refill_rate, now)
    return bool(result)
```

### Sliding Window (Alternative)

Track the exact timestamps of requests in the last window.

```python
from collections import deque

class SlidingWindow:
    def __init__(self, max_requests: int, window_seconds: int):
        self.max_requests = max_requests
        self.window = window_seconds
        self.requests = deque()  # timestamps

    def allow_request(self) -> bool:
        now = time.time()
        # Remove timestamps outside the window
        while self.requests and now - self.requests[0] > self.window:
            self.requests.popleft()

        if len(self.requests) < self.max_requests:
            self.requests.append(now)
            return True
        return False
```

**Tradeoff:** More accurate than fixed window, but higher memory usage (stores all timestamps).

---

## Architecture

```
Client Request
      │
      ▼
API Gateway
  │
  ├── Check rate limit → Redis (distributed counter)
  │     If limited: return 429
  │     If allowed: continue
  │
  ▼
Backend Service
```

**Redis for distributed rate limiting:**
- Single source of truth across multiple API gateway instances
- Atomic operations (Lua scripts or INCR with expiry)
- `INCR key EX 60` — increment counter, expires in 60 seconds

---

## Response Headers

Good API design returns rate limit info in headers:

```
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 943
X-RateLimit-Reset: 1721823600  # Unix timestamp when limit resets
Retry-After: 30  # seconds (only on 429)
```

---

## Customer Context

*"Why does rate limiting matter to our enterprise customer?"*

- Protects your service from abuse or accidental DDoS
- Enables tiered pricing (free: 100 req/min, pro: 10,000 req/min)
- Provides predictable cost and capacity planning
- Ensures fair resource distribution across customers

This is the FDE lens: algorithm → architecture → customer value.
