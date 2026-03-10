# SYNC-01-T01 — API: SyncSessionsCommand Handler

**Story:** [SYNC-01](../SYNC-01-STORY.md)
**Layer:** Backend (API)
**Status:** Not Started
**Assigned To:** —
**Complexity:** M

---

## What to Build

Implement a CQRS command to bulk-upload multiple completed sessions from offline queue. Validates ownership, persists all sessions atomically (all-or-nothing), and returns sync results including any newly created PersonalBests.

---

## Files to Create/Modify

| Path | Purpose | Status |
|------|---------|--------|
| `Application/Sessions/Commands/SyncSessions/SyncSessionsCommand.cs` | Command definition | To Create |
| `Application/Sessions/Commands/SyncSessions/SyncSessionsCommandHandler.cs` | Handler with bulk insert + PB check | To Create |
| `Application/Sessions/Commands/SyncSessions/SyncSessionsCommandValidator.cs` | Input validation | To Create |
| `Application/Sessions/DTOs/SyncSessionsRequestDto.cs` | Request DTO with session list | To Create |
| `Application/Sessions/DTOs/SyncResultDto.cs` | Response DTO with results | To Create |
| `Api/Controllers/SessionsController.cs` | Add POST /api/sessions/sync endpoint | To Modify |

---

## Implementation Notes

### SyncSessionsCommand & Handler

**SyncSessionsCommand.cs:**
```csharp
public class SyncSessionsCommand : IRequest<SyncResultDto>
{
    public Guid UserId { get; set; }
    public List<CreateSessionDto> Sessions { get; set; } = new();
}
```

**SyncSessionsCommandHandler.cs:**
```csharp
public class SyncSessionsCommandHandler : IRequestHandler<SyncSessionsCommand, SyncResultDto>
{
    private readonly IApplicationDbContext _context;
    private readonly ILogger<SyncSessionsCommandHandler> _logger;

    public SyncSessionsCommandHandler(
        IApplicationDbContext context,
        ILogger<SyncSessionsCommandHandler> logger)
    {
        _context = context;
        _logger = logger;
    }

    public async Task<SyncResultDto> Handle(SyncSessionsCommand request, CancellationToken cancellationToken)
    {
        var result = new SyncResultDto
        {
            SyncedAt = DateTime.UtcNow,
            SessionsProcessed = 0,
            NewPersonalBests = new List<PersonalBestDto>(),
            Errors = new List<string>()
        };

        if (request.Sessions.Count == 0)
        {
            return result;
        }

        try
        {
            // 1. Validate all sessions before persisting
            foreach (var sessionDto in request.Sessions)
            {
                ValidateSessionData(sessionDto, request.UserId);
            }

            // 2. Convert DTOs to entities
            var sessionsToAdd = request.Sessions
                .Select(dto => MapToGameSession(dto, request.UserId))
                .ToList();

            // 3. Persist all sessions (atomic)
            await _context.Sessions.AddRangeAsync(sessionsToAdd, cancellationToken);
            await _context.SaveChangesAsync(cancellationToken);

            result.SessionsProcessed = sessionsToAdd.Count;
            _logger.LogInformation(
                "User {UserId} synced {SessionCount} sessions",
                request.UserId,
                sessionsToAdd.Count);

            // 4. Check for new personal bests
            var newPBs = await CheckForNewPersonalBests(request.UserId, sessionsToAdd, cancellationToken);
            result.NewPersonalBests = newPBs;

            return result;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error syncing sessions for user {UserId}", request.UserId);
            result.Errors.Add("Failed to sync sessions. Please try again.");
            throw;  // All-or-nothing: fail the entire batch
        }
    }

    private void ValidateSessionData(CreateSessionDto sessionDto, Guid userId)
    {
        if (sessionDto.GameMode == GameMode.Invalid)
            throw new ValidationException("Invalid game mode in synced session.");

        if (sessionDto.Turns?.Count == 0)
            throw new ValidationException("Session must have at least one turn.");

        foreach (var turn in sessionDto.Turns ?? new List<TurnDto>())
        {
            if (turn.DartEntries?.Count > 3)
                throw new ValidationException("Turn cannot have more than 3 darts.");

            foreach (var dart in turn.DartEntries ?? new List<DartEntryDto>())
            {
                if (dart.Value < 1 || dart.Value > 20 && dart.Value != 25)
                    throw new ValidationException("Dart value must be 1-20 or 25 (bull).");
            }
        }
    }

    private GameSession MapToGameSession(CreateSessionDto dto, Guid userId)
    {
        return new GameSession
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            GameMode = dto.GameMode,
            CreatedAt = dto.CreatedAt ?? DateTime.UtcNow,
            IsDeleted = false,
            Turns = dto.Turns.Select(t => new Turn
            {
                TurnNumber = t.TurnNumber,
                DartEntries = t.DartEntries.Select(d => new DartEntry
                {
                    Value = d.Value,
                    Multiplier = d.Multiplier,
                    Segment = d.Segment
                }).ToList()
            }).ToList()
        };
    }

    private async Task<List<PersonalBestDto>> CheckForNewPersonalBests(
        Guid userId,
        List<GameSession> newSessions,
        CancellationToken cancellationToken)
    {
        var newPBs = new List<PersonalBestDto>();
        var existingPBs = await _context.PersonalBests
            .Where(pb => pb.UserId == userId)
            .ToListAsync(cancellationToken);

        foreach (var session in newSessions)
        {
            var sessionAvg = CalculateSessionAverage(session);
            var avgPB = existingPBs
                .Where(pb => pb.MetricType == PersonalBestMetric.ThreeDartAverage && pb.GameMode == session.GameMode)
                .FirstOrDefault();

            if (avgPB == null || sessionAvg > avgPB.Value)
            {
                var newPB = new PersonalBest
                {
                    UserId = userId,
                    MetricType = PersonalBestMetric.ThreeDartAverage,
                    GameMode = session.GameMode,
                    Value = (int)sessionAvg,
                    AchievedAt = session.CreatedAt
                };

                await _context.PersonalBests.AddAsync(newPB, cancellationToken);
                newPBs.Add(new PersonalBestDto
                {
                    MetricType = PersonalBestMetric.ThreeDartAverage,
                    GameMode = session.GameMode,
                    Value = (int)sessionAvg,
                    AchievedAt = session.CreatedAt
                });
            }
        }

        if (newPBs.Count > 0)
        {
            await _context.SaveChangesAsync(cancellationToken);
        }

        return newPBs;
    }

    private double CalculateSessionAverage(GameSession session)
    {
        var totalPoints = session.Turns.Sum(t =>
            t.DartEntries.Sum(d => d.Value * (int)d.Multiplier));
        var totalDarts = session.Turns.Sum(t => t.DartEntries.Count);
        return totalDarts > 0 ? (double)totalPoints / totalDarts * 3 : 0;
    }
}
```

### DTOs

**SyncSessionsRequestDto.cs:**
```csharp
public class SyncSessionsRequestDto
{
    [Required]
    public List<CreateSessionDto> Sessions { get; set; } = new();
}

public class CreateSessionDto
{
    [Required]
    public GameMode GameMode { get; set; }

    public DateTime? CreatedAt { get; set; }

    [Required]
    [MinLength(1)]
    public List<TurnDto> Turns { get; set; } = new();
}

public class TurnDto
{
    public int TurnNumber { get; set; }
    public List<DartEntryDto> DartEntries { get; set; } = new();
}

public class DartEntryDto
{
    public int Value { get; set; }
    public Multiplier Multiplier { get; set; }
    public string? Segment { get; set; }  // For Number Focus
}
```

**SyncResultDto.cs:**
```csharp
public class SyncResultDto
{
    public DateTime SyncedAt { get; set; }
    public int SessionsProcessed { get; set; }
    public List<PersonalBestDto> NewPersonalBests { get; set; } = new();
    public List<string> Errors { get; set; } = new();
    public bool Success => Errors.Count == 0;
}

public class PersonalBestDto
{
    public PersonalBestMetric MetricType { get; set; }
    public GameMode GameMode { get; set; }
    public int Value { get; set; }
    public DateTime AchievedAt { get; set; }
}
```

### SessionsController Endpoint

Add to existing SessionsController:

```csharp
// POST /api/sessions/sync
[HttpPost("sync")]
[Authorize]
public async Task<ActionResult<SyncResultDto>> SyncSessions([FromBody] SyncSessionsRequestDto request)
{
    var command = new SyncSessionsCommand
    {
        UserId = User.GetUserId(),
        Sessions = request.Sessions
    };

    var result = await _mediator.Send(command);

    return result.Success ? Ok(result) : BadRequest(result);
}
```

### Validator

**SyncSessionsCommandValidator.cs:**
```csharp
public class SyncSessionsCommandValidator : AbstractValidator<SyncSessionsCommand>
{
    public SyncSessionsCommandValidator()
    {
        RuleFor(x => x.UserId)
            .NotEmpty().WithMessage("User ID is required.");

        RuleFor(x => x.Sessions)
            .NotNull().WithMessage("Sessions list is required.")
            .Must(s => s.Count > 0 && s.Count <= 100)
            .WithMessage("Must provide 1-100 sessions per sync.");

        RuleForEach(x => x.Sessions)
            .SetValidator(new CreateSessionDtoValidator());
    }
}

public class CreateSessionDtoValidator : AbstractValidator<CreateSessionDto>
{
    public CreateSessionDtoValidator()
    {
        RuleFor(x => x.GameMode)
            .IsInEnum().WithMessage("Invalid game mode.");

        RuleFor(x => x.Turns)
            .NotEmpty().WithMessage("Session must have at least one turn.");

        RuleForEach(x => x.Turns)
            .SetValidator(new TurnDtoValidator());
    }
}

public class TurnDtoValidator : AbstractValidator<TurnDto>
{
    public TurnDtoValidator()
    {
        RuleFor(x => x.DartEntries)
            .NotEmpty().WithMessage("Turn must have at least one dart.")
            .Must(d => d.Count <= 3).WithMessage("Turn cannot have more than 3 darts.");

        RuleForEach(x => x.DartEntries)
            .SetValidator(new DartEntryDtoValidator());
    }
}

public class DartEntryDtoValidator : AbstractValidator<DartEntryDto>
{
    public DartEntryDtoValidator()
    {
        RuleFor(x => x.Value)
            .Must(v => (v >= 1 && v <= 20) || v == 25)
            .WithMessage("Dart value must be 1-20 or 25 (bull).");

        RuleFor(x => x.Multiplier)
            .IsInEnum().WithMessage("Invalid multiplier.");
    }
}
```

---

## Definition of Done

- [ ] SyncSessionsCommand created with proper structure
- [ ] SyncSessionsCommandHandler implements bulk insert atomically
- [ ] All validation performed before any persistence
- [ ] Sessions validated for correct structure and dart values
- [ ] POST /api/sessions/sync endpoint added to SessionsController
- [ ] All-or-nothing behavior: batch succeeds or fails entirely
- [ ] Personal best detection integrated in sync handler
- [ ] SyncResultDto returns count, new PBs, and errors
- [ ] Proper error handling and logging
- [ ] Batch size limited to 100 sessions
- [ ] Unit tests verify validation, PB detection, atomicity
- [ ] Integration tests verify HTTP endpoint and database persistence

---

## References

- [CQRS Commands](../../shared/ARCHITECTURE.md#cqrs)
- [Batch Operations Best Practices](../../shared/DATABASE-PATTERNS.md#batch-operations)
- [FluentValidation](https://fluentvalidation.net/)
