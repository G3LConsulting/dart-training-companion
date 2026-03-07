#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# mark-story.sh — Update story status in docs/dev-plan/README.md
#
# Usage:
#   bash scripts/mark-story.sh <STORY-ID> <STATUS> [NOTES]
#
# STATUS values:
#   in-progress   →  🔄 In progress
#   review        →  👀 Review
#   done          →  ✅ Done
#   blocked       →  🚫 Blocked
#   not-started   →  🔲 Not started
#
# Examples:
#   bash scripts/mark-story.sh INFRA-01 in-progress
#   bash scripts/mark-story.sh INFRA-01 review
#   bash scripts/mark-story.sh INFRA-01 done
#   bash scripts/mark-story.sh INFRA-01 blocked "Waiting on EF migration tooling"
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

STORY_ID="${1:?Error: STORY_ID required. Usage: $0 <STORY-ID> <STATUS> [NOTES]}"
STATUS="${2:?Error: STATUS required. Usage: $0 <STORY-ID> <STATUS> [NOTES]}"
NOTES="${3:-}"

README="docs/dev-plan/README.md"

if [[ ! -f "$README" ]]; then
    echo "❌ Error: $README not found. Run from the project root." >&2
    exit 1
fi

# Validate status argument
case "$STATUS" in
    in-progress|review|done|blocked|not-started) ;;
    *)
        echo "❌ Invalid STATUS: '$STATUS'" >&2
        echo "   Valid values: in-progress | review | done | blocked | not-started" >&2
        exit 1
        ;;
esac

# Delegate to Python for the actual string replacement
python3 - "$STORY_ID" "$STATUS" "$NOTES" "$README" << 'PYEOF'
import sys
import re

story_id  = sys.argv[1]
status    = sys.argv[2]
notes     = sys.argv[3]
readme    = sys.argv[4]

STATUS_TEXT = {
    "in-progress": "🔄 In progress",
    "review":      "👀 Review",
    "done":        "✅ Done",
    "blocked":     "🚫 Blocked",
    "not-started": "🔲 Not started",
}

new_status_text = STATUS_TEXT[status]

with open(readme, "r", encoding="utf-8") as f:
    lines = f.readlines()

updated = False
new_lines = []

for line in lines:
    # Look for a table row that contains this story ID as a markdown link
    # Example: | [INFRA-01 — ...](path) | MVP | 🔲 Not started | — | — | — |
    if f"[{story_id}" in line and "|" in line:
        parts = line.split("|")
        # Columns (1-indexed from parts[1]):
        #   1: story link
        #   2: phase
        #   3: status   ← update this
        #   4: agent
        #   5: output
        #   6: notes    ← optionally update this
        if len(parts) >= 6:
            parts[3] = f" {new_status_text} "
            if notes and len(parts) > 6:
                parts[6] = f" {notes} "
            line = "|".join(parts)
            updated = True

    new_lines.append(line)

if not updated:
    print(f"❌ Story '{story_id}' not found in {readme}", file=sys.stderr)
    sys.exit(1)

with open(readme, "w", encoding="utf-8") as f:
    f.writelines(new_lines)

print(f"✅  {story_id} → {new_status_text}" + (f"  ({notes})" if notes else ""))
PYEOF
