// Problem: Is A Greater Than B
// Pattern: Basics / Conditionals
// Link: https://codeforces.com/group/MWSDmqGsZm/contest/219158/problem/I
// Difficulty: Easy
// Time:  O(1)
// Space: O(1)

#include <iostream>
using namespace std;

void solve() {
    int a, b;
    cin >> a >> b;
    cout << (a > b ? "YES" : "NO") << "\n";
}

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(NULL);

    solve();
    return 0;
}
