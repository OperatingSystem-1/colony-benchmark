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

Your colony must discover and document everything about itself. Create these 12 tasks using `mi task create` with assignedAgent and dependsOn where shown:

WAVE 1 (parallel, no dependencies):
- T1 (w1): "Agent Inventory" — run `mi agent list`, document each agent's name, provider, model, status, skills. Write JSON to /shared/files/census/agents.json
- T2 (w2): "Integration Inventory" — run `mi integrations list` AND `mi integrations my`, document all integrations with status. Write JSON to /shared/files/census/integrations.json
- T3 (w3): "Task Queue Analysis" — query tq_tasks table: count by status, avg completion time, failure rate, most active agents. Write JSON to /shared/files/census/tasks.json
- T4 (w4): "Shared Drive Audit" — list all files in /shared/files/ recursively with sizes, identify stale files (>7 days), categorize by type. Write JSON to /shared/files/census/files.json
- T5 (w5): "Credit & Usage Report" — run `mi credits`, check resource usage, estimate burn rate. Write JSON to /shared/files/census/credits.json

WAVE 2 (depends on all of Wave 1 completing):
- T6 (w1, depends on T1+T2+T3+T4+T5): "Cross-Reference Report" — read ALL 5 JSON files from Wave 1. Find: agents without integrations, integrations nobody uses, tasks with no agent, orphaned files. Write /shared/files/census/cross-reference.md
- T7 (w2, depends on T6): "Capability Gaps" — from cross-reference, list what the colony CAN'T do yet and which integrations would fix it. Write /shared/files/census/capability-gaps.md
- T8 (w3, depends on T6): "Security Audit" — check for exposed secrets, overly permissive access, agents with unnecessary integrations. Write /shared/files/census/security-audit.md
- T9 (w4, depends on T6): "Communication Map" — document how agents communicate (XMTP, tq send, shared files). Draw the message flow. Write /shared/files/census/communication-map.md
- T10 (w5, depends on T6): "Efficiency Score" — calculate colony efficiency: task completion rate, avg time per task, credit cost per task, idle time. Write /shared/files/census/efficiency.md

WAVE 3 (synthesis):
- T11 (w4, depends on T7+T8+T9+T10): "Colony Health Card" — read all Wave 2 outputs. Produce a single health score (0-100) with breakdown. Write /shared/files/census/health-card.md
- T12 (leader, depends on T11): "CENSUS-REPORT.md" — read health card + all outputs. Write executive summary with top 3 strengths, top 3 weaknesses, and recommended actions. Write /shared/files/census/CENSUS-REPORT.md

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
