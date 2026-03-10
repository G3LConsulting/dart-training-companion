# SYNC-01 — Offline Session Queue & Auto-Sync

**Feature:** Multi-Device Sync
**Phase:** MVP
**Story ID:** SYNC-01
**Status:** Not Started
**Priority:** P1
**Complexity:** L

---

## Context

Users should be able to play darts games offline on their mobile device. When they regain connectivity, completed sessions are automatically synced to the server. This story implements the offline-first queue mechanism using IndexedDB and an auto-sync service that detects connectivity changes.

**Implements:**
- FA §FR-P-03: "Multi-device sync with offline support"
- TA §3: Offline-first architecture, SyncService, health ping

---

## Acceptance Criteria

- [ ] Completed sessions stored in IndexedDB queue when offline
- [ ] SyncService pings GET /api/health to detect connectivity
- [ ] On reconnect: auto-sync sends all queued sessions via POST /api/sessions/sync
- [ ] Sync is all-or-nothing: if batch fails, entire batch retried next trigger
- [ ] Manual sync trigger available in UI (sync banner)
- [ ] Clear offline indicator shown when disconnected

---

## Implementation Tasks

| Task ID | Title | Layer | Status | Assigned |
|---------|-------|-------|--------|----------|
| [SYNC-01-T01](./sync-01-offline-sync/SYNC-01-T01-TASK.md) | API: SyncSessionsCommand handler (bulk upload) | Backend | Not Started | — |
| [SYNC-01-T02](./sync-01-offline-sync/SYNC-01-T02-TASK.md) | Frontend: SyncService + IndexedDB queue | Frontend | Not Started | — |
| [SYNC-01-T03](./sync-01-offline-sync/SYNC-01-T03-TASK.md) | Frontend: Sync banner + offline indicator | Frontend | Not Started | — |
| [SYNC-01-T04](./sync-01-offline-sync/SYNC-01-T04-TASK.md) | Tests: Sync service + API tests | Backend/Frontend | Not Started | — |

---

## Dependencies

- **AUTH-02:** Users must be authenticated for sync API calls
- **GAME-04:** Completed sessions must exist before syncing

---

## Shared References

- [Architecture: Offline-First Pattern](../../shared/ARCHITECTURE.md#offline-first)
- [API Contracts: Sync Endpoint](../../shared/API-CONTRACTS.md#sync)
- [IndexedDB Best Practices](../../shared/FRONTEND-PATTERNS.md#indexed-db)

---

## Key Design Decisions

1. **All-or-Nothing Sync:** Entire batch succeeds or fails together
2. **Health Ping:** Uses /api/health (lightweight) to check connectivity instead of relying on network events
3. **Auto-Retry:** Queued sessions automatically retried after reconnection
4. **IndexedDB:** Persists offline queue across browser sessions
5. **Manual Trigger:** Users can manually sync even when online

---

## Definition of Done

- All acceptance criteria met
- Code reviewed and approved
- Unit tests written and passing (>80% coverage)
- Integration tests confirm sync flow
- Frontend tested on offline/online transitions
- No console errors or warnings
- Performance acceptable (batch sizes up to 100)
