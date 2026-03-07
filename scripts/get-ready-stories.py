#!/usr/bin/env python3
"""
Parse docs/dev-plan/README.md and output JSON describing story states.

Usage:
    python3 scripts/get-ready-stories.py [--scope mvp|all]

Output JSON keys:
    ready        - stories with all deps Done and status Not Started
    in_progress  - currently being worked on
    review       - implemented, awaiting human review/merge
    done         - completed and merged
    blocked      - blocked, needs human attention
    waiting      - not started but deps not yet done
"""

import json
import re
import sys
import argparse
from pathlib import Path


def parse_args():
    parser = argparse.ArgumentParser(description="Get ready stories from README.md")
    parser.add_argument("--scope", choices=["mvp", "all"], default="mvp",
                        help="Filter to MVP stories only (default) or all stories")
    parser.add_argument("--readme", default="docs/dev-plan/README.md",
                        help="Path to README.md (default: docs/dev-plan/README.md)")
    return parser.parse_args()


STATUS_MAP = {
    "Not started": "not_started",
    "In progress": "in_progress",
    "Review":      "review",
    "Done":        "done",
    "Blocked":     "blocked",
}

EMOJI_MAP = {
    "🔲": "not_started",
    "🔄": "in_progress",
    "👀": "review",
    "✅": "done",
    "🚫": "blocked",
}


def parse_status_cell(cell: str) -> str:
    """Extract status string from a table cell that may contain emoji and text."""
    cell = cell.strip()
    # Check text first (more reliable)
    for text, status in STATUS_MAP.items():
        if text.lower() in cell.lower():
            return status
    # Fall back to emoji
    for emoji, status in EMOJI_MAP.items():
        if emoji in cell:
            return status
    return "unknown"


def parse_readme(readme_path: Path) -> dict[str, dict]:
    """
    Parse the README story tables and the Mermaid dependency graph.
    Returns a dict of story_id -> story_info.
    """
    text = readme_path.read_text(encoding="utf-8")
    stories: dict[str, dict] = {}

    # ── Parse story table rows ──────────────────────────────────────────────
    # Table rows look like:
    # | [INFRA-01 — Solution Scaffold](features/infrastructure/infra-01-solution-scaffold.md) | MVP | 🔲 Not started | — | — | — |
    row_pattern = re.compile(
        r"^\|\s*\[([A-Z]+-\d+)[^\]]*\]\(([^)]+)\)\s*\|\s*(MVP|Post-MVP)\s*\|([^|]+)\|",
        re.MULTILINE,
    )

    for match in row_pattern.finditer(text):
        story_id   = match.group(1).strip()
        rel_path   = match.group(2).strip()
        phase      = match.group(3).strip()
        status_raw = match.group(4)

        # The relative path is relative to docs/dev-plan/ (where the README lives)
        file_path = f"docs/dev-plan/{rel_path}"

        stories[story_id] = {
            "id":     story_id,
            "file":   file_path,
            "phase":  phase,
            "status": parse_status_cell(status_raw),
            "deps":   [],
        }

    if not stories:
        print(
            json.dumps({"error": "No stories found. Check that README.md has the expected table format."}),
            file=sys.stderr,
        )
        sys.exit(1)

    # ── Parse Mermaid dependency graph ──────────────────────────────────────
    # Lines like:  INFRA-02 --> INFRA-01
    # means INFRA-02 depends on INFRA-01 (arrow points to dependency)
    dep_pattern = re.compile(r"^\s+([A-Z]+-\d+)\s*-->\s*([A-Z]+-\d+)", re.MULTILINE)

    for match in dep_pattern.finditer(text):
        dependent  = match.group(1).strip()
        dependency = match.group(2).strip()
        if dependent in stories:
            if dependency not in stories[dependent]["deps"]:
                stories[dependent]["deps"].append(dependency)

    return stories


def count_downstream(story_id: str, all_stories: dict, memo: dict = None) -> int:
    """Count the number of stories that transitively depend on story_id."""
    if memo is None:
        memo = {}
    if story_id in memo:
        return memo[story_id]
    count = 0
    for sid, s in all_stories.items():
        if story_id in s.get("deps", []):
            count += 1 + count_downstream(sid, all_stories, memo)
    memo[story_id] = count
    return count


def main():
    args  = parse_args()
    readme = Path(args.readme)

    if not readme.exists():
        print(json.dumps({"error": f"README not found at {readme}"}))
        sys.exit(1)

    all_stories = parse_readme(readme)

    # Apply scope filter
    if args.scope == "mvp":
        scoped = {k: v for k, v in all_stories.items() if v["phase"] == "MVP"}
    else:
        scoped = all_stories

    done_ids = {sid for sid, s in scoped.items() if s["status"] == "done"}

    result: dict[str, list] = {
        "ready":       [],
        "in_progress": [],
        "review":      [],
        "done":        [],
        "blocked":     [],
        "waiting":     [],
    }

    for story_id, story in scoped.items():
        status = story["status"]
        # Only consider deps that are within scope
        scoped_deps = [d for d in story["deps"] if d in scoped]

        if status == "not_started":
            all_deps_done = all(d in done_ids for d in scoped_deps)
            if all_deps_done:
                result["ready"].append(story)
            else:
                result["waiting"].append({
                    **story,
                    "waiting_on": [d for d in scoped_deps if d not in done_ids],
                })
        elif status == "in_progress":
            result["in_progress"].append(story)
        elif status == "review":
            result["review"].append(story)
        elif status == "done":
            result["done"].append(story)
        elif status == "blocked":
            result["blocked"].append(story)
        else:
            result["waiting"].append(story)

    # Sort ready list: stories with most downstream dependents first
    memo: dict = {}
    result["ready"].sort(
        key=lambda s: count_downstream(s["id"], scoped, memo),
        reverse=True,
    )

    print(json.dumps(result, indent=2, ensure_ascii=False))


if __name__ == "__main__":
    main()
