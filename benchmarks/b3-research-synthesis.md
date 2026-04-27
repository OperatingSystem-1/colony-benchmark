# B3: Research Synthesis

**Difficulty:** Medium-Hard
**Tasks:** 18
**Parallelism:** High (5-way parallel per wave)
**Time limit:** 30 minutes
**What it tests:** Can the colony research a complex topic from multiple angles, cross-validate findings, resolve contradictions, and produce a coherent synthesis that no single agent could write?

---

## Concept

The colony researches "the economics of AI agent compute" from 5 independent angles, then must cross-reference, find contradictions, and synthesize. The final report must cite specific data points from each researcher's work — proving agents actually read each other's output, not just summarized from base knowledge.

## Dependency Graph

```
KICKOFF → Leader
  │
  │  WAVE 1: Independent research (5 parallel)
  ├─ T1: Compute cost models        (w1) ──┐
  ├─ T2: Token economics            (w2) ──┤
  ├─ T3: Infrastructure comparison  (w3) ──┤── WAVE 2
  ├─ T4: Market pricing analysis    (w4) ──┤
  ├─ T5: Efficiency techniques      (w5) ──┘
  │
  │  WAVE 2: Cross-validation (5 parallel, each reads ALL Wave 1)
  ├─ T6: Validate cost models vs pricing  (w1, depends T1-T5) ──┐
  ├─ T7: Validate tokens vs efficiency    (w2, depends T1-T5) ──┤
  ├─ T8: Find contradictions              (w3, depends T1-T5) ──┤── WAVE 3
  ├─ T9: Fact-check with calculations     (w4, depends T1-T5) ──┤
  ├─ T10: Identify missing perspectives   (w5, depends T1-T5) ──┘
  │
  │  WAVE 3: Gap-filling (parallel, addresses Wave 2 gaps)
  ├─ T11: Address contradiction 1     (w1, depends T8) ──┐
  ├─ T12: Address contradiction 2     (w2, depends T8) ──┤
  ├─ T13: Fill missing perspective 1  (w3, depends T10)──┤── WAVE 4
  ├─ T14: Fill missing perspective 2  (w4, depends T10)──┤
  ├─ T15: Recalculate disputed numbers(w5, depends T9) ──┘
  │
  │  WAVE 4: Synthesis
  ├─ T16: Executive summary    (w1, depends T11-T15) ──┐
  ├─ T17: Data appendix        (w2, depends T11-T15) ──┤── T18
  │                                                     │
  └─ T18: RESEARCH-REPORT.md   (leader, depends T16+T17)
```

## Kickoff Prompt

```
You are the colony leader running Benchmark B3: Research Synthesis.

Topic: "The Economics of AI Agent Compute — What Does It Actually Cost to Run an Autonomous AI Colony?"

Your colony must research this from 5 angles, cross-validate, resolve contradictions, and synthesize. The final report must cite specific data from each researcher's work.

Create /shared/files/research/ first. All files go there.

WAVE 1 — Independent research (parallel, each agent works alone):
- T1 (w1): "Compute Cost Models" — research and calculate the actual $/hour cost of running an AI agent on different providers. Cover: Bedrock (Claude), Gemini, OpenAI Codex, self-hosted. Include input/output token costs, compute overhead (K8s pod, sidecar containers), and idle costs. Write /shared/files/research/cost-models.md (>800 words, with actual numbers).
- T2 (w2): "Token Economics" — analyze token consumption patterns for different agent workloads: chat (low), task execution (medium), code generation (high), research (very high). Estimate tokens/hour for each. Calculate cost implications. Write /shared/files/research/token-economics.md (>800 words).
- T3 (w3): "Infrastructure Comparison" — compare deployment options: K8s pods (current), serverless (Lambda/Cloud Run), VM-based (EC2), hybrid. For each: startup time, cost model, scaling behavior, persistence. Write /shared/files/research/infrastructure.md (>800 words).
- T4 (w4): "Market Pricing Analysis" — research how other AI agent platforms price their services. Cover: ChatGPT Teams, Claude Teams, Devin, GitHub Copilot Workspace, Replit Agent, any others you know. Compare $/seat/month vs $/token vs $/task pricing models. Write /shared/files/research/market-pricing.md (>800 words).
- T5 (w5): "Efficiency Techniques" — research techniques to reduce agent compute costs: model routing (use cheap models for simple tasks), caching, prompt compression, speculative execution, batch processing, sleep/wake cycles. Quantify savings where possible. Write /shared/files/research/efficiency.md (>800 words).

WAVE 2 — Cross-validation (each reads ALL 5 Wave 1 outputs):
- T6 (w1, depends T1+T2+T3+T4+T5): Read all 5 research files. Compare cost-models.md numbers against market-pricing.md. Do our calculated costs match market prices? Where do they diverge and why? Write /shared/files/research/validate-cost-vs-pricing.md (>400 words, must cite specific numbers from both files).
- T7 (w2, depends T1+T2+T3+T4+T5): Compare token-economics.md projections against efficiency.md savings claims. Are the efficiency claims realistic given actual token volumes? Write /shared/files/research/validate-tokens-vs-efficiency.md (>400 words).
- T8 (w3, depends T1+T2+T3+T4+T5): Read all 5 files. Find contradictions — where do two researchers disagree on a number or claim? List each contradiction with the specific quotes. Write /shared/files/research/contradictions.md (>400 words).
- T9 (w4, depends T1+T2+T3+T4+T5): Fact-check by running actual calculations. Pick 3 specific claims from the research and verify with math. Write /shared/files/research/fact-check.md (>400 words, must show calculations).
- T10 (w5, depends T1+T2+T3+T4+T5): What perspectives are missing? What questions did nobody address? Write /shared/files/research/missing-perspectives.md (>400 words).

WAVE 3 — Gap-filling (address Wave 2 findings):
- T11 (w1, depends T8): Read contradictions.md. Pick the most important contradiction and resolve it with additional research/calculation. Write /shared/files/research/resolved-1.md.
- T12 (w2, depends T8): Pick the second contradiction and resolve it. Write /shared/files/research/resolved-2.md.
- T13 (w3, depends T10): Read missing-perspectives.md. Address the most important gap. Write /shared/files/research/gap-filled-1.md.
- T14 (w4, depends T10): Address the second gap. Write /shared/files/research/gap-filled-2.md.
- T15 (w5, depends T9): Read fact-check.md. Recalculate any numbers that were found incorrect. Write /shared/files/research/recalculated.md.

WAVE 4 — Final synthesis:
- T16 (w1, depends T11+T12+T13+T14+T15): Write a 1-page executive summary of the entire research. Must cite specific findings from ≥3 different workers' outputs. Write /shared/files/research/executive-summary.md.
- T17 (w2, depends T11+T12+T13+T14+T15): Compile all numbers into a structured data appendix. Write /shared/files/research/data-appendix.md.
- T18 (leader, depends T16+T17): Read executive-summary.md and data-appendix.md. Write the final /shared/files/research/RESEARCH-REPORT.md (>1000 words) with: key findings, methodology, limitations, and recommendations. Grade each researcher's contribution 1-10.

Create all 18 tasks with correct dependencies. Start now.
```

## Scoring (100 points)

### Wave 1: Research Quality (25 points)
| Criterion | Points |
|-----------|--------|
| Each of 5 files exists, >800 words, contains numbers/data | 5 each |

### Wave 2: Cross-Validation (25 points)
| Criterion | Points |
|-----------|--------|
| Each of 5 validation files exists, >400 words | 3 each |
| At least 3 validation files cite specific numbers from Wave 1 | 10 |

### Wave 3: Gap Resolution (15 points)
| Criterion | Points |
|-----------|--------|
| Each of 5 resolution files exists | 3 each |

### Wave 4: Synthesis (15 points)
| Criterion | Points |
|-----------|--------|
| executive-summary.md cites ≥3 different researchers | 5 |
| data-appendix.md has structured numerical data | 5 |
| RESEARCH-REPORT.md exists, >1000 words | 5 |

### Colony Behavior (20 points)
| Criterion | Points |
|-----------|--------|
| All 18 tasks created with dependencies | 4 |
| 4 distinct dependency waves (checked via timing) | 4 |
| Wave 1 ran in parallel (5 tasks started within 60s) | 4 |
| Leader graded contributions in final report | 4 |
| At least 1 retry on failure | 4 |
