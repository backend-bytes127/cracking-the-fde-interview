# Binary Search

## When to Use

**Triggers:**
- Sorted array + search in O(log n)
- "Find the minimum value that satisfies condition X"
- "What is the maximum K such that..."
- Monotonic function — answer space has a clear ordering

**Core idea:** Halve the search space at each step by comparing the midpoint to the target or condition. Works on sorted arrays AND on answer spaces where you can determine if a given answer is too small or too large.

---

## Two Variants

**Classic:** Search for a target value in a sorted array.

**Binary search on answer space:** When you can check "is K a valid answer?" in O(n), binary search the space of possible answers.

---

## Template (Classic)

```python
def binary_search(nums: list[int], target: int) -> int:
    left, right = 0, len(nums) - 1

    while left <= right:
        mid = left + (right - left) // 2  # avoids integer overflow

        if nums[mid] == target:
            return mid
        elif nums[mid] < target:
            left = mid + 1  # target is in the right half
        else:
            right = mid - 1  # target is in the left half

    return -1  # not found
```

**Find leftmost occurrence (lower bound):**

```python
def lower_bound(nums, target):
    left, right = 0, len(nums)  # note: right = len(nums), not len-1
    while left < right:
        mid = (left + right) // 2
        if nums[mid] < target:
            left = mid + 1
        else:
            right = mid  # keep mid in consideration
    return left  # first position where nums[left] >= target
```

---

## Problem 1: Search in Rotated Sorted Array

**LC 33 — Medium**

```python
def search(nums: list[int], target: int) -> int:
    left, right = 0, len(nums) - 1

    while left <= right:
        mid = (left + right) // 2

        if nums[mid] == target:
            return mid

        # Determine which half is sorted
        if nums[left] <= nums[mid]:  # left half is sorted
            if nums[left] <= target < nums[mid]:
                right = mid - 1  # target is in the sorted left half
            else:
                left = mid + 1   # target is in the right half
        else:  # right half is sorted
            if nums[mid] < target <= nums[right]:
                left = mid + 1   # target is in the sorted right half
            else:
                right = mid - 1  # target is in the left half

    return -1


# Test
print(search([4, 5, 6, 7, 0, 1, 2], 0))   # 4
print(search([4, 5, 6, 7, 0, 1, 2], 3))   # -1
print(search([1], 0))                       # -1
```

**Key insight:** Even in a rotated array, one half is always sorted. Check which half is sorted, then determine which half the target could be in.

---

## Problem 2: Find Minimum in Rotated Sorted Array

**LC 153 — Medium**

```python
def find_min(nums: list[int]) -> int:
    left, right = 0, len(nums) - 1

    while left < right:
        mid = (left + right) // 2

        if nums[mid] > nums[right]:
            # Minimum is in the right half (rotation point is there)
            left = mid + 1
        else:
            # Minimum is in the left half including mid
            right = mid

    return nums[left]


# Test
print(find_min([3, 4, 5, 1, 2]))    # 1
print(find_min([4, 5, 6, 7, 0, 1, 2]))  # 0
print(find_min([11, 13, 15, 17]))   # 11 (not rotated)
```

---

## Problem 3: Koko Eating Bananas (Binary Search on Answer Space)

**LC 875 — Medium**

Koko can eat k bananas per hour. With h hours and piles of bananas, find the minimum k.

```python
import math

def min_eating_speed(piles: list[int], h: int) -> int:
    def can_finish(speed: int) -> bool:
        # Total hours needed at this speed
        return sum(math.ceil(p / speed) for p in piles) <= h

    # Answer is somewhere in [1, max(piles)]
    left, right = 1, max(piles)

    while left < right:
        mid = (left + right) // 2
        if can_finish(mid):
            right = mid   # try smaller speed
        else:
            left = mid + 1  # speed too slow

    return left


# Test
print(min_eating_speed([3, 6, 7, 11], 8))  # 4
print(min_eating_speed([30, 11, 23, 4, 20], 5))  # 30
```

**The pattern:**
1. Identify the answer space (min to max possible answer)
2. Write `is_feasible(k)` that returns True if k is a valid answer
3. Binary search: if mid is feasible, try smaller; else try larger
4. The left pointer converges to the minimum feasible answer

---

## Other Classic Binary Search Problems

```python
# Find first and last position of element in sorted array (LC 34)
def search_range(nums, target):
    def find_left():
        lo, hi = 0, len(nums) - 1
        while lo <= hi:
            mid = (lo + hi) // 2
            if nums[mid] < target:
                lo = mid + 1
            else:
                hi = mid - 1
        return lo

    def find_right():
        lo, hi = 0, len(nums) - 1
        while lo <= hi:
            mid = (lo + hi) // 2
            if nums[mid] <= target:
                lo = mid + 1
            else:
                hi = mid - 1
        return hi

    l, r = find_left(), find_right()
    if l <= r and r < len(nums) and nums[l] == target:
        return [l, r]
    return [-1, -1]
```

---

## Complexity

- **Time:** O(log n) — halves search space each step
- **Space:** O(1) — iterative version

---

## Common Mistakes

1. **Off-by-one on right boundary:** Use `len(nums) - 1` for classic, `len(nums)` for lower bound
2. **Integer overflow:** Use `left + (right - left) // 2`, not `(left + right) // 2`
3. **Infinite loop:** Ensure left and right always make progress (`left = mid + 1`, not `mid`)

---

## FDE Insight

Binary search on answer space is the key technique. FDE problems often have this shape:

*"What is the minimum number of API servers needed to handle 10,000 requests/second with 99th percentile latency under 200ms?"*

If you can write `is_feasible(n_servers)` — simulate or calculate whether n servers meets the SLA — you can binary search for the minimum n. This turns an O(n) search into O(log n) calls to your feasibility function.
