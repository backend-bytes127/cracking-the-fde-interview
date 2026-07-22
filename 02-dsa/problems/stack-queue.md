# Stack and Queue Problems

| Problem | Pattern | Difficulty | Link |
|---------|---------|------------|------|
| Min Stack | Stack + auxiliary min tracking | Medium | [LC 155](https://leetcode.com/problems/min-stack/) |
| Implement Queue using Stacks | Two stacks | Easy | [LC 232](https://leetcode.com/problems/implement-queue-using-stacks/) |
| Daily Temperatures | Monotonic Stack | Medium | [LC 739](https://leetcode.com/problems/daily-temperatures/) |
| Largest Rectangle in Histogram | Monotonic Stack | Hard | [LC 84](https://leetcode.com/problems/largest-rectangle-in-histogram/) |

---

## Min Stack

**Key insight:** Use a second stack that tracks the minimum at each state.

```python
class MinStack:
    def __init__(self):
        self.stack = []
        self.min_stack = []  # tracks current minimum

    def push(self, val: int) -> None:
        self.stack.append(val)
        min_val = min(val, self.min_stack[-1] if self.min_stack else val)
        self.min_stack.append(min_val)

    def pop(self) -> None:
        self.stack.pop()
        self.min_stack.pop()

    def top(self) -> int:
        return self.stack[-1]

    def get_min(self) -> int:
        return self.min_stack[-1]
```

---

## Implement Queue Using Stacks

**Key insight:** Two stacks simulate a queue. Push to stack1. Pop from stack2 (fill from stack1 when empty).

```python
class MyQueue:
    def __init__(self):
        self.inbox = []   # for push
        self.outbox = []  # for pop/peek

    def push(self, x: int) -> None:
        self.inbox.append(x)

    def pop(self) -> int:
        self._transfer()
        return self.outbox.pop()

    def peek(self) -> int:
        self._transfer()
        return self.outbox[-1]

    def empty(self) -> bool:
        return not self.inbox and not self.outbox

    def _transfer(self):
        if not self.outbox:
            while self.inbox:
                self.outbox.append(self.inbox.pop())

# Amortized O(1) per operation — each element moves at most once
```

See [patterns/monotonic-stack.md](../patterns/monotonic-stack.md) for Daily Temperatures and Largest Rectangle solutions.
