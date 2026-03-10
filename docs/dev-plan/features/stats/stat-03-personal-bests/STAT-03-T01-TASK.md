# STAT-03-T01 — API: GetPersonalBestsQuery Handler

**Story:** [STAT-03](../STAT-03-STORY.md)
**Layer:** Backend (API)
**Status:** Not Started
**Assigned To:** —
**Complexity:** S

---

## What to Build

Implement GetPersonalBestsQuery to retrieve all personal bests for the authenticated user, grouped by game mode and metric type.

---

## Files to Create/Modify

| Path | Purpose | Status |
|------|---------|--------|
| `Application/Stats/Queries/GetPersonalBests/GetPersonalBestsQuery.cs` | Query definition | To Create |
| `Application/Stats/Queries/GetPersonalBests/GetPersonalBestsQueryHandler.cs` | Handler | To Create |
| `Application/Stats/DTOs/PersonalBestsDto.cs` | Response DTO | To Create |
| `Api/Controllers/StatsController.cs` | Add GET /api/stats/personal-bests endpoint | To Modify |

---

## Implementation Notes

### Endpoint

```csharp
// GET /api/stats/personal-bests
[HttpGet("personal-bests")]
[Authorize]
public async Task<ActionResult<PersonalBestsDto>> GetPersonalBests()
{
    var query = new GetPersonalBestsQuery { UserId = User.GetUserId() };
    return Ok(await _mediator.Send(query));
}
```

### DTO Structure

Group PBs by GameMode, then by metric:
```
PersonalBestsDto {
  ByGameMode: {
    Standard501: [
      { metric: "3DartAverage", value: 95.5, achievedAt: ... },
      { metric: "HighestCheckout", value: 170, achievedAt: ... }
    ],
    Cricket: [...],
    ...
  }
}
```

---

## Definition of Done

- [ ] Query handler retrieves and groups PBs correctly
- [ ] PersonalBestsDto created with proper structure
- [ ] GET /api/stats/personal-bests endpoint created
- [ ] Endpoint requires authentication
- [ ] Unit tests verify grouping logic
- [ ] Integration tests confirm endpoint

---

## References

- [Domain Model: PersonalBest](../../../shared/DOMAIN-MODEL.md)
