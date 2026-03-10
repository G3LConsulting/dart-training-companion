# DRILL-06 — Drill Recommendations

**Feature:** Training Drills
**Phase:** Post-MVP
**Status:** 🔲 Not started
**Agent:** —
**Output:** —
**Notes:** —

> ⚠️ This story is Post-MVP and should not be started until MVP is complete and approved.

---

## Context

Players often don't know which drill to practice next. Intelligent recommendations based on current performance gaps turn the drill library into a personalized coach. Analyzing recent stats (e.g., low checkout percentage, weak doubles) and suggesting targeted drills increases engagement and training effectiveness.

> Implements: FA §FR-T-06

---

## Acceptance Criteria

- [ ] Based on recent stats (low checkout %, weak doubles), app recommends a drill
- [ ] "Recommended drill for today" shown on home screen
- [ ] Recommendation updates based on changing stats

---

## Technical Implementation Notes

> ⚠️ No detailed TA spec exists for this feature yet. The following is derived from the FA and general architecture patterns.

- New `GetRecommendedDrillQuery` in Application layer
- Recommendation engine logic:
  - Analyze recent games (e.g., last 10 games or last 7 days) for weakness patterns
  - Map weakness patterns to recommended drills (e.g., checkout % < 40% → Checkout Challenge)
  - Filter out drills user recently completed (avoid repetition)
  - Return top 1-3 recommendations
- Integration with home screen component to display "Recommended drill for today" widget
- Service-layer query to fetch recent stats and compute recommendations on demand
- Optional: Cache recommendation for 24 hours to avoid constant re-computation
- Optional: A/B test different recommendation algorithms

---

## Dependencies

- DRILL-01 — Built-in Drill Library — Drill library must exist to recommend from
- STAT-01 — Game Statistics Foundation — Recent stats needed to analyze weaknesses
- HOME-01 — Home Screen (MVP) — Display location for recommendation

---

## Shared References

- ../../shared/architecture.md
- ../../shared/entities.md
