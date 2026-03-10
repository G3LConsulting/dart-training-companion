# PROF-02-T01 — API: Home Screen Data Query

**Story:** [PROF-02 — Home Screen](story.md)  **Layer:** Application  **Status:** 🔲 Not started  **Agent:** —

---

## What to build

Implement GetHomeDataQuery handler that aggregates all home screen data into single API response. Query retrieves: (1) Quick-start game modes (static list for MVP: 501, 301, Cricket, NumberFocus), (2) Recent sessions (last 3-5 completed GameSessions for authenticated user, ordered by date DESC), (3) Personal bests (fixed metrics: Highest Checkout, 180 Count, 180 Rate; configurable 4th slot from user profile), (4) Weekly summary (sessions played this week vs last week, average score trend). Create HomeDataDto with all sections. Add GET /api/home endpoint to HomeController. Optimize queries (avoid N+1 problem).

---

## Files to create or modify

| Action | Path |
|--------|------|
| Create | `src/DartsCompanion.Application/Home/Queries/GetHomeData/GetHomeDataQuery.cs` |
| Create | `src/DartsCompanion.Application/Home/Queries/GetHomeData/GetHomeDataQueryHandler.cs` |
| Create | `src/DartsCompanion.Application/Common/DTOs/HomeDataDto.cs` |
| Create | `src/DartsCompanion.Application/Common/DTOs/QuickStartCardDto.cs` |
| Create | `src/DartsCompanion.Application/Common/DTOs/RecentSessionDto.cs` |
| Create | `src/DartsCompanion.Application/Common/DTOs/PersonalBestHighlightDto.cs` |
| Create | `src/DartsCompanion.Application/Common/DTOs/WeeklySummaryDto.cs` |
| Create | `src/DartsCompanion.Api/Controllers/HomeController.cs` |

---

## Definition of done

- [ ] GetHomeDataQuery retrieves authenticated user's home data
- [ ] HomeDataDto includes: QuickStartCards, RecentSessions, PersonalBestHighlights, WeeklySummary
- [ ] QuickStartCards: 4 cards (501, 301, Cricket, NumberFocus) with mode name and icon reference
- [ ] RecentSessions: list of 3-5 last completed sessions (ordered by CompletedAt DESC), includes: gameMode, score, averageDartsPerRound, durationMinutes, completedAt
- [ ] PersonalBestHighlights: 3 fixed metrics + 1 configurable (from user profile), includes: metricName, value, achievedDate
- [ ] WeeklySummary: sessionsThisWeek, sessionsLastWeek, averageThisWeek, averageLastWeek, weekTrend (up/down/flat)
- [ ] GET /api/home returns 200 with HomeDataDto
- [ ] GET /api/home returns 401 if user not authenticated
- [ ] Query optimized (use .Include() for related entities, single DB round-trip if possible)
- [ ] Weekly summary calculates based on user's PreferredWeekStartDay
- [ ] All tests pass; no compilation errors

---

## Implementation notes

- Quick-start cards: static list for MVP (can be enum or hardcoded list)
- Recent sessions: query GameSession table, filter by UserId and Status = Completed, take 5, order by CompletedAt DESC
- Personal best highlights: fixed slots are standard (HighestCheckout, 180Count, 180Rate); 4th slot customizable via user profile CustomMetricSlot
- Weekly summary: calculate week boundaries based on user's PreferredWeekStartDay; aggregate sessions and scores for this week vs last week
- Consider: Cache home data briefly (1-5 minutes) if queries are expensive
- Use ICurrentUserService to get authenticated user
- DTOs should be serializable to JSON; use [JsonPropertyName] or AutoMapper
- Link to [API Contracts](../../shared/api-contracts.md) for endpoint spec
- Link to [Domain Model](../../shared/domain-model.md) for entity relationships

---

## References

- [Story: PROF-02](story.md)
- [Domain Model](../../shared/domain-model.md) — GameSession, PersonalBest, UserStats
- [API Contracts](../../shared/api-contracts.md)
- [Architecture](../../shared/architecture.md)
