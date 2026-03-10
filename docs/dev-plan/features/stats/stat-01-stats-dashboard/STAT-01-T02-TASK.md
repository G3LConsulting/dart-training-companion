# STAT-01-T02 — Frontend: Dashboard Component with KPI Cards

**Story:** [STAT-01](../STAT-01-STORY.md)
**Layer:** Frontend (Angular)
**Status:** Not Started
**Assigned To:** —
**Complexity:** M

---

## What to Build

Create Angular component displaying KPI cards (3-dart average, checkout %, games played) with time range selector. Component subscribes to StatsApiService and refreshes when time range changes.

---

## Files to Create/Modify

| Path | Purpose | Status |
|------|---------|--------|
| `src/app/features/stats/dashboard/stats-dashboard.component.ts` | Main dashboard component | To Create |
| `src/app/features/stats/dashboard/stats-dashboard.component.html` | Template | To Create |
| `src/app/features/stats/dashboard/stats-dashboard.component.scss` | Styles | To Create |
| `src/app/shared/components/kpi-card/kpi-card.component.ts` | Reusable KPI card component | To Create |
| `src/app/core/api/stats-api.service.ts` | HTTP service for stats API | To Create |

---

## Implementation Notes

### Dashboard Component

Subscribe to StatsApiService and display KPI cards. Time range selector (7d, 30d, 90d, all) triggers re-fetch.

### KPI Card Component

Reusable component accepting:
- Label (e.g., "3-Dart Average")
- Value (number)
- Unit (e.g., "avg points per 3 darts")
- Icon (optional)
- Trend indicator (up/down, optional)

### Responsive Layout

- Desktop: 3 columns of KPI cards
- Tablet: 2 columns
- Mobile: 1 column, stacked

---

## Definition of Done

- [ ] Dashboard component created and responsive
- [ ] KPI card component created and reusable
- [ ] Time range selector working (updates dashboard)
- [ ] Data loading state shown
- [ ] Error state handled
- [ ] Empty state shown when no data
- [ ] Mobile-friendly layout verified
- [ ] Unit tests verify component logic
- [ ] No console errors or warnings

---

## References

- [Angular Components](https://angular.io/guide/component-overview)
- [Responsive Design](../../../shared/FRONTEND-PATTERNS.md#responsive-design)
