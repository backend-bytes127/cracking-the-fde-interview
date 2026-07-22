# Heap (Priority Queue)

## When to Use

**Triggers:**
- "Top K largest/smallest elements..."
- "Kth largest/smallest..."
- "Median of a stream..."
- "Merge K sorted lists..."
- Priority-based processing

**Core idea:** A heap keeps the minimum (or maximum) element accessible in O(1) and supports insert/remove in O(log n). Python's `heapq` is a min-heap by default — use negative values for max-heap behavior.

---

## Python Heap Basics

```python
import heapq

# Min-heap (default)
heap = []
heapq.heappush(heap, 5)
heapq.heappush(heap, 1)
heapq.heappush(heap, 3)
print(heapq.heappop(heap))  # 1 (smallest)

# Max-heap: negate the values
heap = []
heapq.heappush(heap, -5)
heapq.heappush(heap, -1)
heapq.heappush(heap, -3)
print(-heapq.heappop(heap))  # 5 (largest)

# Heapify an existing list in O(n)
nums = [3, 1, 4, 1, 5, 9]
heapq.heapify(nums)  # in-place

# Heap with tuples: sorted by first element
heapq.heappush(heap, (priority, item))
```

---

## Template: Top K Elements

```python
import heapq

def top_k_largest(nums: list[int], k: int) -> list[int]:
    # Use a min-heap of size k
    # The smallest element in the heap is always the kth largest seen so far
    heap = []

    for num in nums:
        heapq.heappush(heap, num)
        if len(heap) > k:
            heapq.heappop(heap)  # remove the smallest — we only want top k

    return list(heap)  # all elements are top-k largest
```

**Why min-heap of size k?** We want to quickly identify and discard elements smaller than our current k-th largest. The min-heap's top tells us the threshold.

---

## Problem 1: Kth Largest Element in an Array

**LC 215 — Medium**

```python
import heapq

def find_kth_largest(nums: list[int], k: int) -> int:
    heap = []

    for num in nums:
        heapq.heappush(heap, num)
        if len(heap) > k:
            heapq.heappop(heap)

    return heap[0]  # the kth largest is the minimum of the top-k heap


# Test
print(find_kth_largest([3, 2, 1, 5, 6, 4], 2))   # 5
print(find_kth_largest([3, 2, 3, 1, 2, 4, 5, 5, 6], 4))  # 4
```

**Time:** O(n log k) — much better than O(n log n) sorting when k << n.

---

## Problem 2: Merge K Sorted Lists

**LC 23 — Hard**

```python
import heapq
from typing import Optional

class ListNode:
    def __init__(self, val=0, next=None):
        self.val = val
        self.next = next

def merge_k_lists(lists: list[Optional[ListNode]]) -> Optional[ListNode]:
    heap = []

    # Initialize heap with the first node from each list
    for i, node in enumerate(lists):
        if node:
            heapq.heappush(heap, (node.val, i, node))

    dummy = ListNode(0)
    current = dummy

    while heap:
        val, i, node = heapq.heappop(heap)
        current.next = node
        current = current.next

        if node.next:
            heapq.heappush(heap, (node.next.val, i, node.next))
            # i is used as a tiebreaker (ListNode isn't comparable)

    return dummy.next


# Time: O(N log k) where N = total nodes, k = number of lists
```

---

## Problem 3: Find Median from Data Stream

**LC 295 — Hard**

Use two heaps: a max-heap for the lower half, a min-heap for the upper half.

```python
import heapq

class MedianFinder:
    def __init__(self):
        self.lower = []  # max-heap (negate values): stores lower half
        self.upper = []  # min-heap: stores upper half

    def add_num(self, num: int) -> None:
        # Always push to lower first
        heapq.heappush(self.lower, -num)

        # Balance: largest in lower must be <= smallest in upper
        if self.lower and self.upper and -self.lower[0] > self.upper[0]:
            heapq.heappush(self.upper, -heapq.heappop(self.lower))

        # Rebalance sizes: lower can have at most one more element
        if len(self.lower) > len(self.upper) + 1:
            heapq.heappush(self.upper, -heapq.heappop(self.lower))
        elif len(self.upper) > len(self.lower):
            heapq.heappush(self.lower, -heapq.heappop(self.upper))

    def find_median(self) -> float:
        if len(self.lower) > len(self.upper):
            return -self.lower[0]
        return (-self.lower[0] + self.upper[0]) / 2.0


# Test
mf = MedianFinder()
mf.add_num(1)
mf.add_num(2)
print(mf.find_median())  # 1.5
mf.add_num(3)
print(mf.find_median())  # 2.0
```

---

## Complexity

| Operation | Min-heap |
|-----------|----------|
| Push | O(log n) |
| Pop (min) | O(log n) |
| Peek (min) | O(1) |
| Heapify | O(n) |
| Top K | O(n log k) |

---

## FDE Insight

Heaps appear when you need to continuously track top-K from a changing dataset:

*"A customer's system emits events with priorities. Process the highest-priority events first, and always be able to report the top 10 most urgent..."*

Min-heap of size 10, update as new events arrive. O(log 10) = O(1) effectively, regardless of event volume.
