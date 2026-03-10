# TASK: EXPO-02-T02 — Integrate Excel Writer into ExportJobService

**Story:** [EXPO-02](../STORY-EXPO-02.md)
**Layer:** Backend
**Status:** Pending
**Agent:** Backend Team

---

## What to Build

Update ExportJobService to delegate Excel format exports to ExcelExportWriter:

**Changes:**
- Modify ExportJobService to check export job format
- If format = Excel, instantiate and call ExcelExportWriter
- Otherwise, use appropriate writer (CSV, JSON)
- Update IExportWriterFactory to include Excel writer

---

## Files

| File Path | Type | Purpose |
|-----------|------|---------|
| `src/Infrastructure/BackgroundServices/ExportJobService.cs` | Service | Updated to handle Excel format |
| `src/Infrastructure/Export/IExportWriterFactory.cs` | Interface | Factory pattern for writers |
| `src/Infrastructure/Export/ExportWriterFactory.cs` | Implementation | Concrete factory |

---

## Definition of Done

- [ ] ExportJobService compiles and processes Excel exports
- [ ] ExportWriterFactory.CreateWriter(ExportFormat.Excel) returns ExcelExportWriter instance
- [ ] Service calls ExcelExportWriter.WriteAsync for Excel format jobs
- [ ] Service updates job status: Processing → Completed (with file path) or Failed (with error)
- [ ] Dependency injection configured: IExportWriterFactory registered
- [ ] Unit tests mock factory and verify service calls correct writer
- [ ] Integration tests verify Excel format job flows through service

---

## Implementation Notes

**Updated ExportJobService:**
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
                    _logger.LogInformation("Export job {JobId} completed: {FilePath}", job.Id, filePath);
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

**IExportWriterFactory:**
```csharp
public interface IExportWriterFactory
{
    IExportWriter CreateWriter(ExportFormat format);
}
```

**ExportWriterFactory:**
```csharp
public class ExportWriterFactory : IExportWriterFactory
{
    private readonly IServiceProvider _serviceProvider;

    public ExportWriterFactory(IServiceProvider serviceProvider)
    {
        _serviceProvider = serviceProvider;
    }

    public IExportWriter CreateWriter(ExportFormat format)
    {
        return format switch
        {
            ExportFormat.Csv => _serviceProvider.GetRequiredService<CsvExportWriter>(),
            ExportFormat.Excel => _serviceProvider.GetRequiredService<ExcelExportWriter>(),
            ExportFormat.Json => _serviceProvider.GetRequiredService<JsonExportWriter>(),
            _ => throw new ArgumentException($"Unknown export format: {format}")
        };
    }
}
```

**Dependency Injection Setup:**
```csharp
services.AddScoped<IExportWriterFactory, ExportWriterFactory>();
services.AddScoped<CsvExportWriter>();
services.AddScoped<ExcelExportWriter>();
services.AddScoped<JsonExportWriter>();
```

---

## References

- [`../../shared/architecture.md`](../../shared/architecture.md) — Factory pattern, dependency injection
- Previous task: EXPO-01-T01 (ExportJobService base implementation)
