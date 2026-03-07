# STATS-04 — Per-Game-Mode Breakdown & NF Overview Grid

**Feature:** Statistics
**Phase:** MVP
**Status:** 🔲 Not started
**Agent:** —
**Output:** —
**Notes:** —

---

## Context
Filters the stats dashboard by game mode. For Number Focus, adds a 21-cell overview grid colour-coded by weighted accuracy level, and a number selector (1-20 + Bull) for detailed per-number stats.
> Implements: FA FR-S-04, TA §6 (GetNumberFocusStatsQuery → NumberFocusStatsDto)

---

## Acceptance Criteria
- [ ] Game mode filter (from STATS-01) affects all stats widgets and updates displayed KPIs
- [ ] Number Focus mode selected: 21-cell overview grid displayed (numbers 1-20 + Bull)
- [ ] Grid cells colour-coded by best weighted accuracy:
  - Green: ≥80%
  - Yellow: 50-79%
  - Orange: 25-49%
  - Red: <25%
  - Grey: no sessions for that number
- [ ] Clicking a grid cell navigates to detail view: GET /api/stats/number-focus/{number}
- [ ] Number detail shows: total sets, best accuracy %, best weighted accuracy, date achieved
- [ ] Mobile fallback: scrollable list sorted by weakness (ascending weighted accuracy)
- [ ] Grid responsive on desktop (≥1024px); mobile uses list layout
- [ ] Data loads from cache when offline (service worker)

---

## Technical Implementation Notes

**Backend:**
- GetNumberFocusStatsQuery handler: accepts number (1-20 or "bull") and optional range filter
- Per-number query: loads all DartEntry records for (userId, number, dateRange), calculates:
  - totalSets: distinct set count containing that number
  - bestAccuracy: max(hits / attempts) for that number
  - bestWeightedAccuracy: max(weighted score / attempts)
  - bestDate: achievedAt of session with best weighted accuracy
- Returns NumberFocusStatsDto: { number, totalSets, bestAccuracy, bestWeightedAccuracy, bestDate }
- Grid query: calls GetNumberFocusStatsQuery for each number 1-20 + Bull; caches results as array
- Caching: 10-minute cache per (userId, range) to optimize grid requests

**Angular:**
- Standalone component: shared/charts/number-focus-heat-grid/
- NumberFocusHeatGridComponent @Input(): { gridData: NumberFocusStatsDto[], mode: 'grid' | 'list', onCellClick: (number) => void }
- Desktop grid layout: 21 cells in 3 rows × 7 columns (1-7, 8-14, 15-20, Bull centered in last row)
- Grid cell styling: background color by weighted accuracy band, cell text = number, hover tooltip shows stats
- Mobile list layout: scrollable flex column, each row shows number + accuracy bars + weighted accuracy percentage
- List sorted ascending by weighted accuracy (weakest first for training focus)
- Click handler: emit onCellClick(number) event; parent component navigates to detail view
- Detail view component: features/stats/number-focus-detail/ shows full stats for selected number
- Load data from shared/stats/number-focus-stats.service via GetNumberFocusStatsQuery

---

## Dependencies
- Depends on STATS-01 (filter context, time range selector)
- Depends on GAME-08 (Number Focus sessions and DartEntry entities)
- Used by DESK-05 (desktop heat grid display)

---

## Shared References
- [Domain Model](../../shared/domain-model.md) — DartEntry entity, Number Focus session structure, KPI definitions
- [Architecture](../../shared/architecture.md) — Query handler pattern, reusable component architecture
- [API Contracts](../../shared/api-contracts.md) — GET /api/stats/number-focus endpoint, GET /api/stats/number-focus/{number}, NumberFocusStatsDto schema
- [NFRs](../../shared/non-functional-requirements.md) — §12.1 (responsive grid to list), offline caching via service worker
