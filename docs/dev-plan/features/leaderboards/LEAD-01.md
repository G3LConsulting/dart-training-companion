# LEAD-01 — Global Leaderboard

**Feature:** Leaderboards & Sharing
**Phase:** Post-MVP
**Status:** 🔲 Not started
**Agent:** —
**Output:** —
**Notes:** —

> ⚠️ This story is Post-MVP and should not be started until MVP is complete and approved.

---

## Context

Global leaderboards create a sense of community and competitive motivation. Players want to see how they rank against others in their game mode, driving continued engagement and skill improvement. Separate leaderboards per mode (501, Cricket, etc.) ensure fair comparison. Rolling 30-day averages reward consistent play over single breakout games, and minimum play requirements ensure leaderboard integrity.

> Implements: FA §FR-L-01

---

## Acceptance Criteria

- [ ] Separate leaderboards per mode: 501/301 by 3-dart avg, Cricket by MPR; Number Focus excluded
- [ ] Rolling 30-day average; minimum 5 games to qualify
- [ ] Paginated: rank, display name, avatar, metric value
- [ ] User's own rank always visible (even if not on current page)
- [ ] Refreshes when online

---

## Technical Implementation Notes

> ⚠️ No detailed TA spec exists for this feature yet. The following is derived from the FA and general architecture patterns.

- New `Leaderboard` query/read model: LeaderboardEntryId, Rank (int), DisplayName (string), AvatarUrl (string?), MetricValue (decimal), UserId (string), Mode (enum: Game501, Game301, Cricket)
- Background job to compute rolling 30-day averages nightly:
  - For each mode, calculate per-player 3-dart average (501/301) or MPR (Cricket)
  - Filter to players with ≥5 games in window
  - Rank players by metric descending
  - Store computed ranks in Leaderboard table or view
- New `LeaderboardsController` with GET /api/leaderboard?mode={mode}&page={page}&pageSize={pageSize}
- Additional query to return user's own rank: GET /api/leaderboard?mode={mode}&userId={userId}
- Angular `features/leaderboard/` area with:
  - Mode selector (tabs or dropdown)
  - Paginated leaderboard table/list
  - User's rank card always visible (sticky or separate component)
  - Auto-refresh logic when app comes online
- Service layer to fetch leaderboard data and cache with stale-while-revalidate pattern

---

## Dependencies

- AUTH-02 — User Authentication & Profile — User identity and display name
- STAT-01 — Game Statistics Foundation — Game data and metrics to compute leaderboards
- LEAD-02 — Leaderboard Opt-Out — Leaderboard queries must filter by opt-in status

---

## Shared References

- ../../shared/architecture.md
- ../../shared/entities.md
