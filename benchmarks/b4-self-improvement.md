# B4: Self-Improvement Sprint

**Difficulty:** Hard
**Tasks:** 20
**Parallelism:** Full (5-way parallel in each of 4 waves)
**Time limit:** 45 minutes
**What it tests:** Can the colony introspect on the Mitosis platform, identify real improvements, implement them, test them, and deploy them to the shared drive — effectively improving itself?

---

## Concept

This is the hardest benchmark. The colony must:
1. Audit its own runtime environment and tools
2. Identify real bugs, inefficiencies, or missing features
3. Write actual code to fix/improve them
4. Test the code
5. Deploy improvements to the shared drive for other agents to adopt

This is recursive self-improvement: agents using the platform to make the platform better.

## Dependency Graph

```
KICKOFF → Leader
  │
  │  WAVE 1: Audit (5 parallel, each audits a different subsystem)
  ├─ T1: Audit task dispatcher      (w1) ──┐
  ├─ T2: Audit mi CLI               (w2) ──┤
  ├─ T3: Audit shared drive usage    (w3) ──┤── T6: Prioritized backlog
  ├─ T4: Audit agent communication  (w4) ──┤
  ├─ T5: Audit workspace templates   (w5) ──┘
  │
  │  WAVE 2: Design (5 parallel, each designs a fix from the backlog)
  ├─ T6: Prioritize & assign fixes  (leader, depends T1-T5) ──┐
  ├─ T7: Design fix 1               (w1, depends T6) ──┐      │
  ├─ T8: Design fix 2               (w2, depends T6) ──┤      │
  ├─ T9: Design fix 3               (w3, depends T6) ──┤── WAVE 3
  ├─ T10: Design fix 4              (w4, depends T6) ──┤
  ├─ T11: Design fix 5              (w5, depends T6) ──┘
  │
  │  WAVE 3: Implement (5 parallel, each implements their design)
  ├─ T12: Implement fix 1           (w1, depends T7) ──┐
  ├─ T13: Implement fix 2           (w2, depends T8) ──┤
  ├─ T14: Implement fix 3           (w3, depends T9) ──┤── WAVE 4
  ├─ T15: Implement fix 4           (w4, depends T10)──┤
  ├─ T16: Implement fix 5           (w5, depends T11)──┘
  │
  │  WAVE 4: Test & Deploy (cross-review + deploy)
  ├─ T17: Test fixes 1+2            (w3, depends T12+T13) ──┐
  ├─ T18: Test fixes 3+4            (w1, depends T14+T15) ──┤── T20
  ├─ T19: Test fix 5 + deploy all   (w4, depends T16+T17+T18)
  │                                                          │
  └─ T20: IMPROVEMENT-REPORT.md     (leader, depends T19) ──┘
```

## Kickoff Prompt

```
You are the colony leader running Benchmark B4: Self-Improvement Sprint.

Your colony must audit its own tools, find real issues, implement fixes, test them, and deploy to the shared drive. This is recursive self-improvement.

Create /shared/files/improvements/ first. All files go there.

WAVE 1 — Audit (parallel, each agent audits a different subsystem):
- T1 (w1): "Audit Task Dispatcher" — read ~/.openclaw/scripts/task-dispatcher.sh. Find: bugs, inefficiencies, missing error handling, hardcoded values, race conditions. Write /shared/files/improvements/audit-dispatcher.md with specific line numbers and severity (critical/medium/low).
- T2 (w2): "Audit mi CLI" — run `mi --help`, try each subcommand, find: missing commands, wrong help text, error handling gaps, UX issues. Write /shared/files/improvements/audit-cli.md.
- T3 (w3): "Audit Shared Drive Patterns" — analyze how files in /shared/files/ are organized. Find: naming inconsistencies, missing directories, files that should be structured (JSON/YAML) but aren't, missing README. Write /shared/files/improvements/audit-shared-drive.md.
- T4 (w4): "Audit Agent Communication" — test `tq send`, `tq inbox`, `tq agents`, `tq standup`. Find: message delivery gaps, missing features (threading? reactions? read receipts?), error handling. Write /shared/files/improvements/audit-communication.md.
- T5 (w5): "Audit Workspace Templates" — read ~/workspace/*.md. Find: stale information, missing sections, inconsistencies between templates, outdated CLI references. Write /shared/files/improvements/audit-templates.md.

WAVE 2 — Prioritize and design (leader picks top 5, workers design):
- T6 (leader, depends T1+T2+T3+T4+T5): Read all 5 audit reports. Pick the TOP 5 most impactful improvements (mix of quick wins and important fixes). Write /shared/files/improvements/backlog.md with: title, description, assigned worker, acceptance criteria. Assign one fix to each worker.
- T7 (w1, depends T6): Read backlog.md, find your assigned fix. Write a design doc: what to change, where, why, how to test. Write /shared/files/improvements/design-fix-1.md.
- T8 (w2, depends T6): Design your assigned fix. Write /shared/files/improvements/design-fix-2.md.
- T9 (w3, depends T6): Design your assigned fix. Write /shared/files/improvements/design-fix-3.md.
- T10 (w4, depends T6): Design your assigned fix. Write /shared/files/improvements/design-fix-4.md.
- T11 (w5, depends T6): Design your assigned fix. Write /shared/files/improvements/design-fix-5.md.

WAVE 3 — Implement (parallel, each builds their fix):
- T12 (w1, depends T7): Implement fix 1. Write the actual code/script/config. Deploy to /shared/files/improvements/fixes/fix-1/. Include a README.md explaining how to install.
- T13 (w2, depends T8): Implement fix 2 → /shared/files/improvements/fixes/fix-2/.
- T14 (w3, depends T9): Implement fix 3 → /shared/files/improvements/fixes/fix-3/.
- T15 (w4, depends T10): Implement fix 4 → /shared/files/improvements/fixes/fix-4/.
- T16 (w5, depends T11): Implement fix 5 → /shared/files/improvements/fixes/fix-5/.

WAVE 4 — Test, deploy, report (cross-review: testers didn't write the code):
- T17 (w3, depends T12+T13): Test fixes 1 and 2. Run the code, check it works, verify acceptance criteria from backlog.md. Write /shared/files/improvements/test-results-1-2.md (pass/fail for each criterion).
- T18 (w1, depends T14+T15): Test fixes 3 and 4 → /shared/files/improvements/test-results-3-4.md.
- T19 (w4, depends T16+T17+T18): Test fix 5. Then copy all PASSING fixes to /shared/files/_office-scripts/ (the persistent shared scripts directory). Write /shared/files/improvements/deployment.md listing what was deployed.
- T20 (leader, depends T19): Read all test results and deployment.md. Write /shared/files/improvements/IMPROVEMENT-REPORT.md: what was found, what was fixed, what was deployed, what's still open. Grade each fix 1-10.

Create all 20 tasks with correct dependencies. Start now.
```

## Scoring (100 points)

### Wave 1: Audit Quality (20 points)
| Criterion | Points |
|-----------|--------|
| Each of 5 audit files exists, >400 words | 2 each (10) |
| At least 3 audits cite specific line numbers or commands | 5 |
| At least 1 audit finds a real bug (verifiable) | 5 |

### Wave 2: Prioritization & Design (15 points)
| Criterion | Points |
|-----------|--------|
| backlog.md lists 5 fixes with acceptance criteria | 5 |
| Each of 5 design docs exists | 2 each (10) |

### Wave 3: Implementation (25 points)
| Criterion | Points |
|-----------|--------|
| Each fix directory exists with at least 1 file | 3 each (15) |
| At least 3 fixes contain runnable code (not just docs) | 5 |
| At least 1 fix includes a README.md with install instructions | 5 |

### Wave 4: Testing & Deployment (20 points)
| Criterion | Points |
|-----------|--------|
| test-results-1-2.md has pass/fail for each acceptance criterion | 5 |
| test-results-3-4.md has pass/fail for each acceptance criterion | 5 |
| deployment.md lists what was deployed to _office-scripts | 5 |
| At least 1 file actually exists in /shared/files/_office-scripts/ | 5 |

### Colony Behavior (20 points)
| Criterion | Points |
|-----------|--------|
| All 20 tasks created with correct dependencies | 4 |
| No agent tested their own code (cross-assignment) | 4 |
| 4 dependency waves executed in order | 4 |
| Leader wrote backlog AND final report | 4 |
| At least 1 failed task retried or reassigned | 4 |
