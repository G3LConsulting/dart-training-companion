# SYNC-02-T02 — API: GetPendingConflictsQuery + ResolveConflictCommand

**Story:** [SYNC-02](../SYNC-02-STORY.md)
**Layer:** Backend
**Status:** Not Started
**Assigned To:** —
**Complexity:** M

---

## What to Build

Implement query to retrieve pending conflicts for a user and command to resolve conflicts by selecting which session(s) to keep. Resolution triggers stats recalculation.

---

## Files to Create/Modify

| Path | Purpose | Status |
|------|---------|--------|
| `Application/Sessions/Queries/GetPendingConflicts/GetPendingConflictsQuery.cs` | Query definition | To Create |
| `Application/Sessions/Queries/GetPendingConflicts/GetPendingConflictsQueryHandler.cs` | Query handler | To Create |
| `Application/Sessions/Commands/ResolveConflict/ResolveConflictCommand.cs` | Command definition | To Create |
| `Application/Sessions/Commands/ResolveConflict/ResolveConflictCommandHandler.cs` | Command handler | To Create |
| `Api/Controllers/SessionsController.cs` | Add conflict endpoints | To Modify |

---

## Implementation Notes

### Query/Handler

```csharp
public class GetPendingConflictsQuery : IRequest<List<ConflictDto>>
{
    public Guid UserId { get; set; }
}

public class GetPendingConflictsQueryHandler : IRequestHandler<GetPendingConflictsQuery, List<ConflictDto>>
{
    public async Task<List<ConflictDto>> Handle(GetPendingConflictsQuery request, CancellationToken cancellationToken)
    {
        var conflicts = await _context.SyncConflicts
            .Where(sc => sc.UserId == request.UserId && sc.Status == ConflictStatus.Pending)
            .Include(sc => sc.DeviceASession)
            .ToListAsync(cancellationToken);

        return conflicts.Select(c => new ConflictDto
        {
            Id = c.Id,
            GameMode = c.GameMode,
            SessionA = MapToSessionSummaryDto(c.DeviceASession),
            SessionB = JsonSerializer.Deserialize<SessionDto>(c.DeviceBSessionData),
            CreatedAt = c.CreatedAt
        }).ToList();
    }
}
```

### Command/Handler

```csharp
public class ResolveConflictCommand : IRequest<Unit>
{
    public Guid ConflictId { get; set; }
    public Guid UserId { get; set; }
    public ConflictResolution Resolution { get; set; }  // KeepBoth, KeepA, KeepB, KeepNeither
}

public class ResolveConflictCommandHandler : IRequestHandler<ResolveConflictCommand, Unit>
{
    public async Task<Unit> Handle(ResolveConflictCommand request, CancellationToken cancellationToken)
    {
        var conflict = await _context.SyncConflicts.FirstOrDefaultAsync(
            sc => sc.Id == request.ConflictId && sc.UserId == request.UserId,
            cancellationToken);

        if (conflict == null)
            throw new NotFoundException(nameof(SyncConflict), request.ConflictId);

        // Apply resolution
        switch (request.Resolution)
        {
            case ConflictResolution.KeepBoth:
                // Parse DeviceBSessionData and save as new session
                var sessionB = JsonSerializer.Deserialize<CreateSessionDto>(conflict.DeviceBSessionData);
                await _context.Sessions.AddAsync(MapToGameSession(sessionB, request.UserId), cancellationToken);
                break;

            case ConflictResolution.KeepA:
                // Keep DeviceASession, discard B
                break;

            case ConflictResolution.KeepB:
                // Discard DeviceASession, save B
                conflict.DeviceASession.IsDeleted = true;
                var sessionB2 = JsonSerializer.Deserialize<CreateSessionDto>(conflict.DeviceBSessionData);
                await _context.Sessions.AddAsync(MapToGameSession(sessionB2, request.UserId), cancellationToken);
                break;

            case ConflictResolution.KeepNeither:
                // Discard both
                conflict.DeviceASession.IsDeleted = true;
                break;
        }

        conflict.Status = ConflictStatus.Resolved;
        conflict.ResolvedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync(cancellationToken);

        // Trigger stats recalculation
        await _recalculationQueue.EnqueueAsync(request.UserId, cancellationToken);

        return Unit.Value;
    }
}
```

### Endpoints

```csharp
// GET /api/sessions/conflicts
[HttpGet("conflicts")]
[Authorize]
public async Task<ActionResult<List<ConflictDto>>> GetPendingConflicts()
{
    var query = new GetPendingConflictsQuery { UserId = User.GetUserId() };
    var result = await _mediator.Send(query);
    return Ok(result);
}

// POST /api/sessions/conflicts/{id}/resolve
[HttpPost("conflicts/{id}/resolve")]
[Authorize]
public async Task<IActionResult> ResolveConflict(Guid id, [FromBody] ResolveConflictRequest request)
{
    var command = new ResolveConflictCommand
    {
        ConflictId = id,
        UserId = User.GetUserId(),
        Resolution = request.Resolution
    };
    await _mediator.Send(command);
    return NoContent();
}
```

---

## Definition of Done

- [ ] GetPendingConflictsQuery implemented
- [ ] ResolveConflictCommand implemented with all resolution options
- [ ] Endpoints added to SessionsController
- [ ] Resolution triggers stats recalculation
- [ ] Soft-delete used for discarded sessions
- [ ] Unit tests verify query and command logic
- [ ] Integration tests confirm HTTP endpoints

---

## References

- [SYNC-02-T01](./SYNC-02-T01-TASK.md)
- [HIST-02-T02: Stats Recalculation](../../session-history/hist-02-session-deletion/HIST-02-T02-TASK.md)
