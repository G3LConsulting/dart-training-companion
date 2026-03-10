# HIST-02-T01 — API: DeleteSessionCommand Handler

**Story:** [HIST-02](../HIST-02-STORY.md)
**Layer:** Backend (API)
**Status:** Not Started
**Assigned To:** —
**Complexity:** M

---

## What to Build

Implement CQRS command to soft-delete a session and enqueue its user for stats recalculation. The command validates ownership before deletion and queues the user ID to a Channel<Guid> for background processing.

---

## Files to Create/Modify

| Path | Purpose | Status |
|------|---------|--------|
| `Application/Sessions/Commands/DeleteSession/DeleteSessionCommand.cs` | Command definition | To Create |
| `Application/Sessions/Commands/DeleteSession/DeleteSessionCommandHandler.cs` | Command handler with soft-delete + enqueue | To Create |
| `Application/Sessions/Commands/DeleteSession/DeleteSessionCommandValidator.cs` | Input validation | To Create |
| `Api/Controllers/SessionsController.cs` | Add DELETE endpoint | To Modify |

---

## Implementation Notes

### DeleteSessionCommand & Handler

**DeleteSessionCommand.cs:**
```csharp
public class DeleteSessionCommand : IRequest<Unit>
{
    public Guid SessionId { get; set; }
    public Guid UserId { get; set; }
}
```

**DeleteSessionCommandHandler.cs:**
```csharp
public class DeleteSessionCommandHandler : IRequestHandler<DeleteSessionCommand, Unit>
{
    private readonly IApplicationDbContext _context;
    private readonly IRecalculationQueue _recalculationQueue;
    private readonly ILogger<DeleteSessionCommandHandler> _logger;

    public DeleteSessionCommandHandler(
        IApplicationDbContext context,
        IRecalculationQueue recalculationQueue,
        ILogger<DeleteSessionCommandHandler> logger)
    {
        _context = context;
        _recalculationQueue = recalculationQueue;
        _logger = logger;
    }

    public async Task<Unit> Handle(DeleteSessionCommand request, CancellationToken cancellationToken)
    {
        // 1. Find session by id
        var session = await _context.Sessions.FirstOrDefaultAsync(
            s => s.Id == request.SessionId,
            cancellationToken);

        if (session == null)
            throw new NotFoundException(nameof(GameSession), request.SessionId);

        // 2. Verify user owns session
        if (session.UserId != request.UserId)
            throw new UnauthorizedAccessException("User cannot delete sessions they do not own.");

        // 3. Soft-delete the session
        session.IsDeleted = true;
        session.DeletedAt = DateTime.UtcNow;

        // 4. Persist deletion
        _context.Sessions.Update(session);
        await _context.SaveChangesAsync(cancellationToken);

        _logger.LogInformation(
            "Session {SessionId} soft-deleted by user {UserId}",
            request.SessionId,
            request.UserId);

        // 5. Enqueue user for stats recalculation
        try
        {
            await _recalculationQueue.EnqueueAsync(request.UserId, cancellationToken);
            _logger.LogInformation(
                "User {UserId} enqueued for stats recalculation",
                request.UserId);
        }
        catch (Exception ex)
        {
            _logger.LogError(
                ex,
                "Failed to enqueue user {UserId} for recalculation after session deletion",
                request.UserId);
            // Don't throw — deletion succeeded, recalculation can be retried
        }

        return Unit.Value;
    }
}
```

### Validator

**DeleteSessionCommandValidator.cs:**
```csharp
public class DeleteSessionCommandValidator : AbstractValidator<DeleteSessionCommand>
{
    public DeleteSessionCommandValidator()
    {
        RuleFor(x => x.SessionId)
            .NotEmpty().WithMessage("Session ID is required.");

        RuleFor(x => x.UserId)
            .NotEmpty().WithMessage("User ID is required.");
    }
}
```

### RecalculationQueue Interface

Define a service to manage the recalculation queue (Channel<Guid>):

```csharp
public interface IRecalculationQueue
{
    Task EnqueueAsync(Guid userId, CancellationToken cancellationToken);
    IAsyncEnumerable<Guid> DequeueAsync(CancellationToken cancellationToken);
}

public class RecalculationQueue : IRecalculationQueue
{
    private readonly Channel<Guid> _channel;

    public RecalculationQueue(int boundedCapacity = 1000)
    {
        var options = new BoundedChannelOptions(boundedCapacity)
        {
            FullMode = BoundedChannelFullMode.DropOldest
        };
        _channel = Channel.CreateBounded<Guid>(options);
    }

    public async Task EnqueueAsync(Guid userId, CancellationToken cancellationToken)
    {
        await _channel.Writer.WriteAsync(userId, cancellationToken);
    }

    public async IAsyncEnumerable<Guid> DequeueAsync([EnumeratorCancellation] CancellationToken cancellationToken)
    {
        await foreach (var userId in _channel.Reader.ReadAllAsync(cancellationToken))
        {
            yield return userId;
        }
    }
}
```

### SessionsController Endpoint

Add to existing SessionsController:

```csharp
// DELETE /api/sessions/{id}
[HttpDelete("{id}")]
[Authorize]
public async Task<IActionResult> DeleteSession(Guid id)
{
    var command = new DeleteSessionCommand
    {
        SessionId = id,
        UserId = User.GetUserId()
    };
    await _mediator.Send(command);
    return NoContent();
}
```

### Domain Model Extension

Ensure GameSession entity has soft-delete fields:

```csharp
public class GameSession
{
    // ... existing properties ...

    public bool IsDeleted { get; set; } = false;
    public DateTime? DeletedAt { get; set; }
}
```

### Queries Must Filter Deleted Sessions

Update GetSessionHistoryQueryHandler and GetSessionDetailQueryHandler:

```csharp
var sessions = _context.Sessions
    .Where(s => s.UserId == request.UserId && !s.IsDeleted)
    // ... rest of query
```

---

## Definition of Done

- [ ] DeleteSessionCommand created with proper structure
- [ ] DeleteSessionCommandHandler implements soft-delete and enqueue logic
- [ ] DeleteSessionCommandValidator validates inputs
- [ ] IRecalculationQueue interface defined and implemented with Channel<Guid>
- [ ] DELETE /api/sessions/{id} endpoint added to SessionsController
- [ ] GameSession domain model updated with IsDeleted and DeletedAt
- [ ] All history/detail queries updated to filter out deleted sessions
- [ ] Proper error handling and logging in place
- [ ] Command validates user ownership before deletion
- [ ] Recalculation queue enqueue doesn't fail the deletion
- [ ] Unit tests verify deletion logic, authorization, and enqueueing
- [ ] Integration tests verify HTTP endpoint and database state

---

## References

- [CQRS Commands](../../shared/ARCHITECTURE.md#cqrs)
- [System.Threading.Channels Documentation](https://docs.microsoft.com/en-us/dotnet/api/system.threading.channels)
- [Soft Delete Pattern](../../shared/DATABASE-PATTERNS.md#soft-delete)
