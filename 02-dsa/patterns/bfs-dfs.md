# BFS and DFS

## When to Use

**BFS triggers:**
- Shortest path in an unweighted graph
- Level-order traversal
- "Minimum number of steps to reach..."
- Multiple sources spreading simultaneously (multi-source BFS)
- Finding all nodes at distance k

**DFS triggers:**
- All paths from A to B
- Cycle detection
- Connected components
- Topological sort (DFS-based)
- Grid island problems

**Core idea:** BFS explores layer by layer using a queue. DFS goes as deep as possible using a stack (or recursion). BFS gives shortest path in unweighted graphs. DFS is more natural for exploring all possibilities.

---

## BFS Template

```python
from collections import deque

def bfs(graph, start, target):
    queue = deque([start])
    visited = {start}
    steps = 0

    while queue:
        # Process all nodes at current level
        for _ in range(len(queue)):
            node = queue.popleft()

            if node == target:
                return steps

            for neighbor in graph[node]:
                if neighbor not in visited:
                    visited.add(neighbor)
                    queue.append(neighbor)

        steps += 1

    return -1  # target not reachable
```

---

## DFS Template (Iterative)

```python
def dfs(graph, start):
    stack = [start]
    visited = {start}

    while stack:
        node = stack.pop()
        # process node

        for neighbor in graph[node]:
            if neighbor not in visited:
                visited.add(neighbor)
                stack.append(neighbor)
```

**DFS Template (Recursive):**

```python
def dfs_recursive(node, graph, visited):
    visited.add(node)
    # process node

    for neighbor in graph[node]:
        if neighbor not in visited:
            dfs_recursive(neighbor, graph, visited)
```

---

## Problem 1: Binary Tree Level Order Traversal

**LC 102 — Medium**

```python
from collections import deque
from typing import Optional

class TreeNode:
    def __init__(self, val=0, left=None, right=None):
        self.val = val
        self.left = left
        self.right = right

def level_order(root: Optional[TreeNode]) -> list[list[int]]:
    if not root:
        return []

    result = []
    queue = deque([root])

    while queue:
        level = []
        for _ in range(len(queue)):  # process all nodes at current level
            node = queue.popleft()
            level.append(node.val)
            if node.left:
                queue.append(node.left)
            if node.right:
                queue.append(node.right)
        result.append(level)

    return result
```

---

## Problem 2: Rotting Oranges (Multi-Source BFS)

**LC 994 — Medium**

```python
from collections import deque

def oranges_rotting(grid: list[list[int]]) -> int:
    rows, cols = len(grid), len(grid[0])
    queue = deque()
    fresh = 0

    # Initialize: find all rotten oranges (multiple sources)
    for r in range(rows):
        for c in range(cols):
            if grid[r][c] == 2:
                queue.append((r, c, 0))  # (row, col, minutes)
            elif grid[r][c] == 1:
                fresh += 1

    if fresh == 0:
        return 0

    directions = [(0, 1), (0, -1), (1, 0), (-1, 0)]
    minutes = 0

    while queue:
        r, c, time = queue.popleft()

        for dr, dc in directions:
            nr, nc = r + dr, c + dc
            if 0 <= nr < rows and 0 <= nc < cols and grid[nr][nc] == 1:
                grid[nr][nc] = 2  # mark as rotten
                fresh -= 1
                minutes = time + 1
                queue.append((nr, nc, time + 1))

    return minutes if fresh == 0 else -1


# Test
print(oranges_rotting([[2,1,1],[1,1,0],[0,1,1]]))  # 4
print(oranges_rotting([[2,1,1],[0,1,1],[1,0,1]]))  # -1
print(oranges_rotting([[0,2]]))                     # 0
```

**Multi-source BFS:** Start BFS from ALL sources simultaneously. This is the correct approach when spreading starts from multiple points — do not BFS from each source separately.

---

## Problem 3: Number of Islands (DFS on Grid)

**LC 200 — Medium**

```python
def num_islands(grid: list[list[str]]) -> int:
    if not grid:
        return 0

    rows, cols = len(grid), len(grid[0])
    count = 0

    def dfs(r, c):
        # Out of bounds, or water, or already visited
        if r < 0 or r >= rows or c < 0 or c >= cols or grid[r][c] != '1':
            return

        grid[r][c] = '0'  # mark as visited by sinking the island
        dfs(r + 1, c)
        dfs(r - 1, c)
        dfs(r, c + 1)
        dfs(r, c - 1)

    for r in range(rows):
        for c in range(cols):
            if grid[r][c] == '1':
                count += 1
                dfs(r, c)  # sink the entire island

    return count


# Test
grid1 = [
    ["1","1","1","1","0"],
    ["1","1","0","1","0"],
    ["1","1","0","0","0"],
    ["0","0","0","0","0"]
]
print(num_islands(grid1))  # 1

grid2 = [
    ["1","1","0","0","0"],
    ["1","1","0","0","0"],
    ["0","0","1","0","0"],
    ["0","0","0","1","1"]
]
print(num_islands(grid2))  # 3
```

**In-place marking trick:** Mutate `grid[r][c] = '0'` to mark visited instead of using a separate set. Works when the grid is allowed to be modified. Saves O(m×n) space.

---

## Problem 4: Course Schedule (Cycle Detection with DFS)

**LC 207 — Medium**

```python
def can_finish(num_courses: int, prerequisites: list[list[int]]) -> bool:
    graph = [[] for _ in range(num_courses)]
    for course, prereq in prerequisites:
        graph[course].append(prereq)

    # State: 0=unvisited, 1=in current path (gray), 2=fully processed (black)
    state = [0] * num_courses

    def has_cycle(node):
        if state[node] == 1:  # currently in path → cycle
            return True
        if state[node] == 2:  # already processed → no cycle from here
            return False

        state[node] = 1  # mark as in-progress
        for neighbor in graph[node]:
            if has_cycle(neighbor):
                return True
        state[node] = 2  # mark as fully processed
        return False

    return all(not has_cycle(i) for i in range(num_courses) if state[i] == 0)


# Test
print(can_finish(2, [[1, 0]]))         # True
print(can_finish(2, [[1, 0], [0, 1]])) # False (cycle)
```

---

## Complexity

| Algorithm | Time | Space |
|-----------|------|-------|
| BFS | O(V + E) | O(V) — queue |
| DFS iterative | O(V + E) | O(V) — stack |
| DFS recursive | O(V + E) | O(V) — call stack |

---

## FDE Insight

Graph problems appear in FDE interviews in real-world framing constantly:

- Microservice dependencies → cycle detection (DFS 3-color)
- Network topology → BFS for minimum hops
- Data pipeline stages → topological sort
- Customer's infrastructure spread → connected components

The FDE skill is extracting "this is a graph problem" from a description about servers, services, or data flows, and then applying the correct traversal.
