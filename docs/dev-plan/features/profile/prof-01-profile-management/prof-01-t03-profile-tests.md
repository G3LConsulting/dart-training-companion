# PROF-01-T03 — Tests: Profile Management Tests

**Story:** [PROF-01 — Profile Management](story.md)  **Layer:** Testing  **Status:** 🔲 Not started  **Agent:** —

---

## What to build

Write unit tests for GetProfileQuery and UpdateProfileCommand handlers and validators. Test successful retrieval and update, validation error cases (DisplayName too long, TargetAverage negative, invalid enum values), and permission checks (user can only access/modify own profile). Test that profile changes persist in database and are returned by subsequent GET requests.

---

## Files to create or modify

| Action | Path |
|--------|------|
| Create | `tests/DartsCompanion.UnitTests/Profile/Queries/GetProfileQueryHandlerTests.cs` |
| Create | `tests/DartsCompanion.UnitTests/Profile/Commands/UpdateProfileCommandHandlerTests.cs` |
| Create | `tests/DartsCompanion.UnitTests/Profile/Commands/UpdateProfileCommandValidatorTests.cs` |

---

## Definition of done

- [ ] GetProfileQueryHandlerTests: authenticated user retrieves own profile, includes all fields (DisplayName, DominantHand, PreferredGameMode, TargetAverage, PreferredWeekStartDay, CustomMetricSlot)
- [ ] GetProfileQueryHandlerTests: returns 401 if user not authenticated
- [ ] UpdateProfileCommandHandlerTests: valid update modifies all fields, saves to DB
- [ ] UpdateProfileCommandHandlerTests: partial update (only some fields) works correctly
- [ ] UpdateProfileCommandHandlerTests: all fields optional (can update one field only)
- [ ] UpdateProfileCommandValidatorTests: DisplayName required (or optional based on design), max 100 chars
- [ ] UpdateProfileCommandValidatorTests: DominantHand must be left or right
- [ ] UpdateProfileCommandValidatorTests: PreferredGameMode must be in valid list (501, 301, Cricket, NumberFocus)
- [ ] UpdateProfileCommandValidatorTests: TargetAverage > 0 if provided
- [ ] UpdateProfileCommandValidatorTests: PreferredWeekStartDay valid DayOfWeek (0-6)
- [ ] UpdateProfileCommandValidatorTests: CustomMetricSlot valid metric name if provided
- [ ] UpdateProfileCommandHandlerTests: user cannot update another user's profile (permission check)
- [ ] Integration test: update profile, retrieve it again, verify changes persisted
- [ ] All tests pass; coverage >= 80%
- [ ] No compilation errors

---

## Implementation notes

- Use mocked ICurrentUserService to provide authenticated user context
- Test both valid and invalid enum values (e.g., "Invalid" for DominantHand)
- Test partial updates: only include changed fields in UpdateProfileCommand
- Test that GET returns updated values after PUT
- Test permission: mock user context, attempt to update different user's profile (should fail)
- Integration test: use real DbContext (in-memory) to verify persistence
- Test all field combinations (not just single field updates)
- Link to [Architecture](../../shared/architecture.md) for testing patterns

---

## References

- [Story: PROF-01](story.md)
- [Architecture](../../shared/architecture.md)
- xUnit: https://xunit.net/
- Moq: https://github.com/moq/moq4
