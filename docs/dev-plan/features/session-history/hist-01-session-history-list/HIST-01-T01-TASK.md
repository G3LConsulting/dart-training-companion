# HIST-01-T01 — API: GetSessionHistoryQuery + GetSessionDetailQuery

**Story:** [HIST-01](../HIST-01-STORY.md)
**Layer:** Backend (API)
**Status:** Not Started
**Assigned To:** —
**Complexity:** M

---

## What to Build

Implement two CQRS queries to support reading session history and session details:

1. **GetSessionHistoryQuery** — returns paginated, filtered list of sessions for the authenticated user
2. **GetSessionDetailQuery** — returns complete session data including all turns and darts

Both queries must enforce user scoping (users can only see their own sessions).

---

## Files to Create/Modify

| Path | Purpose | Status |
|------|---------|--------|
| `Application/Sessions/Queries/GetSessionHistory/GetSessionHistoryQuery.cs` | Query definition | To Create |
| `Application/Sessions/Queries/GetSessionHistory/GetSessionHistoryQueryHandler.cs` | Query handler with pagination & filtering | To Create |
| `Application/Sessions/Queries/GetSessionDetail/GetSessionDetailQuery.cs` | Query definition | To Create |
| `Application/Sessions/Queries/GetSessionDetail/GetSessionDetailQueryHandler.cs` | Query handler | To Create |
| `Application/Sessions/DTOs/SessionSummaryDto.cs` | DTO for list items | To Create |
| `Application/Sessions/DTOs/SessionDetailDto.cs` | DTO for detail view | To Create |
| `Application/Common/DTOs/PagedResult.cs` | Generic paged result wrapper | To Create |
| `Api/Controllers/SessionsController.cs` | REST endpoints | To Create |

---

## Implementation Notes

### GetSessionHistoryQuery Handler

```csharp
public class GetSessionHistoryQueryHandler : IRequestHandler<GetSessionHistoryQuery, PagedResult<SessionSummaryDto>>
{
    public async Task<PagedResult<SessionSummaryDto>> Handle(GetSessionHistoryQuery request, CancellationToken cancellationToken)
    {
        // 1. Query sessions for current user from ApplicationDbContext
        // 2. Filter by GameMode if provided (optional)
        // 3. Order by CreatedAt descending (most recent first)
        // 4. Apply pagination: skip (PageNumber - 1) * PageSize, take PageSize
        // 5. Project to SessionSummaryDto with:
        //    - Id, CreatedAt, GameMode
        //    - Key stat: 3-dart average (calculated from DartEntry totals)
        //    - Accuracy % (if game mode is Number Focus)
        // 6. Return PagedResult with TotalCount from unfiltered query
    }
}
```

### GetSessionDetailQuery Handler

```csharp
public class GetSessionDetailQueryHandler : IRequestHandler<GetSessionDetailQuery, SessionDetailDto>
{
    public async Task<SessionDetailDto> Handle(GetSessionDetailQuery request, CancellationToken cancellationToken)
    {
        // 1. Find session by id
        // 2. Verify user owns session (throw UnauthorizedAccessException if not)
        // 3. Load all Turn entities and nested DartEntry entities
        // 4. Project to SessionDetailDto with:
        //    - Session metadata (id, gameMode, createdAt, etc.)
        //    - Full Turn list (for 501/301) or CricketTurn list
        //    - All DartEntry data (value, multiplier, segment for NF)
        // 5. Return DTO
    }
}
```

### DTOs

**SessionSummaryDto:**
```csharp
public class SessionSummaryDto
{
    public Guid Id { get; set; }
    public DateTime CreatedAt { get; set; }
    public GameMode GameMode { get; set; }
    public int KeyStat { get; set; }  // 3-dart avg or accuracy %
    public string KeyStatLabel { get; set; }  // "Avg" or "Accuracy"
}
```

**SessionDetailDto:**
```csharp
public class SessionDetailDto
{
    public Guid Id { get; set; }
    public GameMode GameMode { get; set; }
    public DateTime CreatedAt { get; set; }
    public int TotalDarts { get; set; }
    public List<TurnDto> Turns { get; set; }  // or CricketTurnDto list
}

public class TurnDto
{
    public int TurnNumber { get; set; }
    public List<DartDto> Darts { get; set; }
}

public class DartDto
{
    public int Value { get; set; }
    public Multiplier Multiplier { get; set; }
    public int Total => Value * (int)Multiplier;  // 20 = single, 40 = double, 60 = triple
}
```

**PagedResult<T>:**
```csharp
public class PagedResult<T>
{
    public List<T> Items { get; set; }
    public int PageNumber { get; set; }
    public int PageSize { get; set; }
    public int TotalCount { get; set; }
    public int TotalPages => (TotalCount + PageSize - 1) / PageSize;
    public bool HasPreviousPage => PageNumber > 1;
    public bool HasNextPage => PageNumber < TotalPages;
}
```

### SessionsController Endpoints

```csharp
[Authorize]
[ApiController]
[Route("api/[controller]")]
public class SessionsController : ControllerBase
{
    private readonly IMediator _mediator;

    // GET /api/sessions?pageNumber=1&pageSize=20&gameMode=501
    [HttpGet]
    public async Task<ActionResult<PagedResult<SessionSummaryDto>>> GetSessionHistory(
        [FromQuery] int pageNumber = 1,
        [FromQuery] int pageSize = 20,
        [FromQuery] GameMode? gameMode = null)
    {
        var query = new GetSessionHistoryQuery
        {
            UserId = User.GetUserId(),
            PageNumber = pageNumber,
            PageSize = pageSize,
            GameMode = gameMode
        };
        return Ok(await _mediator.Send(query));
    }

    // GET /api/sessions/{id}
    [HttpGet("{id}")]
    public async Task<ActionResult<SessionDetailDto>> GetSessionDetail(Guid id)
    {
        var query = new GetSessionDetailQuery { SessionId = id, UserId = User.GetUserId() };
        return Ok(await _mediator.Send(query));
    }
}
```

### Query Validators

Create FluentValidation validators:
- **GetSessionHistoryQueryValidator:** PageNumber >= 1, PageSize between 1-100
- **GetSessionDetailQueryValidator:** SessionId not empty

---

## Definition of Done

- [ ] GetSessionHistoryQuery handler implemented with pagination and mode filtering
- [ ] GetSessionDetailQuery handler implemented and retrieves full turn/dart data
- [ ] SessionSummaryDto and SessionDetailDto DTOs created
- [ ] PagedResult<T> generic wrapper created
- [ ] SessionsController with GET endpoints created
- [ ] Query validators implemented
- [ ] Queries properly scoped to authenticated user only
- [ ] Unit tests written for both handlers (pagination, filtering, user scoping)
- [ ] Integration tests confirm GET /api/sessions and GET /api/sessions/{id} work end-to-end

---

## References

- [Domain Model: GameSession, Turn, DartEntry](../../../shared/DOMAIN-MODEL.md)
- [API Contracts](../../../shared/API-CONTRACTS.md#sessions)
- [CQRS Pattern](../../../shared/ARCHITECTURE.md#cqrs)
- MediatR documentation: https://github.com/jbogard/MediatR
