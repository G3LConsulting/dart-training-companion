# PROF-02-T03 — Tests: Home Screen Data Tests

**Story:** [PROF-02 — Home Screen](story.md)  **Layer:** Testing  **Status:** 🔲 Not started  **Agent:** —

---

## What to build

Write unit tests for GetHomeDataQuery handler. Test that home data is correctly aggregated: quick-start cards are static list, recent sessions retrieved in correct order, personal best highlights include 3 fixed + 1 configurable metric, and weekly summary calculations are accurate. Test edge cases (no recent sessions, no personal bests, first week, week start day handling). Test permission (user only sees own data).

---

## Files to create or modify

| Action | Path |
|--------|------|
| Create | `tests/DartsCompanion.UnitTests/Home/Queries/GetHomeDataQueryHandlerTests.cs` |

---

## Definition of done

- [ ] GetHomeDataQueryHandlerTests: authenticated user retrieves home data
- [ ] Quick-start cards always present with 4 game modes
- [ ] Recent sessions retrieved in correct order (most recent first), limited to 5 max
- [ ] Personal best highlights include 3 fixed metrics (Highest Checkout, 180 Count, 180 Rate) + 1 from user profile
- [ ] WeeklySummary: sessionsThisWeek counted correctly, sessionsLastWeek counted correctly
- [ ] WeeklySummary: averageThisWeek and averageLastWeek calculated from session scores
- [ ] WeeklySummary: weekTrend calculated correctly (sessions changed, average changed)
- [ ] Week boundaries respect user's PreferredWeekStartDay
- [ ] Empty state: no recent sessions returns empty list, not error
- [ ] Empty state: no personal bests returns zeros or N/A (design decision)
- [ ] User can only see own home data (permission check)
- [ ] All tests pass; coverage >= 80%
- [ ] No compilation errors

---

## Implementation notes

- Mock GameSession, PersonalBest, UserStats repositories
- Mock ICurrentUserService for authenticated user context
- Test week calculation: verify week boundaries for Monday/Sunday start
- Test recent sessions: create 10 sessions, verify only 5 most recent returned
- Test personal best highlights: mock 3 fixed metrics, test custom metric slot from user profile
- Test weekly summary: create sessions spanning 2 weeks, verify count and average correct
- Edge cases: first week (no last week data), user with no sessions, user with 1 session
- Trend calculation: if this week has more sessions than last, trend = "up", with percentage change
- Link to [Architecture](../../shared/architecture.md) for testing patterns

---

## References

- [Story: PROF-02](story.md)
- [Architecture](../../shared/architecture.md)
- xUnit: https://xunit.net/
- Moq: https://github.com/moq/moq4
