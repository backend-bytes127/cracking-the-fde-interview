# Design a URL Shortener

URL shortener is a canonical system design question. It covers hashing, database design, caching, and scalability — all topics that come up in FDE interviews.

---

## Requirements

**Functional:**
- Given a long URL, generate a short URL (e.g., `short.ly/abc123`)
- Redirect short URL to original long URL
- Optional: custom aliases, expiration, analytics

**Non-functional:**
- 100M URLs created per day → ~1,200 writes/second
- 10B redirects per day → ~115,000 reads/second
- High availability (no downtime acceptable)
- Read path must be fast (< 10ms)

---

## Short URL Generation

**Option 1: Hash-based**

```python
import hashlib
import base64

def generate_short_id(long_url: str) -> str:
    # MD5 hash → take first 6 chars of base62 encoding
    hash_bytes = hashlib.md5(long_url.encode()).digest()
    # Base62: 0-9, a-z, A-Z
    base62 = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    result = []
    n = int.from_bytes(hash_bytes[:6], 'big')
    for _ in range(6):
        result.append(base62[n % 62])
        n //= 62
    return ''.join(result)
```

**Problem:** Collisions. Two different URLs could generate the same short ID.

**Solution:** Check for collision in database. If collision, append a counter and rehash.

**Option 2: Counter-based (recommended for interview)**

Maintain a global auto-incrementing counter. Convert counter to base62.

```python
def int_to_base62(n: int) -> str:
    chars = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    result = []
    while n > 0:
        result.append(chars[n % 62])
        n //= 62
    return ''.join(reversed(result)) or '0'

# 62^6 = 56 billion possible short URLs — more than enough
```

**Distributed counter problem:** With multiple app servers, how do you ensure no two servers generate the same counter value?

**Solutions:**
1. Redis INCR — atomic, fast
2. Database auto-increment with pre-allocation (each server pre-fetches a range like 1000-2000)
3. Twitter Snowflake — distributed unique ID generation

---

## Architecture

```
Write path:
User → API Gateway → App Server → Generate ID
                                → Write to DB (id, long_url, created_at)
                                → Cache (id → long_url)
                                → Return short URL

Read path (high frequency):
User → Load Balancer → CDN (cache hit: 0ms)
                     → App Server (cache miss)
                          → Redis cache (cache hit: 1ms)
                          → Database (cache miss: 5-10ms)
                     → 302 Redirect to long URL
```

**Caching is critical:** 80% of redirects are for a small % of popular URLs. Cache aggressively.

---

## Database Schema

```sql
CREATE TABLE urls (
    id BIGINT PRIMARY KEY,          -- base62-encoded = short_id
    short_id VARCHAR(8) UNIQUE NOT NULL,
    long_url TEXT NOT NULL,
    user_id BIGINT,                 -- optional: who created it
    created_at TIMESTAMP NOT NULL,
    expires_at TIMESTAMP,           -- optional: TTL
    click_count BIGINT DEFAULT 0    -- analytics (or separate table at scale)
);

CREATE INDEX idx_short_id ON urls(short_id);
```

---

## Scaling

**Read scaling (115K QPS):**
- CDN for the most popular URLs
- Redis cluster for hot URLs (< 1ms)
- Read replicas for database (< 10ms)

**Write scaling (1,200 QPS):**
- Single primary database can handle this easily
- If needed: sharding by short_id prefix

**Storage estimation:**
- 100M URLs/day × 500 bytes average = 50GB/day
- 1 year = ~18TB
- Horizontally shard the database after ~5TB per shard

---

## Analytics (Optional Depth)

Track click events without blocking the redirect:

```python
# Non-blocking: publish to Pub/Sub, process asynchronously
async def redirect(short_id: str):
    long_url = await get_long_url(short_id)  # fast path
    asyncio.create_task(track_click(short_id, request))  # non-blocking
    return RedirectResponse(long_url, status_code=302)
```

Aggregate in BigQuery for dashboards. Cost and complexity vs. value: offer basic analytics in the product, deep analytics as a premium feature.
