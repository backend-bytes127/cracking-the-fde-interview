# Dynamic Programming Problems

| Problem | Pattern | Difficulty | Link |
|---------|---------|------------|------|
| Coin Change | 1D DP (unbounded knapsack) | Medium | [LC 322](https://leetcode.com/problems/coin-change/) |
| House Robber | 1D DP (adjacent constraint) | Medium | [LC 198](https://leetcode.com/problems/house-robber/) |
| Coin Change II | 2D DP (counting) | Medium | [LC 518](https://leetcode.com/problems/coin-change-ii/) |
| Edit Distance | 2D DP (string) | Hard | [LC 72](https://leetcode.com/problems/edit-distance/) |
| Longest Increasing Subsequence | 1D DP / Binary Search | Medium | [LC 300](https://leetcode.com/problems/longest-increasing-subsequence/) |

See [patterns/dynamic-programming.md](../patterns/dynamic-programming.md) for full solutions.

---

## Coin Change II (Count Ways)

**LC 518 — Medium**

Count the number of ways to make change for amount using coins (unlimited use).

```python
def change(amount: int, coins: list[int]) -> int:
    # dp[a] = number of ways to make amount a
    dp = [0] * (amount + 1)
    dp[0] = 1  # one way to make 0: use no coins

    for coin in coins:
        for a in range(coin, amount + 1):
            dp[a] += dp[a - coin]  # add ways using this coin

    return dp[amount]


# Test
print(change(5, [1, 2, 5]))   # 4: (5),(2+2+1),(2+1+1+1),(1+1+1+1+1)
print(change(3, [2]))          # 0
print(change(10, [10]))        # 1
```

**Key distinction from Coin Change I:** We count *ways* not *minimum coins*. Iterate coins in outer loop to avoid counting permutations (e.g., (1,2) and (2,1) are the same combination).

---

## House Robber II (Circular)

**LC 213 — Medium**

Houses in a circle — first and last are adjacent. Can't rob adjacent houses.

```python
def rob_circular(nums: list[int]) -> int:
    def rob_linear(houses):
        prev2 = prev1 = 0
        for h in houses:
            prev2, prev1 = prev1, max(prev1, prev2 + h)
        return prev1

    if len(nums) == 1:
        return nums[0]

    # Either include first house (exclude last) or include last (exclude first)
    return max(rob_linear(nums[:-1]), rob_linear(nums[1:]))


# Test
print(rob_circular([2,3,2]))    # 3
print(rob_circular([1,2,3,1]))  # 4
```
