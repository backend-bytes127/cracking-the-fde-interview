# Dynamic Programming

## When to Use

**Triggers:**
- "Maximum/minimum..." with choices at each step
- "How many ways to..." (counting paths/combinations)
- Overlapping subproblems (same computation repeated many times)
- "Is it possible to..." with yes/no answer
- Recursive solution has exponential time → memoize it

**Core idea:** Break into subproblems. Cache results. Avoid recomputation.

---

## The DP Framework

1. **Define the subproblem:** `dp[i]` means "the answer for the first i elements"
2. **Write the recurrence:** How does `dp[i]` relate to smaller subproblems?
3. **Identify base cases**
4. **Fill in order** (ensure subproblems are solved before they're needed)
5. **Extract the answer** from the final state

---

## Template (Top-down / Memoization)

```python
from functools import lru_cache

def solve(n):
    @lru_cache(maxsize=None)
    def dp(state):
        if base_case(state):
            return base_value
        return min/max/sum of dp(next_state) for next_state in transitions(state)

    return dp(initial_state)
```

**Template (Bottom-up / Tabulation):**

```python
def solve(nums):
    n = len(nums)
    dp = [0] * (n + 1)
    dp[0] = base_case_value

    for i in range(1, n + 1):
        dp[i] = f(dp[i-1], dp[i-2], ...)  # recurrence

    return dp[n]
```

---

## Problem 1: Coin Change

**LC 322 — Medium**

Find the minimum number of coins to make amount. Return -1 if impossible.

```python
def coin_change(coins: list[int], amount: int) -> int:
    # dp[i] = minimum coins to make amount i
    dp = [float('inf')] * (amount + 1)
    dp[0] = 0  # base case: 0 coins to make amount 0

    for a in range(1, amount + 1):
        for coin in coins:
            if coin <= a:
                # Use this coin: dp[a - coin] + 1 coins
                dp[a] = min(dp[a], dp[a - coin] + 1)

    return dp[amount] if dp[amount] != float('inf') else -1


# Test
print(coin_change([1, 5, 11], 15))  # 3 (5+5+5... wait: 11+4? no → 5+5+5)
print(coin_change([1, 5, 11], 15))  # Actually: 11+1+1+1+1 = 5 coins? 5+5+5=3. → 3
print(coin_change([2], 3))           # -1
print(coin_change([1], 0))           # 0

# Trace for coins=[1,5,11], amount=15:
# dp[0]=0
# dp[5]=1   (one 5-coin)
# dp[10]=2  (two 5-coins)
# dp[11]=1  (one 11-coin)
# dp[15]=3  (three 5-coins) — check: 15-5=10→dp[10]=2, so dp[15]=3 ✓
```

---

## Problem 2: House Robber

**LC 198 — Medium**

Rob houses without robbing adjacent ones. Maximize total.

```python
def rob(nums: list[int]) -> int:
    if not nums:
        return 0
    if len(nums) == 1:
        return nums[0]

    # dp[i] = max money robbing houses 0..i
    # Choice: rob house i (nums[i] + dp[i-2]) or skip it (dp[i-1])
    prev2 = nums[0]
    prev1 = max(nums[0], nums[1])

    for i in range(2, len(nums)):
        current = max(prev1, prev2 + nums[i])
        prev2, prev1 = prev1, current

    return prev1  # space-optimized: O(1)


# Test
print(rob([1, 2, 3, 1]))    # 4 (house 0 + house 2)
print(rob([2, 7, 9, 3, 1])) # 12 (house 0 + house 2 + house 4: 2+9+1=12)
```

---

## Problem 3: Longest Increasing Subsequence (LIS)

**LC 300 — Medium**

```python
def length_of_lis(nums: list[int]) -> int:
    if not nums:
        return 0

    n = len(nums)
    # dp[i] = length of LIS ending at index i
    dp = [1] * n

    for i in range(1, n):
        for j in range(i):
            if nums[j] < nums[i]:
                dp[i] = max(dp[i], dp[j] + 1)

    return max(dp)


# Test
print(length_of_lis([10, 9, 2, 5, 3, 7, 101, 18]))  # 4 ([2,3,7,101] or [2,5,7,101])
print(length_of_lis([0, 1, 0, 3, 2, 3]))            # 4
print(length_of_lis([7, 7, 7, 7, 7]))               # 1


# O(n log n) with binary search (patience sorting)
import bisect

def length_of_lis_optimal(nums: list[int]) -> int:
    tails = []  # tails[i] = smallest tail of IS with length i+1

    for num in nums:
        pos = bisect.bisect_left(tails, num)
        if pos == len(tails):
            tails.append(num)
        else:
            tails[pos] = num  # replace with smaller tail

    return len(tails)
```

---

## Problem 4: Edit Distance

**LC 72 — Hard**

Minimum operations (insert, delete, replace) to convert word1 to word2.

```python
def min_distance(word1: str, word2: str) -> int:
    m, n = len(word1), len(word2)
    # dp[i][j] = edit distance between word1[:i] and word2[:j]
    dp = [[0] * (n + 1) for _ in range(m + 1)]

    # Base cases
    for i in range(m + 1):
        dp[i][0] = i  # delete all of word1
    for j in range(n + 1):
        dp[0][j] = j  # insert all of word2

    for i in range(1, m + 1):
        for j in range(1, n + 1):
            if word1[i - 1] == word2[j - 1]:
                dp[i][j] = dp[i-1][j-1]  # characters match, no operation
            else:
                dp[i][j] = 1 + min(
                    dp[i-1][j],    # delete from word1
                    dp[i][j-1],    # insert into word1
                    dp[i-1][j-1]   # replace in word1
                )

    return dp[m][n]


# Test
print(min_distance("horse", "ros"))    # 3
print(min_distance("intention", "execution"))  # 5
```

---

## Common DP Patterns Summary

| Type | Example | Recurrence shape |
|------|---------|-----------------|
| 1D linear | House Robber, Coin Change | `dp[i] = f(dp[i-1], dp[i-2])` |
| 1D with all j<i | LIS | `dp[i] = max(dp[j] + 1) for j < i` |
| 2D string | Edit Distance, LCS | `dp[i][j] = f(dp[i-1][j], dp[i][j-1], dp[i-1][j-1])` |
| 2D knapsack | Coin Change II, Partition | `dp[i][w] = f(dp[i-1][w], dp[i-1][w-weight])` |
| State machine | Buy/sell stock | Multiple state variables |

---

## Complexity

- **Time:** Depends on state space × transitions per state
- **Space:** O(state space) — often optimizable to O(n) with rolling array

---

## FDE Insight

DP appears less frequently in FDE interviews than graph or array problems, but when it appears it's a strong signal problem. Recognize it by: recursive solution with repeated subproblems. Memoize first, tabulate if you need to optimize space.
