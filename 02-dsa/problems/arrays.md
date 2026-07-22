# Array Problems

| Problem | Pattern | Difficulty | Link |
|---------|---------|------------|------|
| Product of Array Except Self | Prefix/Suffix product | Medium | [LC 238](https://leetcode.com/problems/product-of-array-except-self/) |
| Spiral Matrix | Simulation | Medium | [LC 54](https://leetcode.com/problems/spiral-matrix/) |
| Trapping Rain Water | Two Pointers / Monotonic Stack | Hard | [LC 42](https://leetcode.com/problems/trapping-rain-water/) |
| Maximum Subarray | Kadane's Algorithm | Medium | [LC 53](https://leetcode.com/problems/maximum-subarray/) |

---

## Product of Array Except Self

**Key insight:** No division allowed. Build left products and right products in two passes.

```python
def product_except_self(nums: list[int]) -> list[int]:
    n = len(nums)
    result = [1] * n

    # Pass 1: result[i] = product of all elements to the LEFT of i
    left_product = 1
    for i in range(n):
        result[i] = left_product
        left_product *= nums[i]

    # Pass 2: multiply by product of all elements to the RIGHT of i
    right_product = 1
    for i in range(n - 1, -1, -1):
        result[i] *= right_product
        right_product *= nums[i]

    return result

# Test
print(product_except_self([1,2,3,4]))   # [24,12,8,6]
print(product_except_self([-1,1,0,-3,3]))  # [0,0,9,0,0]
```

---

## Maximum Subarray (Kadane's Algorithm)

**Key insight:** At each position, either extend the existing subarray or start a new one from the current element.

```python
def max_subarray(nums: list[int]) -> int:
    max_sum = nums[0]
    current_sum = nums[0]

    for num in nums[1:]:
        # Either extend or restart subarray here
        current_sum = max(num, current_sum + num)
        max_sum = max(max_sum, current_sum)

    return max_sum

# Test
print(max_subarray([-2,1,-3,4,-1,2,1,-5,4]))  # 6 ([4,-1,2,1])
print(max_subarray([1]))                        # 1
print(max_subarray([5,4,-1,7,8]))              # 23
```
