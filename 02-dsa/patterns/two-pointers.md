# Two Pointers

## When to Use

**Triggers:**
- Sorted array + find a pair/triplet with a target sum
- "Find two numbers that..." in a sorted structure
- Palindrome check
- Remove duplicates in-place
- Container / water problems (maximize/minimize with two boundaries)

**Core idea:** Use two indices that move toward each other (or both forward) based on a condition. Eliminates the need for a nested loop.

---

## Template

```python
def two_pointers(arr):
    left, right = 0, len(arr) - 1

    while left < right:
        current = arr[left] + arr[right]

        if current == target:
            # found answer
            return [left, right]
        elif current < target:
            left += 1   # need larger sum
        else:
            right -= 1  # need smaller sum

    return []  # no answer found
```

**Same-direction variant (used for removing duplicates, fast/slow pointer):**

```python
def remove_duplicates(nums):
    if not nums:
        return 0

    slow = 0
    for fast in range(1, len(nums)):
        if nums[fast] != nums[slow]:
            slow += 1
            nums[slow] = nums[fast]  # move unique element forward

    return slow + 1  # length of deduplicated array
```

---

## Problem 1: Container With Most Water

**LC 11 — Medium**

Given an integer array `height` of length `n`, find two lines that together with the x-axis form a container that holds the most water.

```python
def max_area(height: list[int]) -> int:
    left, right = 0, len(height) - 1
    max_water = 0

    while left < right:
        # Width is the distance between pointers
        # Height is limited by the shorter wall
        width = right - left
        h = min(height[left], height[right])
        max_water = max(max_water, width * h)

        # Move the shorter wall inward — moving the taller one
        # can only decrease width without possibly increasing height
        if height[left] < height[right]:
            left += 1
        else:
            right -= 1

    return max_water


# Test
print(max_area([1, 8, 6, 2, 5, 4, 8, 3, 7]))  # 49
print(max_area([1, 1]))  # 1
```

**Trace:**
```
height = [1, 8, 6, 2, 5, 4, 8, 3, 7]
L=0, R=8: width=8, h=min(1,7)=1, area=8, move L (shorter)
L=1, R=8: width=7, h=min(8,7)=7, area=49, move R (shorter)
L=1, R=7: width=6, h=min(8,3)=3, area=18, move R
...
```

**Why it works:** The greedy insight is that moving the taller wall inward can never increase the area (width decreases, height is still bounded by the shorter wall). So we always move the shorter wall inward.

---

## Problem 2: 3Sum

**LC 15 — Medium**

Find all unique triplets in an array that sum to zero.

```python
def three_sum(nums: list[int]) -> list[list[int]]:
    nums.sort()  # sorting enables two-pointer on the inner loop
    result = []

    for i in range(len(nums) - 2):
        # Skip duplicates for the first element
        if i > 0 and nums[i] == nums[i - 1]:
            continue

        left, right = i + 1, len(nums) - 1
        target = -nums[i]  # we need left + right = -nums[i]

        while left < right:
            s = nums[left] + nums[right]

            if s == target:
                result.append([nums[i], nums[left], nums[right]])
                # Skip duplicates for left and right
                while left < right and nums[left] == nums[left + 1]:
                    left += 1
                while left < right and nums[right] == nums[right - 1]:
                    right -= 1
                left += 1
                right -= 1
            elif s < target:
                left += 1
            else:
                right -= 1

    return result


# Test
print(three_sum([-1, 0, 1, 2, -1, -4]))  # [[-1,-1,2],[-1,0,1]]
print(three_sum([0, 0, 0]))              # [[0,0,0]]
print(three_sum([]))                     # []
```

**Key insight:** Fix one element with the outer loop (`nums[i]`), then reduce to a 2Sum on the remaining sorted subarray.

**Duplicate handling is the tricky part:** Skip duplicate values for `i`, `left`, and `right` to avoid duplicate triplets in the result.

---

## Problem 3: Trapping Rain Water

**LC 42 — Hard**

Given an elevation map, compute how much water it can trap after raining.

```python
def trap(height: list[int]) -> int:
    if not height:
        return 0

    left, right = 0, len(height) - 1
    left_max, right_max = 0, 0
    water = 0

    while left < right:
        if height[left] < height[right]:
            if height[left] >= left_max:
                left_max = height[left]  # update max from left
            else:
                water += left_max - height[left]  # water trapped at left
            left += 1
        else:
            if height[right] >= right_max:
                right_max = height[right]  # update max from right
            else:
                water += right_max - height[right]  # water trapped at right
            right -= 1

    return water


# Test
print(trap([0, 1, 0, 2, 1, 0, 1, 3, 2, 1, 2, 1]))  # 6
print(trap([4, 2, 0, 3, 2, 5]))  # 9
print(trap([]))  # 0
```

**The key insight:** Water at any position is bounded by the minimum of the maximum heights on each side. The two-pointer approach tracks `left_max` and `right_max` as we scan inward. Whichever side has the smaller maximum determines how much water that position holds.

---

## Common Variations

| Variation | Approach |
|-----------|----------|
| Sorted array, find pair summing to target | Classic two-pointer |
| Unsorted array, count pairs | Sort first, then two-pointer |
| Remove duplicates / filter in-place | Fast/slow pointer (same direction) |
| Palindrome check | Left from start, right from end, compare |
| Merge two sorted arrays | Start both pointers at beginning, merge outward |
| Find intersection of two sorted arrays | Two pointers scanning together |

---

## Complexity

- **Time:** O(n) — single pass with two pointers
- **Space:** O(1) — no additional data structures (O(n log n) if sorting required)

---

## FDE Insight

Two-pointer patterns appear in FDE interviews in real-world framing:

*"Given a sorted list of customer request timestamps and a target time window, find the pair of requests that bracket a specific duration..."* — this is two pointers on a sorted array.

*"Given a log of API calls ordered by time, remove consecutive duplicate calls..."* — this is the fast/slow variant.

The algorithm is always the same. The FDE skill is seeing through the real-world framing to recognize the pattern underneath.
