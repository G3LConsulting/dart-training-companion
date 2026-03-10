# STAT-05-T01 — API: Extend GetStatsDashboardQuery with Distribution Data

**Story:** [STAT-05](../STAT-05-STORY.md)
**Layer:** Backend (API)
**Status:** Not Started
**Assigned To:** —
**Complexity:** S

---

## What to Build

Enhance GetStatsDashboardQuery to include scoring distribution data when segment-by-segment entry data is available. Distribution shows which numbers player scores on most frequently.

---

## Files to Modify

| Path | Purpose | Status |
|------|---------|--------|
| `Application/Stats/Queries/GetStatsDashboard/GetStatsDashboardQueryHandler.cs` | Add distribution calculation | To Modify |
| `Application/Stats/DTOs/StatsDashboardDto.cs` | Add distribution field | To Modify |

---

## Implementation Notes

### Distribution Data

For each number (1-20, Bull):
- Count of times scored on
- Percentage of total scores
- Average points per score

Only include if segment-by-segment entry used; otherwise return empty/null.

### Extension

```csharp
public class StatsDashboardDto
{
    // ... existing fields ...
    public ScoringDistributionDto ScoringDistribution { get; set; }
}

public class ScoringDistributionDto
{
    public bool HasData { get; set; }
    public Dictionary<int, int> ScoreCounts { get; set; }
    public string EmptyDataMessage => "Enable segment entry to see your scoring distribution";
}
```

---

## Definition of Done

- [ ] Distribution data added to StatsDashboardDto
- [ ] Calculation logic implemented
- [ ] Handles missing segment data gracefully
- [ ] Returns empty message when no segment data
- [ ] Unit tests verify calculation
- [ ] Integration tests confirm endpoint returns data

---

## References

- [STAT-01: Dashboard](../stat-01-stats-dashboard/STAT-01-T01-TASK.md)
- [GAME-02: Game Entry](../../game-play/GAME-02-STORY.md)
