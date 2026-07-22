# Tree Problems

| Problem | Pattern | Difficulty | Link |
|---------|---------|------------|------|
| Validate BST | DFS with bounds | Medium | [LC 98](https://leetcode.com/problems/validate-binary-search-tree/) |
| LCA of Binary Tree | DFS post-order | Medium | [LC 236](https://leetcode.com/problems/lowest-common-ancestor-of-a-binary-tree/) |
| Serialize and Deserialize | BFS / DFS | Hard | [LC 297](https://leetcode.com/problems/serialize-and-deserialize-binary-tree/) |
| Binary Tree Level Order | BFS | Medium | [LC 102](https://leetcode.com/problems/binary-tree-level-order-traversal/) |

---

## Validate BST

**Key insight:** Pass min/max bounds down the tree. Each node must be strictly within its valid range.

```python
from typing import Optional

class TreeNode:
    def __init__(self, val=0, left=None, right=None):
        self.val = val; self.left = left; self.right = right

def is_valid_bst(root: Optional[TreeNode]) -> bool:
    def validate(node, min_val, max_val):
        if not node:
            return True
        if not (min_val < node.val < max_val):
            return False
        return (validate(node.left, min_val, node.val) and
                validate(node.right, node.val, max_val))

    return validate(root, float('-inf'), float('inf'))
```

---

## Lowest Common Ancestor

**Key insight:** Post-order DFS. A node is the LCA if both p and q are found in its left and right subtrees.

```python
def lowest_common_ancestor(root: TreeNode, p: TreeNode, q: TreeNode) -> TreeNode:
    if not root or root == p or root == q:
        return root  # found one of the targets, or reached null

    left = lowest_common_ancestor(root.left, p, q)
    right = lowest_common_ancestor(root.right, p, q)

    if left and right:
        return root  # p in left subtree, q in right subtree → current is LCA
    return left or right  # both in same subtree
```

---

## Serialize and Deserialize Binary Tree

```python
from collections import deque

class Codec:
    def serialize(self, root: Optional[TreeNode]) -> str:
        if not root:
            return "null"
        result = []
        queue = deque([root])
        while queue:
            node = queue.popleft()
            if node:
                result.append(str(node.val))
                queue.append(node.left)
                queue.append(node.right)
            else:
                result.append("null")
        return ",".join(result)

    def deserialize(self, data: str) -> Optional[TreeNode]:
        if data == "null":
            return None
        vals = data.split(",")
        root = TreeNode(int(vals[0]))
        queue = deque([root])
        i = 1
        while queue and i < len(vals):
            node = queue.popleft()
            if vals[i] != "null":
                node.left = TreeNode(int(vals[i]))
                queue.append(node.left)
            i += 1
            if i < len(vals) and vals[i] != "null":
                node.right = TreeNode(int(vals[i]))
                queue.append(node.right)
            i += 1
        return root
```
