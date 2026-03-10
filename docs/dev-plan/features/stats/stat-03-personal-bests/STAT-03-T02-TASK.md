# STAT-03-T02 — API: PB Check Logic in CreateSessionCommand

**Story:** [STAT-03](../STAT-03-STORY.md)
**Layer:** Backend (API)
**Status:** Not Started
**Assigned To:** —
**Complexity:** M

---

## What to Build

Enhance CreateSessionCommandHandler (GAME-04) to check for new personal bests when a session is saved and update PersonalBest records accordingly.

---

## Files to Modify

| Path | Purpose | Status |
|------|---------|--------|
| `Application/Sessions/Commands/CreateSession/CreateSessionCommandHandler.cs` | Add PB check logic | To Modify |

---

## Implementation Notes

### PB Detection Logic

After session is saved:
1. Calculate session metrics (3-dart avg, checkout, etc.)
2. Query existing PBs for user and game mode
3. Compare session metrics to PBs
4. If metric exceeds existing PB:
   - Update PersonalBest record
   - Return new PB info in response

### Return DTO Enhancement

```csharp
public class CreateSessionResponseDto
{
    public Guid SessionId { get; set; }
    public List<NewPersonalBestDto> NewPersonalBests { get; set; }
}

public class NewPersonalBestDto
{
    public PersonalBestMetric Metric { get; set; }
    public GameMode GameMode { get; set; }
    public int Value { get; set; }
}
```

---

## Definition of Done

- [ ] PB check logic integrated in CreateSessionCommandHandler
- [ ] All relevant metrics checked (3-dart avg, checkout %, etc.)
- [ ] PersonalBest records updated on new PBs
- [ ] Response includes new PBs for UI notification
- [ ] Unit tests verify PB detection
- [ ] Integration tests confirm end-to-end flow

---

## References

- [GAME-04: Create Session](../../game-play/GAME-04-STORY.md)
- [Domain Model: PersonalBest](../../../shared/DOMAIN-MODEL.md)
