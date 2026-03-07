# STATS-06 — Weekly Summary

**Feature:** Statistics
**Phase:** MVP
**Status:** 🔲 Not started
**Agent:** —
**Output:** —
**Notes:** —

---

## Context
Auto-generated weekly summary card shown on the home screen and stats dashboard. Compares current week vs prior week. Week boundary determined by user's WeekStartDay preference.
> Implements: FA FR-S-06, TA §6 (GetWeeklyStatsQuery → WeeklyStatsDto)

---

## Acceptance Criteria
- [ ] Weekly summary card displays current week metrics: sessions played, 3-dart average (per mode), improvement vs prior week
- [ ] Prior week data shown on card for comparison
- [ ] Week boundary respects user preference: Monday or Sunday per ApplicationUser.WeekStartDay
- [ ] Summary card shown on home screen (PROF-05) with "View Full Stats" link
- [ ] Summary card shown in full stats view (STATS-01) as prominent section
- [ ] Improvement indicator displayed: up/down arrow with delta value and percentage
- [ ] Current week card updates on new session save (real-time or next refresh)
- [ ] GET /api/stats/weekly returns WeeklyStatsDto with current and prior week data

---

## Technical Implementation Notes

**Backend:**
- ApplicationUser.WeekStartDay stored as DayOfWeek enum (Monday = 1, Sunday = 0)
- GetWeeklyStatsQuery handler:
  - Calculate current week start/end using user's WeekStartDay preference
  - Calculate prior week start/end (7 days before)
  - Load sessions within each date range, group by mode
  - Aggregate: count sessions, calculate 3-dart average, compute improvement delta
  - Returns WeeklyStatsDto: { currentWeek: { sessions: int, avgBy3Dart: { mode: decimal }, improvementDelta: decimal }, priorWeek: { ... }, improvementPercent: decimal }
- Caching: 1-hour cache per userId (invalidate on session create)
- GetWeeklyStatsQuery runs on home screen load and stats dashboard load

**Angular:**
- Standalone component: shared/charts/weekly-summary-card/
- Component @Input(): { currentWeek: WeeklyStats, priorWeek: WeeklyStats }
- Card layout:
  - Header: "This Week" + week date range (Mon Jan 15 – Sun Jan 21)
  - Body: sessions count, 3-dart averages per mode (501, 301, Cricket)
  - Footer: improvement delta (up/down arrow + percentage)
- Visual styling: highlight improvement if positive (green), warn if negative (orange), neutral if flat
- Prior week comparison: smaller text below current week (e.g. "vs 5 sessions last week")
- Optional: toggle to expand and show detailed prior week metrics
- Responsive: full width on mobile, max-width card on desktop
- Interaction: "View Full Stats" link navigates to STATS-01 dashboard
- Real-time update: subscribe to session-created event via WebSocket; refresh weekly data

---

## Dependencies
- Depends on PROF-01 (user context and WeekStartDay preference)
- Depends on PROF-05 (home screen integration)
- Depends on STATS-01 (stats dashboard context)
- Depends on GAME-04 (sessions must exist)

---

## Shared References
- [Domain Model](../../shared/domain-model.md) — ApplicationUser.WeekStartDay, Session, UserStats entities
- [Architecture](../../shared/architecture.md) — Query handler pattern, DomainEvent subscription pattern
- [API Contracts](../../shared/api-contracts.md) — GET /api/stats/weekly endpoint, WeeklyStatsDto schema
- [NFRs](../../shared/non-functional-requirements.md) — §12.1 (responsive card), weekly summary loads in <1s
