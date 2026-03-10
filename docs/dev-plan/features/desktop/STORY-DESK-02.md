# STORY: DESK-02 — Enhanced Stats Dashboard (Desktop)

**Feature:** Desktop Experience
**Phase:** MVP
**Status:** Pending
**Agent:** Frontend Team
**Output:** Multi-panel stats dashboard with metric overlay, custom date picker, chart zoom/pan
**Notes:** Builds on STAT-01/STAT-02. Extends desktop usability for detailed statistical analysis.

---

## Context

### Implements
- **FA §FR-D-02** — Desktop-optimized stats dashboard with advanced interactions

### Acceptance Criteria

- [ ] On desktop (≥1024px): multi-panel layout (KPI header + primary chart at 2/3 width + secondary panel at 1/3 width)
- [ ] User can overlay multiple metrics on primary chart (e.g., 3-dart average + checkout %)
- [ ] Custom date range picker available in addition to preset ranges (Today, This Week, This Month, This Year)
- [ ] Charts support zoom via mouse scroll
- [ ] Charts support pan via click-and-drag
- [ ] Mobile (<768px) shows simplified single-panel layout without advanced interactions

---

## Tasks

| Task ID | Title | File Changes | Assigned | Status |
|---------|-------|-------------|----------|--------|
| [DESK-02-T01](./desk-02-enhanced-stats-dashboard/TASK-DESK-02-T01.md) | Frontend: Desktop stats layout with multi-panel grid | `features/stats/dashboard/stats-dashboard.component.ts` | Frontend | Pending |
| [DESK-02-T02](./desk-02-enhanced-stats-dashboard/TASK-DESK-02-T02.md) | Frontend: Metric overlay toggle & custom date picker | `features/stats/dashboard/metric-overlay.component.ts`, `date-range-picker.component.ts` | Frontend | Pending |
| [DESK-02-T03](./desk-02-enhanced-stats-dashboard/TASK-DESK-02-T03.md) | Frontend: Chart zoom/pan functionality | `shared/charts/trend-chart/trend-chart.component.ts` | Frontend | Pending |

---

## Dependencies

- **STAT-01** — Stats dashboard component scaffold exists
- **STAT-02** — Trend charts component exists
- **DESK-01** — Responsive layout and breakpoint detection available
- **Shared References:** Architecture (Chart.js, ADR arch-007), NFRs (chart interactions, accessibility)

---

## Shared References

See [`../../shared/architecture.md`](../../shared/architecture.md) for Chart.js integration and component patterns.
See [`../../shared/nfrs.md`](../../shared/nfrs.md) for keyboard navigation and mouse interaction requirements.
