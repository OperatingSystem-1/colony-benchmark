# B1: Colony Census

**Difficulty:** Easy
**Tasks:** 12
**Parallelism:** High (5-way parallel, then merge)
**Time limit:** 15 minutes
**What it tests:** Can the colony discover its own environment, collect structured data in parallel, and synthesize it?

---

## Dependency Graph

```
KICKOFF → Leader
  │
  ├─ T1: Agent inventory       (w1) ──┐
  ├─ T2: Integration inventory  (w2) ──┤
  ├─ T3: Task queue analysis    (w3) ──┤── T6: Cross-reference report (w1)
  ├─ T4: Shared drive audit     (w4) ──┤        │
  ├─ T5: Credit & usage report  (w5) ──┘        │
  │                                              │
  ├─ T7: Capability gaps        (w2, depends T6)─┤
  ├─ T8: Security audit         (w3, depends T6)─┤── T11: Colony health card (w4)
  ├─ T9: Communication map      (w4, depends T6)─┤        │
  ├─ T10: Efficiency score      (w5, depends T6)─┘        │
  │                                                        │
  └─ T12: CENSUS-REPORT.md      (leader, depends T11) ────┘
```

## Kickoff Prompt

```
You are the colony leader running Benchmark B1: Colony Census.

FIRST: Run `mi agent list` to discover your available workers. Assign tasks to REAL agents that are currently online — do NOT use hardcoded names.

Your colony must discover and document everything about itself. Create 12 tasks using `mi task create` with assignedAgent (use real agent names from mi agent list) and dependsOn where shown. Distribute Wave 1 tasks evenly across available workers.

WAVE 1 (parallel, no dependencies — assign each to a different worker):
- "Agent Inventory" — run `mi agent list`, document each agent. Write JSON to /shared/files/census/agents.json
- "Integration Inventory" — run `mi integrations list` AND `mi integrations my`, document all. Write JSON to /shared/files/census/integrations.json
- "Task Queue Analysis" — query task stats: count by status, avg completion time, failure rate. Write JSON to /shared/files/census/tasks.json
- "Shared Drive Audit" — list all files in /shared/files/ with sizes, identify stale files. Write JSON to /shared/files/census/files.json
- "Credit & Usage Report" — run `mi credits`, estimate burn rate. Write JSON to /shared/files/census/credits.json

WAVE 2 (each depends on ALL Wave 1 tasks — use dependsOn with comma-separated task IDs):
- "Cross-Reference Report" — read ALL 5 JSON files from Wave 1. Find gaps. Write /shared/files/census/cross-reference.md
- "Capability Gaps" — what the colony CAN'T do yet. Write /shared/files/census/capability-gaps.md
- "Security Audit" — check for exposed secrets, overly permissive access. Write /shared/files/census/security-audit.md
- "Communication Map" — how agents communicate (XMTP, tq send, shared files). Write /shared/files/census/communication-map.md
- "Efficiency Score" — task completion rate, avg time, credit cost per task. Write /shared/files/census/efficiency.md

WAVE 3 (synthesis):
- "Colony Health Card" (depends on all Wave 2) — single health score (0-100). Write /shared/files/census/health-card.md
- "CENSUS-REPORT.md" (depends on Health Card) — executive summary. Write /shared/files/census/CENSUS-REPORT.md. Assign to yourself.

Create /shared/files/census/ directory first. All outputs MUST be in /shared/files/census/. Start now.
```

## Scoring (100 points)

### Wave 1: Data Collection (30 points)
| Criterion | Points |
|-----------|--------|
| agents.json exists and has ≥5 entries | 6 |
| integrations.json exists and has ≥10 entries | 6 |
| tasks.json exists with status counts | 6 |
| files.json exists with file listing | 6 |
| credits.json exists with balance | 6 |

### Wave 2: Analysis (30 points)
| Criterion | Points |
|-----------|--------|
| cross-reference.md exists, >300 words, references Wave 1 data | 6 |
| capability-gaps.md lists ≥3 specific gaps | 6 |
| security-audit.md checks ≥3 categories | 6 |
| communication-map.md documents ≥2 channels | 6 |
| efficiency.md calculates ≥2 metrics | 6 |

### Wave 3: Synthesis (20 points)
| Criterion | Points |
|-----------|--------|
| health-card.md has a numeric score | 10 |
| CENSUS-REPORT.md exists, >500 words | 10 |

### Colony Behavior (20 points)
| Criterion | Points |
|-----------|--------|
| All 12 tasks created with correct assignedAgent | 4 |
| Dependencies set correctly (Wave 2 depends on Wave 1) | 4 |
| Wave 1 tasks ran in parallel (started within 60s of each other) | 4 |
| Leader evaluated quality in CENSUS-REPORT.md | 4 |
| ≥1 failed task was retried autonomously | 4 |
