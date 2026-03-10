# STAT-05 — Scoring Distribution

**Feature:** Statistics & Analytics
**Phase:** MVP
**Story ID:** STAT-05
**Status:** Not Started
**Priority:** P2
**Complexity:** S

---

## Context

Users who track segment-by-segment want to see which numbers they score on most frequently. This story implements a heatmap or bar chart showing scoring distribution, helping users identify favourite beds and blind spots.

**Implements:**
- FA §FR-S-05: "User can view scoring distribution across numbers"

---

## Acceptance Criteria

- [ ] Heatmap or bar chart showing which numbers player scores on most (from segment data)
- [ ] Helps identify favourite beds and blind spots
- [ ] Only populated when segment-by-segment entry mode used
- [ ] Shows message encouraging segment entry when no data available

---

## Implementation Tasks

| Task ID | Title | Layer | Status | Assigned |
|---------|-------|-------|--------|----------|
| [STAT-05-T01](./stat-05-scoring-distribution/STAT-05-T01-TASK.md) | API: Extend GetStatsDashboardQuery with distribution data | Backend | Not Started | — |
| [STAT-05-T02](./stat-05-scoring-distribution/STAT-05-T02-TASK.md) | Frontend: Scoring distribution chart component | Frontend | Not Started | — |

---

## Dependencies

- **STAT-01:** Dashboard exists
- **GAME-02:** Segment-by-segment entry must exist

---

## Definition of Done

- All acceptance criteria met
- Code reviewed and approved
- Frontend tested on mobile/desktop
- No console errors or warnings
