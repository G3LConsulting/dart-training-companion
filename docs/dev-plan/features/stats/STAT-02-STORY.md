# STAT-02 — Trend Charts

**Feature:** Statistics & Analytics
**Phase:** MVP
**Story ID:** STAT-02
**Status:** Not Started
**Priority:** P1
**Complexity:** M

---

## Context

Users should see trends in their performance over time. This story implements trend charts using Chart.js showing 3-dart average and checkout percentage as line/bar charts with interactive data points and date labels.

**Implements:**
- FA §FR-S-02: "User can view performance trends"
- TA §6: GetTrendDataQuery
- TA ADR arch-007: Chart.js integration

---

## Acceptance Criteria

- [ ] 3-dart average shown as line chart over time
- [ ] Checkout % shown as bar/line chart over time
- [ ] Charts are interactive: tap/click data point shows exact value and date
- [ ] Charts use Chart.js wrapped in dedicated components
- [ ] Charts update with time range from dashboard

---

## Implementation Tasks

| Task ID | Title | Layer | Status | Assigned |
|---------|-------|-------|--------|----------|
| [STAT-02-T01](./stat-02-trend-charts/STAT-02-T01-TASK.md) | API: GetTrendDataQuery handler | Backend | Not Started | — |
| [STAT-02-T02](./stat-02-trend-charts/STAT-02-T02-TASK.md) | Frontend: Trend chart components (Chart.js) | Frontend | Not Started | — |
| [STAT-02-T03](./stat-02-trend-charts/STAT-02-T03-TASK.md) | Frontend: Integrate charts in dashboard | Frontend | Not Started | — |
| [STAT-02-T04](./stat-02-trend-charts/STAT-02-T04-TASK.md) | Tests: Trend data query tests | Backend | Not Started | — |

---

## Dependencies

- **STAT-01:** Dashboard exists

---

## Shared References

- [Chart.js Documentation](https://www.chartjs.org/)
- [ADR arch-007: Chart.js](../../shared/ARCHITECTURE.md#adrs)

---

## Definition of Done

- All acceptance criteria met
- Code reviewed and approved
- Unit tests written and passing
- Frontend tested on mobile/desktop
- Chart rendering and interactions smooth
- No console errors or warnings
