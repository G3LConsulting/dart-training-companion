# STAT-01-T03 — Tests: Stats Dashboard Query Tests

**Story:** [STAT-01](../STAT-01-STORY.md)
**Layer:** Backend (Unit & Integration Tests)
**Status:** Not Started
**Assigned To:** —
**Complexity:** M

---

## What to Build

Unit and integration tests for GetStatsDashboardQuery handler and HTTP endpoint.

---

## Files to Create/Modify

| Path | Purpose | Status |
|------|---------|--------|
| `UnitTests/Stats/GetStatsDashboardQueryTests.cs` | Unit tests | To Create |
| `IntegrationTests/Stats/StatsApiTests.cs` | Integration tests | To Create |

---

## Test Scenarios

### Unit Tests

- Calculate 3-dart average correctly
- Calculate checkout % correctly
- Filter by time range (7d, 30d, 90d, all)
- Filter by game mode
- Handle no sessions (return zeros)
- Handle no sessions in time range (return zeros)

### Integration Tests

- GET /api/stats returns 200 with data
- GET /api/stats?range=7d filters by date
- GET /api/stats?mode=Cricket filters by mode
- GET /api/stats requires authentication (401)
- GET /api/stats returns zeros for new user

---

## Definition of Done

- [ ] All unit tests pass
- [ ] All integration tests pass
- [ ] Code coverage >80%
- [ ] All time ranges tested
- [ ] Game mode filtering tested
- [ ] Authentication required verified
- [ ] No flaky tests

---

## References

- [Testing Guide](../../../shared/TESTING-GUIDE.md)
