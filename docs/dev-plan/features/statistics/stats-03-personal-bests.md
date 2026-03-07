# STATS-03 — Personal Bests

**Feature:** Statistics
**Phase:** MVP
**Status:** 🔲 Not started
**Agent:** —
**Output:** —
**Notes:** —

---

## Context
Dedicated section showing all-time best values for all tracked metrics, with a congratulatory notification when a new PB is set.
> Implements: FA FR-S-03, TA §5 (PersonalBest entity), TA §6 (GetPersonalBestsQuery)

---

## Acceptance Criteria
- [ ] All-time PBs displayed per game mode
- [ ] 501/301 metrics shown: highest turn, highest checkout, best 3-dart average
- [ ] Cricket metrics shown: best MPR
- [ ] Number Focus metrics shown: best accuracy % and best weighted accuracy % per number (1-20 + Bull)
- [ ] PBs shown on home screen highlights section (PROF-05)
- [ ] Congratulatory notification (toast or banner) triggered when a new PB is detected after session save
- [ ] MetricKey format: avg_3dart_501, highest_turn_501, highest_checkout_501, mpr_cricket, nf_accuracy_20, nf_weighted_accuracy_bull, etc.
- [ ] PersonalBest.SessionId links PB to originating session (nullable for aggregated metrics)
- [ ] GET /api/stats/personal-bests returns PersonalBestsDto with all PBs
- [ ] PB details include achieved date and session link for replay (DESK-04)

---

## Technical Implementation Notes

**Backend:**
- PersonalBest entity: { userId, metricKey, value, achievedAt, sessionId? }
- Unique index on (userId, metricKey)
- GetPersonalBestsQuery handler: loads all PersonalBests for user, returns PersonalBestsDto: { bests: [{ metricKey, value, achievedAt, sessionId? }] }
- PB detection logic in CreateSessionCommand handler:
  - After session saved, compute session's metrics (avg, highest turn, etc.)
  - Compare each metric against current PersonalBest record
  - If new value exceeds existing PB, update PersonalBest and emit PbAchievedDomainEvent
  - PbAchievedDomainEvent contains metricKey, oldValue, newValue, sessionId
- Caching: PersonalBests cached indefinitely until new PB detected

**Angular:**
- Standalone component: features/stats/personal-bests/
- Display: list of PBs grouped by mode (501, 301, Cricket, NF)
- Each PB card shows: metricKey label, value, achieved date, optional link to session
- Integration with PROF-05 home screen: top 3 PBs shown in highlights section
- Notification service: subscribe to PbAchievedDomainEvent (via WebSocket or polling) and show toast
- Toast template: "🎯 New Personal Best! {metricKey}: {newValue} (was {oldValue})"
- Toast action: "View" navigates to personal-bests detail; "Replay" navigates to DESK-04 session detail

---

## Dependencies
- Depends on PROF-01 (user context)
- Depends on GAME-04 (sessions must exist to compute PBs)
- Depends on PROF-05 for home screen highlights section

---

## Shared References
- [Domain Model](../../shared/domain-model.md) — PersonalBest entity, MetricKey enum, KPI definitions
- [Architecture](../../shared/architecture.md) — DomainEvent pattern (PbAchievedDomainEvent), Query handler pattern
- [API Contracts](../../shared/api-contracts.md) — GET /api/stats/personal-bests endpoint, PersonalBestsDto schema
- [NFRs](../../shared/non-functional-requirements.md) — §12.1 (responsive), notification shown within 1s of session save
