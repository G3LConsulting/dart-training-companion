# TASK: EXPO-01-T01 — API: RequestExportCommand + ExportJobService BackgroundService

**Story:** [EXPO-01](../STORY-EXPO-01.md)
**Layer:** Backend
**Status:** Pending
**Agent:** Backend Team

---

## What to Build

Implement CQRS command handler and background service to process export requests:

**RequestExportCommand:**
- User provides: export format (CSV/Excel/JSON), scope (All/GameMode/DateRange/CurrentView), optional filters
- Command validation: user authenticated, scope parameters valid
- Creates ExportJob entity in database with status = Pending
- Returns job ID to frontend for polling

**ExportJobService (BackgroundService):**
- Polls database for pending export jobs
- Picks up job, updates status to Processing
- Invokes appropriate export writer (CsvExportWriter, etc.)
- Saves generated file to blob storage or filesystem
- Updates job status to Completed with file path
- On error, updates status to Failed with error message
- Runs indefinitely; scalable to multiple instances

**ExportController:**
- POST /api/export: triggers RequestExportCommand, returns ExportJobDto with jobId
- Implements offline detection: returns 503 if offline

---

## Files

| File Path | Type | Purpose |
|-----------|------|---------|
| `src/Application/Export/Commands/RequestExport/RequestExportCommand.cs` | Command | CQRS command definition |
| `src/Application/Export/Commands/RequestExport/RequestExportCommandHandler.cs` | Handler | Creates ExportJob, enqueues background processing |
| `src/Application/Export/Commands/RequestExport/RequestExportCommandValidator.cs` | Validator | FluentValidation rules |
| `src/Infrastructure/BackgroundServices/ExportJobService.cs` | BackgroundService | Polls and processes jobs |
| `src/Infrastructure/Export/IExportWriter.cs` | Interface | Abstract export writer |
| `src/Api/Controllers/ExportController.cs` | API Controller | HTTP endpoints |
| `src/Application/Common/DTOs/ExportJobDto.cs` | DTO | Response DTO |
| `src/Application/Common/DTOs/ExportStatusDto.cs` | DTO | Status response DTO |

---

## Definition of Done

- [ ] RequestExportCommand compiles and validates input
- [ ] RequestExportCommandHandler creates ExportJob and saves to database
- [ ] ExportJob has: Id (Guid), UserId, Format, Scope, Status, CreatedAt, UpdatedAt, FilePath
- [ ] ExportJobService runs as hosted BackgroundService
- [ ] Service polls database every 5 seconds for new pending jobs
- [ ] Service picks up job, sets Status = Processing
- [ ] Service delegates to appropriate export writer (CsvExportWriter)
- [ ] Service handles exceptions: updates Status = Failed with error message
- [ ] Service updates Status = Completed with file path on success
- [ ] POST /api/export endpoint accepts request, returns ExportJobDto with jobId
- [ ] Endpoint requires [Authorize] attribute (user must be authenticated)
- [ ] Endpoint returns 503 Service Unavailable if offline (no database/storage available)
- [ ] Unit tests mock database and blob storage, verify job creation and status transitions
- [ ] Integration tests with in-memory database verify end-to-end flow

---

## Implementation Notes

**RequestExportCommand:**
```csharp
public class RequestExportCommand : IRequest<ExportJobDto>
{
    public ExportFormat Format { get; set; } // CSV, Excel, Json
    public ExportScope Scope { get; set; } // All, GameMode, DateRange, CurrentView
    public string GameModeFilter { get; set; } // Optional
    public DateTime? StartDate { get; set; } // Optional
    public DateTime? EndDate { get; set; } // Optional
}

public enum ExportFormat { Csv, Excel, Json }
public enum ExportScope { All, GameMode, DateRange, CurrentView }

public class ExportJobDto
{
    public Guid JobId { get; set; }
    public string Status { get; set; } // Pending, Processing, Completed, Failed
    public DateTime CreatedAt { get; set; }
}
```

**ExportJob Entity:**
```csharp
public class ExportJob
{
    public Guid Id { get; set; }
    public string UserId { get; set; }
    public ExportFormat Format { get; set; }
    public ExportScope Scope { get; set; }
    public ExportStatus Status { get; set; } // Pending, Processing, Completed, Failed
    public string FilePath { get; set; }
    public string ErrorMessage { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
}

public enum ExportStatus { Pending, Processing, Completed, Failed }
```

**RequestExportCommandHandler:**
```csharp
public class RequestExportCommandHandler : IRequestHandler<RequestExportCommand, ExportJobDto>
{
    private readonly IApplicationDbContext _dbContext;
    private readonly ICurrentUserService _currentUserService;

    public async Task<ExportJobDto> Handle(RequestExportCommand request, CancellationToken cancellationToken)
    {
        var userId = _currentUserService.UserId;
        if (string.IsNullOrEmpty(userId))
            throw new UnauthorizedAccessException();

        var exportJob = new ExportJob
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            Format = request.Format,
            Scope = request.Scope,
            Status = ExportStatus.Pending,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        _dbContext.ExportJobs.Add(exportJob);
        await _dbContext.SaveChangesAsync(cancellationToken);

        return new ExportJobDto
        {
            JobId = exportJob.Id,
            Status = exportJob.Status.ToString(),
            CreatedAt = exportJob.CreatedAt
        };
    }
}
```

**ExportJobService:**
```csharp
public class ExportJobService : BackgroundService
{
    private readonly ILogger<ExportJobService> _logger;
    private readonly IServiceProvider _serviceProvider;
    private const int PollIntervalSeconds = 5;

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                await ProcessPendingJobsAsync(stoppingToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error processing export jobs");
            }

            await Task.Delay(TimeSpan.FromSeconds(PollIntervalSeconds), stoppingToken);
        }
    }

    private async Task ProcessPendingJobsAsync(CancellationToken cancellationToken)
    {
        using (var scope = _serviceProvider.CreateScope())
        {
            var dbContext = scope.ServiceProvider.GetRequiredService<IApplicationDbContext>();
            var exportWriterFactory = scope.ServiceProvider.GetRequiredService<IExportWriterFactory>();

            var pendingJobs = await dbContext.ExportJobs
                .Where(j => j.Status == ExportStatus.Pending)
                .ToListAsync(cancellationToken);

            foreach (var job in pendingJobs)
            {
                try
                {
                    job.Status = ExportStatus.Processing;
                    job.UpdatedAt = DateTime.UtcNow;
                    await dbContext.SaveChangesAsync(cancellationToken);

                    var writer = exportWriterFactory.CreateWriter(job.Format);
                    var filePath = await writer.WriteAsync(job, cancellationToken);

                    job.Status = ExportStatus.Completed;
                    job.FilePath = filePath;
                    job.UpdatedAt = DateTime.UtcNow;
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error processing export job {JobId}", job.Id);
                    job.Status = ExportStatus.Failed;
                    job.ErrorMessage = ex.Message;
                    job.UpdatedAt = DateTime.UtcNow;
                }

                await dbContext.SaveChangesAsync(cancellationToken);
            }
        }
    }
}
```

**ExportController:**
```csharp
[ApiController]
[Route("api/[controller]")]
[Authorize]
public class ExportController : ControllerBase
{
    private readonly IMediator _mediator;
    private readonly IConnectivityService _connectivityService;

    [HttpPost]
    public async Task<ActionResult<ExportJobDto>> RequestExport([FromBody] RequestExportCommand command)
    {
        if (!_connectivityService.IsOnline)
            return StatusCode(503, "Export requires internet connection");

        var result = await _mediator.Send(command);
        return Accepted(new { jobId = result.JobId, status = result.Status });
    }
}
```

**IExportWriter Interface:**
```csharp
public interface IExportWriter
{
    Task<string> WriteAsync(ExportJob job, CancellationToken cancellationToken);
}

public interface IExportWriterFactory
{
    IExportWriter CreateWriter(ExportFormat format);
}
```

---

## References

- [`../../shared/domain-model.md`](../../shared/domain-model.md) — ExportJob, ExportStatus entities
- [`../../shared/architecture.md`](../../shared/architecture.md) — CQRS pattern, BackgroundService, dependency injection
- [`../../shared/nfrs.md`](../../shared/nfrs.md) — 5-second export, offline constraints
- MediatR: https://github.com/jbogard/MediatR
- FluentValidation: https://fluentvalidation.net/
- Entity Framework Core: https://docs.microsoft.com/en-us/ef/core/
