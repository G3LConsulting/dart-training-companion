# PROF-02 — Home Screen

**Feature:** Player Profiles  **Phase:** MVP  **Status:** 🔲 Not started  **Agent:** —  **Output:** —  **Notes:** —

---

## Context

The home screen is the primary landing page after login, providing quick access to game modes and displaying player progress. This story implements a multi-section dashboard: quick-start panel (4 game mode cards), recent sessions strip (3-5 last completed sessions), personal best highlights (3 fixed + 1 configurable metric), and weekly summary (sessions count, average trend). Responsive layout: stacked on mobile, two-column grid on desktop.

> Implements: FA §FR-P-06 (home screen layout)

---

## Acceptance Criteria

- [ ] Home screen shows quick-start panel with one card per MVP game mode (501, 301, Cricket, Number Focus)
- [ ] Recent sessions strip shows last 3-5 completed sessions as compact cards
- [ ] Personal best highlights row shows 3 fixed + 1 configurable metric
- [ ] Weekly summary card shows sessions played and average vs prior week
- [ ] On desktop: two-column grid layout with persistent sidebar
- [ ] Tapping a game mode card launches game setup for that mode

---

## Tasks

| Task | Layer | Status | Agent |
|------|-------|--------|-------|
| [PROF-02-T01 — API: Home screen data query](prof-02-t01-home-data-query.md) | Application | 🔲 Not started | — |
| [PROF-02-T02 — Frontend: Home screen component](prof-02-t02-home-screen-frontend.md) | UI | 🔲 Not started | — |
| [PROF-02-T03 — Tests: Home screen data tests](prof-02-t03-home-screen-tests.md) | Testing | 🔲 Not started | — |

---

## Dependencies

- AUTH-02 — Login & JWT Token Management — reason: User must be authenticated to view home screen
- PROF-01 — Profile Management — reason: Profile preferences (week start day, custom PB metric) required for home screen layout
- GAME-04 — Session Completion & Scoring — reason: Completed game sessions must exist for recent sessions strip
- STAT-03 — Personal Bests Tracking — reason: Personal best metrics must exist for highlights section

---

## Shared References

- [Domain Model](../../shared/domain-model.md) — GameSession, PersonalBest, UserStats entities
- [Architecture](../../shared/architecture.md) — responsive layout patterns, data aggregation patterns
- [API Contracts](../../shared/api-contracts.md) — GET /api/home
