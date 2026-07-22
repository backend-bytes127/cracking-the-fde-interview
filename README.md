<!-- BADGES -->
<p align="center">
  <a href="https://github.com/backend-bytes127/cracking-the-fde-interview/stargazers"><img src="https://img.shields.io/github/stars/backend-bytes127/cracking-the-fde-interview?style=for-the-badge&color=FFD700" alt="GitHub Stars"></a>
  <a href="https://github.com/backend-bytes127/cracking-the-fde-interview/network/members"><img src="https://img.shields.io/github/forks/backend-bytes127/cracking-the-fde-interview?style=for-the-badge&color=4A90E2" alt="GitHub Forks"></a>
  <a href="https://github.com/backend-bytes127/cracking-the-fde-interview/commits/main"><img src="https://img.shields.io/github/last-commit/backend-bytes127/cracking-the-fde-interview?style=for-the-badge" alt="Last Commit"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="MIT License"></a>
  <a href="https://github.com/backend-bytes127/cracking-the-fde-interview/graphs/contributors"><img src="https://img.shields.io/github/contributors/backend-bytes127/cracking-the-fde-interview?style=for-the-badge" alt="Contributors"></a>
  <a href="CONTRIBUTING.md"><img src="https://img.shields.io/badge/PRs-welcome-brightgreen?style=for-the-badge" alt="PRs Welcome"></a>
</p>

<br/>

<h1 align="center">Cracking the FDE Interview</h1>

<p align="center">
  <em>The most comprehensive open source resource for<br/>
  Forward Deployed Engineer and AI Engineering interviews.<br/>
  Built in public. By a practitioner. For practitioners.</em>
</p>

<p align="center">
  <strong>Covers DSA · AI Engineering · GCP · System Design · RRK · Company Specific Guides</strong>
</p>

<br/>

---

## What Is This?

This is the resource I wish existed when I started preparing for FDE interviews.

**Open source and community driven.** Every section is written to be practical, accurate, and deep. Not cheat sheets. Not link dumps. Actual understanding.

**Covers everything the FDE interview actually tests:**
- DSA — with pattern recognition, not memorization
- AI Engineering — LLMs, RAG, fine-tuning, MLOps
- GCP — Vertex AI, BigQuery, Cloud Run, real architecture
- System Design — rate limiters, distributed systems, design patterns
- RRK (Role Related Knowledge) — customer scenarios, frameworks, communication
- Company-specific guides — Google FDE, Anthropic, Meta, Amazon, Microsoft

**For Google FDE, Anthropic, Meta, Amazon, and Microsoft** — the companies where FDE roles actually exist at scale.

---

## Why FDE Is Different From SWE

FDE interviews are not just harder LeetCode.

A Software Engineer interview tests whether you can implement a given solution correctly. An FDE interview tests whether you can take an ambiguous real-world problem, figure out what matters, write code that works, and explain it clearly to someone who might not be technical.

You need DSA fluency — not to grind 500 problems, but to recognize patterns under pressure and communicate your thinking. You need AI Engineering depth — because FDE roles increasingly require building and deploying AI products, not just integrating APIs. You need GCP knowledge — because most FDE roles at tier 1 companies are tied to cloud platforms. And you need customer thinking — the ability to translate business problems into technical architecture and back.

This resource covers all of it.

---

## Who This Is For

**Three types of engineers use this resource:**

| Path | Description |
|------|-------------|
| SWE → FDE | Software engineers targeting their first FDE role at a tier 1 company |
| Solutions Engineer → AI Engineering | Solutions/Sales engineers moving into more technical AI-focused roles |
| AI Engineering aspirants | Anyone targeting Google/Anthropic/Meta AI engineering roles |

---

## Table of Contents

| Section | Description |
|---------|-------------|
| [01 — What Is FDE](01-what-is-fde/) | Role overview, day in the life, FDE vs SWE vs other roles |
| [02 — DSA](02-dsa/) | Pattern library, problems, real-world problems, mock interview guide |
| [03 — AI Engineering](03-ai-engineering/) | LLM fundamentals, MLOps, GenAI on cloud |
| [04 — RRK](04-rrk/) | GCP deep dive, system design, customer scenarios, behavioral |
| [05 — Company Specific](05-company-specific/) | Google FDE, Anthropic, Meta, Amazon, Microsoft |
| [06 — Resources](06-resources/) | Curated problems, mock platforms, books, courses |
| [My Journey](my-journey/) | Neeraj's public 12-month comeback log |

---

## Companies Covered

| Company | FDE Role Name | DSA Round | RRK Round | AI Depth Required | Notes |
|---------|--------------|-----------|-----------|-------------------|-------|
| Google | Forward Deployed Engineer | Yes | Yes | Medium-High | Two full rounds; RRK is GCP heavy |
| Anthropic | Various (SWE, AI Eng) | Yes | Yes | Very High | Constitutional AI, Claude API mastery expected |
| Meta | Forward Deployed Engineer | Yes | Yes | High | Llama ecosystem, PyTorch, Meta AI products |
| Amazon | Technical Account Manager / AIML specialist | Yes | Yes | High | AWS services, SageMaker, customer obsession |
| Microsoft | Customer Engineer / AI Cloud Solution Architect | Sometimes | Yes | High | Azure AI, Copilot ecosystem |

---

## The DSA Pattern Map

This is the table that changes everything. Stop trying to memorize solutions. Learn to recognize patterns.

| Trigger phrase / constraint | Pattern to use |
|----------------------------|---------------|
| Sorted array + find pair | Two Pointers |
| Subarray with condition, max/min window | Sliding Window |
| Subarray sum = k, range sum queries | Prefix Sum + HashMap |
| Top K elements, kth largest/smallest | Min-Heap of size K |
| Shortest path, unweighted graph | BFS |
| Shortest path, weighted graph | Dijkstra |
| All paths, count paths, DFS on grid | DFS + Backtracking |
| Next greater / smaller element | Monotonic Stack |
| Cycle detection, directed graph | DFS 3-color |
| Cycle detection, undirected graph | Union Find |
| Task ordering, dependency resolution | Topological Sort |
| Grid islands, connected components | DFS with in-place marking |
| Multiple starting points, spreading | Multi-source BFS |
| Overlapping subproblems, optimal substructure | Dynamic Programming |
| All permutations, subsets, combinations | Backtracking |
| Sorted + O(log n) target | Binary Search |
| Find answer in a value range | Binary Search on Answer Space |
| Connectivity queries, union operations | Union Find |

---

## How to Use This Resource

**If you have 12 months:** Start at [01-what-is-fde](01-what-is-fde/). Work through every section. Build up to mock interviews.

**If you have 3 months:** Jump to [02-dsa/patterns](02-dsa/patterns/), [03-ai-engineering](03-ai-engineering/), and [05-company-specific](05-company-specific/) for your target company.

**If you have 3 weeks:** Do the [DSA pattern map](02-dsa/README.md), the [mock interview guide](02-dsa/mock-interview-guide.md), and the [company specific guide](05-company-specific/) for your target role. Then book mocks on [mock platforms](06-resources/mock-platforms.md).

---

## About the Author

**Neeraj Sujan** — senior engineer building this resource in public while preparing for tier 1 FDE interviews.

On July 22, 2026 I got rejected from Google FDE. I made it to the final round. The RRK round went well. The DSA round was the gap. There is a 12-month cooling off period before I can reapply.

I decided to build the resource I wish I had — and document the entire comeback publicly.

🌐 [neerajsujan.com](https://neerajsujan.com)
🐙 [GitHub: backend-bytes127](https://github.com/backend-bytes127)

*"I got rejected from Google FDE on July 22, 2026. This repo is what I did next. Follow the journey in [/my-journey](my-journey/)."*

---

## Contributing

This resource gets better every time someone contributes.

**We need:**
- Interview reports from companies (use the [Add Company Experience](/.github/ISSUE_TEMPLATE/add-company-experience.md) issue template)
- Problem solutions with pattern explanations
- AI Engineering and GCP content
- Corrections to anything that's wrong or outdated

See [CONTRIBUTING.md](CONTRIBUTING.md) for how to contribute.

Every pull request gets reviewed. Every contribution is recognized.

---

## Star History

If this resource helped you, star it. It helps more engineers find it.

[![Star History Chart](https://api.star-history.com/svg?repos=backend-bytes127/cracking-the-fde-interview&type=Date)](https://star-history.com/#backend-bytes127/cracking-the-fde-interview)

---

<p align="center">
  <em>Built for the engineers who want to crack FDE interviews.<br/>
  Made better by every person who contributes.<br/>
  MIT Licensed — free forever.</em>
</p>
