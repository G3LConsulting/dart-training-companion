# DRILL-02 — Starting a Drill Session

**Feature:** Training Drills
**Phase:** Post-MVP
**Status:** 🔲 Not started
**Agent:** —
**Output:** —
**Notes:** —

---

## Context
User selects a drill from the library, reads instructions, confirms readiness, and starts the session.
> Implements: FA FR-T-02
> ⚠️ This story is Post-MVP and should not be started until MVP is complete and approved.

---

## Acceptance Criteria
- [ ] Drill instructions displayed clearly before start
- [ ] Instructions include: goal, target score/accuracy, methodology explanation, estimated duration
- [ ] "Ready to Start" confirmation button shown (prevents accidental start)
- [ ] On confirmation, DrillSession created with startedAt timestamp
- [ ] DrillSession linked to user and drill
- [ ] User navigated to in-drill scoring screen (DRILL-03)
- [ ] "Cancel" option allows user to exit without starting

---

## Technical Implementation Notes

**Backend:**
- New entity: DrillSession { drillSessionId, userId, drillId, startedAt, completedAt?, status: enum (InProgress, Completed, Abandoned) }
- CreateDrillSessionCommand handler:
  - Validates user and drill exist
  - Creates DrillSession with startedAt = DateTime.UtcNow
  - Returns DrillSessionDto { drillSessionId, drill: { name, instructions }, startedAt }
- POST /api/drills/{drillId}/session → { drillSessionId, drill: DrillDetailDto }

**Angular:**
- Standalone component: features/drills/drill-start-confirmation/
- Route: /drills/{drillId}/start
- Get drill details from route params or service cache
- Display drill instructions in large readable font
- Instructions card shows: goal, target, methodology, duration
- Two buttons: "I'm Ready" (primary) and "Cancel" (secondary)
- "Cancel" navigates back to library
- "I'm Ready" POST to CreateDrillSessionCommand, then navigate to /drills/{drillSessionId}/scoring (DRILL-03)
- Loading state: spinner during session creation; error handling for network issues

---

## Dependencies
- Depends on DRILL-01 (drill library and drill selection)
- Requires DrillSession entity and CreateDrillSessionCommand

---

## Shared References
- [Domain Model](../../shared/domain-model.md) — DrillSession entity
- [Architecture](../../shared/architecture.md) — Command handler pattern, routing strategy
- [API Contracts](../../shared/api-contracts.md) — POST /api/drills/{drillId}/session endpoint
- [NFRs](../../shared/non-functional-requirements.md) — §12.1 (responsive), session creation in <1s
