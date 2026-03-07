# STATS-02 — Trend Charts

**Feature:** Statistics
**Phase:** MVP
**Status:** 🔲 Not started
**Agent:** —
**Output:** —
**Notes:** —

---

## Context
Time-series line and bar charts showing how key metrics evolve over time. Uses ng2-charts/Chart.js wrapped in dedicated Angular components.
> Implements: FA FR-S-02, TA §6 (GetTrendDataQuery → TrendDataDto), TA §14 ADR arch-007 (Chart.js wrappers)

---

## Acceptance Criteria
- [ ] Line chart displays 3-dart average over time for 501/301 modes
- [ ] Bar or line chart displays checkout % over time
- [ ] Interactive tooltips: tap/click data point shows exact value
- [ ] Metric selector allows choosing which metric to chart
- [ ] Time range from STATS-01 filter is applied to charts
- [ ] Charts wrapped in TrendChartComponent with Chart.js, @Input() data contract
- [ ] Chart interactions work with mouse (desktop) and keyboard navigation (NFR)
- [ ] GET /api/stats/trends?metric=avg_3dart&mode=501&range=90d returns correct TrendDataDto
- [ ] Charts render on both mobile and desktop without layout shift

---

## Technical Implementation Notes

**Backend:**
- GetTrendDataQuery handler: accepts metric (avg_3dart, checkout_pct, nf_accuracy, nf_weighted_accuracy), mode, and range
- Query aggregates data points per day (or per session if sparse) over the time window
- Returns TrendDataDto: { metric: string, dataPoints: [{ date: ISO8601, value: decimal }], unit: string }
- Caching: 10-minute cache per (userId, metric, mode, range) to optimize repeated requests

**Angular:**
- Standalone component: features/stats/trends/trend-chart-wrapper/
- Child component: shared/charts/trend-chart/ (reusable Chart.js wrapper)
- TrendChartComponent @Input(): { data: TrendDataDto, chartType: 'line' | 'bar' }
- TrendChartComponent @Output(): { pointClicked: EventEmitter<{ date, value }> }
- Metric selector: dropdown populated with mode-specific metrics
- Keyboard navigation: arrow keys to move between data points; Enter to show tooltip
- Responsive: chart height adjusts for mobile (<1024px) vs desktop
- Loading state: skeleton or spinner while fetching trends

---

## Dependencies
- Depends on STATS-01 (filter context and KPI definitions)
- Requires Chart.js and ng2-charts library
- Requires BreakpointObserver from Angular CDK for responsive detection

---

## Shared References
- [Domain Model](../../shared/domain-model.md) — Session, Turn, DartEntry entities for data source
- [Architecture](../../shared/architecture.md) — Chart.js wrapper pattern (ADR arch-007), Query handler pattern
- [API Contracts](../../shared/api-contracts.md) — GET /api/stats/trends endpoint, TrendDataDto schema
- [NFRs](../../shared/non-functional-requirements.md) — §12.1 (responsive), §12.5 (keyboard navigation), trend chart loads in <2s
