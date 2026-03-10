# DRILL-05 — Custom Drills

**Feature:** Training Drills
**Phase:** Post-MVP
**Status:** 🔲 Not started
**Agent:** —
**Output:** —
**Notes:** —

> ⚠️ This story is Post-MVP and should not be started until MVP is complete and approved.

---

## Context

Power users and competitive players want to design their own training routines tailored to specific weaknesses. Allowing users to create simple custom drills (name, target, goal) extends the drill feature without requiring complex scripting. Custom drills are saved to the user's profile and appear alongside built-in drills.

> Implements: FA §FR-T-05

---

## Acceptance Criteria

- [ ] User can create simple custom drill: name, target, goal
- [ ] Custom drills saved to profile, appear under "My Drills" in library
- [ ] Custom drills playable like built-in drills

---

## Technical Implementation Notes

> ⚠️ No detailed TA spec exists for this feature yet. The following is derived from the FA and general architecture patterns.

- Extend `Drill` entity with: IsCustom (bool), CreatedByUserId (string, nullable), CreatedAt (DateTime, nullable)
- New `CreateCustomDrillCommand` in Application layer
- New `DrillsController` POST /api/drills endpoint (create custom) with authorization to prevent tampering
- Angular drill library component enhancement:
  - Separate "My Drills" section in library UI
  - "Create Custom Drill" button launching simple form (name, target, goal)
  - Form validation (e.g., name required, target reasonable)
- Query filtering to show:
  - All built-in drills (IsCustom = false)
  - Current user's custom drills (IsCustom = true AND CreatedByUserId = currentUserId)
- Reuse existing drill session flow (DRILL-02+) for custom drills with no special handling needed

---

## Dependencies

- DRILL-01 — Built-in Drill Library — Library infrastructure and drill entity baseline
- AUTH-02 — User Authentication & Profile — Authorization check for custom drill ownership

---

## Shared References

- ../../shared/architecture.md
- ../../shared/entities.md
