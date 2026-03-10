# STORY: DESK-03 — Number Focus Heat Grid (Desktop)

**Feature:** Desktop Experience
**Phase:** MVP
**Status:** Pending
**Agent:** Frontend Team
**Output:** Full-board heat grid for desktop, scrollable list for mobile, hover tooltips, click navigation
**Notes:** Provides visual dashboard for player accuracy across all 21 targets. Responsive across devices.

---

## Context

### Implements
- **FA §FR-D-05** — Number Focus heat grid with color-coded accuracy visualization

### Acceptance Criteria

- [ ] Desktop (≥1024px): full-board heat grid panel displaying all 21 targets in grid layout
- [ ] Targets color-coded by weighted accuracy: Green ≥80%, Yellow 50–79%, Orange 25–49%, Red <25% or no data
- [ ] Hover tooltip shows: best accuracy, best weighted accuracy, total sets, date of most recent set
- [ ] Click on cell navigates to Number Focus stats detail for that number
- [ ] Mobile (<768px): targets displayed as scrollable list sorted by weighted accuracy (worst first)
- [ ] List shows same tooltip information on tap/click
- [ ] Empty states: no Number Focus sessions yet, display instructional message

---

## Tasks

| Task ID | Title | File Changes | Assigned | Status |
|---------|-------|-------------|----------|--------|
| [DESK-03-T01](./desk-03-number-focus-heat-grid/TASK-DESK-03-T01.md) | Frontend: Heat grid desktop component with tooltips & click navigation | `shared/charts/number-focus-heat-grid/number-focus-heat-grid.component.ts` | Frontend | Pending |

---

## Dependencies

- **STAT-04** — Number Focus stats data query and aggregation
- **DESK-01** — Responsive layout patterns established
- **Shared References:** Domain Model (PersonalBest, UserStats), NFRs (chart interactions, accessibility)

---

## Shared References

See [`../../shared/architecture.md`](../../shared/architecture.md) for component composition and responsive patterns.
See [`../../shared/domain-model.md`](../../shared/domain-model.md) for PersonalBest and UserStats structures.
See [`../../shared/nfrs.md`](../../shared/nfrs.md) for keyboard navigation and color contrast requirements.
