# LEAD-03 — Friends Leaderboard

**Feature:** Leaderboards & Sharing
**Phase:** Post-MVP
**Status:** 🔲 Not started
**Agent:** —
**Output:** —
**Notes:** —

> ⚠️ This story is Post-MVP and should not be started until MVP is complete and approved.

---

## Context

Friendly competition among known players is often more motivating than anonymous global ranking. A friends leaderboard lets players track their standing against a curated group, creating a tighter community and encouraging regular play within networks.

> Implements: FA §FR-L-03

---

## Acceptance Criteria

- [ ] User can follow other players by display name or shareable link
- [ ] "Friends" leaderboard filters to followed players + self
- [ ] Follow/unfollow actions available

---

## Technical Implementation Notes

> ⚠️ No detailed TA spec exists for this feature yet. The following is derived from the FA and general architecture patterns.

- New `Follow` entity: FollowId (Guid), FollowerId (string), FolloweeId (string), CreatedAt (DateTime), with unique constraint (FollowerId, FolloweeId)
- New `FollowsController`:
  - POST /api/friends/{userId} — follow a user (add Follow record)
  - DELETE /api/friends/{userId} — unfollow a user (remove Follow record)
  - GET /api/friends — list current user's follows
- New leaderboard query: GET /api/leaderboard/friends?mode={mode} returning same structure as LEAD-01 but filtered to:
  - Current user
  - All users followed by current user
  - Ranked by metric descending
- Follow discovery UI:
  - Search by display name to find and follow players
  - Shareable follow link (e.g., /user/{username}/follow or referral token)
  - Follow button on other players' profile pages (optional)
- Friends leaderboard component reusing LEAD-01 leaderboard table with different data source
- Service layer to manage Follow relationships

---

## Dependencies

- LEAD-01 — Global Leaderboard — Leaderboard infrastructure and query patterns
- AUTH-02 — User Authentication & Profile — User identity and profiles

---

## Shared References

- ../../shared/architecture.md
- ../../shared/entities.md
