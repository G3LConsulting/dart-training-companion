# STAT-02-T02 — Frontend: Trend Chart Components (Chart.js)

**Story:** [STAT-02](../STAT-02-STORY.md)
**Layer:** Frontend (Angular)
**Status:** Not Started
**Assigned To:** —
**Complexity:** M

---

## What to Build

Create reusable Angular components for trend visualization using Chart.js. Components accept time-series data and render line/bar charts with interactive tooltips.

---

## Files to Create/Modify

| Path | Purpose | Status |
|------|---------|--------|
| `src/app/shared/components/trend-chart/trend-chart.component.ts` | Reusable line chart component | To Create |
| `src/app/shared/components/session-bar-chart/session-bar-chart.component.ts` | Reusable bar chart component | To Create |
| `src/app/core/api/stats-api.service.ts` | Add getTrendData method | To Modify |

---

## Implementation Notes

### TrendChartComponent

Accepts:
- `@Input() data: TrendDataDto`
- `@Input() title: string`
- `@Input() metric: string`

Renders line chart with:
- Responsive sizing
- Interactive tooltips on hover
- Date labels on X-axis
- Value labels on Y-axis

### SessionBarChartComponent

Similar to TrendChartComponent but renders bar chart.

### Dependencies

Use ng2-charts wrapper around Chart.js.

---

## Definition of Done

- [ ] Trend chart component created and responsive
- [ ] Bar chart component created and responsive
- [ ] Chart.js properly integrated via ng2-charts
- [ ] Interactive tooltips working
- [ ] Data binding (@Input) working
- [ ] Charts render correctly with various data sizes
- [ ] Mobile-friendly rendering
- [ ] Unit tests verify rendering
- [ ] No console errors or warnings

---

## References

- [ng2-charts Documentation](https://valor-software.com/ng2-charts/)
- [Chart.js Documentation](https://www.chartjs.org/)
