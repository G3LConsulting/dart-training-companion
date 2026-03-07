# PROF-03 — Multi-Device Sync & Conflict Resolution

**Feature:** Player Profiles
**Phase:** MVP
**Status:** 🔲 Not started
**Agent:** —
**Output:** —
**Notes:** —

---

## Context

Enables offline-queued sessions to be uploaded when connectivity returns, with server-side conflict detection and client-driven resolution. Users can resolve conflicts by choosing KeepBoth/KeepLocal/KeepRemote/KeepNeither per session.

> Implements: FA §FR-P-03, TA §3 (offline-first architecture), TA §6 (SyncSessionsCommand, ResolveConflictCommand)

---

## Acceptance Criteria

- [ ] Completed sessions stored in IndexedDB queue when offline
- [ ] SyncService detects connectivity by pinging GET /api/health
- [ ] Sync triggers automatically on reconnect AND manually via sync-banner UI button
- [ ] POST /api/sessions/sync uploads entire IndexedDB queue as a batch (max 100 sessions)
- [ ] If sync fails or is incomplete, entire batch remains in IndexedDB and retried on next trigger (all-or-nothing)
- [ ] Server returns ConflictDto[] for duplicate/conflicting sessions
- [ ] User presented with conflict resolution UI: KeepBoth / KeepLocal / KeepRemote / KeepNeither per conflict
- [ ] POST /api/sessions/conflicts/resolve applies user decision
- [ ] IndexedDB queue cleared only after confirmed full successful sync

---

## Technical Implementation Notes

**Offline Queue (IndexedDB):**
- Store name: "pendingSessions"
- Schema: { sessionId (auto-increment), session (full GameSession object), syncAttempts, lastSyncError, createdAt }
- Persist to IndexedDB when user completes a game and offline flag is true
- Use native IndexedDB API or idb library for cleaner code

**SyncService (Angular):**
- Location: `src/app/core/sync/sync.service.ts`
- Startup: subscribe to online/offline events via (connectivity.service)
- Connectivity check: GET /api/health on a 30-second interval; sets isOnline$ subject
- Sync trigger:
  - Automatic: when online$ transitions from false to true
  - Manual: user clicks "Sync Now" button in sync-banner
- Sync flow:
  1. Read all pending sessions from IndexedDB
  2. POST /api/sessions/sync with batch (max 100)
  3. If error, entire batch stays in queue; show error banner
  4. If 200 OK with ConflictDto[], emit conflictDetected$ subject
  5. User resolves via conflict resolution UI
  6. POST /api/sessions/conflicts/resolve for each conflict
  7. Only after all conflicts resolved: clear queue from IndexedDB
  8. Show "Sync complete" toast

**Sync Banner Component:**
- Location: `src/app/shared/components/sync-banner/`
- Shows when app is offline (gray indicator) or sync in progress (spinning icon)
- Shows conflict count badge (e.g., "2 conflicts")
- Manual "Sync Now" button disabled during sync
- Disappears when sync complete and online

**Backend Commands:**
- Location: `Application/Sync/Commands/`
- SyncSessionsCommand: sessions[] (GameSessionDto array, max 100)
  - Validator: Sessions NotEmpty(), MaxCount(100)
  - Handler: for each session, check if already exists by SessionId
    - If exists and identical: skip (idempotent)
    - If exists and different: return ConflictDto with details
    - If not exists: create new GameSession
  - Returns: { syncedSessions: int, conflicts: ConflictDto[] }
- ResolveConflictCommand: sessionId, resolution (enum: KeepBoth | KeepLocal | KeepRemote | KeepNeither)
  - Handler: based on resolution:
    - KeepBoth: create second session with new SessionId (rename "copy 2" suffix on date)
    - KeepLocal: insert local version, discard remote
    - KeepRemote: discard local, keep existing remote
    - KeepNeither: discard both, delete existing session

**API Endpoints:**
- Location: `Api/Controllers/SyncController.cs`
- POST /api/sessions/sync: accepts SyncSessionsRequestDto, returns SyncResultDto with conflicts
- POST /api/sessions/conflicts/resolve: accepts ConflictResolutionDto, returns 200 OK

**Data Transfer Objects:**
- ConflictDto: { sessionId, localVersion (full session), remoteVersion (full session), conflictType (enum) }
- SyncSessionsRequestDto: { sessions: GameSessionDto[] }
- SyncResultDto: { syncedCount: int, conflicts: ConflictDto[] }
- ConflictResolutionDto: { sessionId, resolution: string }

**Duplicate Detection:**
- Server-side: GameSession.SessionId must be unique per user
- Conflict detection: compare all fields (game mode, player names, scores, completed at time)
- Return ConflictDto only if session exists with same SessionId but different data

**Angular Connectivity Service:**
- Location: `src/app/core/connectivity/connectivity.service.ts`
- Exposes isOnline$ BehaviorSubject
- Listens to window online/offline events
- Pings GET /api/health to confirm actual connectivity (not just network presence)

---

## Dependencies

- PROF-01 — User Registration & Authentication — user must be authenticated to sync
- GAME-04 — Game Session Recording — sessions must exist before they can be synced

---

## Shared References

- [Domain Model](../../shared/domain-model.md) — GameSession entity
- [Architecture](../../shared/architecture.md) — §3 (offline-first architecture), §6 (sync patterns and data transfer)
- [API Contracts](../../shared/api-contracts.md) — sync endpoints and ConflictDto schema
