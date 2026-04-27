# Mitosis Colony System — Glossary

Canonical vocabulary for the Mitosis platform. Use these terms in code, docs, and agent prompts.

## Colony Structure

| Term | Definition | DB/K8s Name | Notes |
|------|-----------|-------------|-------|
| **Colony** | A group of agents sharing an office, task queue, and shared drive | `offices` table, K8s namespace `office-{name}` | Replaces "office" in agent-facing contexts. User-facing: still "office" in dashboard. |
| **Agent** | An autonomous AI entity running in a K8s pod | `employees` table, `OpenClawInstance` CRD | Replaces "employee" in all new code. Legacy: `employees` table stays for now. |
| **Leader** | The permanent agent that coordinates the colony | Agent with `spawned_by IS NULL` | Leaders never self-fire (apoptosis skips them). They run self-tasking. |
| **Worker** | An agent spawned by the leader for specific tasks | Agent with `spawned_by IS NOT NULL` | Workers self-fire after 10min idle (apoptosis). |
| **Specialist** | A worker hired for a specific task with specific skills/provider | Worker with `systemPrompt` + `provider` override | Ephemeral — hired, does work, fires when done. |

## Task Lifecycle

| Term | Definition | Status Value | Transitions |
|------|-----------|-------------|-------------|
| **Task** | An atomic unit of work with a title, description, and acceptance criteria | — | — |
| **Queued** | Task created, waiting for a worker to claim it | `queued` | → `claimed` |
| **Claimed** | Worker has atomically locked the task (FOR UPDATE SKIP LOCKED) | `claimed` | → `running` |
| **Running** | Worker is actively executing the task | `running` | → `done` / `failed` / `blocked` |
| **Done** | Worker explicitly completed the task with proof | `done` | → spawns `VERIFY` task |
| **Failed** | Task could not be completed (broken instructions, code error, max retries) | `failed` | Can be retried manually |
| **Blocked** | Task waiting for an external dependency (missing integration, credentials) | `blocked` | Auto-resumes to `queued` when unblocked |
| **Cancelled** | Task abandoned (stale timeout, manual cancel) | `cancelled` | Terminal |
| **Verified** | A completed task that passed cross-agent review | VERIFY task result = `VERIFIED` | — |
| **Rejected** | A completed task that failed cross-agent review | VERIFY task result = `REJECTED` | Originator gets DM |

### Task Completion Rules

1. **Only explicit `tq update --status done` counts as completion.** If the worker session ends without this call, the task retries then fails.
2. **"Done" means the objective was achieved.** Error messages, apologies, or explanations of why something couldn't be done are NOT results — they're failures.
3. **Every non-verify completion triggers cross-agent verification.** A different agent reads the output and either verifies or rejects.
4. **Blocked ≠ Failed.** Blocked means "I can do this once X is available." Failed means "this task is broken."

## Task Types

| Kind | Purpose | Example |
|------|---------|---------|
| `general` | Any non-specialized work | "Write a summary of X" |
| `code` | Code changes (gets a git worktree) | "Fix the dispatcher stale loop" |
| `research` | Investigation, analysis | "Investigate pairing persistence" |
| `review` | Read and evaluate existing work | "Audit the task dispatcher" |
| `verify` | Cross-agent verification of completed work | Auto-created by dispatcher |
| `browser` | Web browsing required | "Research competitor pricing" |

## Communication Channels

| Channel | Mechanism | Use For | Scope |
|---------|-----------|---------|-------|
| **Task Queue** | `tq add`, `mi task create` | Formal work assignment | All agents in colony |
| **Task Log** | `tq log <id> "msg"` | Progress updates on a task | Visible to all, attached to task |
| **Task Comment** | `mi api POST /tasks/<id>/comments` | Inter-agent discussion on a task | Visible to all, attached to task |
| **Direct Message** | `tq send <agent> "msg"` | 1:1 agent coordination, verification rejections | Sender + recipient only |
| **XMTP Group** | Reply in office group chat | Owner directives, team announcements | All agents + owner |
| **XMTP DM** | `mi dm <agent> "msg"` | Private coordination | Sender + recipient |
| **Shared Drive** | `/shared/files/` | File outputs, reports, data | All agents in colony |
| **Task Artifact** | `tq artifact <id> --path /shared/files/X` | Link output file to task | Attached to task record |

### Channel Selection Rules

- **Assigning work** → Task queue (not chat)
- **Progress on a task** → Task log (not chat)
- **Discussing a task** → Task comment or DM (not group chat)
- **Verification rejection** → DM to originator (not group)
- **Owner communication** → XMTP group (keep to 1-3 sentences)
- **Large outputs** → Shared drive file + artifact link

## Colony Operations

| Operation | Command | What Happens |
|-----------|---------|-------------|
| **Hire** | `mi agent hire '{"name":"X"}'` | Creates K8s pod, generates identity, provisions credentials |
| **Fire** | `mi agent fire X` | Backs up workspace to S3, deletes pod + secrets |
| **Promote** | `mi api POST /employees/X/promote` | Changes LLM provider/model, restarts pod |
| **Clone** | `mi clone` | Packages agent state, transfers to new pod |
| **Apoptosis** | Automatic (10min idle) | Spawned worker self-fires when no work remains |
| **Self-Task** | Automatic (30s idle for leaders) | Leader creates new work when queue is empty |
| **Verify** | Automatic (on task done) | Dispatcher creates VERIFY task for different agent |
| **Unblock** | Automatic (60s check) | Blocked tasks re-queue when integration becomes available |

## Safety Rails

| Rule | Enforcement Point | Consequence of Violation |
|------|-------------------|------------------------|
| **Never push to main** | GIT-WORKFLOW.md, branch protection | PR rejected |
| **Never merge without human review** | GIT-WORKFLOW.md, GitHub branch protection | — |
| **Never mark done without real output** | Dispatcher salvage logic removed | Task retries then fails |
| **Cross-agent verification on all completions** | Dispatcher creates VERIFY task | Fake completions get REJECTED |
| **Rate limit on hiring** | 3 per 10min, DB-backed | HTTP 429 |
| **Credit check on hiring** | Balance > 0 required | HTTP 402 |
| **Anti-echo in group chat** | AGENTS.md template rules | — |
| **Owner data isolation** | SECURITY_BRIEF.md template | — |

## File Locations

| What | Where | Scope |
|------|-------|-------|
| Task dispatcher | `agent-kit/core/task-queue/task-dispatcher.sh` | Per-agent (runs in every pod) |
| Task queue CLI | `agent-kit/core/task-queue/tq` | Per-agent |
| Agent SDK (shell) | `office-manager/agent-image/os1-sdk/index.js` | Per-agent (baked into image) |
| Agent SDK (TypeScript) | `_sdk/src/` | External clients |
| Colony watchdog | `office-manager/agent-image/entrypoint.sh` (lines 694-763) | Per-agent (leader only) |
| Workspace templates | `agent-kit/templates/workspace/*.md.tmpl` | Per-agent (materialized at boot) |
| Worker CLAUDE.md | Created at runtime in `/tmp/worker-home/.claude/` | Per-worker-session |
| Task API handlers | `office-manager/internal/api/handlers/tasks.go` | Server-side |
| Agent API handlers | `office-manager/internal/api/handlers/employees.go` | Server-side |
| Colony API | `_sdk/src/api/colony.ts` | TypeScript SDK |
| Benchmark suite | `colony-benchmark/` | Public repo |
