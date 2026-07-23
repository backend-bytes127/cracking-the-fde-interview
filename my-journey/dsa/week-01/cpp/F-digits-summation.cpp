// Problem: F. Digits Summation
// Pattern:
// Link: https://codeforces.com/group/MWSDmqGsZm/contest/219158/problem/F
// Difficulty:
// Time:  O()
// Space: O()

#include <iostream>
using namespace std;

void solve() {
    long long a, b;
    cin >> a >> b;
    cout << (a % 10) + (b % 10) << "\n";
}

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(NULL);

    solve();
    return 0;
}
