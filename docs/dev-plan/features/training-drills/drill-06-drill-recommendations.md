# DRILL-06 — Drill Recommendations

**Feature:** Training Drills
**Phase:** Post-MVP
**Status:** 🔲 Not started
**Agent:** —
**Output:** —
**Notes:** —

---

## Context
Surface a recommended drill on the home screen based on weak spots identified in recent stats (e.g. low NF accuracy on Bull → recommend Bull drill).
> Implements: FA FR-T-06
> ⚠️ This story is Post-MVP and should not be started until MVP is complete and approved.

---

## Acceptance Criteria
- [ ] Home screen (PROF-05) shows 1 recommended drill in highlighted section
- [ ] Recommendation reason displayed (e.g. "Your Bull accuracy is below 30%")
- [ ] Recommendation updates after each new session completion
- [ ] Recommended drill links to drill library (DRILL-01) for selection
- [ ] Recommendation logic based on weak spots from recent stats (last 30 days)
- [ ] No recommendation shown if user has no weak spots or insufficient data

---

## Technical Implementation Notes

**Backend:**
- New query: RecommendDrillQuery handler
- Logic: identify weak spots in user's stats (low NF accuracy on specific numbers, low checkout %, etc.)
- Weak spot criteria:
  - NF accuracy <50% on a number (any) → recommend drill for that number
  - 501/301 checkout % <60% → recommend Checkout accuracy drill
  - 501/301 average <20 → recommend Scoring Power drill
- Query loads UserStats and NumberFocusStats for last 30 days
- Returns top-1 weak spot with reason string and matching drill recommendation
- Returns RecommendDrillDto: { drillId, drillName, weakSpotReason, recommendedAt }
- Caching: 24-hour cache per userId (invalidate on session creation)

**Angular:**
- Integration in features/home/ (PROF-05) profile screen
- Recommendation card component: features/drills/drill-recommendation-card/
- Card displays:
  - Drill name and icon/image
  - Reason text: "{MetricName} is {currentValue}% (below {threshold}%)"
  - Difficulty badge
  - "Start Drill" or "View Library" button
- "Start Drill" navigates to DRILL-02 (start confirmation)
- "View Library" navigates to DRILL-01 with drill pre-selected/highlighted
- No recommendation shown: card hidden or "Keep it up!" message if no weak spots detected
- Update mechanism: subscribe to session-completed event (via WebSocket or polling); refresh recommendation on PROF-05 screen
- Responsive: full width on mobile, card-style on desktop

---

## Dependencies
- Depends on DRILL-01 (drill library and drill data)
- Depends on STATS-01 (weak spot detection from stats)
- Depends on PROF-05 (home screen integration)
- Requires RecommendDrillQuery and weak spot detection logic

---

## Shared References
- [Domain Model](../../shared/domain-model.md) — UserStats, Drill entities, weak spot analysis
- [Architecture](../../shared/architecture.md) — Query handler pattern, event subscription pattern
- [API Contracts](../../shared/api-contracts.md) — GET /api/drills/recommend endpoint, RecommendDrillDto schema
- [NFRs](../../shared/non-functional-requirements.md) — §12.1 (responsive card), recommendation loads in <2s after session save
