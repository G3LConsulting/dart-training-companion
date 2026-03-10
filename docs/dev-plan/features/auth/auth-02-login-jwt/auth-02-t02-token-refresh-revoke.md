# AUTH-02-T02 — API: Refresh & Revoke Token Commands

**Story:** [AUTH-02 — Login & JWT Token Management](story.md)  **Layer:** Application  **Status:** 🔲 Not started  **Agent:** —

---

## What to build

Implement RefreshTokenCommand and RevokeRefreshTokenCommand for token lifecycle management. RefreshTokenCommand accepts old refresh token, validates it (exists, not expired, not revoked), issues new JWT and refresh token, and rotates refresh token (old one marked revoked). RevokeRefreshTokenCommand accepts refresh token and marks it revoked (logout flow). Create validators for both commands. Add POST /api/auth/refresh and POST /api/auth/logout endpoints to AuthController. Include proper error handling (invalid token, expired token).

---

## Files to create or modify

| Action | Path |
|--------|------|
| Create | `src/DartsCompanion.Application/Auth/Commands/RefreshToken/RefreshTokenCommand.cs` |
| Create | `src/DartsCompanion.Application/Auth/Commands/RefreshToken/RefreshTokenCommandHandler.cs` |
| Create | `src/DartsCompanion.Application/Auth/Commands/RefreshToken/RefreshTokenCommandValidator.cs` |
| Create | `src/DartsCompanion.Application/Auth/Commands/RevokeRefreshToken/RevokeRefreshTokenCommand.cs` |
| Create | `src/DartsCompanion.Application/Auth/Commands/RevokeRefreshToken/RevokeRefreshTokenCommandHandler.cs` |
| Create | `src/DartsCompanion.Application/Auth/Commands/RevokeRefreshToken/RevokeRefreshTokenCommandValidator.cs` |
| Modify | `src/DartsCompanion.Api/Controllers/AuthController.cs` |

---

## Definition of done

- [ ] RefreshTokenCommand accepts refreshToken string
- [ ] RefreshTokenCommandHandler: finds token in DB, validates exists and not expired/revoked
- [ ] On success: marks old token as revoked, generates new JWT (15min) and refresh token (7day), returns TokenDto
- [ ] Returns 401 for invalid, expired, or revoked token
- [ ] RevokeRefreshTokenCommand accepts refreshToken string
- [ ] RevokeRefreshTokenCommandHandler: marks token revoked (IsRevoked = true)
- [ ] Returns 204 No Content on success
- [ ] Returns 404 if token not found
- [ ] Both validators check refreshToken not empty
- [ ] POST /api/auth/refresh returns 200 with new TokenDto on success
- [ ] POST /api/auth/logout returns 204 on success
- [ ] All tests pass; no compilation errors

---

## Implementation notes

- RefreshToken lookup: find by token string and not IsRevoked and ExpiryDate > now
- Refresh token rotation: important security practice; always issue new refresh token on refresh request
- RevokeRefreshTokenCommand typically called on logout; can be called directly for explicit logout
- Store refresh tokens in database for revocation; don't store in cache (needs persistence across requests)
- Consider adding CreatedAt to RefreshToken for audit trail
- Link to [Architecture](../../shared/architecture.md) for token refresh patterns
- Reference [NFRs](../../shared/nfrs.md) for security requirements

---

## References

- [Story: AUTH-02](story.md)
- [Domain Model](../../shared/domain-model.md)
- [Architecture](../../shared/architecture.md)
- [API Contracts](../../shared/api-contracts.md)
- [NFRs](../../shared/nfrs.md) — security requirements
