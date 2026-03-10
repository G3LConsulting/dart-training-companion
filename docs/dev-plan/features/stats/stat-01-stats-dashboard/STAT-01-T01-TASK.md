# STAT-01-T01 — API: GetStatsDashboardQuery Handler

**Story:** [STAT-01](../STAT-01-STORY.md)
**Layer:** Backend (API)
**Status:** Not Started
**Assigned To:** —
**Complexity:** M

---

## What to Build

Implement GetStatsDashboardQuery to calculate and return key performance indicators (KPIs) for authenticated user, with optional time range and game mode filtering.

---

## Files to Create/Modify

| Path | Purpose | Status |
|------|---------|--------|
| `Application/Stats/Queries/GetStatsDashboard/GetStatsDashboardQuery.cs` | Query definition | To Create |
| `Application/Stats/Queries/GetStatsDashboard/GetStatsDashboardQueryHandler.cs` | Handler with KPI calculations | To Create |
| `Application/Stats/DTOs/StatsDashboardDto.cs` | Response DTO | To Create |
| `Api/Controllers/StatsController.cs` | GET /api/stats endpoint | To Create |

---

## Implementation Notes

### Query & Handler

Calculate KPIs from sessions:
- **3-Dart Average:** (Total Points / Total Darts) * 3
- **Checkout %:** (Completed Games / Total Games) * 100
- **Total Games:** Count of non-deleted sessions
- **Time Range Filtering:** 7 days, 30 days, 90 days, all time

### Endpoint

```csharp
// GET /api/stats?range=30d&mode=501
[HttpGet]
[Authorize]
public async Task<ActionResult<StatsDashboardDto>> GetStatsDashboard(
    [FromQuery] string range = "all",
    [FromQuery] GameMode? mode = null)
{
    var query = new GetStatsDashboardQuery
    {
        UserId = User.GetUserId(),
        Range = ParseRange(range),
        GameMode = mode
    };
    return Ok(await _mediator.Send(query));
}
```

---

## Definition of Done

- [ ] Query handler implemented with KPI calculations
- [ ] Time range filtering working (7d, 30d, 90d, all)
- [ ] Game mode filtering working
- [ ] StatsDashboardDto created
- [ ] GET /api/stats endpoint created
- [ ] Proper error handling
- [ ] Unit tests verify calculations
- [ ] Integration tests confirm endpoint

---

## References

- [CQRS Pattern](../../../shared/ARCHITECTURE.md#cqrs)
- [Domain Model: UserStats](../../../shared/DOMAIN-MODEL.md)
