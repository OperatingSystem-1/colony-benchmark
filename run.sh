#!/bin/bash
# Colony Benchmark Runner
# Usage: ./run.sh <namespace> <leader> [benchmark] [timeout_minutes]
#
# Example: ./run.sh office-cloud-ridge-8de4eec7 os1-sora b1 15
set -euo pipefail

CLUSTER="${CLUSTER:?Set CLUSTER to your EKS cluster ARN}"
NS="${1:?Usage: ./run.sh <namespace> <leader> [benchmark] [timeout_minutes]}"
LEADER="${2:?Usage: ./run.sh <namespace> <leader> [benchmark] [timeout_minutes]}"
BENCHMARK="${3:-b1}"
TIMEOUT_MIN="${4:-30}"

KC="kubectl --context $CLUSTER -n $NS"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

log() { echo "[$(date -u +%H:%M:%S)] $*"; }

# ── Load benchmark prompt ──────────────────────────────────────────
BENCH_FILE="$SCRIPT_DIR/benchmarks/${BENCHMARK}-*.md"
BENCH_FILE=$(ls $BENCH_FILE 2>/dev/null | head -1)
if [ -z "$BENCH_FILE" ]; then
    echo "ERROR: Unknown benchmark '$BENCHMARK'. Available:"
    ls "$SCRIPT_DIR/benchmarks/" | sed 's/\.md$//' | sed 's/^/  /'
    exit 1
fi

# Extract kickoff prompt — content between "## Kickoff Prompt" and "## Scoring"
KICKOFF=$(awk '/^## Kickoff Prompt/{found=1;next} /^## Scoring/{found=0} found' "$BENCH_FILE" | grep -v '^```')
if [ -z "$KICKOFF" ]; then
    echo "ERROR: Could not extract kickoff prompt from $BENCH_FILE"
    exit 1
fi

# ── Pre-flight ─────────────────────────────────────────────────────
log "=== Colony Benchmark: $(basename "$BENCH_FILE" .md) ==="
log "Namespace: $NS"
log "Leader: $LEADER"
log "Timeout: ${TIMEOUT_MIN}min"
log ""

# Check leader is running
LEADER_STATUS=$($KC get pod ${LEADER}-0 -o jsonpath='{.status.phase}' 2>/dev/null || echo "NotFound")
if [ "$LEADER_STATUS" != "Running" ]; then
    log "ERROR: Leader ${LEADER}-0 is $LEADER_STATUS"
    exit 1
fi
log "Leader ${LEADER}-0: Running"

# Count ready workers
WORKERS=$($KC get openclawinstances -o jsonpath='{range .items[*]}{.metadata.name} {.status.phase}{"\n"}{end}' 2>/dev/null | grep Running | grep -v "$LEADER" | wc -l | tr -d ' ')
log "Workers ready: $WORKERS"

if [ "$WORKERS" -lt 3 ]; then
    log "WARNING: Only $WORKERS workers ready (recommend 5)"
fi

# ── Send ONE kickoff ───────────────────────────────────────────────
log ""
log "Sending kickoff to $LEADER..."
START_TIME=$(date +%s)

$KC exec ${LEADER}-0 -c openclaw -- openclaw agent \
    --local \
    --session-id "benchmark-${BENCHMARK}-$(date +%s)" \
    --message "$KICKOFF" \
    2>&1 | tail -20

log ""
log "Kickoff sent. Monitoring autonomously for ${TIMEOUT_MIN} minutes..."
log "NO FURTHER INTERVENTION. Colony must self-organize."
log ""

# ── Monitor (passive, no intervention) ─────────────────────────────
END_TIME=$((START_TIME + TIMEOUT_MIN * 60))

while [ "$(date +%s)" -lt "$END_TIME" ]; do
    REMAINING=$(( (END_TIME - $(date +%s)) / 60 ))

    echo ""
    log "──── T+$((( $(date +%s) - START_TIME ) / 60))min (${REMAINING}min remaining) ────"

    # Task summary
    $KC exec office-postgres-0 -- psql -h localhost -p 5433 -U tq_admin -d tq -t -c \
        "SELECT status || ': ' || count(*) FROM tq_tasks
         WHERE created_at > NOW() - INTERVAL '${TIMEOUT_MIN} minutes'
         GROUP BY status ORDER BY status;" 2>/dev/null || true

    # File count in benchmark dir
    BENCH_DIR=$(echo "$KICKOFF" | grep -o '/shared/files/[a-z_-]*/' | head -1)
    if [ -n "$BENCH_DIR" ]; then
        FILE_COUNT=$($KC exec ${LEADER}-0 -c openclaw -- sh -c \
            "find ${BENCH_DIR} -type f 2>/dev/null | wc -l" 2>/dev/null || echo "0")
        log "Files in ${BENCH_DIR}: $FILE_COUNT"
    fi

    sleep 120
done

# ── Score ──────────────────────────────────────────────────────────
log ""
log "=== Time's up. Scoring... ==="
log ""

if [ -f "$SCRIPT_DIR/scorer/${BENCHMARK}.sh" ]; then
    bash "$SCRIPT_DIR/scorer/${BENCHMARK}.sh" "$NS" "$LEADER"
else
    log "No scorer found for $BENCHMARK. Manual scoring required."
    log "Check: $BENCH_FILE for scoring rubric."
fi
