# STAT-03 — Personal Bests & PB Notifications

**Feature:** Statistics & Analytics
**Phase:** MVP
**Story ID:** STAT-03
**Status:** Not Started
**Priority:** P1
**Complexity:** M

---

## Context

Users want to track their best performances in each game mode and metric. This story implements personal best (PB) tracking and shows a congratulatory notification when a new PB is achieved during gameplay.

**Implements:**
- FA §FR-S-03: "User can view and track personal bests"
- TA §6: GetPersonalBestsQuery

---

## Acceptance Criteria

- [ ] "Personal Bests" section shows all-time best for each tracked metric
- [ ] Grouped by game mode (501/301, Cricket, Number Focus)
- [ ] When a PB is broken during a game, congratulatory notification shown
- [ ] PB check happens on session save (CreateSessionCommand)
- [ ] Mobile-friendly layout for PB display

---

## Implementation Tasks

| Task ID | Title | Layer | Status | Assigned |
|---------|-------|-------|--------|----------|
| [STAT-03-T01](./stat-03-personal-bests/STAT-03-T01-TASK.md) | API: GetPersonalBestsQuery handler | Backend | Not Started | — |
| [STAT-03-T02](./stat-03-personal-bests/STAT-03-T02-TASK.md) | API: PB check logic in CreateSessionCommand | Backend | Not Started | — |
| [STAT-03-T03](./stat-03-personal-bests/STAT-03-T03-TASK.md) | Frontend: Personal bests view + notification | Frontend | Not Started | — |
| [STAT-03-T04](./stat-03-personal-bests/STAT-03-T04-TASK.md) | Tests: PB detection and query tests | Backend | Not Started | — |

---

## Dependencies

- **STAT-01:** Dashboard context
- **GAME-04:** Sessions must exist

---

## Shared References

- [Domain Model: PersonalBest](../../shared/DOMAIN-MODEL.md)

---

## Definition of Done

- All acceptance criteria met
- Code reviewed and approved
- Unit tests written and passing (>80% coverage)
- Frontend tested on mobile viewports
- Notifications display correctly
- No console errors or warnings
