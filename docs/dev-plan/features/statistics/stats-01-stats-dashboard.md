# STATS-01 — Stats Dashboard

**Feature:** Statistics
**Phase:** MVP
**Status:** 🔲 Not started
**Agent:** —
**Output:** —
**Notes:** —

---

## Context
Central statistics screen showing key KPIs per game mode for a selectable time range. The UserStats entity provides pre-computed aggregates.
> Implements: FA FR-S-01, TA §6 (GetStatsDashboardQuery → StatsDashboardDto)

---

## Acceptance Criteria
- [ ] Time range selector available: Last 7 days / 30 days / 90 days / All time
- [ ] Game mode filter available: 501 / 301 / Cricket / Number Focus
- [ ] 501/301 KPIs displayed: 3-dart average, highest turn, checkout %, total sessions, total darts
- [ ] Cricket KPIs displayed: MPR (marks per round), total sessions
- [ ] Number Focus KPIs displayed: average accuracy %, average weighted accuracy %, total sets
- [ ] Dashboard loads with last-used filter selection persisted
- [ ] "Recalculating" state shown when IsRecalculating=true on UserStats
- [ ] GET /api/stats?range=30d&mode=501 returns StatsDashboardDto with correct structure
- [ ] Dashboard responsive on mobile and desktop layouts

---

## Technical Implementation Notes

**Backend:**
- GetStatsDashboardQuery handler: accepts range (7d, 30d, 90d, all) and mode (501, 301, cricket, nf)
- Query loads UserStats.StatsJson and deserializes to mode-specific DTO
- Returns StatsDashboardDto with IsRecalculating flag for polling UI state
- Caching: consider 5-minute cache per (userId, mode, range) tuple to reduce query load

**Angular:**
- Standalone component: features/stats/dashboard/
- Components used: time-range-selector, game-mode-filter, kpi-card (reusable for all KPI displays)
- State: store last-selected range + mode in localStorage (restore on component init)
- HTTP service: call GET /api/stats before showing; if IsRecalculating=true, start 3s polling until false
- KPI cards: render appropriately based on mode (different KPIs per game type)

---

## Dependencies
- Depends on PROF-01 (user must be logged in)
- Depends on GAME-04 (sessions exist to compute stats)
- UserStats entity must have StatsJson serialized with mode-specific data

---

## Shared References
- [Domain Model](../../shared/domain-model.md) — UserStats entity, KPI field definitions per mode
- [Architecture](../../shared/architecture.md) — Query handler pattern, DTO serialization
- [API Contracts](../../shared/api-contracts.md) — GET /api/stats endpoint, StatsDashboardDto schema
- [NFRs](../../shared/non-functional-requirements.md) — §12.1 (responsive), dashboard loads in <2s
