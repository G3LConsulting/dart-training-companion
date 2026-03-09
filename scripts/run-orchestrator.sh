#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# run-orchestrator.sh — Launch the multi-agent orchestrator
#
# The orchestrator reads the story index, finds all ready MVP stories,
# spawns developer sub-agents (via Claude Code Task tool), and reports results.
#
# Usage:
#   bash scripts/run-orchestrator.sh
#
# Prerequisites:
#   - Claude Code CLI installed: https://claude.ai/code
#   - Run from the project root
#   - Git remote "origin" configured
#   - Recommended: add alias claude-yolo='claude --dangerously-skip-permissions'
#     to ~/.zshrc for interactive sessions without approval prompts
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# ── Preflight checks ──────────────────────────────────────────────────────────
if ! command -v claude &>/dev/null; then
    echo "❌  'claude' CLI not found."
    echo "    Install Claude Code: https://claude.ai/code"
    exit 1
fi

if [[ ! -f "$PROJECT_ROOT/docs/dev-plan/README.md" ]]; then
    echo "❌  docs/dev-plan/README.md not found."
    echo "    Run this script from the project root."
    exit 1
fi

cd "$PROJECT_ROOT"

# ── Print current status ───────────────────────────────────────────────────────
echo ""
echo "🎯  Darts Training Companion — Multi-Agent Orchestrator"
echo "────────────────────────────────────────────────────────"
echo "📁  Project root: $PROJECT_ROOT"
echo "📅  $(date '+%Y-%m-%d %H:%M')"
echo ""
echo "📊  Current story status (MVP scope):"
python3 scripts/get-ready-stories.py --scope mvp | python3 -c "
import json, sys
data = json.load(sys.stdin)
print(f\"    ✅ Done:         {len(data['done'])}\")
print(f\"    🔀 Merge ready:  {len(data.get('merge_ready', []))}\")
print(f\"    🧪 QA:           {len(data.get('qa', []))}\")
print(f\"    👀 Review:       {len(data['review'])}\")
print(f\"    🔄 In progress:  {len(data['in_progress'])}\")
print(f\"    🔲 Ready:        {len(data['ready'])}\")
print(f\"    ⏳ Waiting:      {len(data['waiting'])}\")
print(f\"    🚫 Blocked:      {len(data['blocked'])}\")
print()

work = (data.get('merge_ready', []) + data.get('qa', [])
        + data['review'] + data['ready'])
if work:
    ids = ', '.join(s['id'] for s in work)
    print(f'    Stories queued for this wave: {ids}')
elif data['in_progress']:
    ids = ', '.join(s['id'] for s in data['in_progress'])
    print(f'    ⚠️  Stories in progress from previous run: {ids}')
elif not data['waiting'] and not data['blocked']:
    print('    🎉 All MVP stories are complete!')
"
echo ""

# ── Ask for confirmation ───────────────────────────────────────────────────────
read -r -p "▶  Launch orchestrator? [y/N] " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
fi

echo ""
echo "🚀  Launching orchestrator agent..."
echo ""

# ── Prepare log directory ────────────────────────────────────────────────────
mkdir -p logs
echo "📋  Agent progress logs → logs/"
echo "    Open a second terminal and run:"
echo ""
echo "      tail -f logs/*.log"
echo ""
echo "    to watch all agents in real-time."
echo "────────────────────────────────────────────────────────"
echo ""

# ── Build the orchestrator prompt ─────────────────────────────────────────────
ORCHESTRATOR_PROMPT="$(cat .claude/agents/orchestrator.md)

---

## Runtime Context

Project root:  $PROJECT_ROOT
Current date:  $(date '+%Y-%m-%d')
Git branch:    $(git branch --show-current)

Begin now: run \`python3 scripts/get-ready-stories.py --scope mvp\` and execute your full workflow.
"

# ── Launch claude ──────────────────────────────────────────────────────────────
claude \
    --model claude-opus-4-5 \
    --dangerously-skip-permissions \
    -p "$ORCHESTRATOR_PROMPT"
