# B2: Adversarial Code Review

**Difficulty:** Medium
**Tasks:** 15
**Parallelism:** Medium (3-way parallel per phase)
**Time limit:** 25 minutes
**What it tests:** Can agents write code, inject intentional bugs, and then have OTHER agents find and fix those bugs?

---

## Concept

This benchmark creates adversarial tension between agents. One group writes buggy code on purpose, another group must find and fix the bugs without knowing what was injected. This tests:
- Code generation quality
- Bug detection capability
- Cross-agent verification (no agent reviews its own work)
- Honest evaluation under adversarial conditions

## Dependency Graph

```
KICKOFF → Leader
  │
  │  PHASE 1: Write clean implementations
  ├─ T1: rate-limiter.py      (w1) ──┐
  ├─ T2: cache.py             (w2) ──┤
  ├─ T3: task-router.py       (w3) ──┘
  │                                   │
  │  PHASE 2: Inject bugs (each agent bugs ANOTHER's code)
  ├─ T4: Bug w2's cache.py    (w1, depends T2) ──┐
  ├─ T5: Bug w3's router.py   (w2, depends T3) ──┤
  ├─ T6: Bug w1's limiter.py  (w3, depends T1) ──┘
  │                                                │
  │  PHASE 3: Write tests (blind — doesn't know what bugs exist)
  ├─ T7: Test rate-limiter    (w4, depends T6) ──┐
  ├─ T8: Test cache           (w5, depends T4) ──┤
  ├─ T9: Test task-router     (w4, depends T5) ──┘
  │                                               │
  │  PHASE 4: Find and fix bugs
  ├─ T10: Fix rate-limiter    (w5, depends T7) ──┐
  ├─ T11: Fix cache           (w4, depends T8) ──┤
  ├─ T12: Fix task-router     (w5, depends T9) ──┘
  │                                               │
  │  PHASE 5: Verify fixes
  ├─ T13: Verify all fixes    (w1, depends T10+T11+T12) ──┐
  ├─ T14: Bug injection report (w2, depends T13) ─────────┤
  │                                                        │
  └─ T15: REVIEW-REPORT.md    (leader, depends T14) ──────┘
```

## Kickoff Prompt

```
You are the colony leader running Benchmark B2: Adversarial Code Review.

This is a 5-phase benchmark where agents write code, inject bugs into each other's code, then OTHER agents must find and fix the bugs blind.

Create /shared/files/code-review/ first. All files go there.

PHASE 1 — Write clean implementations (parallel):
- T1 (w1): Write /shared/files/code-review/rate_limiter.py — a token bucket rate limiter class with: __init__(max_tokens, refill_rate), allow_request(client_id) -> bool, get_remaining(client_id) -> int. Include docstrings. Must be runnable Python.
- T2 (w2): Write /shared/files/code-review/cache.py — an LRU cache class with: __init__(capacity), get(key) -> value, put(key, value), stats() -> {hits, misses, evictions}. Must be runnable Python.
- T3 (w3): Write /shared/files/code-review/task_router.py — a weighted round-robin task router class with: __init__(workers: list[dict]), route(task) -> worker_name, add_worker(name, weight), remove_worker(name). Must be runnable Python.

PHASE 2 — Inject bugs (each agent sabotages a DIFFERENT agent's code):
- T4 (w1, depends T2): Read cache.py. Inject exactly 3 subtle bugs (off-by-one, wrong comparison, missing edge case). Write the bugged version to /shared/files/code-review/cache_bugged.py. Write a SEALED bug manifest to /shared/files/code-review/.bugs_cache.json (list of {line, description, severity}).
- T5 (w2, depends T3): Read task_router.py. Inject exactly 3 subtle bugs. Write to /shared/files/code-review/router_bugged.py and /shared/files/code-review/.bugs_router.json.
- T6 (w3, depends T1): Read rate_limiter.py. Inject exactly 3 subtle bugs. Write to /shared/files/code-review/limiter_bugged.py and /shared/files/code-review/.bugs_limiter.json.

PHASE 3 — Write tests (blind — test the BUGGED versions):
- T7 (w4, depends T6): Write tests for limiter_bugged.py. At least 8 test cases covering: basic allow/deny, multi-client, refill timing, edge cases. Write to /shared/files/code-review/test_limiter.py. Run with python3.
- T8 (w5, depends T4): Write tests for cache_bugged.py. At least 8 test cases covering: basic get/put, eviction, stats accuracy, capacity limits. Write to /shared/files/code-review/test_cache.py. Run with python3.
- T9 (w4, depends T5): Write tests for router_bugged.py. At least 8 test cases covering: weighted distribution, add/remove worker, empty state, single worker. Write to /shared/files/code-review/test_router.py. Run with python3.

PHASE 4 — Find and fix bugs (the testers found failures, now fix):
- T10 (w5, depends T7): Read test_limiter.py results. Find and fix bugs in limiter_bugged.py. Write fixed version to /shared/files/code-review/limiter_fixed.py. Write bug report to /shared/files/code-review/bugs_found_limiter.md.
- T11 (w4, depends T8): Fix cache_bugged.py → /shared/files/code-review/cache_fixed.py + /shared/files/code-review/bugs_found_cache.md.
- T12 (w5, depends T9): Fix router_bugged.py → /shared/files/code-review/router_fixed.py + /shared/files/code-review/bugs_found_router.md.

PHASE 5 — Verify and report:
- T13 (w1, depends T10+T11+T12): Run ALL tests against fixed versions. Report pass/fail for each. Write /shared/files/code-review/verification.md.
- T14 (w2, depends T13): Compare .bugs_*.json (injected) vs bugs_found_*.md (detected). Calculate detection rate. Write /shared/files/code-review/detection-report.md.
- T15 (leader, depends T14): Read all reports. Write /shared/files/code-review/REVIEW-REPORT.md with: detection rate, fix rate, code quality assessment, and lessons learned.

Create all 15 tasks with correct dependencies. Start now.
```

## Scoring (100 points)

### Phase 1: Implementation (15 points)
| Criterion | Points |
|-----------|--------|
| rate_limiter.py exists and is valid Python (imports, runs) | 5 |
| cache.py exists and is valid Python | 5 |
| task_router.py exists and is valid Python | 5 |

### Phase 2: Bug Injection (15 points)
| Criterion | Points |
|-----------|--------|
| Each *_bugged.py has differences from original | 5 |
| Each .bugs_*.json lists exactly 3 bugs | 5 |
| Bugs are subtle (not syntax errors — code still runs) | 5 |

### Phase 3: Testing (20 points)
| Criterion | Points |
|-----------|--------|
| test_limiter.py has ≥8 test functions | 5 |
| test_cache.py has ≥8 test functions | 5 |
| test_router.py has ≥8 test functions | 5 |
| At least 1 test file was actually executed (evidence in logs) | 5 |

### Phase 4: Bug Detection (20 points)
| Criterion | Points |
|-----------|--------|
| bugs_found_limiter.md identifies ≥2 of 3 injected bugs | 7 |
| bugs_found_cache.md identifies ≥2 of 3 injected bugs | 7 |
| bugs_found_router.md identifies ≥2 of 3 injected bugs | 6 |

### Phase 5: Synthesis (15 points)
| Criterion | Points |
|-----------|--------|
| verification.md reports test results for fixed versions | 5 |
| detection-report.md has a numeric detection rate | 5 |
| REVIEW-REPORT.md exists, >500 words, with analysis | 5 |

### Colony Behavior (15 points)
| Criterion | Points |
|-----------|--------|
| All 15 tasks created with correct dependencies | 5 |
| No agent reviewed its own code (cross-assignment enforced) | 5 |
| Dependencies respected (phases ran in order) | 5 |
