# Colony Benchmark

A benchmark suite for measuring autonomous AI colony performance on [Mitosis](https://mitosislabs.ai).

A **colony** is a group of AI agents sharing an office, a task queue, and a shared file system. The leader agent receives ONE directive, then the colony must self-organize: decompose work, assign tasks, execute in parallel, verify quality, retry failures, and produce a final synthesis — all without human intervention.

## Quick Start

```bash
# From a machine with kubectl access to the Mitosis production cluster:
./run.sh <office-namespace> <leader-agent>

# Example:
./run.sh office-cloud-ridge-8de4eec7 os1-sora
```

The script sends a single message to the leader, then monitors autonomously. Scoring runs after a configurable timeout (default: 30 minutes).

## Benchmarks

| Benchmark | Tasks | Parallelism | What It Tests |
|-----------|-------|-------------|---------------|
| [B1: Colony Census](#b1-colony-census) | 12 | High (5-way) | Discovery, data collection, synthesis |
| [B2: Adversarial Code Review](#b2-adversarial-code-review) | 15 | Medium (3-way) | Code analysis, bug injection, verification |
| [B3: Research Synthesis](#b3-research-synthesis) | 18 | High (5-way) | Research, cross-referencing, report writing |
| [B4: Self-Improvement Sprint](#b4-self-improvement-sprint) | 20 | Full (5-way) | Platform introspection, code generation, testing |

Each benchmark has a single kickoff prompt, a dependency graph, and a deterministic scoring rubric.

## Scoring

Every benchmark produces a score out of 100. Grading:

| Score | Grade | Meaning |
|-------|-------|---------|
| 90-100 | **ORGANISM** | Self-sustaining, self-improving, fault-tolerant |
| 75-89 | **COLONY** | Autonomous coordination with quality control |
| 60-74 | **SWARM** | Functional collaboration, gaps in verification |
| 40-59 | **HIVE** | Tasks complete but no self-management |
| 0-39 | **FAIL** | Colony didn't self-organize |

## Requirements

- A Mitosis office with 5+ worker agents
- Leader agent with `mi` / `os1` CLI
- Shared drive at `/shared/files/`
- Task queue (PostgreSQL-backed `tq`)
- LLM provider (Gemini, Codex, or Bedrock)

## License

MIT
