# AUTH-04-T03 — Tests: Account Deletion Tests

**Story:** [AUTH-04 — Account Deletion](story.md)  **Layer:** Testing  **Status:** 🔲 Not started  **Agent:** —

---

## What to build

Write unit tests for DeleteAccountCommand handler and validator. Test successful deletion (account soft-deleted, IsDeleted = true, DeletedAt set), email validation (mismatch returns 400), leaderboard anonymization (display name set to "[Deleted User]"), refresh token revocation, and database transaction integrity. Test that deleted accounts cannot login and are filtered from queries.

---

## Files to create or modify

| Action | Path |
|--------|------|
| Create | `tests/DartsCompanion.UnitTests/Auth/Commands/DeleteAccountCommandHandlerTests.cs` |
| Create | `tests/DartsCompanion.UnitTests/Auth/Commands/DeleteAccountCommandValidatorTests.cs` |

---

## Definition of done

- [ ] DeleteAccountCommandHandlerTests: valid email soft-deletes account (IsDeleted = true)
- [ ] DeleteAccountCommandHandlerTests: DeletedAt timestamp set correctly
- [ ] DeleteAccountCommandHandlerTests: email mismatch returns 400
- [ ] DeleteAccountCommandHandlerTests: all user's leaderboard entries anonymized (DisplayName = "[Deleted User]")
- [ ] DeleteAccountCommandHandlerTests: all user's refresh tokens revoked (IsRevoked = true)
- [ ] DeleteAccountCommandHandlerTests: deleted user cannot login (filtered out by login query)
- [ ] DeleteAccountCommandHandlerTests: deleted user not included in profile queries
- [ ] DeleteAccountCommandValidatorTests: email required, email format validation
- [ ] Test transaction: if anonymization fails, entire operation rolled back
- [ ] All tests pass; coverage >= 80%
- [ ] No compilation errors

---

## Implementation notes

- Use mocked DbContext or real in-memory database for integration tests
- Test soft delete: verify IsDeleted = true after deletion, verify user still in DB (not hard-deleted)
- Test leaderboard anonymization: query all GameSession entries with user's Id, verify DisplayName updated
- Test token revocation: verify all RefreshToken rows for user marked IsRevoked = true
- Test login failure: attempt to login with deleted user's credentials, verify rejected
- Test queries filter deleted users: GetUserQuery, GetProfileQuery should exclude IsDeleted = true
- Test atomic transaction: use database transaction; verify rollback on failure
- Consider edge case: user deleted mid-session (token becomes invalid on next refresh)
- Link to [Architecture](../../shared/architecture.md) for testing patterns

---

## References

- [Story: AUTH-04](story.md)
- [Architecture](../../shared/architecture.md)
- xUnit: https://xunit.net/
- Moq: https://github.com/moq/moq4
