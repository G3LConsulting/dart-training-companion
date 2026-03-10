# SYNC-02-T04 — Tests: Conflict Detection and Resolution

**Story:** [SYNC-02](../SYNC-02-STORY.md)
**Layer:** Backend
**Status:** Not Started
**Assigned To:** —
**Complexity:** M

---

## What to Build

Comprehensive tests for conflict detection logic and conflict resolution command.

---

## Files to Create/Modify

| Path | Purpose | Status |
|------|---------|--------|
| `UnitTests/Sessions/SyncConflictDetectionTests.cs` | Conflict detection unit tests | To Create |
| `UnitTests/Sessions/ResolveConflictCommandTests.cs` | Conflict resolution command tests | To Create |
| `IntegrationTests/Sessions/ConflictResolutionApiTests.cs` | Integration tests for conflict endpoints | To Create |

---

## Implementation Notes

### Detection Tests

Test scenarios:
- Detect overlapping sessions in same mode
- Don't detect non-overlapping sessions
- Don't detect overlapping sessions in different modes
- Handle multiple conflicts per user
- Filter out deleted sessions

### Resolution Tests

Test all resolution options:
- KeepBoth: Both sessions saved
- KeepA: SessionA kept, B discarded
- KeepB: SessionB saved, A discarded
- KeepNeither: Both discarded

Also test:
- Stats recalculation triggered
- Conflict marked as resolved
- Unauthorized access prevented

---

## Definition of Done

- [ ] All unit tests pass
- [ ] All integration tests pass
- [ ] Code coverage >80%
- [ ] All resolution options tested
- [ ] Stats recalculation verified
- [ ] Authorization verified
- [ ] No flaky tests

---

## References

- [Testing Guide](../../../shared/TESTING-GUIDE.md)
- [SYNC-02-T01: Conflict Detection](./SYNC-02-T01-TASK.md)
- [SYNC-02-T02: Conflict Resolution](./SYNC-02-T02-TASK.md)
