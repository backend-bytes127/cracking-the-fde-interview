# Mock Interview Guide — DSA

The gap between knowing algorithms and performing in an interview is larger than most candidates expect. This guide is about closing that gap.

---

## The Brutal Truth

You can know every pattern in this repository and still fail the DSA round.

The reason is almost always the same: you go silent when you're stuck, you start coding before you understand the problem, or you don't handle edge cases naturally.

These are fixable. But you have to practice fixing them, not just practice algorithms.

---

## Before the Interview

**Practice talking out loud. Always.**

Every time you practice a problem, narrate what you're doing. Even when you're alone. Especially when you're alone.

Record yourself on camera. Watch it back. You will hear exactly where you go silent. You will see exactly when you start typing before you've said what you're going to do.

It's uncomfortable. Do it anyway.

**Time yourself.**

Set a timer for 25 minutes. Solve a medium problem including narration, edge case discussion, and complexity analysis. If you can't do it in 25 minutes, you need more practice — not just more knowledge.

**Simulate real conditions.**

Use a blank document or a shared coding environment, not your IDE. No autocomplete. No compiler running continuously. Just you and a code editor.

---

## During the Interview

### The First 60 Seconds: Read and Clarify

Read the entire problem before writing a single line of code. Take 60 seconds.

Then ask clarifying questions:
- What are the input constraints? (n size, negative numbers, empty input?)
- What should I return if there's no valid answer?
- Can I modify the input in-place?
- Is the array sorted?

These questions signal that you think carefully before acting — a key FDE trait.

### The Next 2 Minutes: State Your Approach

Before coding, say the pattern out loud:

> "This looks like BFS because we're finding the shortest path in an unweighted graph. I'll use a queue and a visited set."

> "The key insight here is prefix sum — if I precompute cumulative sums, I can answer range sum queries in O(1) instead of O(n) each."

If you can't articulate your approach in one sentence, you're not ready to code yet.

Start with the naive approach if the optimal one isn't obvious:

> "The naive approach is O(n²) — check every pair. I think we can optimize with a hash map to get O(n). Let me think through that..."

### While You Code: Talk Constantly

Never go silent for more than 30 seconds.

What to say when coding:
- "I'm using a hash map here to track counts — O(1) lookup instead of O(n)"
- "This variable `left` represents the start of my current window"
- "I'm choosing index `i + 1` here because each element can only be used once"

If you're stuck:
- "Let me trace through a small example..."
- "The constraint that the array is sorted suggests I can do better than linear scan..."
- "What happens if I add this element to the window? The sum exceeds the target, so I need to shrink from the left..."

### Handling Edge Cases

Before finalizing your solution, say out loud:

> "Let me think about edge cases. What if the input is empty? What if n=1? What if there are negative numbers?"

Then handle them — either in code or explain why the general solution already handles them.

This is not optional. FDE engineers work with customer systems. Interviewers are listening for whether you think about what breaks.

### If You Get Stuck

Getting stuck is not failure. Handling being stuck gracefully is.

**Step 1:** Trace through a small concrete example. Literally draw it out or write it.

**Step 2:** Say the pattern map out loud. "Is there a sorted array here? Is this asking for a subarray? Is there a graph structure?"

**Step 3:** Ask for a hint. "I'm thinking about this as a BFS problem but I'm not sure how to set up the graph structure — would it make sense to treat each element as a node?"

Asking for a hint thoughtfully is fine. Sitting in silence is not.

---

## Communication Phrases That Work

These are natural-sounding phrases that signal clear thinking:

**When you see the problem:**
- "Let me think through this step by step before I start coding."
- "My initial read is that this is a sliding window problem because we're looking for a maximum length subarray with a property."

**When you're coding:**
- "I'm using a stack here because I need to process elements in LIFO order..."
- "This outer loop is O(n), and the inner while loop looks like O(n) worst case, but amortized each element is pushed and popped at most once — so overall O(n)."

**When you need to think:**
- "Let me trace through the example to verify..."
- "I want to make sure I handle the case where the input is empty..."

**When you're explaining complexity:**
- "Time complexity is O(n log k) — n elements, each pushed/popped from the heap once, heap operations are O(log k)."
- "Space is O(n) for the visited set in BFS."

**When you're done:**
- "My solution handles the main case. Edge cases I've considered: empty input returns 0, single element returns itself. Would you like me to optimize the space complexity?"

---

## Recommended Mock Interview Sequence

| Week | Activity |
|------|----------|
| 1–2 | Record yourself solo. One problem per session. Watch the recording. |
| 3–4 | Pramp.com 2× per week. Peer interviews. |
| 5–8 | Pramp 3× per week + one problem timed with recording per week |
| 9–12 | One paid mock on interviewing.io per month |

See [06-resources/mock-platforms.md](../06-resources/mock-platforms.md) for platform details.

---

## The Scoring Rubric (What Interviewers Actually Rate)

| Dimension | What they're looking for |
|-----------|--------------------------|
| Problem comprehension | Did you understand what was asked? Did you clarify well? |
| Approach identification | Did you find the right pattern quickly? |
| Communication | Could the interviewer follow your thinking throughout? |
| Code quality | Is the code correct, clean, and readable? |
| Edge case handling | Did you think about what breaks without being prompted? |
| Optimization | Did you start simple and improve? Did you know the complexity? |

For FDE specifically, **communication** is weighted as heavily as **code quality**. Both must be strong.
