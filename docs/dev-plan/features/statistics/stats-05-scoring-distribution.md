# STATS-05 — Scoring Distribution

**Feature:** Statistics
**Phase:** MVP
**Status:** 🔲 Not started
**Agent:** —
**Output:** —
**Notes:** —

---

## Context
Heatmap or bar chart visualising how often each number/segment was targeted, helping users identify favourite beds and blind spots.
> Implements: FA FR-S-05, TA §6 (GetStatsDashboardQuery returns distribution data)

---

## Acceptance Criteria
- [ ] Visual distribution displayed as bar chart or heatmap of dart frequency by number (1-20 + Bull)
- [ ] Top-3 most hit numbers highlighted with gold/bronze badges
- [ ] Bottom-3 least hit numbers highlighted with weak spot indicator
- [ ] Available for Number Focus game mode
- [ ] Inherits time range filter from STATS-01
- [ ] Chart responsive on mobile and desktop
- [ ] Tooltip shows exact frequency (count and percentage) on hover/tap
- [ ] Data loads from GET /api/stats/distribution?mode=nf&range=30d

---

## Technical Implementation Notes

**Backend:**
- Scoring distribution data included in StatsDashboardDto when mode=nf
- Aggregation logic: count DartEntry records per number (1-20, bull) over time range
- Returns distribution array: [{ number, count, percentage }]
- Top-3: sort descending by count, take first 3
- Bottom-3: sort ascending by count, take first 3 (or all if <3 with data)
- Exclude numbers with zero attempts from bottom-3 display

**Angular:**
- Standalone component: features/stats/dashboard/scoring-distribution/ (used as section within dashboard)
- Display: horizontal bar chart (Chart.js) or SVG heatmap
- Bar chart approach: X-axis = numbers 1-20 + Bull, Y-axis = frequency count
- Heatmap approach: 21 cells in grid layout, cell intensity by frequency percentile
- Top-3 badge: gold star icon, positioned above bar or on cell
- Bottom-3 indicator: warning icon, red underline, or cell outline
- Tooltip: shows exact count and percentage of total darts
- Responsive: stacked chart on mobile, side-by-side on desktop
- Interaction: click bar/cell to filter STATS-01 by that number (optional drill recommendation trigger)

---

## Dependencies
- Depends on STATS-01 (time range and mode context)
- Depends on GAME-08 (Number Focus sessions and DartEntry data)
- Data source: DartEntry and Turn aggregation queries

---

## Shared References
- [Domain Model](../../shared/domain-model.md) — DartEntry entity, Turn entity for segment targeting
- [Architecture](../../shared/architecture.md) — Chart.js wrapper pattern, Query handler pattern
- [API Contracts](../../shared/api-contracts.md) — GET /api/stats/distribution endpoint, ScoringDistributionDto schema
- [NFRs](../../shared/non-functional-requirements.md) — §12.1 (responsive chart), distribution loads in <2s
