# String Problems

| Problem | Pattern | Difficulty | Link |
|---------|---------|------------|------|
| Group Anagrams | Sorting + HashMap | Medium | [LC 49](https://leetcode.com/problems/group-anagrams/) |
| Longest Substring Without Repeating Characters | Sliding Window | Medium | [LC 3](https://leetcode.com/problems/longest-substring-without-repeating-characters/) |
| Minimum Window Substring | Sliding Window | Hard | [LC 76](https://leetcode.com/problems/minimum-window-substring/) |
| Valid Palindrome | Two Pointers | Easy | [LC 125](https://leetcode.com/problems/valid-palindrome/) |

---

## Group Anagrams

**Key insight:** Anagrams have the same sorted characters. Use sorted string as the hash map key.

```python
from collections import defaultdict

def group_anagrams(strs: list[str]) -> list[list[str]]:
    groups = defaultdict(list)
    for s in strs:
        key = tuple(sorted(s))  # "eat" → ('a','e','t')
        groups[key].append(s)
    return list(groups.values())

# Test
print(group_anagrams(["eat","tea","tan","ate","nat","bat"]))
# [["eat","tea","ate"],["tan","nat"],["bat"]]
```

**Alternative key:** character frequency tuple instead of sorted — avoids O(k log k) sorting:

```python
def group_anagrams_v2(strs: list[str]) -> list[list[str]]:
    groups = defaultdict(list)
    for s in strs:
        count = [0] * 26
        for c in s:
            count[ord(c) - ord('a')] += 1
        groups[tuple(count)].append(s)
    return list(groups.values())
```

---

## Isomorphic Strings

**Key insight:** Two strings are isomorphic if there's a one-to-one character mapping between them.

```python
def is_isomorphic(s: str, t: str) -> bool:
    s_to_t = {}
    t_to_s = {}
    for cs, ct in zip(s, t):
        if cs in s_to_t and s_to_t[cs] != ct:
            return False
        if ct in t_to_s and t_to_s[ct] != cs:
            return False
        s_to_t[cs] = ct
        t_to_s[ct] = cs
    return True

# Test
print(is_isomorphic("egg", "add"))  # True
print(is_isomorphic("foo", "bar"))  # False
print(is_isomorphic("paper", "title"))  # True
```
