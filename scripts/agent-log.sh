#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# agent-log.sh — Write a timestamped progress line to the agent log file
#
# Usage (from any agent):
#   bash scripts/agent-log.sh <AGENT-TYPE> <STORY-ID> <MESSAGE>
#
# Creates: logs/<agent-type>-<story-id>.log
#
# Examples:
#   bash scripts/agent-log.sh developer INFRA-01 "Step 2 — Reading context documents"
#   bash scripts/agent-log.sh reviewer  PROF-01  "Step 4 — Architecture review: all checks passed"
#   bash scripts/agent-log.sh qa-tester AUTH-01  "Step 6 — API contract verification started"
#   bash scripts/agent-log.sh orchestrator WAVE "Step 3 — Merging 2 stories"
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

AGENT_TYPE="${1:?Error: AGENT_TYPE required}"
STORY_ID="${2:?Error: STORY_ID required}"
MESSAGE="${3:?Error: MESSAGE required}"

LOG_DIR="logs"
mkdir -p "$LOG_DIR"

LOG_FILE="$LOG_DIR/${AGENT_TYPE}-$(echo "$STORY_ID" | tr '[:upper:]' '[:lower:]').log"

TIMESTAMP=$(date '+%H:%M:%S')
echo "[$TIMESTAMP] [$AGENT_TYPE] $STORY_ID — $MESSAGE" | tee -a "$LOG_FILE"
