# AUTH-04-T01 — API: Delete Account Command

**Story:** [AUTH-04 — Account Deletion](story.md)  **Layer:** Application  **Status:** 🔲 Not started  **Agent:** —

---

## What to build

Implement DeleteAccountCommand with handler and validator. DeleteAccountCommand accepts email (for confirmation). Handler retrieves authenticated user from context, validates email matches, soft-deletes account (IsDeleted = true, DeletedAt = now), anonymizes display name in all leaderboard entries (set to "[Deleted User]"), revokes all refresh tokens, returns 204. Add DELETE /api/profile endpoint to ProfileController (or AuthController). Include Fluent Validation to ensure email matches account email.

---

## Files to create or modify

| Action | Path |
|--------|------|
| Create | `src/DartsCompanion.Application/Auth/Commands/DeleteAccount/DeleteAccountCommand.cs` |
| Create | `src/DartsCompanion.Application/Auth/Commands/DeleteAccount/DeleteAccountCommandHandler.cs` |
| Create | `src/DartsCompanion.Application/Auth/Commands/DeleteAccount/DeleteAccountCommandValidator.cs` |
| Modify | `src/DartsCompanion.Api/Controllers/ProfileController.cs` or `AuthController.cs` |
| Modify | `src/DartsCompanion.Domain/Entities/ApplicationUser.cs` (add IsDeleted, DeletedAt if not already present) |

---

## Definition of done

- [ ] DeleteAccountCommand accepts email string
- [ ] DeleteAccountCommandHandler: retrieves authenticated user from ICurrentUserService or HttpContext
- [ ] Validates email matches user's email; returns 400 if mismatch
- [ ] Sets user.IsDeleted = true, user.DeletedAt = DateTime.UtcNow
- [ ] Removes or anonymizes user's display name from all leaderboard entries (query GameSessions, set DisplayName = "[Deleted User]")
- [ ] Revokes all user's refresh tokens (update RefreshToken table, set IsRevoked = true where UserId = user.Id)
- [ ] Saves changes to database in a transaction
- [ ] DELETE /api/profile returns 204 No Content on success
- [ ] DELETE /api/profile returns 400 if email doesn't match
- [ ] DELETE /api/profile returns 401 if user not authenticated
- [ ] DeleteAccountCommandValidator: email required, email format valid
- [ ] All tests pass; no compilation errors

---

## Implementation notes

- Get current user from dependency injection (ICurrentUserService or extract from HttpContext.User)
- Soft delete: don't remove from database; query filters out IsDeleted = true users
- Anonymize leaderboard: update all related GameSession.DisplayName or separate leaderboard cache
- Revoke all refresh tokens: prevents user from using existing tokens to get new JWTs
- Consider: Hard delete via background job (post-MVP); for now soft delete is sufficient for GDPR compliance
- Ensure email confirmation is case-insensitive (normalize before comparison)
- Use database transaction to ensure atomicity (IsDeleted + leaderboard update + token revocation)
- Link to [API Contracts](../../shared/api-contracts.md) for endpoint specs
- Link to [NFRs](../../shared/nfrs.md) for GDPR requirements

---

## References

- [Story: AUTH-04](story.md)
- [Domain Model](../../shared/domain-model.md)
- [API Contracts](../../shared/api-contracts.md)
- [Architecture](../../shared/architecture.md)
- [NFRs](../../shared/nfrs.md) — GDPR compliance
