# DESK-02 — Enhanced Stats Dashboard (Desktop)

**Feature:** Desktop & Export
**Phase:** MVP
**Status:** 🔲 Not started
**Agent:** —
**Output:** —
**Notes:** —

---

## Context
On desktop (≥1024px), the stats dashboard gains a multi-panel layout with a large primary chart (2/3 width), secondary panel (1/3), metric overlay support, custom date ranges, and zoom/pan on charts.
> Implements: FA FR-D-02, TA §14 ADR arch-007 (Chart.js wrappers)

---

## Acceptance Criteria
- [ ] Desktop layout (≥1024px): KPI header row, primary chart panel (2/3 width), secondary metric panel (1/3)
- [ ] Mobile layout (<1024px): unchanged, stacked single column
- [ ] Multiple metrics overlaid on same chart (e.g. avg + checkout % together)
- [ ] Custom date range picker: from/to calendar inputs
- [ ] Zoom and pan on time axis of trend charts:
  - [ ] Mouse wheel: zoom in/out
  - [ ] Drag: pan left/right on time axis
  - [ ] Touch gestures: pinch zoom (via Hammer.js)
- [ ] Chart interactions work with keyboard (NFR: arrow keys, enter, escape)
- [ ] Legend toggleable: click legend item to show/hide data series
- [ ] Chart responsive: maintains aspect ratio on resize
- [ ] Export button integrated (DESK-06)

---

## Technical Implementation Notes

**Backend:**
- No backend changes required; reuse existing GetTrendDataQuery endpoints

**Angular:**
- Enhanced dashboard component: features/stats/dashboard/ (extends STATS-01 and STATS-02)
- Breakpoint detection: show enhanced layout on desktop, fallback to mobile on <1024px
- Layout: CSS Grid or Flexbox
  - Row 1: KPI cards (game mode filter, time range selector, custom date picker)
  - Row 2: Main chart (2/3 width) + secondary panel (1/3 width)
- Primary chart panel:
  - Metric selector: checkbox group or multi-select dropdown (avg 3-dart, checkout %, NF accuracy, etc.)
  - Chart: Chart.js LineChart or BarChart (reuses TrendChartComponent from STATS-02)
  - Multiple datasets: each selected metric = 1 dataset on chart; different colors per metric
  - Legend: toggleable via click; hiding series via legend item click
  - Chart plugins: Chart.js zoom plugin (chartjs-plugin-zoom) + filler plugin for area fills
  - Toolbar: zoom reset button, export to image button
- Zoom/pan interactions:
  - Chart.js zoom config: mode: 'xy', wheel: { enabled: true, speed: 0.1 }, drag: { enabled: true }
  - Hammerjs for touch gestures: pinch event → zoom
  - Pan: drag on chart with cursor change (cursor: grab/grabbing)
- Custom date picker:
  - Material DateRangePicker (Angular Material mat-date-range-input) or custom calendar
  - From/To date inputs: validate dateFrom < dateTo
  - Apply button: refetch chart data with new range
  - Validation error: show "Invalid date range" if from > to
- Secondary panel (1/3 width):
  - Displays secondary metric (different from primary) or alternative view
  - Options: summary stats, mini-chart, comparison table
  - Responsive: moves below main chart on tablet (1024px-1200px), stays beside on desktop (>1200px)
- Keyboard navigation:
  - Arrow keys: navigate chart data points (left/right = previous/next day)
  - Enter: show tooltip for current data point
  - Escape: close tooltip or zoom reset
  - Tab: cycle through chart controls (legend, zoom button, etc.)
- Responsive: chart height adjusts for mobile vs desktop; legend repositioned for space

---

## Dependencies
- Depends on STATS-01 (stats dashboard foundation)
- Depends on STATS-02 (trend charts foundation)
- Depends on DESK-01 (desktop navigation context)
- Requires Chart.js, ng2-charts, chartjs-plugin-zoom, Hammer.js libraries
- Requires Angular CDK BreakpointObserver and Material DateRangePicker (or custom)

---

## Shared References
- [Domain Model](../../shared/domain-model.md) — Session, Turn, DartEntry entities for data
- [Architecture](../../shared/architecture.md) — Chart.js wrapper pattern (ADR arch-007), responsive layout patterns
- [API Contracts](../../shared/api-contracts.md) — GET /api/stats/trends endpoint (existing)
- [NFRs](../../shared/non-functional-requirements.md) — §12.1 (responsive 2/3-1/3 layout), §12.5 (keyboard navigation), §12.3 (desktop ≥1024px), chart zoom in <500ms
