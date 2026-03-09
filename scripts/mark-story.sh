#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# mark-story.sh — Update story status in docs/dev-plan/README.md
#                 and in the individual story file
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
# Both the README table row and the **Status:** field in the story file
# are updated in a single call.
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

# Delegate to Python for both file updates
python3 - "$STORY_ID" "$STATUS" "$NOTES" "$README" << 'PYEOF'
import sys
import re
from pathlib import Path

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

# ── 1. Update docs/dev-plan/README.md ────────────────────────────────────────

with open(readme, "r", encoding="utf-8") as f:
    lines = f.readlines()

readme_updated = False
story_file_rel = None   # relative path extracted from the README link
new_lines = []

for line in lines:
    # Look for a table row that contains this story ID as a markdown link
    # Example: | [INFRA-01 — ...](features/infrastructure/infra-01-...md) | MVP | 🔲 Not started | ...
    if f"[{story_id}" in line and "|" in line:
        # Extract the story file path from the markdown link
        match = re.search(r'\[' + re.escape(story_id) + r'[^\]]*\]\(([^)]+)\)', line)
        if match:
            story_file_rel = match.group(1).strip()

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
            readme_updated = True

    new_lines.append(line)

if not readme_updated:
    print(f"❌ Story '{story_id}' not found in {readme}", file=sys.stderr)
    sys.exit(1)

with open(readme, "w", encoding="utf-8") as f:
    f.writelines(new_lines)

print(f"✅  README    {story_id} → {new_status_text}" + (f"  ({notes})" if notes else ""))

# ── 2. Update the individual story file ──────────────────────────────────────

if not story_file_rel:
    print(f"⚠️  Could not extract story file path from README for {story_id} — skipping story file update.", file=sys.stderr)
    sys.exit(0)

# The path in the README is relative to docs/dev-plan/
readme_dir = Path(readme).parent
story_file = readme_dir / story_file_rel

if not story_file.exists():
    print(f"⚠️  Story file not found at {story_file} — skipping story file update.", file=sys.stderr)
    sys.exit(0)

with open(story_file, "r", encoding="utf-8") as f:
    story_lines = f.readlines()

story_updated = False
new_story_lines = []

for line in story_lines:
    # Match: **Status:** <any emoji + text>
    # Example: **Status:** 🔲 Not started
    if re.match(r'^\*\*Status:\*\*', line):
        new_line = f"**Status:** {new_status_text}\n"
        # Append notes inline if provided
        if notes:
            new_line = f"**Status:** {new_status_text} — {notes}\n"
        new_story_lines.append(new_line)
        story_updated = True
    else:
        new_story_lines.append(line)

if not story_updated:
    print(f"⚠️  No **Status:** field found in {story_file} — skipping story file update.", file=sys.stderr)
else:
    with open(story_file, "w", encoding="utf-8") as f:
        f.writelines(new_story_lines)
    print(f"✅  Story     {story_file} → {new_status_text}" + (f"  ({notes})" if notes else ""))

PYEOF
