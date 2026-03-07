# PROF-04 — Match & Session History

**Feature:** Player Profiles
**Phase:** MVP
**Status:** 🔲 Not started
**Agent:** —
**Output:** —
**Notes:** —

---

## Context

Displays a paginated, filterable list of past game sessions. Users can view session summaries and delete individual entries, which asynchronously triggers stats recalculation.

> Implements: FA §FR-P-04, TA §6 (GetSessionHistoryQuery, DeleteSessionCommand)

---

## Acceptance Criteria

- [ ] Paginated session list (default pageSize=20) with filter by game mode
- [ ] Each row shows: game mode, date, player names (if 2-player), key result metric (avg/checkout/MPR/weighted accuracy)
- [ ] Deleted sessions soft-deleted (IsDeleted=true); removed from list immediately
- [ ] On session delete: stats recalculation enqueued asynchronously; UI shows recalculating indicator
- [ ] Angular polls GET /api/stats/recalculation-status until IsRecalculating=false
- [ ] 404 returned if session not found or not owned by requesting user
- [ ] Delete confirmation dialog required before removal

---

## Technical Implementation Notes

**Backend Query Structure:**
- Location: `Application/Sessions/Queries/`
- GetSessionHistoryQuery: userId (implicit from auth), pageNumber (default 1), pageSize (default 20), gameMode (optional filter)
  - Handler: filters GameSession where UserId == userId AND IsDeleted == false
  - If gameMode provided, add AND GameMode == gameMode
  - Order by CompletedAt DESC
  - Returns paginated SessionSummaryDto[]
  - Includes total count for pagination UI
- GetSessionDetailQuery: sessionId
  - Handler: loads full GameSession by id, validates ownership
  - Returns SessionDetailDto with all fields

**Backend Command Structure:**
- Location: `Application/Sessions/Commands/`
- DeleteSessionCommand: sessionId
  - Handler:
    - Loads GameSession by id, validates ownership
    - Sets IsDeleted = true, DeletedAt = now
    - Enqueues userId to StatsRecalculationService via Channel<Guid> (fire-and-forget)
    - Commits transaction
    - Returns 200 OK
  - No validator needed (simple command)

**Session Summary DTO:**
- SessionSummaryDto: { sessionId, gameMode (enum), completedAt (DateTime), playerNames (string[] for 2-player), keyMetric (decimal?), keyMetricLabel (string) }
- keyMetric is the "most interesting" result for that game mode:
  - 501/301: average (points per dart)
  - Cricket: checkout percentage or weighted accuracy
  - Number Focus: accuracy or session score
- keyMetricLabel: "Avg", "Checkout %", "Accuracy", etc.

**Pagination DTO:**
- GetSessionHistoryResultDto: { sessions: SessionSummaryDto[], totalCount: int, pageNumber: int, pageSize: int }

**API Endpoints:**
- Location: `Api/Controllers/SessionsController.cs`
- GET /api/sessions?pageNumber=1&pageSize=20&gameMode=501: returns GetSessionHistoryResultDto
- GET /api/sessions/{sessionId}: returns SessionDetailDto
- DELETE /api/sessions/{sessionId}: soft-deletes and enqueues stats recalc, returns 200 OK

**Stats Recalculation Service:**
- Location: `Infrastructure/Services/StatsRecalculationService.cs`
- Channel<Guid> receives userId on each delete
- Background worker consumes from channel and recalculates UserStats for that user
- Calculates all metrics: average, checkout percentage, MPR, etc.
- Updates UserStats entity, commits to DB
- No UI blocking; entire operation async

**Recalculation Status Query:**
- Location: `Application/Stats/Queries/`
- GetRecalculationStatusQuery: userId (implicit from auth)
  - Handler: checks if userId is in StatsRecalculationService queue or currently processing
  - Returns { isRecalculating: bool }

**Recalculation Status Endpoint:**
- Location: `Api/Controllers/StatsController.cs`
- GET /api/stats/recalculation-status: returns { isRecalculating: bool }

**Angular Frontend:**
- Location: `src/app/features/history/` (standalone component)
- Page layout:
  - Header: "Match History"
  - Toolbar: Dropdown filter for game mode (All/501/301/Cricket/NumberFocus)
  - Session list: table or card grid
  - Pagination controls: previous/next page, page size selector (10/20/50)
- Session row/card:
  - Game mode icon + label
  - Date + time (human-readable)
  - Player names (if available)
  - Key metric display (large, emphasized)
  - Delete button (trash icon)
- Delete flow:
  - Click delete → confirmation dialog: "Delete this session? This action cannot be undone."
  - On confirm: DELETE /api/sessions/{sessionId}
  - UI immediately removes row
  - Show "Stats recalculating..." indicator at top
  - Poll GET /api/stats/recalculation-status every 2 seconds
  - When IsRecalculating=false, show "Done" toast, hide indicator
- Pagination: clickable page numbers, next/prev buttons, "Page X of Y"
- Responsive: stacked cards on mobile, table on desktop

**Accessibility:**
- Alt text for game mode icons
- ARIA labels on delete buttons and pagination controls
- Confirm dialog is keyboard-navigable

---

## Dependencies

- PROF-01 — User Registration & Authentication — user must be authenticated to view history
- GAME-04 — Game Session Recording — sessions must be created and stored before they can be viewed/deleted

---

## Shared References

- [Domain Model](../../shared/domain-model.md) — GameSession, UserStats entities
- [Architecture](../../shared/architecture.md) — §6 (query patterns, async background workers)
- [API Contracts](../../shared/api-contracts.md) — session history endpoints and DTOs
