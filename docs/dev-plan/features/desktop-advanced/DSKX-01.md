# DSKX-01 — Side-by-Side Game Mode Comparison

**Feature:** Desktop Advanced
**Phase:** Post-MVP
**Status:** 🔲 Not started
**Agent:** —
**Output:** —
**Notes:** —

> ⚠️ This story is Post-MVP and should not be started until MVP is complete and approved.

---

## Context

Desktop users analyzing their game progression benefit from comparing performance across modes on the same timeline. A side-by-side comparison view reveals patterns (e.g., "my 501 average improved after I focused on Cricket drills") and helps identify which modes need attention.

> Implements: FA §FR-D-03

---

## Acceptance Criteria

- [ ] Desktop "Compare" view with 2+ game mode stat panels side by side
- [ ] User selects modes and metrics to compare
- [ ] Shared time axis aligns all panels
- [ ] Comparison view exportable via export feature

---

## Technical Implementation Notes

> ⚠️ No detailed TA spec exists for this feature yet. The following is derived from the FA and general architecture patterns.

- New Angular comparison component at `features/stats/comparison.component`
- UI controls to select:
  - 2-4 modes to compare (checkboxes or multi-select)
  - Metric per mode (3-dart avg for 501/301, MPR for Cricket, etc.)
  - Time range (last 30 days, 90 days, all time)
- Reuse existing trend chart components (from STAT-02) with synchronized x-axis:
  - Each mode's chart in a separate panel
  - All panels share same date range on x-axis
  - Responsive layout (stack vertically on small desktop, side-by-side on wide desktop)
- Data fetching: Reuse GetTrendQuery per mode, join results client-side by date
- Export integration (DESK-02):
  - "Export comparison" button generating PNG or PDF
  - Comparison layout serialized for export

---

## Dependencies

- STAT-02 — Trend Charts & Filters — Trend data and chart components
- DESK-02 — Desktop Stats & Export (MVP) — Export infrastructure and responsive layout

---

## Shared References

- ../../shared/architecture.md
- ../../shared/entities.md
