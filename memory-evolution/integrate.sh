#!/bin/bash
# Memory Evolution Integration - Adapted for OpenClaw workspace
# Based on: memory-evolution-mother-skill

set -euo pipefail

# Base paths - configurable
MEMORY_BASE="${MEMORY_BASE:-/workspace/memory-evolution/data}"
mkdir -p "$MEMORY_BASE"

# === Core Functions ===

# 1. Evolution Log Append
# Usage: evolution_log --source <source> --track <track> --title <title> --insight <insight> --action <action>
evolution_log() {
    local SOURCE="" TRACK="" TITLE="" INSIGHT="" ACTION="" CONFIDENCE="0.80"
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --source) SOURCE="$2"; shift 2 ;;
            --track) TRACK="$2"; shift 2 ;;
            --title) TITLE="$2"; shift 2 ;;
            --insight) INSIGHT="$2"; shift 2 ;;
            --action) ACTION="$2"; shift 2 ;;
            --confidence) CONFIDENCE="$2"; shift 2 ;;
            *) shift ;;
        esac
    done
    
    [[ -z "$SOURCE" || -z "$TRACK" || -z "$TITLE" ]] && echo "Missing required args" && return 1
    
    local LOG_MD="$MEMORY_BASE/evolution_log.md"
    local LOG_JSONL="$MEMORY_BASE/evolution_log.jsonl"
    local TS_LOCAL=$(date +"%Y-%m-%d %H:%M:%S")
    local TS_ISO=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    # Generate fingerprint
    local FINGERPRINT=$(echo "${TRACK}|${TITLE}|${INSIGHT}" | sha256sum | cut -c1-16)
    
    # Check for duplicates
    if [[ -f "$LOG_JSONL" ]]; then
        local DUPLICATE=$(grep -q "\"fingerprint\":\"$FINGERPRINT\"" "$LOG_JSONL" && echo "true" || echo "false")
        if [[ "$DUPLICATE" == "true" ]]; then
            echo "⏭️  [Evolution] Duplicate detected, skipping: $TITLE"
            return 0
        fi
    fi
    
    # Get related previous
    local RELATED_PREV=""
    if [[ -f "$LOG_JSONL" ]]; then
        RELATED_PREV=$(tail -5 "$LOG_JSONL" 2>/dev/null | grep "\"track\":\"$TRACK\"" | tail -1 | python3 -c 'import sys,json; print(json.load(sys.stdin).get("title","")[:50])' 2>/dev/null || echo "")
    fi
    
    # Append to MD
    cat >> "$LOG_MD" <<EOF
## [$TS_LOCAL] $TITLE
- source: $SOURCE
- track: $TRACK
- related_prev: ${RELATED_PREV:-none}
- fingerprint: $FINGERPRINT
- insight: $INSIGHT
- action: $ACTION
- confidence: $CONFIDENCE

EOF
    
    # Append to JSONL
    echo "{\"ts\":\"$TS_ISO\",\"source\":\"$SOURCE\",\"track\":\"$TRACK\",\"title\":\"$TITLE\",\"related_prev\":\"$RELATED_PREV\",\"fingerprint\":\"$FINGERPRINT\",\"insight\":\"$INSIGHT\",\"action\":\"$ACTION\",\"confidence\":\"$CONFIDENCE\"}" >> "$LOG_JSONL"
    
    echo "✅ [Evolution] Logged: $TITLE (track: $TRACK)"
}

# 2. Anti-Repeat Chain Builder
evolution_chain_build() {
    local CHAIN_MD="$MEMORY_BASE/evolution_chains.md"
    local LOG_JSONL="$MEMORY_BASE/evolution_log.jsonl"
    
    [[ ! -f "$LOG_JSONL" ]] && echo "No log file found" && return
    
    echo "# Evolution Chains" > "$CHAIN_MD"
    echo "" >> "$CHAIN_MD"
    
    # Group by track and show chains
    python3 - <<PY
import json
from collections import defaultdict

chains = defaultdict(list)
with open("$LOG_JSONL") as f:
    for line in f:
        if line.strip():
            e = json.loads(line)
            chains[e.get("track","unknown")].append(e)

for track, events in chains.items():
    print(f"## 🔗 {track}")
    print(f"    Events: {len(events)}")
    for e in events[-3:]:
        print(f"    - {e.get('title','')}")
    print("")
PY
    >> "$CHAIN_MD"
    
    echo "🔗 [Evolution] Chains built: $CHAIN_MD"
}

# 3. Effect Receipt Append
# Usage: effect_track --capability <name> --time_saved <min> --repeat_avoided <bool> --outcome <success|partial|fail>
effect_track() {
    local CAPABILITY="" TIME_SAVED="0" REPEAT_AVOIDED="false" OUTCOME="success"
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --capability) CAPABILITY="$2"; shift 2 ;;
            --time_saved) TIME_SAVED="$2"; shift 2 ;;
            --repeat_avoided) REPEAT_AVOIDED="$2"; shift 2 ;;
            --outcome) OUTCOME="$2"; shift 2 ;;
            *) shift ;;
        esac
    done
    
    [[ -z "$CAPABILITY" ]] && echo "Missing --capability" && return 1
    
    local RECEIPT_JSONL="$MEMORY_BASE/effect_receipts.jsonl"
    local TS_ISO=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    echo "{\"ts\":\"$TS_ISO\",\"capability\":\"$CAPABILITY\",\"time_saved_min\":$TIME_SAVED,\"repeat_avoided\":$REPEAT_AVOIDED,\"outcome\":\"$OUTCOME\"}" >> "$RECEIPT_JSONL"
    
    echo "📊 [Effect] Tracked: $CAPABILITY (outcome: $OUTCOME)"
}

# 4. Effect Scoreboard
effect_scoreboard() {
    local SCOREBOARD_MD="$MEMORY_BASE/effect_scoreboard.md"
    local RECEIPT_JSONL="$MEMORY_BASE/effect_receipts.jsonl"
    
    [[ ! -f "$RECEIPT_JSONL" ]] && echo "No receipts found" && return
    
    python3 - <<PY > "$SCOREBOARD_MD"
import json
from collections import defaultdict

caps = defaultdict(lambda: {"runs": 0, "success": 0, "partial": 0, "fail": 0, "time_saved": 0, "repeat_avoided": 0})

with open("$RECEIPT_JSONL") as f:
    for line in f:
        if line.strip():
            e = json.loads(line)
            name = e.get("capability","unknown")
            caps[name]["runs"] += 1
            outcome = e.get("outcome","fail")
            caps[name][outcome] = caps[name].get(outcome,0) + 1
            caps[name]["time_saved"] += e.get("time_saved_min",0)
            if e.get("repeat_avoided"):
                caps[name]["repeat_avoided"] += 1

print("# Effect Scoreboard\n")
print("| Capability | Runs | Success | Partial | Fail | Time Saved (min) | Repeat Avoided |")
print("|------------|------|---------|---------|------|------------------|----------------|")
for name, stats in sorted(caps.items(), key=lambda x: x[1]["time_saved"], reverse=True):
    print(f"| {name} | {stats['runs']} | {stats.get('success',0)} | {stats.get('partial',0)} | {stats.get('fail',0)} | {stats['time_saved']} | {stats['repeat_avoided']} |")
PY
    
    echo "📈 [Effect] Scoreboard: $SCOREBOARD_MD"
    cat "$SCOREBOARD_MD"
}

# 5. Quick Status
evolution_status() {
    echo "🧬 Memory Evolution Status"
    echo "==========================="
    echo "Data directory: $MEMORY_BASE"
    echo ""
    
    for f in evolution_log.jsonl effect_receipts.jsonl; do
        if [[ -f "$MEMORY_BASE/$f" ]]; then
            local COUNT=$(wc -l < "$MEMORY_BASE/$f")
            echo "  $f: $COUNT entries"
        else
            echo "  $f: (empty)"
        fi
    done
}

# Export functions
export -f evolution_log
export -f evolution_chain_build
export -f effect_track
export -f effect_scoreboard
export -f evolution_status
export MEMORY_BASE
