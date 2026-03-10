# HIST-01 — Session History List & Detail View

**Feature:** Session History
**Phase:** MVP
**Story ID:** HIST-01
**Status:** Not Started
**Priority:** P1
**Complexity:** M

---

## Context

Users need the ability to review their completed darts sessions at any time. This story implements the core read-only browsing of session history with chronological listing, pagination, filtering by game mode, and detailed view of individual sessions including all turns and darts thrown.

**Implements:**
- FA §FR-P-04: "User can view and manage session history"
- TA §6: GetSessionHistoryQuery, GetSessionDetailQuery

---

## Acceptance Criteria

- [ ] User can browse chronological list of completed sessions (most recent first)
- [ ] List shows date, game mode, key stat (e.g., average, accuracy)
- [ ] Paginated (20 per page)
- [ ] Tapping a session opens full detail view
- [ ] Detail shows all turns/darts from the session (read-only)
- [ ] Filterable by game mode (501, 301, Cricket, Number Focus)

---

## Implementation Tasks

| Task ID | Title | Layer | Status | Assigned |
|---------|-------|-------|--------|----------|
| [HIST-01-T01](./hist-01-session-history-list/HIST-01-T01-TASK.md) | API: GetSessionHistoryQuery + GetSessionDetailQuery | Backend | Not Started | — |
| [HIST-01-T02](./hist-01-session-history-list/HIST-01-T02-TASK.md) | Frontend: Session history list component | Frontend | Not Started | — |
| [HIST-01-T03](./hist-01-session-history-list/HIST-01-T03-TASK.md) | Frontend: Session detail component | Frontend | Not Started | — |
| [HIST-01-T04](./hist-01-session-history-list/HIST-01-T04-TASK.md) | Tests: History query tests | Backend | Not Started | — |

---

## Dependencies

- **AUTH-02:** User must be authenticated to access their own session history
- **GAME-04:** Sessions must exist in the database before they can be retrieved

---

## Shared References

- [Domain Model: GameSession, Turn, CricketTurn, DartEntry](../../shared/DOMAIN-MODEL.md)
- [API Contracts: Session Endpoints](../../shared/API-CONTRACTS.md#sessions)
- [Architecture: CQRS Pattern](../../shared/ARCHITECTURE.md#cqrs)

---

## Definition of Done

- All acceptance criteria met
- Code reviewed and approved
- Unit tests written and passing (>80% coverage)
- Integration tests confirm API contracts
- Frontend tested on mobile viewports
- No console errors or warnings
