# Problem: F. Digits Summation
# Pattern:
# Link: https://codeforces.com/group/MWSDmqGsZm/contest/219158/problem/F
# Difficulty:
# Time:  O()
# Space: O()

import sys
input = sys.stdin.readline


def solve():
    a, b = map(int, input().split())
    # your logic here
    last_digit_a = a%10
    last_digit_b = b%10
    result = last_digit_a + last_digit_b
    print(result)


if __name__ == "__main__":
    solve()
