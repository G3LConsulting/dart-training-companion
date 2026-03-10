# INFRA-01-T02 — Domain Entities & Enums

| Metadata | Value |
|----------|-------|
| Story | [INFRA-01](../infra-01-solution-scaffolding.md) — Solution Scaffolding & Domain Model |
| Layer | DB |
| Status | 🔲 Not started |
| Agent | Backend Lead |

## What to Build

Create all entity classes and enums in DartsCompanion.Domain. These form the core business model representing game sessions, turns, dart entries, user data, and administrative entities.

## Files to Create or Modify

| File Path | Purpose | Type |
|-----------|---------|------|
| src/DartsCompanion.Domain/Entities/ApplicationUser.cs | User identity entity | Create |
| src/DartsCompanion.Domain/Entities/RefreshToken.cs | JWT refresh token entity | Create |
| src/DartsCompanion.Domain/Entities/GameSession.cs | Game session aggregate root | Create |
| src/DartsCompanion.Domain/Entities/Turn.cs | Game turn (abstract base) | Create |
| src/DartsCompanion.Domain/Entities/CricketTurn.cs | Cricket-specific turn | Create |
| src/DartsCompanion.Domain/Entities/DartEntry.cs | Single dart entry | Create |
| src/DartsCompanion.Domain/Entities/UserStats.cs | User lifetime statistics | Create |
| src/DartsCompanion.Domain/Entities/PersonalBest.cs | User's personal bests record | Create |
| src/DartsCompanion.Domain/Entities/ExportJob.cs | Async export job tracker | Create |
| src/DartsCompanion.Domain/Enums/GameMode.cs | 501, Cricket, etc. | Create |
| src/DartsCompanion.Domain/Enums/Hand.cs | Right, Left | Create |
| src/DartsCompanion.Domain/Enums/DartOutcome.cs | Hit, Miss, OutOfRange | Create |
| src/DartsCompanion.Domain/Enums/ExportFormat.cs | CSV, Excel, PDF | Create |
| src/DartsCompanion.Domain/Enums/ExportStatus.cs | Pending, Processing, Completed, Failed | Create |

## Definition of Done

- [ ] All entities compile without errors
- [ ] ApplicationUser extends IdentityUser<Guid>
- [ ] All entity fields match the domain model specification
- [ ] Enum values are defined as per domain model
- [ ] Entity relationships are properly defined (navigation properties, foreign keys)
- [ ] Value objects (if any) are immutable and properly structured
- [ ] No circular references between entities

## Implementation Notes

1. **ApplicationUser**: Must extend `IdentityUser<Guid>` and include fields for created timestamp, last login, player profile data
2. **RefreshToken**: Should include token hash, expiration, and revocation tracking
3. **GameSession**: Aggregate root containing turns, players, game type, start/end times, and scoring state
4. **Turn**: Abstract base for game turns; CricketTurn implements cricket-specific logic
5. **DartEntry**: Represents a single dart with value, outcome, and timestamp
6. **UserStats**: Aggregated statistics (games played, average score, win rate, best game)
7. **PersonalBest**: Tracks user's personal records (highest finish, fastest game, etc.)
8. **ExportJob**: Tracks async export requests with status and file path
9. All enums should use explicit integer values where relevant for API stability
10. Consider adding base entity class with Id, CreatedAt, UpdatedAt for common tracking

## References

- [Domain Model](../../../shared/domain-model.md)
- [Technical Approach §5](../../../shared/technical-approach.md#section-5-domain-model)
