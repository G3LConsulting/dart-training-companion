# STAT-01 — Stats Dashboard & KPIs

**Feature:** Statistics & Analytics
**Phase:** MVP
**Story ID:** STAT-01
**Status:** Not Started
**Priority:** P1
**Complexity:** M

---

## Context

Users need a central dashboard to view their key performance indicators (KPIs) across their darts sessions. This story implements the core stats dashboard showing 3-dart average, checkout percentage, and total games played, with time range filtering.

**Implements:**
- FA §FR-S-01: "User can view personal performance statistics"
- TA §6: GetStatsDashboardQuery

---

## Acceptance Criteria

- [ ] Personal stats dashboard accessible from main navigation
- [ ] Key KPIs shown: 3-dart average, checkout %, total games played
- [ ] Time range selector: Last 7 days / 30 days / 90 days / All time
- [ ] KPIs update when time range changes
- [ ] Works on mobile and desktop viewports
- [ ] Handles empty state (no sessions)

---

## Implementation Tasks

| Task ID | Title | Layer | Status | Assigned |
|---------|-------|-------|--------|----------|
| [STAT-01-T01](./stat-01-stats-dashboard/STAT-01-T01-TASK.md) | API: GetStatsDashboardQuery handler | Backend | Not Started | — |
| [STAT-01-T02](./stat-01-stats-dashboard/STAT-01-T02-TASK.md) | Frontend: Dashboard component with KPI cards | Frontend | Not Started | — |
| [STAT-01-T03](./stat-01-stats-dashboard/STAT-01-T03-TASK.md) | Tests: Stats dashboard query tests | Backend | Not Started | — |

---

## Dependencies

- **AUTH-02:** User must be authenticated
- **GAME-04:** Sessions must exist

---

## Shared References

- [Domain Model: UserStats](../../shared/DOMAIN-MODEL.md)
- [API Contracts: Stats Endpoints](../../shared/API-CONTRACTS.md#stats)
- [CQRS Pattern](../../shared/ARCHITECTURE.md#cqrs)

---

## Definition of Done

- All acceptance criteria met
- Code reviewed and approved
- Unit tests written and passing (>80% coverage)
- Frontend tested on mobile viewports
- No console errors or warnings
