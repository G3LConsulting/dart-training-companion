# TASK: EXPO-01-T02 — API: GetExportStatusQuery + DownloadExportQuery

**Story:** [EXPO-01](../STORY-EXPO-01.md)
**Layer:** Backend
**Status:** Pending
**Agent:** Backend Team

---

## What to Build

Implement CQRS queries to retrieve export job status and download files:

**GetExportStatusQuery:**
- Frontend polls this endpoint to check job status
- Returns: jobId, status (Pending/Processing/Completed/Failed), progress percentage (if available), error message (if failed)
- Only allows access to own exports (user-scoped query)

**DownloadExportQuery (or endpoint):**
- GET /api/export/{jobId}/download
- Returns file stream (Content-Disposition: attachment)
- Only allows access to own exports
- Returns 404 if job not found or already deleted
- Returns 400 if job status is not Completed
- File served from blob storage or filesystem

---

## Files

| File Path | Type | Purpose |
|-----------|------|---------|
| `src/Application/Export/Queries/GetExportStatus/GetExportStatusQuery.cs` | Query | CQRS query definition |
| `src/Application/Export/Queries/GetExportStatus/GetExportStatusQueryHandler.cs` | Handler | Retrieves job from database |
| `src/Application/Export/Queries/DownloadExport/DownloadExportQuery.cs` | Query | CQRS query definition |
| `src/Application/Export/Queries/DownloadExport/DownloadExportQueryHandler.cs` | Handler | Retrieves file from storage |
| `src/Application/Common/DTOs/ExportStatusDto.cs` | DTO | Status response DTO |
| `src/Api/Controllers/ExportController.cs` | API Controller | HTTP endpoints (GET methods) |

---

## Definition of Done

- [ ] GetExportStatusQuery compiles and accepts jobId
- [ ] GetExportStatusQueryHandler queries database for ExportJob by jobId
- [ ] Handler verifies user owns the export (UserId matches current user)
- [ ] Handler returns ExportStatusDto with: jobId, status, errorMessage, createdAt
- [ ] GET /api/export/{jobId} endpoint calls GetExportStatusQuery
- [ ] DownloadExportQuery compiles and accepts jobId
- [ ] DownloadExportQueryHandler retrieves file from blob storage/filesystem
- [ ] Handler verifies user owns the export
- [ ] Handler verifies job status is Completed
- [ ] GET /api/export/{jobId}/download endpoint returns file stream with correct Content-Disposition header
- [ ] Endpoint returns 404 if job not found or user doesn't own it
- [ ] Endpoint returns 400 if job status is not Completed
- [ ] Endpoint returns correct Content-Type for file format (text/csv, application/vnd.openxmlformats-officedocument.spreadsheetml.sheet, application/json)
- [ ] Unit tests mock database and storage, verify authorization checks
- [ ] Integration tests verify file download and status polling workflows

---

## Implementation Notes

**GetExportStatusQuery:**
```csharp
public class GetExportStatusQuery : IRequest<ExportStatusDto>
{
    public Guid JobId { get; set; }
}

public class ExportStatusDto
{
    public Guid JobId { get; set; }
    public string Status { get; set; } // Pending, Processing, Completed, Failed
    public int ProgressPercentage { get; set; } // 0-100
    public string ErrorMessage { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
}
```

**GetExportStatusQueryHandler:**
```csharp
public class GetExportStatusQueryHandler : IRequestHandler<GetExportStatusQuery, ExportStatusDto>
{
    private readonly IApplicationDbContext _dbContext;
    private readonly ICurrentUserService _currentUserService;

    public async Task<ExportStatusDto> Handle(GetExportStatusQuery request, CancellationToken cancellationToken)
    {
        var userId = _currentUserService.UserId;
        if (string.IsNullOrEmpty(userId))
            throw new UnauthorizedAccessException();

        var exportJob = await _dbContext.ExportJobs
            .FirstOrDefaultAsync(j => j.Id == request.JobId && j.UserId == userId, cancellationToken);

        if (exportJob == null)
            throw new NotFoundException(nameof(ExportJob), request.JobId);

        return new ExportStatusDto
        {
            JobId = exportJob.Id,
            Status = exportJob.Status.ToString(),
            ProgressPercentage = CalculateProgress(exportJob.Status),
            ErrorMessage = exportJob.ErrorMessage,
            CreatedAt = exportJob.CreatedAt,
            UpdatedAt = exportJob.UpdatedAt
        };
    }

    private int CalculateProgress(ExportStatus status)
    {
        return status switch
        {
            ExportStatus.Pending => 25,
            ExportStatus.Processing => 75,
            ExportStatus.Completed => 100,
            ExportStatus.Failed => 0,
            _ => 0
        };
    }
}
```

**DownloadExportQuery:**
```csharp
public class DownloadExportQuery : IRequest<FileStreamDto>
{
    public Guid JobId { get; set; }
}

public class FileStreamDto
{
    public Stream Stream { get; set; }
    public string FileName { get; set; }
    public string ContentType { get; set; }
}
```

**DownloadExportQueryHandler:**
```csharp
public class DownloadExportQueryHandler : IRequestHandler<DownloadExportQuery, FileStreamDto>
{
    private readonly IApplicationDbContext _dbContext;
    private readonly ICurrentUserService _currentUserService;
    private readonly IBlobStorageService _blobStorage;

    public async Task<FileStreamDto> Handle(DownloadExportQuery request, CancellationToken cancellationToken)
    {
        var userId = _currentUserService.UserId;
        if (string.IsNullOrEmpty(userId))
            throw new UnauthorizedAccessException();

        var exportJob = await _dbContext.ExportJobs
            .FirstOrDefaultAsync(j => j.Id == request.JobId && j.UserId == userId, cancellationToken);

        if (exportJob == null)
            throw new NotFoundException(nameof(ExportJob), request.JobId);

        if (exportJob.Status != ExportStatus.Completed)
            throw new InvalidOperationException($"Export job is in {exportJob.Status} status, not ready for download");

        var stream = await _blobStorage.GetFileAsync(exportJob.FilePath, cancellationToken);
        var fileName = Path.GetFileName(exportJob.FilePath);
        var contentType = GetContentType(exportJob.Format);

        return new FileStreamDto
        {
            Stream = stream,
            FileName = fileName,
            ContentType = contentType
        };
    }

    private string GetContentType(ExportFormat format)
    {
        return format switch
        {
            ExportFormat.Csv => "text/csv",
            ExportFormat.Excel => "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
            ExportFormat.Json => "application/json",
            _ => "application/octet-stream"
        };
    }
}
```

**ExportController Updates:**
```csharp
[ApiController]
[Route("api/[controller]")]
[Authorize]
public class ExportController : ControllerBase
{
    private readonly IMediator _mediator;

    [HttpGet("{jobId}")]
    public async Task<ActionResult<ExportStatusDto>> GetStatus(Guid jobId)
    {
        try
        {
            var result = await _mediator.Send(new GetExportStatusQuery { JobId = jobId });
            return Ok(result);
        }
        catch (NotFoundException)
        {
            return NotFound();
        }
    }

    [HttpGet("{jobId}/download")]
    public async Task<IActionResult> Download(Guid jobId)
    {
        try
        {
            var result = await _mediator.Send(new DownloadExportQuery { JobId = jobId });
            return File(result.Stream, result.ContentType, result.FileName);
        }
        catch (NotFoundException)
        {
            return NotFound();
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }
}
```

---

## References

- [`../../shared/domain-model.md`](../../shared/domain-model.md) — ExportJob entity
- [`../../shared/architecture.md`](../../shared/architecture.md) — CQRS pattern, exception handling
- MediatR: https://github.com/jbogard/MediatR
- Entity Framework Core: https://docs.microsoft.com/en-us/ef/core/
