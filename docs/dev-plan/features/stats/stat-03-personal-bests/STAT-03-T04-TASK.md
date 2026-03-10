# STAT-03-T04 — Tests: PB Detection and Query Tests

**Story:** [STAT-03](../STAT-03-STORY.md)
**Layer:** Backend (Unit & Integration Tests)
**Status:** Not Started
**Assigned To:** —
**Complexity:** M

---

## What to Build

Unit and integration tests for PB detection in CreateSessionCommand and GetPersonalBestsQuery.

---

## Files to Create/Modify

| Path | Purpose | Status |
|------|---------|--------|
| `UnitTests/Stats/PersonalBestDetectionTests.cs` | PB detection unit tests | To Create |
| `UnitTests/Stats/GetPersonalBestsQueryTests.cs` | Query unit tests | To Create |
| `IntegrationTests/Stats/PersonalBestApiTests.cs` | Integration tests | To Create |

---

## Test Scenarios

### Detection Tests

- Detect new PB (no existing record)
- Update existing PB when exceeded
- Don't update PB when not exceeded
- Handle multiple metrics per mode
- Handle multiple game modes

### Query Tests

- Retrieve all PBs for user
- Group by game mode correctly
- Return empty list for new user
- Include achieved date
- Filter by game mode (optional)

### Integration Tests

- POST session detects and stores new PBs
- Response includes new PBs
- GET /api/stats/personal-bests returns grouped data
- Notification triggered on new PB

---

## Definition of Done

- [ ] All unit tests pass
- [ ] All integration tests pass
- [ ] Code coverage >80%
- [ ] PB detection verified for all metrics
- [ ] Grouping logic verified
- [ ] No flaky tests

---

## References

- [Testing Guide](../../../shared/TESTING-GUIDE.md)
