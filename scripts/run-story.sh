#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# run-story.sh — Manually run a developer agent for a single story
#
# Useful for:
#   - Implementing a specific story outside the orchestrator
#   - Re-running a blocked story after fixing the blocker
#   - Testing the developer agent on a single story
#
# Usage:
#   bash scripts/run-story.sh <STORY-ID>
#
# Examples:
#   bash scripts/run-story.sh INFRA-01
#   bash scripts/run-story.sh PROF-01
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

STORY_ID="${1:?Usage: $0 <STORY-ID>   (e.g. INFRA-01, PROF-01)}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# ── Preflight checks ──────────────────────────────────────────────────────────
if ! command -v claude &>/dev/null; then
    echo "❌  'claude' CLI not found."
    echo "    Install Claude Code: https://claude.ai/code"
    exit 1
fi

cd "$PROJECT_ROOT"

# ── Resolve story file path ────────────────────────────────────────────────────
STORY_FILE=$(python3 - "$STORY_ID" << 'PYEOF'
import json, subprocess, sys

story_id = sys.argv[1]

result = subprocess.run(
    ["python3", "scripts/get-ready-stories.py", "--scope", "all"],
    capture_output=True, text=True
)

if result.returncode != 0:
    print("NOT_FOUND")
    sys.exit(0)

data = json.loads(result.stdout)
buckets = ["ready", "in_progress", "review", "qa", "merge_ready", "done", "blocked", "waiting"]
for bucket in buckets:
    for s in data.get(bucket, []):
        if s["id"] == story_id:
            print(s["file"])
            sys.exit(0)

print("NOT_FOUND")
PYEOF
)

if [[ "$STORY_FILE" == "NOT_FOUND" ]]; then
    echo "❌  Story '$STORY_ID' not found in docs/dev-plan/README.md"
    echo ""
    echo "    Valid story IDs:"
    python3 scripts/get-ready-stories.py --scope all | python3 -c "
import json, sys
data = json.load(sys.stdin)
buckets = ['ready','in_progress','review','done','blocked','waiting']
ids = [s['id'] for b in buckets for s in data.get(b, [])]
for i in sorted(ids):
    print(f'      {i}')
"
    exit 1
fi

# ── Show story info ────────────────────────────────────────────────────────────
echo ""
echo "🚀  Running developer agent"
echo "────────────────────────────────────────────────────────"
echo "    Story:  $STORY_ID"
echo "    File:   $STORY_FILE"
echo "    Branch: feat/$(echo "$STORY_ID" | tr '[:upper:]' '[:lower:]')"
echo ""

# ── Ask for confirmation ───────────────────────────────────────────────────────
read -r -p "▶  Launch developer agent? [y/N] " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
fi

echo ""

# ── Prepare log directory ────────────────────────────────────────────────────
mkdir -p logs
echo "📋  Agent progress logs → logs/"
echo "    Open a second terminal and run:"
echo ""
echo "      tail -f logs/*.log"
echo ""
echo "    to watch the agent in real-time."
echo "────────────────────────────────────────────────────────"
echo ""

# ── Mark story in-progress ────────────────────────────────────────────────────
bash scripts/mark-story.sh "$STORY_ID" in-progress || true

# ── Build developer agent prompt ──────────────────────────────────────────────
DEVELOPER_PROMPT="$(cat .claude/agents/developer.md)

---

## Your Assignment

STORY_ID:        $STORY_ID
STORY_FILE_PATH: $STORY_FILE
PROJECT_ROOT:    $PROJECT_ROOT
Current date:    $(date '+%Y-%m-%d')

Begin by reading your context documents (CLAUDE.md, the story file, and shared docs).
Then implement the story end-to-end as described in your instructions above.
Do not stop until the branch is committed and the story is marked for review.
"

# ── Launch the developer agent ─────────────────────────────────────────────────
claude \
    --model claude-sonnet-4-5 \
    --dangerously-skip-permissions \
    -p "$DEVELOPER_PROMPT"
