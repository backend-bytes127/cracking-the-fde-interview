# Prefix Sum

## When to Use

**Triggers:**
- "Subarray sum equals k..."
- "Range sum queries..."
- "Number of subarrays with sum divisible by..."
- Repeated range sum queries on the same array (preprocess once, query in O(1))

**Core idea:** Precompute cumulative sums so any subarray sum `sum(i, j)` can be computed as `prefix[j+1] - prefix[i]` in O(1) instead of O(n).

---

## Template

```python
# Build prefix sum array
def build_prefix(nums):
    prefix = [0] * (len(nums) + 1)
    for i, n in enumerate(nums):
        prefix[i + 1] = prefix[i] + n
    return prefix

# Query range sum [i, j] (inclusive, 0-indexed)
def range_sum(prefix, i, j):
    return prefix[j + 1] - prefix[i]
```

**HashMap variant** — for counting subarrays with a specific sum:

```python
from collections import defaultdict

def count_subarrays_with_sum(nums, k):
    count = 0
    prefix_sum = 0
    seen = defaultdict(int)
    seen[0] = 1  # empty prefix

    for num in nums:
        prefix_sum += num
        # If (prefix_sum - k) was seen before, those subarrays sum to k
        count += seen[prefix_sum - k]
        seen[prefix_sum] += 1

    return count
```

---

## Problem 1: Subarray Sum Equals K

**LC 560 — Medium**

Count the number of subarrays whose sum equals k.

```python
from collections import defaultdict

def subarray_sum(nums: list[int], k: int) -> int:
    count = 0
    prefix_sum = 0
    seen = defaultdict(int)
    seen[0] = 1  # there's one empty prefix with sum 0

    for num in nums:
        prefix_sum += num

        # We want prefix_sum - prev_prefix = k → prev_prefix = prefix_sum - k
        # Check if we've seen (prefix_sum - k) before
        count += seen[prefix_sum - k]
        seen[prefix_sum] += 1

    return count


# Test
print(subarray_sum([1, 1, 1], 2))      # 2 ([1,1] at index 0-1 and 1-2)
print(subarray_sum([1, 2, 3], 3))      # 2 ([3] and [1,2])
print(subarray_sum([-1, -1, 1], 0))   # 1
```

**Trace for [1, 1, 1], k=2:**
```
seen = {0: 1}
num=1: prefix=1, look for (1-2)=-1 → not in seen → count=0. seen={0:1, 1:1}
num=1: prefix=2, look for (2-2)=0  → in seen, count+=1. count=1. seen={0:1,1:1,2:1}
num=1: prefix=3, look for (3-2)=1  → in seen, count+=1. count=2. seen={0:1,1:1,2:1,3:1}
Result: 2 ✓
```

---

## Problem 2: Contiguous Array

**LC 525 — Medium**

Find the maximum length of a contiguous subarray with equal numbers of 0s and 1s.

```python
def find_max_length(nums: list[int]) -> int:
    # Treat 0 as -1: when count reaches 0 again, equal 0s and 1s
    count = 0
    max_len = 0
    seen = {0: -1}  # prefix count → first index where this count occurred

    for i, num in enumerate(nums):
        count += 1 if num == 1 else -1

        if count in seen:
            # Subarray from seen[count]+1 to i has equal 0s and 1s
            max_len = max(max_len, i - seen[count])
        else:
            seen[count] = i  # only record first occurrence

    return max_len


# Test
print(find_max_length([0, 1]))           # 2
print(find_max_length([0, 1, 0]))        # 2
print(find_max_length([0, 0, 1, 0, 0, 0, 1, 1]))  # 6
```

---

## Problem 3: Range Sum Query — Immutable

**LC 303 — Easy**

```python
class NumArray:
    def __init__(self, nums: list[int]):
        # Build prefix sum: prefix[i] = sum of nums[0..i-1]
        self.prefix = [0] * (len(nums) + 1)
        for i, n in enumerate(nums):
            self.prefix[i + 1] = self.prefix[i] + n

    def sum_range(self, left: int, right: int) -> int:
        # sum(left..right) = prefix[right+1] - prefix[left]
        return self.prefix[right + 1] - self.prefix[left]


# Test
na = NumArray([-2, 0, 3, -5, 2, -1])
print(na.sum_range(0, 2))   # 1  (-2+0+3)
print(na.sum_range(2, 5))   # -1 (3-5+2-1)
print(na.sum_range(0, 5))   # -3
```

---

## 2D Prefix Sum (Bonus)

For matrix range sum queries:

```python
def build_2d_prefix(matrix):
    m, n = len(matrix), len(matrix[0])
    prefix = [[0] * (n + 1) for _ in range(m + 1)]

    for i in range(1, m + 1):
        for j in range(1, n + 1):
            prefix[i][j] = (matrix[i-1][j-1]
                           + prefix[i-1][j]
                           + prefix[i][j-1]
                           - prefix[i-1][j-1])
    return prefix

def region_sum(prefix, r1, c1, r2, c2):
    return (prefix[r2+1][c2+1]
            - prefix[r1][c2+1]
            - prefix[r2+1][c1]
            + prefix[r1][c1])
```

---

## Complexity

- **Build:** O(n) time, O(n) space
- **Query:** O(1) time after preprocessing
- **HashMap variant:** O(n) time, O(n) space

---

## FDE Insight

Prefix sum with a hashmap is one of the most underused patterns — and it solves a class of problems that naively looks like O(n²).

FDE framing: *"Given a time series of customer API call counts, find the longest contiguous period where the running total was exactly k..."*

This is exactly `subarray_sum(nums, k)`. The business framing is different; the algorithm is identical.
