# Cloud Pub/Sub

Pub/Sub is Google Cloud's asynchronous messaging service. It decouples services that produce events from services that consume them.

---

## Core Concepts

```
Publisher → Topic → Subscription → Subscriber
                  ↗ Subscription → Subscriber
                  ↗ Subscription → Subscriber
```

- **Topic:** Named channel for messages. Publishers write to topics.
- **Subscription:** Named pull/push consumer attached to a topic.
- **Message:** Data (up to 10MB) with optional attributes.
- **Acknowledgment:** Subscriber confirms message was processed. Unack'd messages are redelivered.

---

## Delivery Guarantees

**At-least-once:** Messages are delivered at least once. Duplicates are possible. Design consumers to be idempotent.

**Ordered delivery:** Available with ordering keys — messages with the same key are delivered in order.

---

## Common Patterns

### Fan-Out

```python
# One event → multiple consumers
# Topology:
# event-topic → analytics-sub → analytics-service
#             → notifications-sub → notification-service
#             → audit-sub → audit-logger
```

**Use case:** New customer order triggers inventory update, email notification, and audit log simultaneously.

### Event-Driven Pipeline

```python
# GCS file arrives → Pub/Sub notification → Cloud Run processor → BigQuery
```

**GCS notification trigger:**
```bash
gsutil notification create \
  -t my-topic \
  -f json \
  gs://my-bucket
```

---

## Python Example

```python
from google.cloud import pubsub_v1

# Publish
publisher = pubsub_v1.PublisherClient()
topic_path = publisher.topic_path("my-project", "my-topic")

data = b"Hello, World!"
future = publisher.publish(topic_path, data, origin="my-service")
print(f"Published message ID: {future.result()}")

# Subscribe (pull)
subscriber = pubsub_v1.SubscriberClient()
subscription_path = subscriber.subscription_path("my-project", "my-subscription")

def callback(message):
    print(f"Received: {message.data}")
    message.ack()  # acknowledge so it's not redelivered

with subscriber:
    streaming_pull = subscriber.subscribe(subscription_path, callback=callback)
    try:
        streaming_pull.result(timeout=60)
    except Exception:
        streaming_pull.cancel()
```

---

## Pub/Sub vs Other Options

| Option | When to use |
|--------|------------|
| Pub/Sub | Async, fan-out, event-driven, GCP-native |
| Cloud Tasks | Delayed execution, rate-limited task queues |
| Eventarc | Trigger Cloud Run/GKE from GCP events (uses Pub/Sub under the hood) |
| Kafka | You need Kafka-specific features (log compaction, exactly-once) — usually Pub/Sub is sufficient |

---

## FDE Interview Scenarios

**"A customer wants real-time data from their application to BigQuery for analytics."**

```
App → Pub/Sub → Dataflow (streaming) → BigQuery
             → Cloud Run (real-time alerts if needed)
```

Why Dataflow? Pub/Sub delivers messages in near-real-time but not guaranteed order. Dataflow handles windowing, late data, and exactly-once writes to BigQuery.

**"A customer's Pub/Sub subscriber is falling behind. What do you do?"**

1. Check subscription metrics: `subscription/oldest_unacked_message_age`
2. Scale up consumers (more Cloud Run instances, or higher concurrency)
3. Check if messages are being processed or just failing — look for undeliverable message dead-letter topic
4. If consistently behind: increase subscription ack deadline, add more subscriber replicas
