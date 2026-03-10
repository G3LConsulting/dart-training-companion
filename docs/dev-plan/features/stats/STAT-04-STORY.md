# STAT-04 — Per-Game-Mode Breakdown & Number Focus Stats

**Feature:** Statistics & Analytics
**Phase:** MVP
**Story ID:** STAT-04
**Status:** Not Started
**Priority:** P1
**Complexity:** L

---

## Context

Users play multiple game modes and want mode-specific statistics. For Number Focus mode, per-target statistics are especially valuable to identify strengths and weaknesses. This story implements mode filtering and Number Focus number selector with color-coded heat grid.

**Implements:**
- FA §FR-S-04: "User can view game-mode-specific stats and Number Focus target breakdown"
- TA §6: GetNumberFocusStatsQuery

---

## Acceptance Criteria

- [ ] Stats filterable by game mode (501, 301, Cricket, Number Focus)
- [ ] Number Focus: number selector (1-20 + Bull) drills into per-target stats
- [ ] Number Focus overview grid: all 21 numbers, color-coded by weighted accuracy
- [ ] Color scheme: green ≥80%, yellow 50-79%, orange 25-49%, red <25%
- [ ] Per-number view shows hit distribution trend and accuracy over time

---

## Implementation Tasks

| Task ID | Title | Layer | Status | Assigned |
|---------|-------|-------|--------|----------|
| [STAT-04-T01](./stat-04-game-mode-breakdown/STAT-04-T01-TASK.md) | API: GetNumberFocusStatsQuery handler | Backend | Not Started | — |
| [STAT-04-T02](./stat-04-game-mode-breakdown/STAT-04-T02-TASK.md) | Frontend: Game mode filter + NF stats view | Frontend | Not Started | — |
| [STAT-04-T03](./stat-04-game-mode-breakdown/STAT-04-T03-TASK.md) | Frontend: Number Focus heat grid component | Frontend | Not Started | — |
| [STAT-04-T04](./stat-04-game-mode-breakdown/STAT-04-T04-TASK.md) | Tests: Number Focus stats tests | Backend | Not Started | — |

---

## Dependencies

- **STAT-01:** Dashboard context
- **GAME-07:** Number Focus sessions must exist

---

## Shared References

- [Domain Model: DartEntry, UserStats](../../shared/DOMAIN-MODEL.md)

---

## Definition of Done

- All acceptance criteria met
- Code reviewed and approved
- Unit tests written and passing (>80% coverage)
- Frontend tested on mobile/desktop
- Heat grid color coding verified
- No console errors or warnings
