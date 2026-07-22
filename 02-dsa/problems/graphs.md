# Graph Problems

| Problem | Pattern | Difficulty | Link |
|---------|---------|------------|------|
| Clone Graph | BFS / DFS with hash map | Medium | [LC 133](https://leetcode.com/problems/clone-graph/) |
| Alien Dictionary | Topological Sort | Hard | [LC 269](https://leetcode.com/problems/alien-dictionary/) |
| Course Schedule | Cycle Detection (Topo Sort) | Medium | [LC 207](https://leetcode.com/problems/course-schedule/) |
| Number of Islands | DFS/BFS on grid | Medium | [LC 200](https://leetcode.com/problems/number-of-islands/) |

---

## Clone Graph

**Key insight:** Use a hash map (original node → clone node) to avoid infinite loops and handle shared references.

```python
from typing import Optional

class Node:
    def __init__(self, val=0, neighbors=None):
        self.val = val
        self.neighbors = neighbors or []

def clone_graph(node: Optional[Node]) -> Optional[Node]:
    if not node:
        return None

    cloned = {}  # original → clone

    def dfs(n):
        if n in cloned:
            return cloned[n]
        clone = Node(n.val)
        cloned[n] = clone  # register before recursing (handles cycles)
        for neighbor in n.neighbors:
            clone.neighbors.append(dfs(neighbor))
        return clone

    return dfs(node)
```

---

## Course Schedule (Cycle Detection)

See [patterns/topological-sort.md](../patterns/topological-sort.md) for the full solution.

```python
from collections import deque, defaultdict

def can_finish(num_courses: int, prerequisites: list[list[int]]) -> bool:
    graph = defaultdict(list)
    in_degree = [0] * num_courses

    for course, prereq in prerequisites:
        graph[prereq].append(course)
        in_degree[course] += 1

    queue = deque(i for i in range(num_courses) if in_degree[i] == 0)
    completed = 0

    while queue:
        course = queue.popleft()
        completed += 1
        for next_course in graph[course]:
            in_degree[next_course] -= 1
            if in_degree[next_course] == 0:
                queue.append(next_course)

    return completed == num_courses
```
