# DRILL-01 — Built-in Drill Library

**Feature:** Training Drills
**Phase:** Post-MVP
**Status:** 🔲 Not started
**Agent:** —
**Output:** —
**Notes:** —

> ⚠️ This story is Post-MVP and should not be started until MVP is complete and approved.

---

## Context

Players need access to structured training drills to improve specific skills and break out of casual play patterns. A built-in library of proven drills provides immediate value without requiring users to construct their own training routines.

This story establishes the foundation for all drill features by defining the core drill entity, populating it with well-known competitive drills, and making them available offline.

> Implements: FA §FR-T-01

---

## Acceptance Criteria

- [ ] Built-in drill library with drills organized by category and difficulty (Beginner, Intermediate, Advanced)
- [ ] At least 6 named drills: Bob's 27, JDC Challenge, A1 Routine, Checkout Challenge, Doubles Boomerang, Shanghai
- [ ] Each drill shows name, description, instructions, target, estimated duration
- [ ] Library available offline

---

## Technical Implementation Notes

> ⚠️ No detailed TA spec exists for this feature yet. The following is derived from the FA and general architecture patterns.

- New `Drill` entity: DrillId (Guid), Name (string), Description (string), Instructions (string), Category (string), Difficulty (enum: Beginner/Intermediate/Advanced), Target (string), EstimatedDurationMinutes (int), IsBuiltIn (bool)
- New `DrillsController` with GET /api/drills endpoint (paginated, filterable by category/difficulty)
- Seed data SQL script populating at least 6 built-in drills
- Angular `features/drills/` area with drill library component
- Local caching of drill data via service layer to support offline access
- Drill detail modal/page showing full instructions before user starts

---

## Dependencies

- AUTH-02 — User Authentication & Profile — Authentication required to save drill session history

---

## Shared References

- ../../shared/architecture.md
- ../../shared/entities.md
