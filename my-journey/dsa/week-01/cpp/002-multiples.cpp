// Problem: Multiples
// Pattern: Basics / Conditionals
// Link: https://codeforces.com/group/MWSDmqGsZm/contest/219158/problem/J
// Difficulty: Easy
// Time:  O(1)
// Space: O(1)

#include <iostream>
using namespace std;

void solve() {
    int a, b;
    cin >> a >> b;
    // your logic here
    if (a % b == 0 || b % a == 0)
        cout << "Multiples\n";
    else
        cout << "No Multiples\n";
}

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(NULL);

    solve();
    return 0;
}
