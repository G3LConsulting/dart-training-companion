# DSKX-02 — Session Drill-Down / Replay View

**Feature:** Desktop Advanced
**Phase:** Post-MVP
**Status:** 🔲 Not started
**Agent:** —
**Output:** —
**Notes:** —

> ⚠️ This story is Post-MVP and should not be started until MVP is complete and approved.

---

## Context

Understanding individual session performance requires detailed per-turn breakdown. Desktop users analyzing specific games want to see exactly how each turn unfolded: dart-by-dart logs, per-turn scoring trends, and session-level metrics. This granular view helps identify patterns (e.g., "I always struggle with high checkouts") and validate training improvements.

> Implements: FA §FR-D-04

---

## Acceptance Criteria

- [ ] From history or stats, click any session to open detailed view
- [ ] 501/301/Cricket: turn-by-turn table, per-turn bar chart, session metrics
- [ ] Number Focus: dart-by-dart log, stacked bar per 10-dart group, session accuracy vs PB
- [ ] Read-only view

---

## Technical Implementation Notes

> ⚠️ No detailed TA spec exists for this feature yet. The following is derived from the FA and general architecture patterns.

- Extend `GetSessionDetailQuery` to return:
  - For 501/301/Cricket: Turn-by-turn breakdown (turn number, target, darts thrown, score, running total)
  - For Number Focus: Dart-by-dart log (number, sector hit, points, running accuracy)
  - Session metadata (mode, date, duration, final score, mode-specific metrics)
- Enhanced `SessionDetailComponent` for desktop with:
  - Session header: mode, date, final score, key metrics
  - Mode-specific table: turn-by-turn or dart-by-dart depending on game type
  - Per-turn bar chart showing points per turn (501/301/Cricket) or accuracy per 10-dart block (NF)
  - Optional: per-turn PB comparison overlay
  - Read-only (no editing, no deletion buttons visible)
- Route structure: `/sessions/{sessionId}` navigable from history and stats pages
- Navigation breadcrumbs back to history or original stats view
- Optional: Keyboard/touch navigation between sessions (prev/next buttons)

---

## Dependencies

- HIST-01 — Session History (MVP) — Session data source and navigation entry point
- DESK-02 — Desktop Stats & Export (MVP) — Desktop UI patterns and session detail routing

---

## Shared References

- ../../shared/architecture.md
- ../../shared/entities.md
