# DESK-04 — Session Drill-Down (Replay View)

**Feature:** Desktop & Export
**Phase:** Post-MVP
**Status:** 🔲 Not started
**Agent:** —
**Output:** —
**Notes:** —

---

## Context
Click any completed session in history to see a turn-by-turn table and charts. NF shows dart-by-dart log with stacked bar chart per 10-dart group. Read-only.
> Implements: FA FR-D-04
> ⚠️ This story is Post-MVP and should not be started until MVP is complete and approved.

---

## Acceptance Criteria
- [ ] Session detail view accessible from session history list (PROF-04)
- [ ] 501/301/Cricket: turn-by-turn table display
  - [ ] Columns: Turn #, Score, Remaining, 3-Dart Avg, Checkout %
  - [ ] Sortable by column
  - [ ] Rows clickable for turn detail (optional)
- [ ] Number Focus: dart-by-dart log display
  - [ ] Table: Dart #, Number, Ring (Single/Double/Triple), Result (hit/miss)
  - [ ] Stacked bar chart per 10-dart group showing distribution
  - [ ] Visual: bar chart x-axis = dart groups (1-10, 11-20, ...), y-axis = hit count
- [ ] Session metadata shown: date, duration, final score, mode
- [ ] Read-only view (no editing)
- [ ] GET /api/sessions/{id} used for data fetching
- [ ] Charts respond to interactions (tooltip, zoom for desktop)

---

## Technical Implementation Notes

**Backend:**
- GetSessionDetailQuery handler: loads Session by sessionId
- For 501/301/Cricket: return turns with computed 3-dart avg, remaining per turn
- For NF: return all DartEntry records sorted by sequence
- Session returned with: id, mode, score, date, duration, turns[], darts[]
- Already implemented in MVP (PROF-04); reuse existing endpoint

**Angular:**
- Standalone component: features/history/session-detail/
- Route: /history/{sessionId} or nested within history list
- Breadcrumb: History > Session {date}
- Session metadata header: mode badge, date, duration, final score
- 501/301/Cricket turn-by-turn view:
  - Table component: Turn #, Score, Remaining, 3-Dart Avg, Checkout %
  - ng-repeat or *ngFor over session.turns
  - Sortable: click column header to sort
  - Row interaction: optional row detail expansion or turn-level tooltip
- Number Focus dart-by-dart view:
  - Table component: Dart #, Number, Ring, Result (hit/miss icon)
  - ng-repeat over session.darts
  - Stacked bar chart: Chart.js bar chart with grouped darts (1-10, 11-20, etc.)
  - X-axis: dart groups, Y-axis: hit count per ring type
  - Legend: Single/Double/Triple colors
  - Responsive: table scrollable on mobile, chart stacked on mobile
- Chart integration: TrendChartComponent or custom chart component
- Keyboard navigation: arrow keys to scroll table, tab through rows
- Print-friendly: optional print stylesheet for session summary
- Share session: optional button to trigger LEAD-04 sharing (share session summary image)

---

## Dependencies
- Depends on PROF-04 (session history integration)
- Depends on GetSessionDetailQuery (already in MVP)
- Uses existing session data model

---

## Shared References
- [Domain Model](../../shared/domain-model.md) — Session, Turn, DartEntry entities
- [Architecture](../../shared/architecture.md) — Query handler pattern, Chart.js wrapper pattern
- [API Contracts](../../shared/api-contracts.md) — GET /api/sessions/{id} endpoint (existing), SessionDetailDto schema
- [NFRs](../../shared/non-functional-requirements.md) — §12.1 (responsive table/chart), session detail loads in <2s, read-only view confirmed
