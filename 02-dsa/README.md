# DSA for FDE Interviews

DSA for FDE is not the same as DSA for SWE — even though the algorithms are identical.

**The difference is the skill being tested.**

A SWE DSA interview tests whether you know the optimal algorithm. An FDE DSA interview tests whether you can identify the right pattern quickly, communicate your thinking clearly, and adapt when the problem is framed in real-world terms rather than abstract ones.

This section is built around that distinction.

---

## How to Use This Section

| Path | Description |
|------|-------------|
| [patterns/](patterns/) | Pattern library — learn to recognize, not memorize |
| [problems/](problems/) | Curated problem sets organized by topic |
| [real-world-problems/](real-world-problems/) | FDE-style problems: real world context, algorithmic core |
| [mock-interview-guide.md](mock-interview-guide.md) | How to perform in the actual interview |

**Start with patterns. Then do problems. Then do mocks.**

If you're short on time, prioritize in this order:
1. Two Pointers, Sliding Window, Prefix Sum (arrays — most frequent)
2. BFS/DFS, Topological Sort (graphs — very common in FDE)
3. Binary Search (appears everywhere)
4. Dynamic Programming (medium frequency but high signal)
5. Heap, Union Find, Monotonic Stack (good to have)

---

## The Pattern Recognition Table

Stop trying to memorize solutions. Learn to recognize patterns.

When you see a trigger → you know the pattern → you know the template → you code it.

| Trigger phrase / constraint | Pattern |
|----------------------------|---------|
| Sorted array, find pair | Two Pointers |
| Subarray with condition, max/min window | Sliding Window |
| Subarray sum = k, range sum queries | Prefix Sum + HashMap |
| Top K elements, kth largest/smallest | Min-Heap of size K |
| Shortest path, unweighted graph | BFS |
| Shortest path, weighted graph | Dijkstra |
| All paths, count paths, DFS on grid | DFS + Backtracking |
| Next greater / smaller element | Monotonic Stack |
| Cycle detection, directed graph | DFS 3-color |
| Cycle detection, undirected graph | Union Find |
| Task ordering, dependency resolution | Topological Sort |
| Grid islands, connected components | DFS with in-place marking |
| Multiple starting points, spreading | Multi-source BFS |
| Overlapping subproblems, optimal substructure | Dynamic Programming |
| All permutations, subsets, combinations | Backtracking |
| Sorted + O(log n) target | Binary Search |
| Find answer in a value range | Binary Search on Answer Space |
| Connectivity queries, union operations | Union Find |

---

## Why FDE DSA Is Different

**Real-world framing.** FDE interview problems are often framed with business context. "Given a network of microservices where each edge has a latency..." is BFS/Dijkstra. "Given a sequence of events from a customer's data pipeline..." is often sliding window or monotonic stack. You need to extract the algorithm from the framing.

**Communication is graded.** Interviewers are explicitly listening for how you think, not just what you produce. If you go silent for 5 minutes and write the correct solution, that is worse than talking through a slightly inefficient approach.

**Edge cases matter more.** FDE engineers work directly with customer systems. Interviewers want to know you think about what breaks, not just what works. Call out edge cases unprompted.

**Speed expectations.** FDE DSA rounds often run faster than SWE rounds because time is also spent on communication. Aim to solve medium-difficulty problems in 25 minutes including explanation.

---

## Complexity Reference

| Pattern | Time | Space | Notes |
|---------|------|-------|-------|
| Two Pointers | O(n) | O(1) | Single pass, sorted or specific condition |
| Sliding Window | O(n) | O(k) | k = window size or unique elements |
| Prefix Sum | O(n) | O(n) | Preprocessing; queries become O(1) |
| BFS | O(V+E) | O(V) | Level-order, shortest path unweighted |
| DFS | O(V+E) | O(V) | Recursive stack; use for paths/cycles |
| Dijkstra | O((V+E) log V) | O(V) | Priority queue; positive weights |
| Binary Search | O(log n) | O(1) | Sorted input or answer space |
| Heap (top K) | O(n log k) | O(k) | Min-heap of size k |
| Union Find | O(α(n)) ≈ O(1) | O(n) | With path compression + union by rank |
| Topological Sort | O(V+E) | O(V) | Kahn's (BFS) or DFS |
| DP (1D) | O(n) | O(n) or O(1) | Depends on state |
| DP (2D) | O(m×n) | O(m×n) | Can often optimize to O(n) |
| Backtracking | O(2^n) or O(n!) | O(n) | Exponential; acceptable for small n |

---

## The Patterns

Each pattern guide includes:
- When to use it (trigger phrases)
- Core idea in one sentence
- Python template with comments
- 3 worked problems
- FDE-specific insight

| Pattern | File |
|---------|------|
| Two Pointers | [patterns/two-pointers.md](patterns/two-pointers.md) |
| Sliding Window | [patterns/sliding-window.md](patterns/sliding-window.md) |
| Prefix Sum | [patterns/prefix-sum.md](patterns/prefix-sum.md) |
| Binary Search | [patterns/binary-search.md](patterns/binary-search.md) |
| BFS / DFS | [patterns/bfs-dfs.md](patterns/bfs-dfs.md) |
| Dynamic Programming | [patterns/dynamic-programming.md](patterns/dynamic-programming.md) |
| Backtracking | [patterns/backtracking.md](patterns/backtracking.md) |
| Heap | [patterns/heap.md](patterns/heap.md) |
| Union Find | [patterns/union-find.md](patterns/union-find.md) |
| Topological Sort | [patterns/topological-sort.md](patterns/topological-sort.md) |
| Monotonic Stack | [patterns/monotonic-stack.md](patterns/monotonic-stack.md) |
