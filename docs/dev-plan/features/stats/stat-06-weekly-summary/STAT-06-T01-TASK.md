# STAT-06-T01 — API: GetWeeklyStatsQuery Handler

**Story:** [STAT-06](../STAT-06-STORY.md)
**Layer:** Backend (API)
**Status:** Not Started
**Assigned To:** —
**Complexity:** M

---

## What to Build

Implement GetWeeklyStatsQuery to calculate current week and prior week statistics, respecting user's preferred week start day. Returns sessions count, average score, and improvement indicator.

---

## Files to Create/Modify

| Path | Purpose | Status |
|------|---------|--------|
| `Application/Stats/Queries/GetWeeklyStats/GetWeeklyStatsQuery.cs` | Query definition | To Create |
| `Application/Stats/Queries/GetWeeklyStats/GetWeeklyStatsQueryHandler.cs` | Handler with week boundary logic | To Create |
| `Application/Stats/DTOs/WeeklyStatsDto.cs` | Response DTO | To Create |
| `Api/Controllers/StatsController.cs` | Add GET /api/stats/weekly endpoint | To Modify |

---

## Implementation Notes

### Week Boundary Calculation

Respect ApplicationUser.WeekStartDay (Monday or Sunday):

```csharp
private (DateTime start, DateTime end) GetWeekBoundaries(
    DateTime date,
    DayOfWeek weekStartDay)
{
    int daysToSubtract = (int)date.DayOfWeek - (int)weekStartDay;
    if (daysToSubtract < 0) daysToSubtract += 7;

    var weekStart = date.AddDays(-daysToSubtract).Date;
    var weekEnd = weekStart.AddDays(7).AddSeconds(-1);

    return (weekStart, weekEnd);
}
```

### Metrics

- Current week: sessions count, average 3-dart score
- Prior week: sessions count, average 3-dart score
- Improvement: percentage change in average

### Endpoint

```csharp
// GET /api/stats/weekly
[HttpGet("weekly")]
[Authorize]
public async Task<ActionResult<WeeklyStatsDto>> GetWeeklyStats()
{
    var query = new GetWeeklyStatsQuery { UserId = User.GetUserId() };
    return Ok(await _mediator.Send(query));
}
```

---

## Definition of Done

- [ ] Query handler calculates week boundaries correctly
- [ ] Respects user's week start day preference
- [ ] Calculates current and prior week stats
- [ ] Improvement metric calculated correctly
- [ ] WeeklyStatsDto created
- [ ] GET /api/stats/weekly endpoint created
- [ ] Unit tests verify week boundary logic
- [ ] Integration tests confirm endpoint

---

## References

- [Domain Model: ApplicationUser.WeekStartDay](../../../shared/DOMAIN-MODEL.md)
- [PROF-01: User Preferences](../../profile/PROF-01-STORY.md)
