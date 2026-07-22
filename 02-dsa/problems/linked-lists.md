# Linked List Problems

| Problem | Pattern | Difficulty | Link |
|---------|---------|------------|------|
| Reverse Linked List | Iterative pointer reversal | Easy | [LC 206](https://leetcode.com/problems/reverse-linked-list/) |
| Linked List Cycle II | Fast/Slow Pointers | Medium | [LC 142](https://leetcode.com/problems/linked-list-cycle-ii/) |
| Merge Two Sorted Lists | Two Pointers | Easy | [LC 21](https://leetcode.com/problems/merge-two-sorted-lists/) |
| LRU Cache | HashMap + Doubly Linked List | Medium | [LC 146](https://leetcode.com/problems/lru-cache/) |

---

## Reverse Linked List

```python
from typing import Optional

class ListNode:
    def __init__(self, val=0, next=None):
        self.val = val
        self.next = next

def reverse_list(head: Optional[ListNode]) -> Optional[ListNode]:
    prev = None
    current = head

    while current:
        next_node = current.next   # save next
        current.next = prev        # reverse the pointer
        prev = current             # move prev forward
        current = next_node        # move current forward

    return prev  # prev is now the new head
```

---

## Linked List Cycle II (Find Cycle Start)

**Floyd's Tortoise and Hare:**

```python
def detect_cycle(head: Optional[ListNode]) -> Optional[ListNode]:
    slow = fast = head

    # Phase 1: detect cycle
    while fast and fast.next:
        slow = slow.next
        fast = fast.next.next
        if slow == fast:
            break
    else:
        return None  # no cycle

    # Phase 2: find cycle start
    # Move one pointer to head. Both advance at same speed.
    # They meet at the cycle start.
    slow = head
    while slow != fast:
        slow = slow.next
        fast = fast.next

    return slow
```

**Why phase 2 works:** Mathematical proof — distance from head to cycle start equals distance from meeting point to cycle start. Taking on trust is fine in an interview.

---

## LRU Cache

**Design:** O(1) get and put. Use a hash map for O(1) lookup + doubly linked list for O(1) insertion/deletion.

```python
class DLinkedNode:
    def __init__(self, key=0, val=0):
        self.key = key
        self.val = val
        self.prev = self.next = None

class LRUCache:
    def __init__(self, capacity: int):
        self.capacity = capacity
        self.cache = {}  # key → node
        # Sentinel head and tail simplify edge cases
        self.head = DLinkedNode()
        self.tail = DLinkedNode()
        self.head.next = self.tail
        self.tail.prev = self.head

    def _remove(self, node):
        node.prev.next = node.next
        node.next.prev = node.prev

    def _insert_front(self, node):
        node.next = self.head.next
        node.prev = self.head
        self.head.next.prev = node
        self.head.next = node

    def get(self, key: int) -> int:
        if key not in self.cache:
            return -1
        node = self.cache[key]
        self._remove(node)
        self._insert_front(node)  # most recently used
        return node.val

    def put(self, key: int, value: int) -> None:
        if key in self.cache:
            self._remove(self.cache[key])
        node = DLinkedNode(key, value)
        self.cache[key] = node
        self._insert_front(node)
        if len(self.cache) > self.capacity:
            # Remove LRU (the node just before tail)
            lru = self.tail.prev
            self._remove(lru)
            del self.cache[lru.key]
```
