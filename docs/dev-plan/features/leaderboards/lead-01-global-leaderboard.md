# LEAD-01 — Global Leaderboard

**Feature:** Leaderboards
**Phase:** Post-MVP
**Status:** 🔲 Not started
**Agent:** —
**Output:** —
**Notes:** —

---

## Context
Global leaderboards per game mode. 501/301 ranked by 30-day rolling 3-dart average. Cricket by MPR. Number Focus excluded. Minimum 5 games in window to appear. User's own rank always visible.
> Implements: FA FR-L-01
> ⚠️ This story is Post-MVP and should not be started until MVP is complete and approved.

---

## Acceptance Criteria
- [ ] Separate leaderboards available per mode: 501, 301, Cricket
- [ ] 501/301 leaderboards ranked by 30-day rolling 3-dart average (descending)
- [ ] Cricket leaderboard ranked by 30-day rolling MPR (descending)
- [ ] Number Focus excluded from leaderboards (not applicable)
- [ ] Minimum 5 games required in 30-day window to appear on leaderboard
- [ ] Current user's rank always visible even if outside top-100
- [ ] Display shows: rank, display name (never email), KPI value (avg or MPR), optional game count
- [ ] Leaderboard requires opt-in: ApplicationUser.LeaderboardOptIn must be true
- [ ] Top-10 users highlighted with badges (gold, silver, bronze for ranks 1-3)
- [ ] GET /api/leaderboards/{mode} returns ranked list with user's position

---

## Technical Implementation Notes

**Backend:**
- New query: GetLeaderboardQuery handler
- Input: mode (501, 301, cricket)
- Logic:
  - Load all ApplicationUsers where LeaderboardOptIn = true
  - For each user, calculate 30-day rolling metric (avg 3-dart or MPR)
  - Filter: only users with ≥5 games in window
  - Sort by metric descending
  - Include current user's rank even if outside top-100 window
  - Return top-100 + current user (if not in top-100)
- Returns GetLeaderboardDto: { rank: int, displayName: string, metric: decimal, gameCount: int, position: int? (current user's position) }
- Caching: 1-hour cache per (mode) to optimize queries
- Consider materialized view or precalculated leaderboard table for performance

**Angular:**
- Standalone component: features/leaderboards/global-leaderboard/
- Route: /leaderboards/{mode}
- Mode selector: tabs or dropdown (501, 301, Cricket)
- Display: scrollable table or ranked list
- Columns: rank (with badges for top-3), display name, KPI value (avg or MPR), game count
- Top-3 badges: gold/silver/bronze icons/colors
- Current user highlighting: bold text or row highlight
- Current user always visible: if not in top-100, shown at bottom with "Your Rank" label
- Scroll interactions:
  - Load top-100 initially
  - Pagination or infinite scroll for older ranks
  - Jump-to-user link on current user's rank (scroll/highlight)
- Responsive: table on desktop, simplified card list on mobile
- Refresh logic: auto-refresh every 5 minutes (or manual button); opt-in toggle visible in nav

---

## Dependencies
- Depends on PROF-01 (user opt-in status)
- Depends on LEAD-02 (opt-out toggle implementation)
- Requires ApplicationUser.LeaderboardOptIn field
- Requires aggregation of 30-day rolling stats per mode

---

## Shared References
- [Domain Model](../../shared/domain-model.md) — ApplicationUser.LeaderboardOptIn, UserStats entities, 30-day rolling metrics
- [Architecture](../../shared/architecture.md) — Query handler pattern, caching strategy, materialized view pattern
- [API Contracts](../../shared/api-contracts.md) — GET /api/leaderboards/{mode} endpoint, GetLeaderboardDto schema
- [NFRs](../../shared/non-functional-requirements.md) — §12.1 (responsive table), §13.4 (leaderboard loads in <2s), privacy (display name only)
