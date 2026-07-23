// Problem: L. The Brothers
// Pattern:
// Link: https://codeforces.com/group/MWSDmqGsZm/contest/219158/problem/L
// Difficulty:
// Time:  O()
// Space: O()

#include <iostream>
using namespace std;

void solve() {
    string first1, last1, first2, last2;
    cin >> first1 >> last1 >> first2 >> last2;
    // your logic here
    if (last1 == last2)
        cout << "ARE Brothers\n";
    else
        cout << "NOT\n";
}

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(NULL);

    solve();
    return 0;
}
