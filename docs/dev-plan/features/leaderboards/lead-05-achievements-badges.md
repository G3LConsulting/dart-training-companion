# LEAD-05 — Achievements & Badges

**Feature:** Leaderboards
**Phase:** Post-MVP
**Status:** 🔲 Not started
**Agent:** —
**Output:** —
**Notes:** —

---

## Context
Award badges for milestones: First 180, 10 games played, 7-day streak, avg benchmarks, drill stars, NF Sharp Eye/Treble Hunter/All-Round. Visible on profile. Shareable via LEAD-04.
> Implements: FA FR-L-05
> ⚠️ This story is Post-MVP and should not be started until MVP is complete and approved.

---

## Acceptance Criteria
- [ ] Badges awarded automatically for milestones:
  - [ ] First 180 (501/301): hit a 180 score in a turn
  - [ ] 10 games played (per mode)
  - [ ] 7-day streak: play darts on 7 consecutive days
  - [ ] Average benchmarks: 3-dart avg ≥20, ≥25, ≥30 (501/301)
  - [ ] Checkout benchmarks: checkout % ≥70%, ≥80%, ≥90%
  - [ ] Drill stars: earn 10+ 3-star drill results (post-MVP, depends on DRILL-04)
  - [ ] Number Focus specializations: Sharp Eye (50+ sets, avg accuracy ≥80%), Treble Hunter (20+ sets, 80%+ accuracy on 20), All-Round (80%+ on all numbers)
- [ ] Badges visible on user profile (PROF-01)
- [ ] Badge display: icon, name, description, achievement date
- [ ] Push notification (or in-app toast) when badge earned
- [ ] Badges shareable via LEAD-04 image generation
- [ ] Badge progress shown (e.g. "8/10 games toward badge")
- [ ] Leaderboard board profile shows earned badges (optional)

---

## Technical Implementation Notes

**Backend:**
- New entities: Badge { badgeId, name, description, icon: string, category: enum (Milestone, Average, Specialty) }, UserBadge { userBadgeId, userId, badgeId, awardedAt }
- Unique constraint: (userId, badgeId) to prevent duplicate awards
- Badge data seeded via EF Core or JSON (20-30 predefined badges)
- Badge check logic: triggered in event handlers
  - CreateSessionCommand handler: check for First 180, Average benchmark, Checkout benchmark, streak
  - SaveDrillResultCommand handler: check for Drill stars
  - Session completion: re-check Number Focus specializations
- DomainEvent: BadgeAwardedDomainEvent { userId, badgeId, badgeName, awardedAt }
- GetUserBadgesQuery handler: loads all earned badges for user with achievement dates
- API endpoints:
  - GET /api/users/{userId}/badges → GetUserBadgesQuery
  - GET /api/badges → list all badges (for badge collection view)

**Details on badge checks:**
- First 180: in CreateSessionCommand, check if session.turns contains turn.score=180; if found, check if user has First180Badge; if not, award
- 10 games per mode: after session save, count sessions per mode; if count reaches 10 and badge not yet earned, award
- 7-day streak: after session save, check consecutive days with sessions (DateTime comparisons); if 7 consecutive days met, award
- Average benchmarks: after session save, compute current 30-day average for mode; if meets threshold (≥20, ≥25, ≥30), award corresponding badge
- Checkout: similar to average benchmarks
- Drill stars: in SaveDrillResultCommand, check if DrillResult.starsAwarded=3; count user's 3-star drills; if reaches 10, award
- NF specializations: GetNumberFocusStatsQuery computes; after session, check Sharp Eye (50+ sets, 80%+ avg accuracy), Treble Hunter (20+ sets on 20, 80%+), All-Round (80%+ on all 21 numbers)

**Angular:**
- Standalone component: features/profile/badges-section/ (displays on user profile PROF-01)
- Badge card: icon (SVG or image), name, description, achievement date
- Badge grid/list: responsive layout (3 columns on desktop, 1 on mobile)
- Locked badges: show locked/greyed out icon with progress bar (e.g. "8/10 games")
- Earned badges: highlighted, clickable to view details and share
- Share badge: "Share" button on earned badge card → LEAD-04 image generation with badge data
- Notification: subscribe to BadgeAwardedDomainEvent (via WebSocket or polling); show toast "Badge Earned! {badgeName}" with optional animation
- Badge collection view: features/badges/badge-collection/ shows all badges (earned + locked) with progress toward locked badges
- Optional leaderboard profile: show top 3-5 recent badges on public profile view (PROF-06, if public profiles are featured)

---

## Dependencies
- Depends on GAME-04 (session creation for milestone checks)
- Depends on DRILL-04 (drill results for Drill Stars badge)
- Depends on STATS-01 (stats computation for average/checkout benchmarks)
- Depends on PROF-01 (profile display)
- Depends on LEAD-04 (badge sharing via image generation)
- Requires Badge and UserBadge entities, badge seeding

---

## Shared References
- [Domain Model](../../shared/domain-model.md) — Badge, UserBadge entities, milestone definitions
- [Architecture](../../shared/architecture.md) — DomainEvent pattern, event subscription, badge check logic in command handlers
- [API Contracts](../../shared/api-contracts.md) — GET /api/users/{userId}/badges, GET /api/badges, BadgeDto schema
- [NFRs](../../shared/non-functional-requirements.md) — §12.1 (responsive badge grid), notification shown within 1s of badge earned, badge image generation via LEAD-04
