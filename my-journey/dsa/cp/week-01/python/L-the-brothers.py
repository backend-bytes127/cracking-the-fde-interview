# Problem: L. The Brothers
# Pattern:
# Link: https://codeforces.com/group/MWSDmqGsZm/contest/219158/problem/L
# Difficulty:
# Time:  O()
# Space: O()

import sys
input = sys.stdin.readline


def solve():
    first1, last1 = input().split()
    first2, last2 = input().split()
    # your logic here
    if last1 == last2:
        print("ARE Brothers")
    else:
        print("NOT")


if __name__ == "__main__":
    solve()
