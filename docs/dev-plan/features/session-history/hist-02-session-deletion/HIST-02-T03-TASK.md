# HIST-02-T03 — API: GetRecalculationStatusQuery

**Story:** [HIST-02](../HIST-02-STORY.md)
**Layer:** Backend (API)
**Status:** Not Started
**Assigned To:** —
**Complexity:** S

---

## What to Build

Implement a CQRS query to check if a user's stats are currently being recalculated. Frontend uses this to poll and show "Updating stats..." indicator while recalculation is in progress.

---

## Files to Create/Modify

| Path | Purpose | Status |
|------|---------|--------|
| `Application/Stats/Queries/GetRecalculationStatus/GetRecalculationStatusQuery.cs` | Query definition | To Create |
| `Application/Stats/Queries/GetRecalculationStatus/GetRecalculationStatusQueryHandler.cs` | Query handler | To Create |
| `Application/Stats/DTOs/RecalculationStatusDto.cs` | Response DTO | To Create |
| `Api/Controllers/StatsController.cs` | Add GET endpoint | To Create |

---

## Implementation Notes

### Query & Handler

**GetRecalculationStatusQuery.cs:**
```csharp
public class GetRecalculationStatusQuery : IRequest<RecalculationStatusDto>
{
    public Guid UserId { get; set; }
}
```

**GetRecalculationStatusQueryHandler.cs:**
```csharp
public class GetRecalculationStatusQueryHandler : IRequestHandler<GetRecalculationStatusQuery, RecalculationStatusDto>
{
    private readonly RecalculationState _recalculationState;

    public GetRecalculationStatusQueryHandler(RecalculationState recalculationState)
    {
        _recalculationState = recalculationState;
    }

    public Task<RecalculationStatusDto> Handle(
        GetRecalculationStatusQuery request,
        CancellationToken cancellationToken)
    {
        var isRecalculating = _recalculationState.GetIsRecalculating(request.UserId);

        var dto = new RecalculationStatusDto
        {
            IsRecalculating = isRecalculating,
            CheckedAt = DateTime.UtcNow
        };

        return Task.FromResult(dto);
    }
}
```

### DTO

**RecalculationStatusDto.cs:**
```csharp
public class RecalculationStatusDto
{
    public bool IsRecalculating { get; set; }
    public DateTime CheckedAt { get; set; }
}
```

### StatsController Endpoint

**StatsController.cs:**
```csharp
[Authorize]
[ApiController]
[Route("api/[controller]")]
public class StatsController : ControllerBase
{
    private readonly IMediator _mediator;

    public StatsController(IMediator mediator)
    {
        _mediator = mediator;
    }

    // GET /api/stats/recalculation-status
    [HttpGet("recalculation-status")]
    public async Task<ActionResult<RecalculationStatusDto>> GetRecalculationStatus()
    {
        var query = new GetRecalculationStatusQuery { UserId = User.GetUserId() };
        var result = await _mediator.Send(query);
        return Ok(result);
    }
}
```

---

## Definition of Done

- [ ] GetRecalculationStatusQuery created with proper structure
- [ ] GetRecalculationStatusQueryHandler queries RecalculationState
- [ ] RecalculationStatusDto DTO created
- [ ] GET /api/stats/recalculation-status endpoint added to StatsController
- [ ] Endpoint requires authentication
- [ ] Returns correct status based on RecalculationState
- [ ] No database queries needed (uses in-memory state)
- [ ] Proper error handling
- [ ] Unit tests verify query handler and endpoint behavior
- [ ] Integration tests confirm HTTP endpoint works correctly

---

## References

- [CQRS Queries](../../shared/ARCHITECTURE.md#cqrs)
- [RecalculationState (from HIST-02-T02)](./HIST-02-T02-TASK.md)
