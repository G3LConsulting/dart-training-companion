# LEAD-02 — Leaderboard Opt-Out

**Feature:** Leaderboards & Sharing
**Phase:** Post-MVP
**Status:** 🔲 Not started
**Agent:** —
**Output:** —
**Notes:** —

> ⚠️ This story is Post-MVP and should not be started until MVP is complete and approved.

---

## Context

Not all players want their data on public leaderboards. Offering opt-out respects user privacy preferences and removes any friction for players concerned about visibility. Default opt-out (privacy-by-default) ensures users make an active choice if they want to be ranked.

> Implements: FA §FR-L-02

---

## Acceptance Criteria

- [ ] User can toggle leaderboard visibility on/off in profile settings
- [ ] When opted out, user's data not shown on any public leaderboard
- [ ] Default is opted-out (LeaderboardOptIn=false)

---

## Technical Implementation Notes

> ⚠️ No detailed TA spec exists for this feature yet. The following is derived from the FA and general architecture patterns.

- `ApplicationUser` entity already modeled with `LeaderboardOptIn` (bool, default false)
- Extend `UpdateProfileCommand` to accept LeaderboardOptIn flag
- Profile settings UI toggle for "Show me on leaderboards"
- Filter all leaderboard queries to exclude users where LeaderboardOptIn = false:
  - Modify background job leaderboard computation to exclude opted-out users
  - Modify LeaderboardsController GET endpoints with WHERE LeaderboardOptIn = true
- Service layer method to update user's LeaderboardOptIn status via UpdateProfileCommand
- No immediate UI changes needed for opted-out users except the settings toggle

---

## Dependencies

- LEAD-01 — Global Leaderboard — Leaderboard infrastructure to filter
- PROF-01 — User Profile & Settings (MVP) — Settings page location for opt-in toggle

---

## Shared References

- ../../shared/architecture.md
- ../../shared/entities.md
