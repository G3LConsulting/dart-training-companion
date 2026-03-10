# TASK: EXPO-03-T02 — Integrate JSON Writer into ExportJobService

**Story:** [EXPO-03](../STORY-EXPO-03.md)
**Layer:** Backend
**Status:** Pending
**Agent:** Backend Team

---

## What to Build

Update ExportJobService and ExportWriterFactory to delegate JSON format exports to JsonExportWriter:

**Changes:**
- Ensure IExportWriterFactory includes JSON writer in CreateWriter method
- Update ExportJobService to handle Json format
- Update dependency injection to register JsonExportWriter

---

## Files

| File Path | Type | Purpose |
|-----------|------|---------|
| `src/Infrastructure/BackgroundServices/ExportJobService.cs` | Service | Handles JSON format (no changes needed if factory exists) |
| `src/Infrastructure/Export/ExportWriterFactory.cs` | Factory | Includes JsonExportWriter case |

---

## Definition of Done

- [ ] ExportWriterFactory.CreateWriter(ExportFormat.Json) returns JsonExportWriter instance
- [ ] Service calls JsonExportWriter.WriteAsync for JSON format jobs
- [ ] Service updates job status: Processing → Completed (with file path) or Failed (with error)
- [ ] Dependency injection configured: JsonExportWriter registered as scoped service
- [ ] Unit tests verify factory returns correct writer for Json format
- [ ] Integration tests verify JSON format job flows through service to completion

---

## Implementation Notes

**ExportWriterFactory Update:**
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

**Dependency Injection:**
```csharp
services.AddScoped<JsonExportWriter>();
```

---

## References

- Previous task: EXPO-02-T02 (factory integration pattern)
- EXPO-01-T01: ExportJobService base implementation
