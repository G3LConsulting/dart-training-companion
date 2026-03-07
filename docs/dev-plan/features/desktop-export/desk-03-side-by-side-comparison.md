# DESK-03 — Side-by-Side Game Mode Comparison

**Feature:** Desktop & Export
**Phase:** Post-MVP
**Status:** 🔲 Not started
**Agent:** —
**Output:** —
**Notes:** —

---

## Context
Dedicated Compare view allowing users to select two game modes and metrics, display them on a shared time axis, and export the comparison directly.
> Implements: FA FR-D-03
> ⚠️ This story is Post-MVP and should not be started until MVP is complete and approved.

---

## Acceptance Criteria
- [ ] Dedicated Compare view: /compare route
- [ ] Game mode selector (left): choose first mode (501, 301, Cricket)
- [ ] Game mode selector (right): choose second mode (501, 301, Cricket, or NF)
- [ ] Metric selector: choose metric to compare per side (3-dart avg, checkout %, MPR, accuracy, etc.)
- [ ] Charts side-by-side: left chart = mode 1 metric, right chart = mode 2 metric
- [ ] Shared time axis: both charts zoom/pan together (linked interaction)
- [ ] Time range filter: same range applies to both sides
- [ ] Export comparison: button to export both charts + data as Excel or PDF (DESK-06)
- [ ] Desktop only feature (no mobile layout)
- [ ] Save comparison: optional ability to save comparison preset

---

## Technical Implementation Notes

**Backend:**
- No new backend endpoints required; reuse GetTrendDataQuery with two separate calls
- Optional: create GetComparisonQuery that returns both datasets in one response for efficiency

**Angular:**
- Standalone component: features/stats/compare-view/
- Route: /compare (desktop only; redirects to stats on mobile)
- Layout: two equal-width columns (1/2 each)
- Left column:
  - Mode selector: dropdown (501, 301, Cricket)
  - Metric selector: dropdown of available metrics for selected mode
  - Chart: TrendChartComponent instance (Chart.js)
- Right column: same structure as left
- Shared time range: one picker at top that applies to both charts
- Interactions:
  - Chart 1 zoom/pan event → sync Chart 2 zoom/pan to same time range
  - Use Chart.js plugin or custom event binding for zoom synchronization
- Export button: call DESK-06 export flow with both datasets
- Responsive: N/A (desktop only); hide compare link on mobile nav
- Optional: save preset button → store comparison settings (localStorage or server) with name

---

## Dependencies
- Depends on STATS-02 (trend charts and GetTrendDataQuery)
- Depends on DESK-01 (desktop context)
- Depends on DESK-06 (export integration)
- Requires linked Chart.js zoom/pan mechanism

---

## Shared References
- [Domain Model](../../shared/domain-model.md) — Session, Turn, DartEntry entities
- [Architecture](../../shared/architecture.md) — Chart.js wrapper pattern, linked interaction pattern
- [API Contracts](../../shared/api-contracts.md) — GET /api/stats/trends endpoint (existing)
- [NFRs](../../shared/non-functional-requirements.md) — §12.3 (desktop only), linked zoom/pan in <100ms
