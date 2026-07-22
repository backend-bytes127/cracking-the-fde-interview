# Heap Problems

| Problem | Pattern | Difficulty | Link |
|---------|---------|------------|------|
| Kth Largest Element | Min-Heap size K | Medium | [LC 215](https://leetcode.com/problems/kth-largest-element-in-an-array/) |
| Merge K Sorted Lists | Min-Heap | Hard | [LC 23](https://leetcode.com/problems/merge-k-sorted-lists/) |
| Task Scheduler | Greedy + Max-Heap | Medium | [LC 621](https://leetcode.com/problems/task-scheduler/) |
| Find Median from Data Stream | Two Heaps | Hard | [LC 295](https://leetcode.com/problems/find-median-from-data-stream/) |

See [patterns/heap.md](../patterns/heap.md) for Kth Largest, Merge K Sorted Lists, and Median from Data Stream.

---

## Task Scheduler

**LC 621 — Medium**

Schedule CPU tasks with a cooldown n between same tasks. Minimize total intervals.

```python
import heapq
from collections import Counter, deque

def least_interval(tasks: list[str], n: int) -> int:
    count = Counter(tasks)
    max_heap = [-c for c in count.values()]
    heapq.heapify(max_heap)

    time = 0
    queue = deque()  # (count_remaining, time_available)

    while max_heap or queue:
        time += 1

        if max_heap:
            cnt = 1 + heapq.heappop(max_heap)  # process one task
            if cnt < 0:
                queue.append((cnt, time + n))  # schedule when it can run again

        if queue and queue[0][1] == time:
            heapq.heappush(max_heap, queue.popleft()[0])

    return time


# Test
print(least_interval(["A","A","A","B","B","B"], 2))  # 8
print(least_interval(["A","A","A","B","B","B"], 0))  # 6
```
