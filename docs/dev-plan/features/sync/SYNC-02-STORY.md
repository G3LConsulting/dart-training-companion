# SYNC-02 — Sync Conflict Detection & Resolution

**Feature:** Multi-Device Sync
**Phase:** MVP
**Story ID:** SYNC-02
**Status:** Not Started
**Priority:** P2
**Complexity:** L

---

## Context

When users play offline on multiple devices simultaneously, completed sessions from both devices may conflict (overlapping time windows, same game mode). This story implements detection of such conflicts during sync and provides a UI for users to resolve them by choosing which version to keep.

**Implements:**
- FA §FR-P-03: "Conflict resolution for multi-device sync"
- TA §6: GetPendingConflictsQuery, ResolveConflictCommand

---

## Acceptance Criteria

- [ ] When sync detects conflicting sessions (same account, both offline, time overlap), conflicts flagged
- [ ] Conflict resolution screen shows conflicting sessions side by side (date, mode, key stats)
- [ ] User can choose: keep both, keep one (device A or B), keep neither
- [ ] After resolution, aggregate stats and PBs recalculated
- [ ] Unambiguous sessions (only on one device) merge automatically without user interaction
- [ ] Conflicts stored temporarily until resolved

---

## Implementation Tasks

| Task ID | Title | Layer | Status | Assigned |
|---------|-------|-------|--------|----------|
| [SYNC-02-T01](./sync-02-conflict-resolution/SYNC-02-T01-TASK.md) | API: Conflict detection in SyncSessionsCommand | Backend | Not Started | — |
| [SYNC-02-T02](./sync-02-conflict-resolution/SYNC-02-T02-TASK.md) | API: GetPendingConflictsQuery + ResolveConflictCommand | Backend | Not Started | — |
| [SYNC-02-T03](./sync-02-conflict-resolution/SYNC-02-T03-TASK.md) | Frontend: Conflict resolution screen | Frontend | Not Started | — |
| [SYNC-02-T04](./sync-02-conflict-resolution/SYNC-02-T04-TASK.md) | Tests: Conflict detection and resolution | Backend/Frontend | Not Started | — |

---

## Dependencies

- **SYNC-01:** Sync infrastructure must exist first
- **HIST-02:** Recalculation infrastructure used after conflict resolution

---

## Shared References

- [Domain Model: GameSession, SyncConflict](../../shared/DOMAIN-MODEL.md)
- [API Contracts: Conflicts Endpoint](../../shared/API-CONTRACTS.md#conflicts)

---

## Key Design Decisions

1. **Automatic Merge:** Non-conflicting sessions auto-merged
2. **Manual Resolution:** Conflicts require explicit user choice
3. **Temporary Storage:** Conflicts stored in SyncConflict table until resolved
4. **Recalculation Trigger:** Resolution triggers stats recalculation

---

## Definition of Done

- All acceptance criteria met
- Code reviewed and approved
- Unit tests written and passing (>80% coverage)
- Integration tests confirm detection and resolution
- Frontend tested on mobile viewports
- No console errors or warnings
