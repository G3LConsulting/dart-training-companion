# SYNC-02-T01 — API: Conflict Detection in SyncSessionsCommand

**Story:** [SYNC-02](../SYNC-02-STORY.md)
**Layer:** Backend
**Status:** Not Started
**Assigned To:** —
**Complexity:** M

---

## What to Build

Enhance SyncSessionsCommandHandler to detect conflicting sessions during sync. When two sessions from different devices have overlapping time windows and same game mode, flag as conflict instead of auto-merging.

---

## Files to Modify

| Path | Purpose | Status |
|------|---------|--------|
| `Application/Sessions/Commands/SyncSessions/SyncSessionsCommandHandler.cs` | Add conflict detection logic | To Modify |
| `Application/Sessions/DTOs/SyncResultDto.cs` | Add conflicts field | To Modify |
| `Domain/Entities/SyncConflict.cs` | Domain model for conflicts | To Create |
| `Infrastructure/Persistence/ApplicationDbContext.cs` | Add SyncConflicts DbSet | To Modify |

---

## Implementation Notes

### Conflict Detection Logic

```csharp
private List<SyncConflict> DetectConflicts(
    List<GameSession> incomingSessions,
    List<GameSession> existingSessions,
    Guid userId)
{
    var conflicts = new List<SyncConflict>();

    foreach (var incoming in incomingSession)
    {
        var overlapping = existingSessions
            .Where(es =>
                es.UserId == userId &&
                !es.IsDeleted &&
                es.GameMode == incoming.GameMode &&
                IsTimeOverlap(es.CreatedAt, incoming.CreatedAt))
            .ToList();

        if (overlapping.Count > 0)
        {
            foreach (var overlap in overlapping)
            {
                conflicts.Add(new SyncConflict
                {
                    Id = Guid.NewGuid(),
                    UserId = userId,
                    DeviceASessionId = overlap.Id,
                    DeviceBSessionId = null,  // Incoming session not yet persisted
                    DeviceBSessionData = JsonSerializer.Serialize(incoming),
                    GameMode = incoming.GameMode,
                    CreatedAt = DateTime.UtcNow,
                    Status = ConflictStatus.Pending
                });
            }
        }
    }

    return conflicts;
}

private bool IsTimeOverlap(DateTime time1, DateTime time2, int windowMinutes = 30)
{
    var diff = Math.Abs((time1 - time2).TotalMinutes);
    return diff < windowMinutes;
}
```

### SyncResultDto Enhancement

```csharp
public class SyncResultDto
{
    // ... existing fields ...
    public List<SyncConflictDto> Conflicts { get; set; } = new();
}
```

---

## Definition of Done

- [ ] Conflict detection logic implemented in handler
- [ ] Time overlap window configurable (default 30 minutes)
- [ ] Conflicts stored in SyncConflict table
- [ ] SyncResultDto includes conflicts list
- [ ] Unambiguous sessions saved regardless of conflicts
- [ ] Unit tests verify detection logic
- [ ] Integration tests confirm conflict storage

---

## References

- [Domain Model: SyncConflict](../../../shared/DOMAIN-MODEL.md)
- [SYNC-01](../SYNC-01-STORY.md)
