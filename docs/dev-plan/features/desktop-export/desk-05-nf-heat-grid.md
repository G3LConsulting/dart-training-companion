# DESK-05 — Number Focus Heat Grid

**Feature:** Desktop & Export
**Phase:** MVP
**Status:** 🔲 Not started
**Agent:** —
**Output:** —
**Notes:** —

---

## Context
Desktop: 21-cell grid (1-20 + Bull) colour-coded by best weighted accuracy. Hover shows tooltip with stats. Click navigates to detail. Mobile: scrollable list sorted by weakness.
> Implements: FA FR-D-05, TA §4 (NumberFocusHeatGridComponent)

---

## Acceptance Criteria
- [ ] Desktop (≥1024px): 21-cell grid layout (numbers 1-20 + Bull)
- [ ] Grid cells colour-coded by best weighted accuracy:
  - [ ] Green: ≥80%
  - [ ] Yellow: 50-79%
  - [ ] Orange: 25-49%
  - [ ] Red: <25%
  - [ ] Grey: no data
- [ ] Hover tooltip: shows best accuracy %, best weighted accuracy %, total sets, date of best
- [ ] Click/tap cell: navigates to number detail view (GET /api/stats/number-focus/{number})
- [ ] Mobile (<1024px): scrollable list sorted ascending by weighted accuracy (weakest first)
- [ ] Mobile list: number card showing name, accuracy %, weighted accuracy %, total sets
- [ ] Data loads with cached data when offline (service worker)
- [ ] Grid loads from GET /api/stats (NF mode) endpoint
- [ ] Number detail view: full stats for selected number (part of STATS-04)

---

## Technical Implementation Notes

**Backend:**
- Number Focus heat grid data returned from GetNumberFocusStatsQuery (from STATS-04)
- Array of { number, bestAccuracy, bestWeightedAccuracy, totalSets, bestDate }
- Caching: 10-minute cache per userId to reduce query load
- GET /api/stats?mode=nf&range=30d includes grid data in response

**Angular:**
- Standalone component: shared/charts/number-focus-heat-grid/
- Component @Input(): { gridData: NumberFocusStatsDto[], mode: 'grid' | 'list' }
- Component @Output(): { cellClick: EventEmitter<{ number: string | int }> }
- Parent component (features/stats/dashboard/): detects breakpoint and passes mode='grid' (desktop) or mode='list' (mobile)
- Desktop grid view:
  - Grid layout: CSS Grid with 7 columns
  - Cells: 1-7 (row 1), 8-14 (row 2), 15-20 (row 3), Bull (centered in row 4)
  - Cell styling: background color by weighted accuracy band; cell text = number; font-weight bold
  - Hover: background lightens; cursor: pointer
  - Tooltip: Material Tooltip or custom div (position: absolute on hover)
  - Tooltip content: "Number {num}: {weightedAcc}% WA ({bestAcc}%), {sets} sets, Best: {date}"
  - Click: emit cellClick event; parent navigates to detail view
- Mobile list view:
  - Flex column layout, scrollable
  - List items: grid cell as card (rounded corners, shadow)
  - Card layout: number (large, left), stats (right): weighted accuracy % (bold), best accuracy %, total sets (small)
  - Sorted ascending by weightedAccuracy (weakest first for training focus)
  - Each card clickable → emit cellClick event
  - Responsive: full width on mobile, padding
- Offline support: data cached in service worker IndexedDB or localStorage
- Refetch mechanism: subscribe to stats refresh event (manual or after session save); re-call GetNumberFocusStatsQuery

---

## Dependencies
- Depends on STATS-04 (Number Focus stats and GetNumberFocusStatsQuery)
- Depends on GAME-08 (Number Focus sessions and DartEntry data)
- Depends on DESK-01 (breakpoint detection context)
- Uses shared service for number focus stats

---

## Shared References
- [Domain Model](../../shared/domain-model.md) — DartEntry, Session, Number Focus entity structure
- [Architecture](../../shared/architecture.md) — Reusable component pattern, breakpoint-responsive display
- [API Contracts](../../shared/api-contracts.md) — GET /api/stats?mode=nf endpoint, NumberFocusStatsDto schema
- [NFRs](../../shared/non-functional-requirements.md) — §12.1 (responsive grid to list), §13 (offline caching), grid loads in <2s
