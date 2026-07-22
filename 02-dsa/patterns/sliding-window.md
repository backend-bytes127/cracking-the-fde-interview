# Sliding Window

## When to Use

**Triggers:**
- "Longest/shortest subarray/substring with condition..."
- "Maximum sum subarray of size k..."
- "At most k distinct characters/elements..."
- Contiguous elements (subarray or substring) with a constraint

**Core idea:** Maintain a window [left, right] and expand/shrink it based on whether the current window satisfies the condition. Avoids O(n²) nested loops.

---

## Two Variants

**Fixed-size window:** Window size is given (e.g., "subarray of size k").

**Variable-size window:** Find the smallest or largest window satisfying a condition.

---

## Template (Variable Size)

```python
def sliding_window(s):
    left = 0
    window = {}  # or a counter, or a set
    result = 0

    for right in range(len(s)):
        # Expand window: add s[right]
        window[s[right]] = window.get(s[right], 0) + 1

        # Shrink window from left while condition violated
        while not valid(window):  # define your validity condition
            window[s[left]] -= 1
            if window[s[left]] == 0:
                del window[s[left]]
            left += 1

        # Window [left, right] is now valid
        result = max(result, right - left + 1)

    return result
```

---

## Problem 1: Longest Substring Without Repeating Characters

**LC 3 — Medium**

```python
def length_of_longest_substring(s: str) -> int:
    seen = {}  # char → last index
    left = 0
    max_len = 0

    for right, char in enumerate(s):
        # If char was seen and is inside current window
        if char in seen and seen[char] >= left:
            left = seen[char] + 1  # shrink window past the duplicate

        seen[char] = right  # update position
        max_len = max(max_len, right - left + 1)

    return max_len


# Test
print(length_of_longest_substring("abcabcbb"))  # 3 ("abc")
print(length_of_longest_substring("bbbbb"))     # 1 ("b")
print(length_of_longest_substring("pwwkew"))    # 3 ("wke")
print(length_of_longest_substring(""))          # 0
```

**Trace:**
```
s = "abcabcbb"
right=0 (a): seen={a:0}, window=[0,0], len=1
right=1 (b): seen={a:0,b:1}, window=[0,1], len=2
right=2 (c): seen={a:0,b:1,c:2}, window=[0,2], len=3
right=3 (a): a seen at 0, left=1. seen={a:3,...}, window=[1,3], len=3
right=4 (b): b seen at 1 >= left=1, left=2. window=[2,4], len=3
...
```

---

## Problem 2: Minimum Window Substring

**LC 76 — Hard**

Find the minimum window in `s` that contains all characters of `t`.

```python
from collections import Counter

def min_window(s: str, t: str) -> str:
    if not t or not s:
        return ""

    need = Counter(t)   # characters we still need
    missing = len(t)    # total characters still needed
    left = 0
    best_left, best_right = 0, float('inf')

    for right, char in enumerate(s):
        # If this char is needed, reduce missing count
        if need[char] > 0:
            missing -= 1
        need[char] -= 1  # track that we've seen this char

        if missing == 0:  # window contains all of t
            # Shrink from left while window is still valid
            while need[s[left]] < 0:
                need[s[left]] += 1
                left += 1

            # Update best window
            if right - left < best_right - best_left:
                best_left, best_right = left, right

            # Move left one more to try to find smaller window
            need[s[left]] += 1
            missing += 1
            left += 1

    return "" if best_right == float('inf') else s[best_left:best_right + 1]


# Test
print(min_window("ADOBECODEBANC", "ABC"))  # "BANC"
print(min_window("a", "a"))               # "a"
print(min_window("a", "aa"))              # ""
```

---

## Problem 3: Longest Subarray with At Most K Distinct Characters

**LC 340 — Medium (Premium)**

```python
from collections import defaultdict

def length_of_longest_substring_k_distinct(s: str, k: int) -> int:
    if k == 0 or not s:
        return 0

    count = defaultdict(int)
    left = 0
    max_len = 0

    for right, char in enumerate(s):
        count[char] += 1

        # Shrink window if we have more than k distinct chars
        while len(count) > k:
            count[s[left]] -= 1
            if count[s[left]] == 0:
                del count[s[left]]
            left += 1

        max_len = max(max_len, right - left + 1)

    return max_len


# Test
print(length_of_longest_substring_k_distinct("eceba", 2))  # 3 ("ece")
print(length_of_longest_substring_k_distinct("aa", 1))     # 2
```

---

## Fixed-Size Window Template

```python
def max_sum_subarray(nums: list[int], k: int) -> int:
    # Initialize the first window
    window_sum = sum(nums[:k])
    max_sum = window_sum

    # Slide the window
    for i in range(k, len(nums)):
        window_sum += nums[i] - nums[i - k]  # add new, remove old
        max_sum = max(max_sum, window_sum)

    return max_sum
```

---

## Complexity

- **Time:** O(n) — each element enters and leaves the window at most once
- **Space:** O(k) — the window data structure (k = distinct elements or window size)

---

## FDE Insight

Sliding window appears in FDE interviews as:

*"Given a stream of API requests, find the longest time window where the error rate stays below 5%..."*

*"A customer's event pipeline has timestamps. Find the maximum number of events in any 60-second window..."*

Both are variable-size sliding window. The window expands with new events, shrinks when the condition is violated, and you track the maximum valid window size.

Recognize the pattern: **contiguous elements + a condition to maintain = sliding window**.
