# STAT-06 — Weekly Summary

**Feature:** Statistics & Analytics
**Phase:** MVP
**Story ID:** STAT-06
**Status:** Not Started
**Priority:** P2
**Complexity:** M

---

## Context

Users want a quick summary of their performance each week, showing sessions played, average score, and improvement vs the prior week. This story implements weekly summary generation and display, with a card layout suitable for sharing (post-MVP).

**Implements:**
- FA §FR-S-06: "User can view weekly performance summary"
- TA §6: GetWeeklyStatsQuery

---

## Acceptance Criteria

- [ ] Weekly summary generated at end of each week (boundary = user's week start day)
- [ ] Shows: sessions played, average score, improvement vs prior week
- [ ] Drill recommendation slot present but empty in MVP (awaits Module 3)
- [ ] Accessible from home screen / profile screen
- [ ] Card layout ready for sharing (post-MVP feature)

---

## Implementation Tasks

| Task ID | Title | Layer | Status | Assigned |
|---------|-------|-------|--------|----------|
| [STAT-06-T01](./stat-06-weekly-summary/STAT-06-T01-TASK.md) | API: GetWeeklyStatsQuery handler | Backend | Not Started | — |
| [STAT-06-T02](./stat-06-weekly-summary/STAT-06-T02-TASK.md) | Frontend: Weekly summary card component | Frontend | Not Started | — |
| [STAT-06-T03](./stat-06-weekly-summary/STAT-06-T03-TASK.md) | Tests: Weekly stats calculation tests | Backend | Not Started | — |

---

## Dependencies

- **STAT-01:** Dashboard context
- **PROF-01:** User preferences (week start day)

---

## Shared References

- [Domain Model: ApplicationUser.WeekStartDay](../../shared/DOMAIN-MODEL.md)

---

## Definition of Done

- All acceptance criteria met
- Code reviewed and approved
- Unit tests written and passing (>80% coverage)
- Week boundary calculation verified for all day starts
- Frontend tested on mobile/desktop
- No console errors or warnings
