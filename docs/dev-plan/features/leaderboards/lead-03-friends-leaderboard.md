# LEAD-03 — Friends Leaderboard

**Feature:** Leaderboards
**Phase:** Post-MVP
**Status:** 🔲 Not started
**Agent:** —
**Output:** —
**Notes:** —

---

## Context
Users can follow other players by display name or shareable link. A "Friends" filter on the leaderboard shows only followed players.
> Implements: FA FR-L-03
> ⚠️ This story is Post-MVP and should not be started until MVP is complete and approved.

---

## Acceptance Criteria
- [ ] "Follow" functionality available: by display name search or shareable profile link
- [ ] "Friends" tab/filter on global leaderboard (LEAD-01) shows only followed players
- [ ] Friends leaderboard ranked by same metric as global (3-dart avg or MPR)
- [ ] Unfollow action available on each friend
- [ ] Friends list persists across sessions
- [ ] Followed players must be opted-in to leaderboard (LEAD-02) to appear on Friends leaderboard
- [ ] Search UI: find and follow users by display name
- [ ] Shareable profile link: /profile/{userId} or similar; clicking link offers "Follow" action
- [ ] Friend count shown in profile

---

## Technical Implementation Notes

**Backend:**
- New entity: UserFollow { userFollowId, followerId, followedUserId, followedAt, isActive: bool }
- Unique constraint: (followerId, followedUserId)
- CreateFollowCommand handler: validates both users exist, creates UserFollow record
- DeleteFollowCommand handler: soft-delete or hard-delete UserFollow
- GetFriendsLeaderboardQuery handler:
  - Load followed users for current user (where isActive=true)
  - For each followed user, get 30-day metric (if LeaderboardOptIn=true and ≥5 games)
  - Sort by metric descending
  - Return GetFriendsLeaderboardDto: same schema as LEAD-01 but filtered to friends
- SearchUsersQuery handler: find users by displayName (prefix match, case-insensitive), limit 20 results
- API endpoints:
  - POST /api/friends/{followedUserId} → CreateFollowCommand
  - DELETE /api/friends/{followedUserId} → DeleteFollowCommand
  - GET /api/leaderboards/friends → GetFriendsLeaderboardQuery
  - GET /api/users/search?q={displayName} → SearchUsersQuery

**Angular:**
- Leaderboard component (LEAD-01) extended: add "Friends" tab alongside "Global"
- Friends tab: calls GET /api/leaderboards/friends; displays same ranked list as global
- If followed user opted-out of leaderboards, shown in "Friends" but marked as "Stats hidden"
- Follow flow:
  - Button/link in user search results: "Follow" action
  - Search input: searchable dropdown (GET /api/users/search?q={term})
  - Click result: POST CreateFollowCommand
  - Success: add to friends list, show toast "Following {displayName}"
- Unfollow action: button on each friend row → DELETE /api/friends/{userId} → remove from list
- Profile integration: display friend count in profile header
- Shareable link: /profile/{userId} shows option to Follow (if not already following and if current user authenticated)
- Profile route handler: resolve user data; show Follow button if not current user and not following

---

## Dependencies
- Depends on LEAD-01 (global leaderboard feature)
- Depends on LEAD-02 (opt-in requirement)
- Depends on PROF-01 (user profiles and search)
- Requires UserFollow entity and follow/unfollow commands

---

## Shared References
- [Domain Model](../../shared/domain-model.md) — UserFollow entity, user search capability
- [Architecture](../../shared/architecture.md) — Command handler pattern, Query handler pattern, soft-delete pattern
- [API Contracts](../../shared/api-contracts.md) — POST/DELETE /api/friends endpoint, GET /api/leaderboards/friends, GET /api/users/search
- [NFRs](../../shared/non-functional-requirements.md) — §12.1 (responsive leaderboard), search results in <1s, follow action in <1s
