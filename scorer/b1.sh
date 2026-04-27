#!/bin/bash
# B1: Colony Census — Scorer
set -euo pipefail

CLUSTER="${CLUSTER:-arn:aws:eks:us-east-2:856898221895:cluster/os1-production}"
NS="${1:?namespace required}"
LEADER="${2:?leader required}"
KC="kubectl --context $CLUSTER -n $NS"
DIR="/shared/files/census"
TOTAL=0

score() { local pts=$1; TOTAL=$((TOTAL + pts)); echo "    +$pts"; }
miss()  { echo "    +0 (missing)"; }

file_words() {
    $KC exec ${LEADER}-0 -c openclaw -- wc -w "$1" 2>/dev/null | awk '{print $1}' || echo "0"
}

file_exists() {
    $KC exec ${LEADER}-0 -c openclaw -- test -f "$1" 2>/dev/null && echo "1" || echo "0"
}

json_entries() {
    $KC exec ${LEADER}-0 -c openclaw -- python3 -c "
import json, sys
try:
    d = json.load(open('$1'))
    if isinstance(d, list): print(len(d))
    elif isinstance(d, dict): print(len(d))
    else: print(0)
except: print(0)
" 2>/dev/null || echo "0"
}

echo "═══════════════════════════════════════════"
echo "  B1: Colony Census — Scoring"
echo "═══════════════════════════════════════════"
echo ""

# ── Wave 1: Data Collection (30 points) ──
echo "── WAVE 1: Data Collection (30 pts) ──"

for pair in "agents.json:5" "integrations.json:10" "tasks.json:0" "files.json:0" "credits.json:0"; do
    FILE="${pair%%:*}"
    MIN_ENTRIES="${pair##*:}"
    E=$(file_exists "$DIR/$FILE")
    if [ "$E" = "1" ]; then
        ENTRIES=$(json_entries "$DIR/$FILE")
        if [ "$MIN_ENTRIES" -gt 0 ] && [ "${ENTRIES:-0}" -ge "$MIN_ENTRIES" ] 2>/dev/null; then
            echo "  ✓ $FILE ($ENTRIES entries, need ≥$MIN_ENTRIES)"; score 6
        elif [ "$MIN_ENTRIES" -eq 0 ]; then
            echo "  ✓ $FILE exists"; score 6
        else
            echo "  ~ $FILE exists but only $ENTRIES entries (need ≥$MIN_ENTRIES)"; score 3
        fi
    else
        echo "  ✗ $FILE"; miss
    fi
done

# ── Wave 2: Analysis (30 points) ──
echo ""
echo "── WAVE 2: Analysis (30 pts) ──"

for FILE in cross-reference.md capability-gaps.md security-audit.md communication-map.md efficiency.md; do
    E=$(file_exists "$DIR/$FILE")
    if [ "$E" = "1" ]; then
        W=$(file_words "$DIR/$FILE")
        if [ "${W:-0}" -ge 300 ] 2>/dev/null; then
            echo "  ✓ $FILE ($W words)"; score 6
        else
            echo "  ~ $FILE ($W words, want ≥300)"; score 3
        fi
    else
        echo "  ✗ $FILE"; miss
    fi
done

# ── Wave 3: Synthesis (20 points) ──
echo ""
echo "── WAVE 3: Synthesis (20 pts) ──"

E=$(file_exists "$DIR/health-card.md")
if [ "$E" = "1" ]; then
    HAS_SCORE=$($KC exec ${LEADER}-0 -c openclaw -- grep -cEi '[0-9]+\s*/\s*100|score.*[0-9]|health.*[0-9]' "$DIR/health-card.md" 2>/dev/null || echo "0")
    if [ "${HAS_SCORE:-0}" -ge 1 ]; then
        echo "  ✓ health-card.md (has numeric score)"; score 10
    else
        echo "  ~ health-card.md (exists but no numeric score)"; score 5
    fi
else
    echo "  ✗ health-card.md"; miss
fi

E=$(file_exists "$DIR/CENSUS-REPORT.md")
if [ "$E" = "1" ]; then
    W=$(file_words "$DIR/CENSUS-REPORT.md")
    if [ "${W:-0}" -ge 500 ] 2>/dev/null; then
        echo "  ✓ CENSUS-REPORT.md ($W words)"; score 10
    else
        echo "  ~ CENSUS-REPORT.md ($W words, want ≥500)"; score 5
    fi
else
    echo "  ✗ CENSUS-REPORT.md"; miss
fi

# ── Colony Behavior (20 points) ──
echo ""
echo "── COLONY BEHAVIOR (20 pts) ──"

TASK_COUNT=$($KC exec office-postgres-0 -- psql -h localhost -p 5433 -U tq_admin -d tq -qAtX -c \
    "SELECT count(*) FROM tq_tasks WHERE title LIKE '%Audit%' OR title LIKE '%Census%' OR title LIKE '%Inventory%' OR title LIKE '%Cross%' OR title LIKE '%Capability%' OR title LIKE '%Security%' OR title LIKE '%Communication%' OR title LIKE '%Efficiency%' OR title LIKE '%Health%'" 2>/dev/null || echo "0")
if [ "${TASK_COUNT:-0}" -ge 10 ]; then
    echo "  ✓ ≥10 benchmark tasks created"; score 4
else
    echo "  ~ Only $TASK_COUNT tasks found"; [ "${TASK_COUNT:-0}" -ge 5 ] && score 2
fi

ASSIGNED=$($KC exec office-postgres-0 -- psql -h localhost -p 5433 -U tq_admin -d tq -qAtX -c \
    "SELECT count(DISTINCT assigned_agent) FROM tq_tasks WHERE assigned_agent IS NOT NULL" 2>/dev/null || echo "0")
if [ "${ASSIGNED:-0}" -ge 5 ]; then
    echo "  ✓ Tasks distributed across ≥5 agents"; score 4
else
    echo "  ~ Only $ASSIGNED distinct agents assigned"; [ "${ASSIGNED:-0}" -ge 3 ] && score 2
fi

DEPS=$($KC exec office-postgres-0 -- psql -h localhost -p 5433 -U tq_admin -d tq -qAtX -c \
    "SELECT count(*) FROM tq_tasks WHERE depends_on IS NOT NULL AND depends_on != ''" 2>/dev/null || echo "0")
if [ "${DEPS:-0}" -ge 5 ]; then
    echo "  ✓ Dependencies set ($DEPS tasks)"; score 4
else
    echo "  ~ Only $DEPS dependencies"; [ "${DEPS:-0}" -ge 2 ] && score 2
fi

# Leader evaluation
E=$(file_exists "$DIR/CENSUS-REPORT.md")
if [ "$E" = "1" ]; then
    EVALS=$($KC exec ${LEADER}-0 -c openclaw -- grep -ci 'score\|grade\|quality\|rating\|/10' "$DIR/CENSUS-REPORT.md" 2>/dev/null || echo "0")
    if [ "${EVALS:-0}" -ge 3 ]; then
        echo "  ✓ Leader evaluated quality"; score 4
    else
        echo "  ~ Evaluation unclear ($EVALS mentions)"; [ "${EVALS:-0}" -ge 1 ] && score 2
    fi
else
    echo "  ✗ No report to check evaluation"; miss
fi

# Retry behavior
RETRIES=$($KC exec office-postgres-0 -- psql -h localhost -p 5433 -U tq_admin -d tq -qAtX -c \
    "SELECT count(*) FROM tq_tasks WHERE title LIKE '%retry%' OR title LIKE '%Retry%' OR retry_count > 0" 2>/dev/null || echo "0")
if [ "${RETRIES:-0}" -ge 1 ]; then
    echo "  ✓ Retry behavior observed"; score 4
else
    echo "  ✗ No retries observed"; miss
fi

# ── Final Score ──
echo ""
echo "═══════════════════════════════════════════"
echo "  TOTAL: $TOTAL / 100"
echo ""
if [ "$TOTAL" -ge 90 ]; then   echo "  ORGANISM"
elif [ "$TOTAL" -ge 75 ]; then echo "  COLONY"
elif [ "$TOTAL" -ge 60 ]; then echo "  SWARM"
elif [ "$TOTAL" -ge 40 ]; then echo "  HIVE"
else                           echo "  FAIL"
fi
echo "═══════════════════════════════════════════"
