# DRILL-02 — Starting a Drill Session

**Feature:** Training Drills
**Phase:** Post-MVP
**Status:** 🔲 Not started
**Agent:** —
**Output:** —
**Notes:** —

> ⚠️ This story is Post-MVP and should not be started until MVP is complete and approved.

---

## Context

Users need a clear entry point into drill-based training. The session initiation flow establishes intent, ensures the user understands what they're about to do, and creates a timestamped record of the training activity. This flow bridges the drill library with active gameplay.

> Implements: FA §FR-T-02

---

## Acceptance Criteria

- [ ] User selects drill from library and starts session
- [ ] Instructions displayed before drill begins
- [ ] User confirms readiness before starting

---

## Technical Implementation Notes

> ⚠️ No detailed TA spec exists for this feature yet. The following is derived from the FA and general architecture patterns.

- New `DrillSession` entity: DrillSessionId (Guid), UserId (string), DrillId (Guid), StartedAt (DateTime), CompletedAt (DateTime?, nullable until session completes), CurrentRound (int), Results (JSON or related entity collection)
- New `DrillSessionsController` with POST /api/drills/{drillId}/sessions endpoint to create session
- Angular drill session initialization component with:
  - Full drill instructions display
  - "Ready to start?" confirmation button
  - Navigation back to library
- Service layer method to instantiate DrillSession and persist it
- Optional timer/estimated duration countdown shown during confirmation

---

## Dependencies

- DRILL-01 — Built-in Drill Library — Drill must exist in library before session can start

---

## Shared References

- ../../shared/architecture.md
- ../../shared/entities.md
