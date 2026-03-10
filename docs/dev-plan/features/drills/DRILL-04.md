# DRILL-04 — Drill Completion & Results

**Feature:** Training Drills
**Phase:** Post-MVP
**Status:** 🔲 Not started
**Agent:** —
**Output:** —
**Notes:** —

> ⚠️ This story is Post-MVP and should not be started until MVP is complete and approved.

---

## Context

Completing a drill is a milestone. The results screen provides immediate feedback on performance versus the drill's target, comparison to personal best, and motivation through a visual rating. Saved results become part of the player's training history and feed into recommendations and badges.

> Implements: FA §FR-T-04

---

## Acceptance Criteria

- [ ] Results screen shows: score/hit rate vs target, PB comparison, star rating (1-3 stars)
- [ ] Option to repeat drill or return to library
- [ ] Drill results saved to history

---

## Technical Implementation Notes

> ⚠️ No detailed TA spec exists for this feature yet. The following is derived from the FA and general architecture patterns.

- New `DrillResult` entity: DrillResultId (Guid), UserId (string), DrillId (Guid), CompletedAt (DateTime), FinalScore (int or decimal), TargetScore (int or decimal), Stars (enum: 1/2/3), PBScore (int? for comparison), DrillSessionId (Guid)
- New `DrillResultsController` with POST /api/drills/{drillId}/sessions/{sessionId}/complete endpoint
- Angular drill results component displaying:
  - Final score / hit rate prominently
  - Target and PB for comparison (e.g., "Target: 100, You: 87, PB: 92")
  - Star rating (1-3 stars based on performance thresholds)
  - "Repeat Drill" button (navigates back to DRILL-02 flow)
  - "Back to Library" button
- Star rating logic: Define performance thresholds per drill type (e.g., meeting target = 3 stars, 80% of target = 2 stars, below 80% = 1 star)
- Service to compute PB and determine star rating, then persist DrillResult

---

## Dependencies

- DRILL-03 — In-Drill Scoring & Guidance — Drill must complete with valid results before saving
- STAT-03 — Personal Bests — PB comparison and retrieval

---

## Shared References

- ../../shared/architecture.md
- ../../shared/entities.md
