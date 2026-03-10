# DRILL-03 — In-Drill Scoring & Guidance

**Feature:** Training Drills
**Phase:** Post-MVP
**Status:** 🔲 Not started
**Agent:** —
**Output:** —
**Notes:** —

> ⚠️ This story is Post-MVP and should not be started until MVP is complete and approved.

---

## Context

The core of the drill experience is step-by-step structured feedback. Different drill types have different scoring logic (e.g., Halve It requires pass/fail per round; Bob's 27 and 501 variants track cumulative scoring). This story implements the scoring framework and guidance display to keep players on track during a drill.

> Implements: FA §FR-T-03

---

## Acceptance Criteria

- [ ] Step-by-step guidance during drill (e.g. "Now aim for T20 — throw 3 darts")
- [ ] Per-step result input (hits, misses, score)
- [ ] Pass/fail per round shown for applicable drills (e.g. Halve It)
- [ ] Cumulative performance tracked in real time

---

## Technical Implementation Notes

> ⚠️ No detailed TA spec exists for this feature yet. The following is derived from the FA and general architecture patterns.

- Drill-specific scoring engine: Abstract `DrillScoringStrategy` with implementations per drill type (e.g., `BobsScoreStrategy`, `HalveItScoreStrategy`)
- `DrillRound` entity to track per-round state: RoundNumber, Instructions, Target, Results, RoundStatus (enum)
- Drill session component with real-time UI:
  - Current step/target instructions
  - Input form for dart results (reuse GameSessionComponent's score input patterns)
  - Cumulative display of score, hits, pass/fail status
  - Next round button (or auto-advance where appropriate)
- Application service layer evaluating each round per the drill's scoring strategy
- LocalStorage or in-memory session state for responsive UI updates

---

## Dependencies

- DRILL-02 — Starting a Drill Session — Session must be initialized to begin scoring
- GAME-02 — Score Input & Validation — Reuse score input component and validation logic

---

## Shared References

- ../../shared/architecture.md
- ../../shared/entities.md
