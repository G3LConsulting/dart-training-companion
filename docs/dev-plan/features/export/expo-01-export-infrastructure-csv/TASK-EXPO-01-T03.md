# TASK: EXPO-01-T03 — API: CSV Export Writer

**Story:** [EXPO-01](../STORY-EXPO-01.md)
**Layer:** Backend
**Status:** Pending
**Agent:** Backend Team

---

## What to Build

Implement CsvExportWriter that generates CSV files from export job data:

**Features:**
- Flat CSV file format: one row per turn/dart
- Human-readable headers: Session ID, Date, Game Mode, Target, Multiplier, Score, etc.
- UTF-8 encoding with BOM (Byte Order Mark) for Excel compatibility
- Scope filtering: export scope applied to query (All, GameMode, DateRange, CurrentView)
- File naming: `darts-companion_{scope}_{YYYY-MM-DD}.csv`
- Handles large datasets: streams rows to avoid memory bloat

**Header Row:**
Session ID | Date | Game Mode | Target | Multiplier | Score | Round | Leg | Checkout | Player | Notes

---

## Files

| File Path | Type | Purpose |
|-----------|------|---------|
| `src/Infrastructure/Export/CsvExportWriter.cs` | Implementation | CSV generation logic |
| `src/Application/Common/Interfaces/IExportWriter.cs` | Interface | Abstract export writer |
| `src/Infrastructure/Export/ExportDataProvider.cs` | Helper | Queries data per export scope |

---

## Definition of Done

- [ ] CsvExportWriter implements IExportWriter
- [ ] WriteAsync method accepts ExportJob, queries data per scope, generates CSV
- [ ] CSV includes header row with column names
- [ ] Each turn/dart is one CSV row
- [ ] File saved to blob storage or filesystem with proper naming convention
- [ ] File encoding is UTF-8 with BOM
- [ ] Scope filtering applied: All, GameMode, DateRange, CurrentView
- [ ] Large exports handled efficiently (streaming, no in-memory loading of entire dataset)
- [ ] Date/time columns formatted consistently (ISO 8601)
- [ ] Numeric columns (score, multiplier) are valid numbers (no quotes or formatting)
- [ ] Unit tests verify CSV format, BOM presence, header row, scope filtering
- [ ] Integration tests verify end-to-end export with sample data

---

## Implementation Notes

**CSV Header:**
```
Session ID,Date,Game Mode,Target,Multiplier,Score,Round,Leg,Checkout,Player Notes
```

**CsvExportWriter:**
```csharp
public class CsvExportWriter : IExportWriter
{
    private readonly IApplicationDbContext _dbContext;
    private readonly IBlobStorageService _blobStorage;
    private readonly IExportDataProvider _dataProvider;
    private const string BOM = "\uFEFF"; // UTF-8 BOM

    public async Task<string> WriteAsync(ExportJob job, CancellationToken cancellationToken)
    {
        var data = await _dataProvider.GetExportDataAsync(job, cancellationToken);
        var fileName = GenerateFileName(job);
        var filePath = await WriteToStorageAsync(fileName, data, cancellationToken);
        return filePath;
    }

    private async Task<string> WriteToStorageAsync(string fileName, ExportData data, CancellationToken cancellationToken)
    {
        using (var memoryStream = new MemoryStream())
        using (var writer = new StreamWriter(memoryStream, System.Text.Encoding.UTF8))
        {
            // Write BOM
            writer.Write(BOM);

            // Write header
            writer.WriteLine("Session ID,Date,Game Mode,Target,Multiplier,Score,Round,Leg,Checkout,Player Notes");

            // Write rows
            foreach (var dart in data.Darts)
            {
                var row = CsvEscape(new[]
                {
                    dart.SessionId.ToString(),
                    dart.Date.ToString("yyyy-MM-dd HH:mm:ss"),
                    dart.GameMode,
                    dart.Target.ToString(),
                    dart.Multiplier.ToString(),
                    dart.Score.ToString(),
                    dart.Round.ToString(),
                    dart.Leg.ToString(),
                    dart.IsCheckout ? "Yes" : "No",
                    dart.Notes ?? ""
                });

                writer.WriteLine(row);
            }

            writer.Flush();
            memoryStream.Position = 0;
            return await _blobStorage.UploadFileAsync(fileName, memoryStream, "text/csv", cancellationToken);
        }
    }

    private string GenerateFileName(ExportJob job)
    {
        var dateStr = DateTime.UtcNow.ToString("yyyy-MM-dd");
        var scopeStr = job.Scope switch
        {
            ExportScope.All => "all-data",
            ExportScope.GameMode => $"mode-{job.GameModeFilter}",
            ExportScope.DateRange => $"range-{job.StartDate:yyyy-MM-dd}-{job.EndDate:yyyy-MM-dd}",
            ExportScope.CurrentView => "current-view",
            _ => "export"
        };
        return $"darts-companion_{scopeStr}_{dateStr}.csv";
    }

    private string CsvEscape(string[] fields)
    {
        return string.Join(",", fields.Select(f =>
        {
            if (string.IsNullOrEmpty(f)) return "";
            if (f.Contains(",") || f.Contains("\"") || f.Contains("\n"))
                return $"\"{f.Replace("\"", "\"\"")}\"";
            return f;
        }));
    }
}

public class ExportData
{
    public List<DartExportRow> Darts { get; set; }
}

public class DartExportRow
{
    public Guid SessionId { get; set; }
    public DateTime Date { get; set; }
    public string GameMode { get; set; }
    public int Target { get; set; }
    public int Multiplier { get; set; }
    public int Score { get; set; }
    public int Round { get; set; }
    public int Leg { get; set; }
    public bool IsCheckout { get; set; }
    public string Notes { get; set; }
}
```

**ExportDataProvider:**
```csharp
public interface IExportDataProvider
{
    Task<ExportData> GetExportDataAsync(ExportJob job, CancellationToken cancellationToken);
}

public class ExportDataProvider : IExportDataProvider
{
    private readonly IApplicationDbContext _dbContext;
    private readonly ICurrentUserService _currentUserService;

    public async Task<ExportData> GetExportDataAsync(ExportJob job, CancellationToken cancellationToken)
    {
        var userId = job.UserId;

        IQueryable<Dart> query = _dbContext.Darts
            .Where(d => d.Session.UserId == userId);

        // Apply scope filters
        if (job.Scope == ExportScope.GameMode && !string.IsNullOrEmpty(job.GameModeFilter))
        {
            query = query.Where(d => d.Session.GameMode == job.GameModeFilter);
        }

        if (job.Scope == ExportScope.DateRange)
        {
            if (job.StartDate.HasValue)
                query = query.Where(d => d.Session.StartTime >= job.StartDate.Value);
            if (job.EndDate.HasValue)
                query = query.Where(d => d.Session.StartTime <= job.EndDate.Value.AddDays(1));
        }

        var darts = await query
            .OrderBy(d => d.Session.StartTime)
            .ThenBy(d => d.Round)
            .ThenBy(d => d.Leg)
            .Select(d => new DartExportRow
            {
                SessionId = d.SessionId,
                Date = d.Session.StartTime,
                GameMode = d.Session.GameMode,
                Target = d.Target,
                Multiplier = d.Multiplier,
                Score = d.Score,
                Round = d.Round,
                Leg = d.Leg,
                IsCheckout = d.IsCheckout,
                Notes = d.Notes
            })
            .ToListAsync(cancellationToken);

        return new ExportData { Darts = darts };
    }
}
```

**Dependency Injection:**
```csharp
services.AddScoped<IExportWriter, CsvExportWriter>();
services.AddScoped<IExportDataProvider, ExportDataProvider>();
```

---

## References

- [`../../shared/domain-model.md`](../../shared/domain-model.md) — Dart, Session, GameMode entities
- [`../../shared/nfrs.md`](../../shared/nfrs.md) — Export performance targets
- CSV RFC 4180: https://tools.ietf.org/html/rfc4180
- UTF-8 BOM: https://www.unicode.org/faq/utf_bom.html
