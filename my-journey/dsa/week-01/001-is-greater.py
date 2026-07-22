# Problem: Is A Greater Than B
# Pattern: Basics / Conditionals
# Link: https://codeforces.com/group/MWSDmqGsZm/contest/219158/problem/I
# Difficulty: Easy
# Time:  O(1)
# Space: O(1)

import sys
input = sys.stdin.readline


def solve():
    a, b = map(int, input().split())
    print("YES" if a > b else "NO")


if __name__ == "__main__":
    solve()
