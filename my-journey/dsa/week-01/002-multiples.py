# Problem: Multiples
# Pattern: Basics / Conditionals
# Link: https://codeforces.com/group/MWSDmqGsZm/contest/219158/problem/J
# Difficulty: Easy
# Time:  O(1)
# Space: O(1)

import sys
input = sys.stdin.readline


def solve():
    a, b = map(int, input().split())
    # your logic here
    if a % b == 0 or b % a == 0:
        print("Multiples")
    else:
        print("No Multiples")


if __name__ == "__main__":
    solve()
