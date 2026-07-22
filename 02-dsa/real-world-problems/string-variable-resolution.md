# String Variable Resolution

**Type:** Real-world FDE problem  
**Core algorithm:** Stack parsing + Recursive memoization  
**Difficulty:** Medium-Hard  
**Time limit (interview):** 35 minutes

---

## The Problem

You're building a configuration system for a customer. Configuration values can reference other configuration values using `%variable%` syntax.

Given:
- A `mappings` dictionary where keys are `%variable%` names and values can contain other variables
- An `input` string that may contain variables

Resolve the input string to its final value.

**Example:**

```python
mappings = {
    "%home%":   "/users/john",
    "%config%": "%home%/settings",
    "%app%":    "%config%/app"
}
input_str = "path is %app%/myfile.txt"
# Expected output: "path is /users/john/settings/app/myfile.txt"
```

**Constraints:**
- No regex — manual string parsing only
- Handle nested variables (variables that reference other variables)
- Handle circular dependencies gracefully (raise an error or return a sentinel)
- Optimize with memoization for repeated lookups
- Variables are delimited by `%` characters

---

## Understanding the Problem

Before coding, walk through the resolution chain:

```
%app% → %config%/app
      → %home%/settings/app
      → /users/john/settings/app

input: "path is %app%/myfile.txt"
     → "path is /users/john/settings/app/myfile.txt"
```

The key insight: we need to resolve variables **recursively**. When we find a variable, we look it up in mappings, then resolve the resulting string — which may itself contain variables.

---

## Approach 1: Stack-Based String Parsing

Parse the string character by character. When we encounter `%`, we're either starting or ending a variable token.

```python
def resolve_string_stack(input_str: str, mappings: dict) -> str:
    """
    Resolve variables in input_str using a stack-based parser.
    Variables are delimited by % signs.
    """

    def extract_tokens(s: str) -> list:
        """Extract a list of literal strings and %variable% tokens."""
        tokens = []
        i = 0
        while i < len(s):
            if s[i] == '%':
                # Find the closing %
                j = s.find('%', i + 1)
                if j == -1:
                    # Malformed: no closing %, treat rest as literal
                    tokens.append(s[i:])
                    break
                tokens.append(s[i:j+1])  # include both % delimiters
                i = j + 1
            else:
                # Collect literal characters until next %
                j = s.find('%', i)
                if j == -1:
                    tokens.append(s[i:])
                    break
                tokens.append(s[i:j])
                i = j
        return tokens

    def resolve_token(token: str, visited: set) -> str:
        """Resolve a single %variable% token."""
        if token not in mappings:
            return token  # unknown variable: return as-is

        if token in visited:
            raise ValueError(f"Circular dependency detected: {token}")

        value = mappings[token]
        new_visited = visited | {token}
        return resolve_value(value, new_visited)

    def resolve_value(value: str, visited: set) -> str:
        """Resolve all variables in a value string."""
        tokens = extract_tokens(value)
        parts = []
        for token in tokens:
            if token.startswith('%') and token.endswith('%') and len(token) > 1:
                parts.append(resolve_token(token, visited))
            else:
                parts.append(token)
        return ''.join(parts)

    return resolve_value(input_str, set())


# ── Tests ──────────────────────────────────────────────────────────────────

mappings = {
    "%home%":   "/users/john",
    "%config%": "%home%/settings",
    "%app%":    "%config%/app"
}

print(resolve_string_stack("path is %app%/myfile.txt", mappings))
# → "path is /users/john/settings/app/myfile.txt"

print(resolve_string_stack("%home%/.bashrc", mappings))
# → "/users/john/.bashrc"

print(resolve_string_stack("no variables here", mappings))
# → "no variables here"

# Circular dependency test
circular = {
    "%a%": "%b%/foo",
    "%b%": "%a%/bar",
}
try:
    resolve_string_stack("%a%", circular)
except ValueError as e:
    print(f"Caught: {e}")  # → "Caught: Circular dependency detected: %a%"
```

---

## Approach 2: Recursive with Memoization

When the same variable is resolved multiple times (e.g., `%home%` appears in 100 values), we want to cache the result.

```python
def resolve_string_memoized(input_str: str, mappings: dict) -> str:
    """
    Resolve variables with memoization to avoid redundant work.
    """
    memo = {}  # token → resolved value

    def resolve_token(token: str, resolving: set) -> str:
        """Resolve a %variable% token with cycle detection and memoization."""
        if token in memo:
            return memo[token]

        if token not in mappings:
            return token  # unknown → return unchanged

        if token in resolving:
            raise ValueError(f"Circular dependency: {token}")

        resolving = resolving | {token}  # immutable update — don't mutate the set
        resolved = resolve_value(mappings[token], resolving)
        memo[token] = resolved  # cache the result
        return resolved

    def resolve_value(value: str, resolving: set) -> str:
        """Resolve all %variable% tokens in a string."""
        result = []
        i = 0
        while i < len(value):
            if value[i] == '%':
                j = value.find('%', i + 1)
                if j == -1:
                    result.append(value[i:])
                    break
                token = value[i:j+1]
                result.append(resolve_token(token, resolving))
                i = j + 1
            else:
                j = value.find('%', i)
                if j == -1:
                    result.append(value[i:])
                    break
                result.append(value[i:j])
                i = j
        return ''.join(result)

    return resolve_value(input_str, set())


# ── Tests ──────────────────────────────────────────────────────────────────

mappings = {
    "%home%":   "/users/john",
    "%config%": "%home%/settings",
    "%app%":    "%config%/app"
}

# Test memoization: both uses of %home% resolve via the cache on second call
result = resolve_string_memoized(
    "%home% is the base and %app% is under %home%",
    mappings
)
print(result)
# → "/users/john is the base and /users/john/settings/app is under /users/john"
```

---

## Detailed Trace

**Input:** `"path is %app%/myfile.txt"`  
**Mappings:**
```
%home% → /users/john
%config% → %home%/settings
%app% → %config%/app
```

```
resolve_value("path is %app%/myfile.txt", resolving={})
  extract tokens: ["path is ", "%app%", "/myfile.txt"]
  token "%app%":
    resolve_token("%app%", {})
      mappings["%app%"] = "%config%/app"
      resolving = {"%app%"}
      resolve_value("%config%/app", {"%app%"})
        tokens: ["%config%", "/app"]
        token "%config%":
          resolve_token("%config%", {"%app%"})
            mappings["%config%"] = "%home%/settings"
            resolving = {"%app%", "%config%"}
            resolve_value("%home%/settings", {"%app%", "%config%"})
              tokens: ["%home%", "/settings"]
              token "%home%":
                resolve_token("%home%", {"%app%", "%config%"})
                  mappings["%home%"] = "/users/john"
                  resolving = {"%app%", "%config%", "%home%"}
                  resolve_value("/users/john", {...})
                    no tokens → return "/users/john"
                  memo["%home%"] = "/users/john"
                  return "/users/john"
              result: "/users/john" + "/settings" = "/users/john/settings"
            return "/users/john/settings"
          memo["%config%"] = "/users/john/settings"
          return "/users/john/settings"
        result: "/users/john/settings" + "/app" = "/users/john/settings/app"
      memo["%app%"] = "/users/john/settings/app"
      return "/users/john/settings/app"
  final result: "path is " + "/users/john/settings/app" + "/myfile.txt"
               = "path is /users/john/settings/app/myfile.txt" ✓
```

---

## Edge Cases

| Case | Expected behavior |
|------|------------------|
| Unknown variable `%unknown%` | Return `%unknown%` unchanged |
| No variables in input | Return input unchanged |
| Empty input string | Return empty string |
| Variable with empty value `%x%: ""` | Substitute empty string |
| Circular dependency `%a% → %b% → %a%` | Raise `ValueError` |
| Variable appears multiple times | Resolve once (memoized), reuse |
| Malformed `%` (no closing `%`) | Treat remainder as literal |

---

## Complexity

| Approach | Time | Space |
|----------|------|-------|
| Stack (no memo) | O(n × d) where d = nesting depth | O(d) call stack |
| Memoized | O(n × k) first time, O(n) after | O(k) memo where k = unique variables |

---

## How to Present This in an Interview

1. **Clarify:** "Can values only be other variables, or can they be partial strings mixed with variables?" (Answer: mixed — the hard case)
2. **Identify the pattern:** "This is recursive variable resolution — each value may itself contain variables, so I need to resolve transitively."
3. **Raise the constraint:** "I need to handle circular dependencies — if %a% references %b% which references %a%, that's an infinite loop."
4. **Start simple:** Show the recursive approach first. Then add memoization as the optimization.
5. **Run your trace:** Walk through the main example step by step.

This problem is a strong signal of FDE-style thinking because it combines string parsing (engineering detail) with graph cycle detection (algorithmic depth) and memoization (practical optimization).
