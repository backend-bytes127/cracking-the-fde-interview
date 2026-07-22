# Union Find (Disjoint Set Union)

## When to Use

**Triggers:**
- "Are A and B connected?"
- "How many connected components?"
- Dynamically union groups of elements
- Cycle detection in undirected graphs
- Minimum spanning tree (Kruskal's)

**Core idea:** Maintain a forest where each tree represents a connected component. Two operations: `find` (get the root/representative of a component) and `union` (merge two components).

---

## Template with Path Compression + Union by Rank

```python
class UnionFind:
    def __init__(self, n: int):
        self.parent = list(range(n))  # each node is its own parent
        self.rank = [0] * n           # tree height estimate
        self.components = n           # number of distinct components

    def find(self, x: int) -> int:
        if self.parent[x] != x:
            self.parent[x] = self.find(self.parent[x])  # path compression
        return self.parent[x]

    def union(self, x: int, y: int) -> bool:
        px, py = self.find(x), self.find(y)
        if px == py:
            return False  # already in same component

        # Union by rank: attach smaller tree to larger
        if self.rank[px] < self.rank[py]:
            px, py = py, px
        self.parent[py] = px
        if self.rank[px] == self.rank[py]:
            self.rank[px] += 1

        self.components -= 1
        return True  # successfully merged

    def connected(self, x: int, y: int) -> bool:
        return self.find(x) == self.find(y)
```

**Performance with path compression + union by rank:** O(α(n)) per operation — effectively O(1). α is the inverse Ackermann function.

---

## Problem 1: Number of Provinces

**LC 547 — Medium**

Find the number of groups of directly/indirectly connected cities.

```python
def find_circle_num(is_connected: list[list[int]]) -> int:
    n = len(is_connected)
    uf = UnionFind(n)

    for i in range(n):
        for j in range(i + 1, n):
            if is_connected[i][j]:
                uf.union(i, j)

    return uf.components


# Test
print(find_circle_num([[1,1,0],[1,1,0],[0,0,1]]))  # 2
print(find_circle_num([[1,0,0],[0,1,0],[0,0,1]]))  # 3
```

---

## Problem 2: Number of Islands II (Dynamic)

**LC 305 — Medium (Premium)**

Islands are added one by one. After each addition, report the count.

```python
def num_islands2(m: int, n: int, positions: list[list[int]]) -> list[int]:
    uf = UnionFind(m * n)
    on_land = set()
    result = []

    def idx(r, c):
        return r * n + c

    for r, c in positions:
        if (r, c) not in on_land:
            on_land.add((r, c))
            uf.components += 1  # new island (we adjust count externally here)

            for dr, dc in [(0,1),(0,-1),(1,0),(-1,0)]:
                nr, nc = r + dr, c + dc
                if (nr, nc) in on_land:
                    uf.union(idx(r, c), idx(nr, nc))  # union reduces components

        result.append(uf.components)

    return result
```

---

## Problem 3: Redundant Connection

**LC 684 — Medium**

Find the extra edge in a graph that creates a cycle.

```python
def find_redundant_connection(edges: list[list[int]]) -> list[int]:
    n = len(edges)
    uf = UnionFind(n + 1)  # 1-indexed

    for u, v in edges:
        if not uf.union(u, v):
            return [u, v]  # union failed → they're already connected → cycle edge

    return []


# Test
print(find_redundant_connection([[1,2],[1,3],[2,3]]))  # [2,3]
print(find_redundant_connection([[1,2],[2,3],[3,4],[1,4],[1,5]]))  # [1,4]
```

**Key insight:** Process edges one by one. The first edge where both nodes are already in the same component creates the cycle.

---

## Complexity

| Operation | Naive | With path compression + union by rank |
|-----------|-------|---------------------------------------|
| find | O(n) | O(α(n)) ≈ O(1) |
| union | O(n) | O(α(n)) ≈ O(1) |
| Total for m operations | O(m·n) | O(m·α(n)) ≈ O(m) |

---

## FDE Insight

Union Find is the go-to for "are these two things connected?" with dynamic updates.

FDE framing: *"A customer has a network of services. As new network links are added, quickly determine if a pair of services can communicate..."*

This is exactly Union Find: union when a link is added, find/connected for connectivity queries.
