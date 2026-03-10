# LEAD-05 — Achievements & Badges

**Feature:** Leaderboards & Sharing
**Phase:** Post-MVP
**Status:** 🔲 Not started
**Agent:** —
**Output:** —
**Notes:** —

> ⚠️ This story is Post-MVP and should not be started until MVP is complete and approved.

---

## Context

Badges recognize milestones and provide intrinsic motivation for continued play. Variety in badge types—covering different game modes, drill achievements, and long-term engagement—ensures all player types feel recognized. In-app notifications celebrate achievements in real time.

> Implements: FA §FR-L-05

---

## Acceptance Criteria

- [ ] Badges awarded for milestones: First 180, 10 games, avg above 40/60/80/100, 7-day streak, 3-star drill, NF Sharp Eye (≥80% accuracy), NF Treble Hunter (≥50% treble rate), NF All-Round (all numbers completed)
- [ ] Badges visible on profile
- [ ] Earning badge triggers in-app notification
- [ ] Badges shareable via FR-L-04

---

## Technical Implementation Notes

> ⚠️ No detailed TA spec exists for this feature yet. The following is derived from the FA and general architecture patterns.

- New `Badge` entity: BadgeId (Guid), Name (string), Description (string), Icon (string, URL or SVG), Category (enum: GameMode/Drill/Engagement), Criteria (JSON or separate entity)
- New `UserBadge` entity: UserBadgeId (Guid), UserId (string), BadgeId (Guid), AwardedAt (DateTime)
- Seed data SQL script with badge definitions for each milestone type
- Badge evaluation service with trigger points:
  - 180 check: When session is created with 180 score (once per user)
  - 10 games: Evaluate after each session completion
  - Avg above 40/60/80/100: Evaluate nightly or on-demand after session
  - 7-day streak: Nightly check for consecutive play days
  - 3-star drill: On drill completion (DRILL-04)
  - NF Sharp Eye/Treble Hunter/All-Round: On Number Focus session completion
- Notification service to emit badge earned event and trigger in-app notification
- Angular profile component displaying:
  - Badge grid/list showing earned badges
  - Badge detail modal with description and award date
  - Optional: Badge progress for in-progress badges (e.g., "7-day streak: 5/7 days")
- Integration with LEAD-04 to allow badge sharing as image card

---

## Dependencies

- AUTH-02 — User Authentication & Profile — User identity and profile display
- STAT-03 — Personal Bests — Stat milestones and averages
- GAME-04 — Number Focus Game Mode — NF-specific badge criteria
- DRILL-04 — Drill Completion & Results — Drill achievements
- NOTIF-01 — In-App Notifications (if exists) — Badge notification delivery

---

## Shared References

- ../../shared/architecture.md
- ../../shared/entities.md
