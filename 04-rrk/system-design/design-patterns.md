# System Design Patterns

Recurring patterns that appear across almost every system design question.

---

## Caching

**When to cache:** Read-heavy, expensive computation, data that doesn't change frequently.

**Cache aside (lazy loading):**
```python
def get_user(user_id: str) -> User:
    cached = redis.get(f"user:{user_id}")
    if cached:
        return deserialize(cached)

    user = db.query("SELECT * FROM users WHERE id = ?", user_id)
    redis.setex(f"user:{user_id}", ttl=3600, value=serialize(user))
    return user
```

**Write-through:** Update cache on every write. Cache always consistent with DB. Higher write latency.

**Write-behind (write-back):** Write to cache immediately, persist to DB asynchronously. Lower write latency, risk of data loss.

**Cache eviction policies:**
- LRU (Least Recently Used): evict what hasn't been used recently
- LFU (Least Frequently Used): evict what's used least often
- TTL: expire after a fixed time

---

## Database Sharding

Split data across multiple databases to scale beyond a single node.

**Hash-based sharding:**
```python
def get_shard(user_id: int, num_shards: int = 16) -> int:
    return hash(user_id) % num_shards
```

**Range-based sharding:** Shard by value range (e.g., user_id 0-1M on shard 1).

**Problems with sharding:**
- Cross-shard joins are expensive/impossible
- Re-sharding when adding new shards is painful
- Hot shards if distribution is uneven

**When to shard:** After you've exhausted vertical scaling and read replicas. Don't shard prematurely.

---

## Message Queues

Decouple producers and consumers. Enable async processing.

```
Use cases:
- Send email/notification asynchronously
- Process uploaded files in background
- Fan-out one event to multiple consumers
- Buffer spikes in traffic
- Retry failed operations
```

**At-least-once vs exactly-once:**
- Pub/Sub gives at-least-once delivery (duplicates possible)
- Design consumers to be idempotent: processing the same message twice has the same effect as once

```python
def process_order(order_id: str):
    # Idempotent: check if already processed
    if db.exists(f"processed_orders:{order_id}"):
        return  # already handled, skip

    # Process the order
    result = fulfill_order(order_id)

    # Mark as processed
    db.set(f"processed_orders:{order_id}", "true", ex=86400)
```

---

## API Design Patterns

**Pagination:**
```python
# Cursor-based (preferred for large datasets)
GET /api/users?limit=20&cursor=eyJ1c2VyX2lkIjogMTAwfQ==

# Offset-based (simpler but problematic with updates)
GET /api/users?limit=20&offset=40
```

**Circuit Breaker:**
Prevent cascading failures when a downstream service is degraded.

```python
class CircuitBreaker:
    def __init__(self, failure_threshold=5, timeout=60):
        self.failures = 0
        self.threshold = failure_threshold
        self.timeout = timeout
        self.state = "CLOSED"  # CLOSED, OPEN, HALF_OPEN
        self.last_failure = None

    def call(self, func, *args):
        if self.state == "OPEN":
            if time.time() - self.last_failure > self.timeout:
                self.state = "HALF_OPEN"
            else:
                raise Exception("Circuit is OPEN")

        try:
            result = func(*args)
            self.on_success()
            return result
        except Exception as e:
            self.on_failure()
            raise

    def on_success(self):
        self.failures = 0
        self.state = "CLOSED"

    def on_failure(self):
        self.failures += 1
        self.last_failure = time.time()
        if self.failures >= self.threshold:
            self.state = "OPEN"
```

---

## CAP Theorem

In a distributed system, you can only guarantee 2 of 3:
- **C**onsistency: all nodes see the same data at the same time
- **A**vailability: every request gets a response
- **P**artition tolerance: system works despite network partitions

Network partitions happen. So the real choice is C vs A during a partition.

**CP systems (choose consistency):** Banking, financial transactions, inventory management
**AP systems (choose availability):** Social media, search, recommendations — eventual consistency is fine

**In FDE interviews:** Be explicit about which tradeoff you're making and why it's appropriate for the customer's use case.
