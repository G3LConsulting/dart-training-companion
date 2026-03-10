# STAT-02-T04 — Tests: Trend Data Query Tests

**Story:** [STAT-02](../STAT-02-STORY.md)
**Layer:** Backend (Unit & Integration Tests)
**Status:** Not Started
**Assigned To:** —
**Complexity:** M

---

## What to Build

Unit and integration tests for GetTrendDataQuery handler and HTTP endpoint.

---

## Files to Create/Modify

| Path | Purpose | Status |
|------|---------|--------|
| `UnitTests/Stats/GetTrendDataQueryTests.cs` | Unit tests | To Create |
| `IntegrationTests/Stats/TrendDataApiTests.cs` | Integration tests | To Create |

---

## Test Scenarios

### Unit Tests

- Aggregate sessions by date correctly
- Calculate daily metrics (avg, checkout %)
- Filter by metric type
- Filter by time range
- Handle sparse data (gaps in days)
- Handle single session
- Handle no sessions (empty array)

### Integration Tests

- GET /api/stats/trends returns 200 with data
- GET /api/stats/trends?metric=avg_3dart works
- GET /api/stats/trends?range=30d filters dates
- GET /api/stats/trends requires authentication (401)
- Response format matches Chart.js expectations

---

## Definition of Done

- [ ] All unit tests pass
- [ ] All integration tests pass
- [ ] Code coverage >80%
- [ ] Aggregation verified with real data
- [ ] Time range filtering verified
- [ ] Data format verified for Chart.js
- [ ] No flaky tests

---

## References

- [Testing Guide](../../../shared/TESTING-GUIDE.md)
