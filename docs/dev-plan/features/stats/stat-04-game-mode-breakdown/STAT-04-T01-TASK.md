# STAT-04-T01 — API: GetNumberFocusStatsQuery Handler

**Story:** [STAT-04](../STAT-04-STORY.md)
**Layer:** Backend (API)
**Status:** Not Started
**Assigned To:** —
**Complexity:** L

---

## What to Build

Implement GetNumberFocusStatsQuery to return per-target statistics for Number Focus game mode, including hit distribution and accuracy trends for each target (1-20 + Bull).

---

## Files to Create/Modify

| Path | Purpose | Status |
|------|---------|--------|
| `Application/Stats/Queries/GetNumberFocusStats/GetNumberFocusStatsQuery.cs` | Query definition | To Create |
| `Application/Stats/Queries/GetNumberFocusStats/GetNumberFocusStatsQueryHandler.cs` | Handler with per-target calcs | To Create |
| `Application/Stats/DTOs/NumberFocusStatsDto.cs` | Response DTO | To Create |
| `Api/Controllers/StatsController.cs` | Add GET /api/stats/number-focus/{number} endpoint | To Modify |

---

## Implementation Notes

### Metrics Per Target

For each target (1-20, Bull):
- Weighted accuracy (hits / total attempts * 100)
- Hit count and trend
- Attempts count
- Accuracy by round

### Weighted Accuracy Calculation

```
Weighted Accuracy = (Total Hits / Total Attempts) * 100
Color coding:
- Green: >= 80%
- Yellow: 50-79%
- Orange: 25-49%
- Red: < 25%
```

### Endpoint

```csharp
// GET /api/stats/number-focus/{number}
[HttpGet("number-focus/{number}")]
[Authorize]
public async Task<ActionResult<NumberFocusStatsDto>> GetNumberFocusStats(string number)
{
    var query = new GetNumberFocusStatsQuery
    {
        UserId = User.GetUserId(),
        TargetNumber = number
    };
    return Ok(await _mediator.Send(query));
}
```

---

## Definition of Done

- [ ] Query handler calculates per-target stats correctly
- [ ] Weighted accuracy calculation verified
- [ ] Hit distribution trend data returned
- [ ] NumberFocusStatsDto created
- [ ] Endpoint created and working
- [ ] Handles all 21 targets (1-20, Bull)
- [ ] Unit tests verify calculations
- [ ] Integration tests confirm endpoint

---

## References

- [Domain Model: DartEntry](../../../shared/DOMAIN-MODEL.md)
- [GAME-07: Number Focus](../../game-play/GAME-07-STORY.md)
