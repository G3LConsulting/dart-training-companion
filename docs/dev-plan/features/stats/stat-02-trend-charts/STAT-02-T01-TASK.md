# STAT-02-T01 — API: GetTrendDataQuery Handler

**Story:** [STAT-02](../STAT-02-STORY.md)
**Layer:** Backend (API)
**Status:** Not Started
**Assigned To:** —
**Complexity:** M

---

## What to Build

Implement GetTrendDataQuery to calculate time-series data for trend visualization. Query aggregates KPIs by day and returns data points for Chart.js rendering.

---

## Files to Create/Modify

| Path | Purpose | Status |
|------|---------|--------|
| `Application/Stats/Queries/GetTrendData/GetTrendDataQuery.cs` | Query definition | To Create |
| `Application/Stats/Queries/GetTrendData/GetTrendDataQueryHandler.cs` | Handler with aggregation | To Create |
| `Application/Stats/DTOs/TrendDataDto.cs` | Response DTO | To Create |
| `Api/Controllers/StatsController.cs` | Add GET /api/stats/trends endpoint | To Modify |

---

## Implementation Notes

### Aggregation Logic

Aggregate daily stats:
- Group sessions by date
- Calculate daily 3-dart average, checkout %
- Return as list of data points for Chart.js

### Endpoint

```csharp
// GET /api/stats/trends?metric=avg_3dart&range=90d
[HttpGet("trends")]
[Authorize]
public async Task<ActionResult<TrendDataDto>> GetTrendData(
    [FromQuery] string metric,
    [FromQuery] string range = "90d")
{
    var query = new GetTrendDataQuery
    {
        UserId = User.GetUserId(),
        Metric = metric,
        Range = ParseRange(range)
    };
    return Ok(await _mediator.Send(query));
}
```

---

## Definition of Done

- [ ] Query handler aggregates sessions by date
- [ ] Returns time-series data points
- [ ] Supports multiple metrics (avg_3dart, checkout_%)
- [ ] Time range filtering working
- [ ] TrendDataDto matches Chart.js expectations
- [ ] Endpoint created and working
- [ ] Unit tests verify aggregation
- [ ] Integration tests confirm endpoint

---

## References

- [Chart.js Data Format](https://www.chartjs.org/docs/latest/general/data-structures.html)
- [STAT-02: Trend Charts](../STAT-02-STORY.md)
