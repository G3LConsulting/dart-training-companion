# HIST-02 — Session Deletion & Stats Recalculation

**Feature:** Session History
**Phase:** MVP
**Story ID:** HIST-02
**Status:** Not Started
**Priority:** P1
**Complexity:** L

---

## Context

Users need the ability to delete erroneous or unwanted sessions from their history. When a session is deleted, all aggregate statistics and personal bests must be recalculated asynchronously to reflect only the remaining sessions. This prevents stale stats from lingering after deletion.

**Implements:**
- FA §FR-P-04: "User can delete sessions and have stats automatically recalculated"
- TA §3: BackgroundService-based recalculation with Channel<Guid>
- TA §6: DeleteSessionCommand, GetRecalculationStatusQuery

---

## Acceptance Criteria

- [ ] User can delete a session from session detail view with confirmation prompt
- [ ] Confirmation message: "Deleting this session will update your statistics. This cannot be undone."
- [ ] After deletion, stats recalculation happens asynchronously in background
- [ ] User sees "Updating stats..." indicator during recalculation
- [ ] User can poll recalculation status (GET /api/stats/recalculation-status)
- [ ] After recalculation completes, all aggregate stats and PBs reflect remaining sessions only
- [ ] Soft-delete used (IsDeleted flag, not physical deletion)

---

## Implementation Tasks

| Task ID | Title | Layer | Status | Assigned |
|---------|-------|-------|--------|----------|
| [HIST-02-T01](./hist-02-session-deletion/HIST-02-T01-TASK.md) | API: DeleteSessionCommand handler | Backend | Not Started | — |
| [HIST-02-T02](./hist-02-session-deletion/HIST-02-T02-TASK.md) | API: StatsRecalculationService (BackgroundService) | Backend | Not Started | — |
| [HIST-02-T03](./hist-02-session-deletion/HIST-02-T03-TASK.md) | API: GetRecalculationStatusQuery | Backend | Not Started | — |
| [HIST-02-T04](./hist-02-session-deletion/HIST-02-T04-TASK.md) | Frontend: Delete confirmation + recalculation polling | Frontend | Not Started | — |
| [HIST-02-T05](./hist-02-session-deletion/HIST-02-T05-TASK.md) | Tests: Deletion and recalculation tests | Backend | Not Started | — |

---

## Dependencies

- **HIST-01:** Session detail view must exist before delete button can be added
- **STAT-01:** Stats dashboard must exist for recalculation to make sense

---

## Shared References

- [Domain Model: GameSession, UserStats](../../shared/DOMAIN-MODEL.md)
- [API Contracts: Sessions](../../shared/API-CONTRACTS.md#sessions)
- [Architecture: BackgroundService, Channel<T>](../../shared/ARCHITECTURE.md)

---

## Key Design Decisions

1. **Soft Delete:** Uses IsDeleted flag instead of physical deletion for audit trail
2. **Async Recalculation:** Runs in background to avoid blocking the delete request
3. **Status Polling:** Frontend polls to know when recalculation completes
4. **All-or-Nothing:** Recalculation is atomic per user (all stats updated together)

---

## Definition of Done

- All acceptance criteria met
- Code reviewed and approved
- Unit tests written and passing (>80% coverage)
- Integration tests confirm deletion and recalculation flow
- Frontend tested on mobile viewports
- No console errors or warnings
- Recalculation performance acceptable (even with large session counts)
