# Topological Sort

## When to Use

**Triggers:**
- "Given dependencies, find a valid ordering..."
- "Can all tasks be completed?"
- "Find the order in which to process items..."
- DAG (Directed Acyclic Graph) processing

**Core idea:** Order nodes in a directed graph so that for every directed edge A → B, node A comes before B. Only possible if the graph has no cycles.

---

## Two Approaches

**Kahn's Algorithm (BFS-based):** Uses in-degree counts. More intuitive, detects cycles naturally.

**DFS-based:** Uses post-order DFS. Good when you already have DFS set up.

---

## Template: Kahn's Algorithm (BFS)

```python
from collections import deque, defaultdict

def topological_sort(n: int, edges: list[list[int]]) -> list[int]:
    graph = defaultdict(list)
    in_degree = [0] * n

    for u, v in edges:
        graph[u].append(v)
        in_degree[v] += 1

    # Start with all nodes that have no prerequisites
    queue = deque(i for i in range(n) if in_degree[i] == 0)
    order = []

    while queue:
        node = queue.popleft()
        order.append(node)

        for neighbor in graph[node]:
            in_degree[neighbor] -= 1
            if in_degree[neighbor] == 0:
                queue.append(neighbor)

    if len(order) != n:
        return []  # cycle detected — topological sort impossible

    return order
```

---

## Problem 1: Course Schedule (Can All Courses Be Taken?)

**LC 207 — Medium**

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


# Test
print(can_finish(2, [[1, 0]]))          # True: take 0 then 1
print(can_finish(2, [[1, 0], [0, 1]])) # False: cycle
```

---

## Problem 2: Course Schedule II (Return the Order)

**LC 210 — Medium**

```python
from collections import deque, defaultdict

def find_order(num_courses: int, prerequisites: list[list[int]]) -> list[int]:
    graph = defaultdict(list)
    in_degree = [0] * num_courses

    for course, prereq in prerequisites:
        graph[prereq].append(course)
        in_degree[course] += 1

    queue = deque(i for i in range(num_courses) if in_degree[i] == 0)
    order = []

    while queue:
        course = queue.popleft()
        order.append(course)

        for next_course in graph[course]:
            in_degree[next_course] -= 1
            if in_degree[next_course] == 0:
                queue.append(next_course)

    return order if len(order) == num_courses else []


# Test
print(find_order(4, [[1,0],[2,0],[3,1],[3,2]]))  # [0,1,2,3] or [0,2,1,3]
print(find_order(2, [[0,1],[1,0]]))               # [] (cycle)
```

---

## Problem 3: Alien Dictionary

**LC 269 — Hard (Premium)**

Given a sorted list of alien words, determine the character ordering.

```python
from collections import deque, defaultdict

def alien_order(words: list[str]) -> str:
    # Build adjacency list from unique characters
    graph = {char: [] for word in words for char in word}
    in_degree = {char: 0 for char in graph}

    # Compare adjacent words to find ordering constraints
    for i in range(len(words) - 1):
        w1, w2 = words[i], words[i + 1]
        min_len = min(len(w1), len(w2))

        # Invalid: longer word is prefix of shorter word
        if len(w1) > len(w2) and w1[:min_len] == w2[:min_len]:
            return ""

        for j in range(min_len):
            if w1[j] != w2[j]:
                graph[w1[j]].append(w2[j])
                in_degree[w2[j]] += 1
                break  # only first difference matters

    # Kahn's algorithm
    queue = deque(c for c in in_degree if in_degree[c] == 0)
    result = []

    while queue:
        char = queue.popleft()
        result.append(char)
        for neighbor in graph[char]:
            in_degree[neighbor] -= 1
            if in_degree[neighbor] == 0:
                queue.append(neighbor)

    return "".join(result) if len(result) == len(graph) else ""


# Test
print(alien_order(["wrt", "wrf", "er", "ett", "rftt"]))  # "wertf"
print(alien_order(["z", "x"]))                            # "zx"
print(alien_order(["z", "x", "z"]))                       # "" (cycle)
```

---

## Complexity

- **Time:** O(V + E) — each node and edge processed once
- **Space:** O(V + E) — graph + in-degree array + queue

---

## FDE Insight

Topological sort is a natural fit for any "dependency ordering" problem:

*"A customer's data pipeline has steps with dependencies. What's the minimum valid execution order to avoid running a step before its inputs are ready?"*

Build the graph (step → depends on step), topological sort it, and the result is a valid execution order. If the graph has a cycle, the pipeline has a circular dependency — that's your error to surface.
