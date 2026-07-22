# Backtracking

## When to Use

**Triggers:**
- "Find all permutations/subsets/combinations..."
- "Generate all valid X..."
- "Is there any arrangement that satisfies..."
- Constraint satisfaction problems

**Core idea:** Build a solution incrementally. At each step, add a candidate, recurse, then undo the addition (backtrack) before trying the next candidate.

---

## Template

```python
def backtrack(result, current, candidates, start, ...):
    if is_complete(current):
        result.append(list(current))  # copy, not reference
        return

    for i in range(start, len(candidates)):
        if not is_valid(candidates[i], current):
            continue

        current.append(candidates[i])     # choose
        backtrack(result, current, candidates, i + 1, ...)  # explore
        current.pop()                     # unchoose (backtrack)
```

---

## Problem 1: Subsets

**LC 78 — Medium**

Generate all subsets of a set of unique integers.

```python
def subsets(nums: list[int]) -> list[list[int]]:
    result = []

    def backtrack(start, current):
        result.append(list(current))  # every state is a valid subset

        for i in range(start, len(nums)):
            current.append(nums[i])     # include nums[i]
            backtrack(i + 1, current)   # recurse with remaining
            current.pop()               # exclude nums[i]

    backtrack(0, [])
    return result


# Test
print(subsets([1, 2, 3]))
# [[], [1], [1,2], [1,2,3], [1,3], [2], [2,3], [3]]
```

**Trace for [1,2,3]:**
```
backtrack(0, [])   → add []
  include 1:
  backtrack(1, [1]) → add [1]
    include 2:
    backtrack(2, [1,2]) → add [1,2]
      include 3:
      backtrack(3, [1,2,3]) → add [1,2,3]
    backtrack(3, [1,3]) → add [1,3]
  include 2:
  backtrack(2, [2]) → add [2]
    ...
```

---

## Problem 2: Combination Sum

**LC 39 — Medium**

Find all combinations that sum to target. Each candidate can be used multiple times.

```python
def combination_sum(candidates: list[int], target: int) -> list[list[int]]:
    result = []
    candidates.sort()  # optional but helps with pruning

    def backtrack(start, current, remaining):
        if remaining == 0:
            result.append(list(current))
            return

        for i in range(start, len(candidates)):
            if candidates[i] > remaining:
                break  # prune: candidates are sorted, no point continuing

            current.append(candidates[i])
            backtrack(i, current, remaining - candidates[i])  # i not i+1 (reuse allowed)
            current.pop()

    backtrack(0, [], target)
    return result


# Test
print(combination_sum([2, 3, 6, 7], 7))
# [[2,2,3], [7]]
print(combination_sum([2, 3, 5], 8))
# [[2,2,2,2], [2,3,3], [3,5]]
```

---

## Problem 3: Word Search

**LC 79 — Medium**

Given a grid, find if a word exists as a path through adjacent cells.

```python
def exist(board: list[list[str]], word: str) -> bool:
    rows, cols = len(board), len(board[0])

    def backtrack(r, c, idx):
        if idx == len(word):
            return True  # found the entire word

        if r < 0 or r >= rows or c < 0 or c >= cols:
            return False
        if board[r][c] != word[idx]:
            return False

        # Temporarily mark as visited
        temp = board[r][c]
        board[r][c] = '#'

        found = (backtrack(r + 1, c, idx + 1) or
                 backtrack(r - 1, c, idx + 1) or
                 backtrack(r, c + 1, idx + 1) or
                 backtrack(r, c - 1, idx + 1))

        board[r][c] = temp  # restore (backtrack)
        return found

    for r in range(rows):
        for c in range(cols):
            if backtrack(r, c, 0):
                return True

    return False


# Test
board = [["A","B","C","E"],["S","F","C","S"],["A","D","E","E"]]
print(exist(board, "ABCCED"))  # True
print(exist(board, "SEE"))     # True
print(exist(board, "ABCB"))    # False
```

---

## Permutations vs Combinations vs Subsets

| Problem type | Allow reuse? | Order matters? | Start index |
|-------------|-------------|----------------|-------------|
| Subsets | No | No | `i + 1` |
| Combinations | No | No | `i + 1` |
| Combination Sum (reuse) | Yes | No | `i` |
| Permutations | No | Yes | `0` + used set |

---

## Permutations template:

```python
def permute(nums):
    result = []

    def backtrack(current, remaining):
        if not remaining:
            result.append(list(current))
            return
        for i in range(len(remaining)):
            current.append(remaining[i])
            backtrack(current, remaining[:i] + remaining[i+1:])
            current.pop()

    backtrack([], nums)
    return result
```

---

## Complexity

- **Time:** O(n × 2^n) for subsets, O(n × n!) for permutations
- **Space:** O(n) recursion depth

Backtracking is inherently exponential. That's fine — the problem space is exponential. The goal is to prune as early as possible.

---

## FDE Insight

Backtracking in FDE interviews often appears as configuration/assignment problems:

*"Given a list of microservices and their resource requirements, find all valid assignments to available VMs such that no VM is overloaded..."*

This is a constraint satisfaction / packing problem. Backtracking with pruning (skip assignments that would overflow) is the right approach.
