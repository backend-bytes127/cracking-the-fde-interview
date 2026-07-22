# Monotonic Stack

## When to Use

**Triggers:**
- "Next greater/smaller element..."
- "Previous greater/smaller element..."
- "Largest rectangle in histogram..."
- "Daily temperatures..."
- Spanning questions on arrays where each element depends on nearby elements

**Core idea:** Maintain a stack where elements are always in monotonically increasing or decreasing order. When a new element violates the order, pop and process elements until the invariant is restored.

---

## Two Types

**Monotonically increasing stack:** Pop when new element is smaller. Useful for finding the next smaller element.

**Monotonically decreasing stack:** Pop when new element is larger. Useful for finding the next greater element.

---

## Template (Next Greater Element)

```python
def next_greater(nums: list[int]) -> list[int]:
    n = len(nums)
    result = [-1] * n
    stack = []  # stores indices

    for i in range(n):
        # While current element is greater than stack top → it's the answer
        while stack and nums[i] > nums[stack[-1]]:
            idx = stack.pop()
            result[idx] = nums[i]  # nums[i] is the next greater for nums[idx]
        stack.append(i)

    return result
```

---

## Problem 1: Daily Temperatures

**LC 739 — Medium**

For each day, find how many days until a warmer temperature. Return 0 if none.

```python
def daily_temperatures(temperatures: list[int]) -> list[int]:
    n = len(temperatures)
    result = [0] * n
    stack = []  # stores indices of temperatures waiting for a warmer day

    for i, temp in enumerate(temperatures):
        # Current temp is warmer than temps at indices in stack
        while stack and temperatures[stack[-1]] < temp:
            idx = stack.pop()
            result[idx] = i - idx  # days until warmer
        stack.append(i)

    return result


# Test
print(daily_temperatures([73,74,75,71,69,72,76,73]))
# [1,1,4,2,1,1,0,0]
print(daily_temperatures([30,40,50,60]))
# [1,1,1,0]
print(daily_temperatures([30,60,90]))
# [1,1,0]
```

**Trace for [73,74,75,71,69,72,76,73]:**
```
i=0 (73): stack=[], push 0. stack=[0]
i=1 (74): 74>73, pop 0: result[0]=1-0=1. push 1. stack=[1]
i=2 (75): 75>74, pop 1: result[1]=2-1=1. push 2. stack=[2]
i=3 (71): 71<75, push 3. stack=[2,3]
i=4 (69): 69<71, push 4. stack=[2,3,4]
i=5 (72): 72>69, pop 4: result[4]=5-4=1. 72>71, pop 3: result[3]=5-3=2. 72<75, push 5. stack=[2,5]
i=6 (76): 76>72, pop 5: result[5]=6-5=1. 76>75, pop 2: result[2]=6-2=4. push 6. stack=[6]
i=7 (73): 73<76, push 7. stack=[6,7]
Final: result=[1,1,4,2,1,1,0,0] ✓
```

---

## Problem 2: Largest Rectangle in Histogram

**LC 84 — Hard**

Find the largest rectangle that can be formed within the histogram.

```python
def largest_rectangle_area(heights: list[int]) -> int:
    stack = []  # monotonically increasing stack of indices
    max_area = 0
    # Append 0 to flush remaining elements in stack
    heights = heights + [0]

    for i, h in enumerate(heights):
        start = i
        # Pop bars taller than current — they can't extend further right
        while stack and heights[stack[-1]] > h:
            idx = stack.pop()
            height = heights[idx]
            width = i - (stack[-1] + 1 if stack else 0)
            max_area = max(max_area, height * width)
            start = idx  # current bar can extend left to where we just popped

        stack.append(start)  # use 'start' not 'i' to allow left extension

    return max_area


# Cleaner alternative using explicit width tracking
def largest_rectangle_area_v2(heights: list[int]) -> int:
    stack = []  # (index, height)
    max_area = 0

    for i, h in enumerate(heights):
        start = i
        while stack and stack[-1][1] > h:
            idx, height = stack.pop()
            max_area = max(max_area, height * (i - idx))
            start = idx
        stack.append((start, h))

    for idx, height in stack:
        max_area = max(max_area, height * (len(heights) - idx))

    return max_area


# Test
print(largest_rectangle_area([2,1,5,6,2,3]))  # 10 (bars 5 and 6, width 2)
print(largest_rectangle_area([2,4]))           # 4
```

---

## Problem 3: Trapping Rain Water (Monotonic Stack Approach)

**LC 42 — Hard** (alternative to two-pointer approach)

```python
def trap(height: list[int]) -> int:
    stack = []  # monotonically decreasing stack
    water = 0

    for i, h in enumerate(height):
        while stack and height[stack[-1]] < h:
            bottom = stack.pop()  # the valley
            if not stack:
                break
            left = stack[-1]
            width = i - left - 1
            bounded_height = min(height[left], h) - height[bottom]
            water += width * bounded_height

        stack.append(i)

    return water


# Test
print(trap([0,1,0,2,1,0,1,3,2,1,2,1]))  # 6
```

---

## Complexity

- **Time:** O(n) — each element is pushed and popped at most once
- **Space:** O(n) — stack

---

## FDE Insight

Monotonic stack problems can be framed as:

*"Given a time series of CPU utilization readings, for each reading find the next time the utilization drops below the current level..."*

This is "next smaller element" — maintain a monotonically increasing stack. When a lower reading is found, the stack elements that exceed it get their answer recorded.

The trick to recognize this pattern: when an element's answer depends on the next element that breaks some monotonic relationship, it's likely a monotonic stack.
