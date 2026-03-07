# DRILL-04 — Drill Completion & Results

**Feature:** Training Drills
**Phase:** Post-MVP
**Status:** 🔲 Not started
**Agent:** —
**Output:** —
**Notes:** —

---

## Context
Results screen after drill completion. Shows score/hit rate vs target, PB comparison, star rating (1-3 stars), and options to repeat or return to library.
> Implements: FA FR-T-04
> ⚠️ This story is Post-MVP and should not be started until MVP is complete and approved.

---

## Acceptance Criteria
- [ ] Results screen displays drill name and completion time
- [ ] Score/hit rate shown prominently with target comparison (e.g. "18/20 rings" or "89% accuracy")
- [ ] Pass/fail summary shown if drill has step outcomes
- [ ] Personal best comparison displayed: current score vs previous best (if exists)
- [ ] Star rating shown: 1-3 stars based on score vs target
  - [ ] 3 stars: score meets or exceeds target
  - [ ] 2 stars: score 75-99% of target
  - [ ] 1 star: score <75% of target
- [ ] Drill result saved to database
- [ ] "Repeat" button available to start same drill again
- [ ] "Back to Library" button returns to DRILL-01
- [ ] Optional: "Share" button to trigger LEAD-04 sharing flow

---

## Technical Implementation Notes

**Backend:**
- DrillResult entity saved by SaveDrillResultCommand (from DRILL-03)
- DrillResult computed fields: score (sum of step scores), starsAwarded (based on score vs target), achievedAt = DateTime.UtcNow
- GetDrillResultQuery handler: loads DrillResult by drillResultId, includes drill metadata, prior best score
- PB detection: after saving, compare current score against best DrillResult for this drill; update PersonalBest if exceeded
- Return DrillResultDto: { drillName, score, target, starsAwarded, achievedAt, previousBestScore?, improvement? }

**Angular:**
- Standalone component: features/drills/drill-results/
- Route: /drills/{drillSessionId}/results
- Display sections:
  - Header: drill name, time elapsed (completedAt - startedAt)
  - Score card: large score display, target, comparison bar
  - Star rating: animated star icons (1-3) with accompanying message
  - PB comparison: "New Personal Best!" or "Beat by 5 pts" or "Close to PB (3 pts away)"
  - Pass/fail summary (if applicable): breakdown of steps passed/failed
- Buttons:
  - "Repeat Drill" (primary): POST CreateDrillSessionCommand for same drill; navigate to DRILL-02
  - "Back to Library" (secondary): navigate to DRILL-01
  - "Share" (tertiary, optional): emit shareResult event; parent integrates LEAD-04 sharing logic
- Animations: star fade-in, score counter animation from 0 to final value
- Responsive: full screen on mobile, centered card on desktop

---

## Dependencies
- Depends on DRILL-03 (drill result context)
- Depends on STATS-03 for PB comparison/notification
- Uses DrillResult entity

---

## Shared References
- [Domain Model](../../shared/domain-model.md) — DrillResult entity, PersonalBest linkage
- [Architecture](../../shared/architecture.md) — Query handler pattern, animation patterns
- [API Contracts](../../shared/api-contracts.md) — GET /api/drills/{drillSessionId}/results endpoint, DrillResultDto schema
- [NFRs](../../shared/non-functional-requirements.md) — §12.1 (responsive), results load in <1s, star animation smooth (60fps)
