# TASK: EXPO-03-T01 — API: JSON Export Writer

**Story:** [EXPO-03](../STORY-EXPO-03.md)
**Layer:** Backend
**Status:** Pending
**Agent:** Backend Team

---

## What to Build

Implement JsonExportWriter to generate structured JSON export with full data graph:

**Structure:**
```json
{
  "exportMetadata": {
    "exportedAt": "2026-03-09T10:30:00Z",
    "scope": "All",
    "userAgent": "Darts Companion v1.0"
  },
  "profile": {
    "displayName": "Player Name",
    "joinedAt": "2025-01-15",
    "timezone": "UTC"
  },
  "gameSessions": [
    {
      "id": "guid",
      "gameMode": "X01",
      "startTime": "2026-03-09T10:00:00Z",
      "endTime": "2026-03-09T10:30:00Z",
      "darts": [
        {
          "target": 20,
          "multiplier": 3,
          "score": 60,
          "round": 1,
          "leg": 1
        }
      ]
    }
  ],
  "numberFocusSets": [...],
  "personalBestRecords": [...]
}
```

**Features:**
- Scope filtering: All, GameMode, DateRange, CurrentView
- Excludes sensitive fields: password, passwordHash, emailConfirmationToken, etc.
- JSON is pretty-printed (indented for readability)
- File naming: `darts-companion_{scope}_{YYYY-MM-DD}.json`

---

## Files

| File Path | Type | Purpose |
|-----------|------|---------|
| `src/Infrastructure/Export/JsonExportWriter.cs` | Implementation | JSON generation logic |

---

## Definition of Done

- [ ] JsonExportWriter implements IExportWriter
- [ ] WriteAsync method accepts ExportJob, queries data, generates .json
- [ ] JSON includes: exportMetadata, profile, gameSessions, numberFocusSets, personalBestRecords
- [ ] exportMetadata contains: exportedAt (ISO 8601), scope, userAgent
- [ ] profile excludes: password, email, auth tokens, sensitive info
- [ ] gameSessions includes all sessions with darts nested
- [ ] numberFocusSets includes all NF sets with metadata
- [ ] personalBestRecords includes all PB records
- [ ] Scope filtering applied: All, GameMode, DateRange, CurrentView
- [ ] JSON is valid (passes JSON schema validation)
- [ ] JSON is pretty-printed (not minified)
- [ ] File saved to blob storage with correct naming convention
- [ ] Large datasets handled efficiently (streaming writer)
- [ ] Unit tests verify JSON structure, schema compliance, sensitive field exclusion
- [ ] Integration tests verify end-to-end .json generation and parsing

---

## Implementation Notes

**JsonExportWriter:**
```csharp
public class JsonExportWriter : IExportWriter
{
    private readonly IApplicationDbContext _dbContext;
    private readonly IBlobStorageService _blobStorage;
    private readonly IExportDataProvider _dataProvider;

    public async Task<string> WriteAsync(ExportJob job, CancellationToken cancellationToken)
    {
        var data = await _dataProvider.GetExportDataAsync(job, cancellationToken);
        var fileName = GenerateFileName(job);
        var filePath = await WriteToStorageAsync(fileName, job, data, cancellationToken);
        return filePath;
    }

    private async Task<string> WriteToStorageAsync(string fileName, ExportJob job, ExportData data, CancellationToken cancellationToken)
    {
        using (var memoryStream = new MemoryStream())
        {
            using (var writer = new StreamWriter(memoryStream, System.Text.Encoding.UTF8))
            {
                var jsonObject = new
                {
                    exportMetadata = new
                    {
                        exportedAt = DateTime.UtcNow.ToString("O"),
                        scope = job.Scope.ToString(),
                        userAgent = "Darts Companion v1.0"
                    },
                    profile = await GetProfileAsync(job.UserId, cancellationToken),
                    gameSessions = data.Darts.GroupBy(d => d.SessionId).Select(g => new
                    {
                        id = g.Key,
                        gameMode = g.First().GameMode,
                        darts = g.Select(d => new
                        {
                            target = d.Target,
                            multiplier = d.Multiplier,
                            score = d.Score,
                            round = d.Round,
                            leg = d.Leg
                        }).ToList()
                    }).ToList(),
                    numberFocusSets = await GetNumberFocusSetsAsync(job.UserId, job, cancellationToken),
                    personalBestRecords = await GetPersonalBestRecordsAsync(job.UserId, cancellationToken)
                };

                var jsonString = JsonConvert.SerializeObject(jsonObject, Formatting.Indented);
                await writer.WriteAsync(jsonString);
                writer.Flush();
            }

            memoryStream.Position = 0;
            return await _blobStorage.UploadFileAsync(fileName, memoryStream, "application/json", cancellationToken);
        }
    }

    private async Task<dynamic> GetProfileAsync(string userId, CancellationToken cancellationToken)
    {
        var user = await _dbContext.Users.FirstOrDefaultAsync(u => u.Id == userId, cancellationToken);
        if (user == null)
            return null;

        return new
        {
            displayName = user.DisplayName,
            joinedAt = user.CreatedAt.ToString("O"),
            timezone = user.PreferredTimezone ?? "UTC"
        };
    }

    private async Task<List<dynamic>> GetNumberFocusSetsAsync(string userId, ExportJob job, CancellationToken cancellationToken)
    {
        var query = _dbContext.NumberFocusSets.Where(nf => nf.UserId == userId);

        // Apply scope filtering
        if (job.Scope == ExportScope.DateRange)
        {
            if (job.StartDate.HasValue)
                query = query.Where(nf => nf.CreatedAt >= job.StartDate.Value);
            if (job.EndDate.HasValue)
                query = query.Where(nf => nf.CreatedAt <= job.EndDate.Value);
        }

        return (await query.ToListAsync(cancellationToken)).Select(nf => new
        {
            id = nf.Id,
            number = nf.Number,
            accuracy = nf.Accuracy,
            weightedAccuracy = nf.WeightedAccuracy,
            totalSets = nf.TotalSets,
            createdAt = nf.CreatedAt.ToString("O")
        }).Cast<dynamic>().ToList();
    }

    private async Task<List<dynamic>> GetPersonalBestRecordsAsync(string userId, CancellationToken cancellationToken)
    {
        var records = await _dbContext.PersonalBests
            .Where(pb => pb.UserId == userId)
            .ToListAsync(cancellationToken);

        return records.Select(pb => new
        {
            id = pb.Id,
            gameMode = pb.GameMode,
            score = pb.Score,
            roundCount = pb.RoundCount,
            achievedAt = pb.AchievedAt.ToString("O")
        }).Cast<dynamic>().ToList();
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
        return $"darts-companion_{scopeStr}_{dateStr}.json";
    }
}
```

**Alternative: Using System.Text.Json (Recommended)**
```csharp
using System.Text.Json;
using System.Text.Json.Serialization;

public class JsonExportWriter : IExportWriter
{
    private static readonly JsonSerializerOptions JsonOptions = new JsonSerializerOptions
    {
        WriteIndented = true,
        DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull,
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase
    };

    public async Task<string> WriteAsync(ExportJob job, CancellationToken cancellationToken)
    {
        // ... build jsonObject ...
        var jsonString = JsonSerializer.Serialize(jsonObject, JsonOptions);
        // ... upload ...
    }
}
```

---

## References

- [`../../shared/domain-model.md`](../../shared/domain-model.md) — Entity structures
- [`../../shared/nfrs.md`](../../shared/nfrs.md) — GDPR data export requirements
- Newtonsoft.Json: https://www.newtonsoft.com/json
- System.Text.Json: https://docs.microsoft.com/en-us/dotnet/standard/serialization/system-text-json-overview
