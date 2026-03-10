# PROF-01-T01 — API: Profile Query & Update Commands

**Story:** [PROF-01 — Profile Management](story.md)  **Layer:** Application  **Status:** 🔲 Not started  **Agent:** —

---

## What to build

Implement GetProfileQuery with handler to retrieve authenticated user's profile (display name, dominant hand, game mode, target average, week start day, custom metric slot). Implement UpdateProfileCommand with handler and validator to update all profile fields. Create ProfileDto DTO with all editable fields. Add GET /api/profile and PUT /api/profile endpoints to ProfileController. Include Fluent Validation for all update fields (DisplayName max 100, TargetAverage > 0, DominantHand valid enum, etc.).

---

## Files to create or modify

| Action | Path |
|--------|------|
| Create | `src/DartsCompanion.Application/Profile/Queries/GetProfile/GetProfileQuery.cs` |
| Create | `src/DartsCompanion.Application/Profile/Queries/GetProfile/GetProfileQueryHandler.cs` |
| Create | `src/DartsCompanion.Application/Profile/Commands/UpdateProfile/UpdateProfileCommand.cs` |
| Create | `src/DartsCompanion.Application/Profile/Commands/UpdateProfile/UpdateProfileCommandHandler.cs` |
| Create | `src/DartsCompanion.Application/Profile/Commands/UpdateProfile/UpdateProfileCommandValidator.cs` |
| Create | `src/DartsCompanion.Application/Common/DTOs/ProfileDto.cs` |
| Create | `src/DartsCompanion.Api/Controllers/ProfileController.cs` |

---

## Definition of done

- [ ] GetProfileQuery retrieves authenticated user's profile
- [ ] GetProfileQueryHandler returns ProfileDto with all user's profile fields
- [ ] GET /api/profile returns 200 with ProfileDto
- [ ] GET /api/profile returns 401 if user not authenticated
- [ ] UpdateProfileCommand accepts: displayName, dominantHand, preferredGameMode, targetAverage, preferredWeekStartDay, customMetricSlot
- [ ] UpdateProfileCommandHandler updates all provided fields, saves to database
- [ ] UpdateProfileCommandValidator: DisplayName max 100, DominantHand in [left, right], PreferredGameMode in valid list, TargetAverage > 0, PreferredWeekStartDay in [0-6], CustomMetricSlot in valid metrics
- [ ] PUT /api/profile returns 204 No Content on success
- [ ] PUT /api/profile returns 400 for validation errors
- [ ] PUT /api/profile returns 401 if user not authenticated
- [ ] ProfileDto includes: UserId, Email, DisplayName, DominantHand, PreferredGameMode, TargetAverage, PreferredWeekStartDay, CustomMetricSlot, CreatedAt
- [ ] All tests pass; no compilation errors

---

## Implementation notes

- Get authenticated user from ICurrentUserService or HttpContext.User
- ProfileDto maps from ApplicationUser; use AutoMapper if configured
- Dominant hand: enum (Left = 0, Right = 1) or string in database
- Preferred game mode: string (e.g., "501", "301", "Cricket", "NumberFocus")
- Target average: decimal, nullable (user can leave unset)
- Week start day: DayOfWeek enum (0 = Sunday, 1 = Monday, etc.) or int
- Custom metric slot: string referencing a metric name or null
- UpdateProfileCommand only updates provided fields (partial update pattern); consider using [JsonIgnore(Condition.WhenWritingNull)] for optional fields
- Link to [API Contracts](../../shared/api-contracts.md) for endpoint specs
- Link to [Domain Model](../../shared/domain-model.md) for ApplicationUser field types

---

## References

- [Story: PROF-01](story.md)
- [Domain Model](../../shared/domain-model.md)
- [API Contracts](../../shared/api-contracts.md)
- [Architecture](../../shared/architecture.md)
