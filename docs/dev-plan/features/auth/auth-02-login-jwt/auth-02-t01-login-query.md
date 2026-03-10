# AUTH-02-T01 — API: Login Query Handler

**Story:** [AUTH-02 — Login & JWT Token Management](story.md)  **Layer:** Application  **Status:** 🔲 Not started  **Agent:** —

---

## What to build

Implement LoginQuery (CQRS query for login) with handler that validates email and password against ApplicationUser using UserManager. Check that account exists, is verified (EmailConfirmed), and password is correct. On success, generate JWT access token (15-minute expiry) and refresh token (7-day expiry), store refresh token in database, return TokenDto with both tokens. On failure, return clear error (invalid credentials, unverified account). Create LoginQueryValidator with Fluent Validation. Add POST /api/auth/login endpoint to AuthController.

---

## Files to create or modify

| Action | Path |
|--------|------|
| Create | `src/DartsCompanion.Application/Auth/Queries/Login/LoginQuery.cs` |
| Create | `src/DartsCompanion.Application/Auth/Queries/Login/LoginQueryHandler.cs` |
| Create | `src/DartsCompanion.Application/Auth/Queries/Login/LoginQueryValidator.cs` |
| Create | `src/DartsCompanion.Application/Common/DTOs/TokenDto.cs` |
| Create | `src/DartsCompanion.Application/Common/Interfaces/ITokenService.cs` |
| Create | `src/DartsCompanion.Infrastructure/Security/JwtTokenService.cs` |
| Modify | `src/DartsCompanion.Api/Controllers/AuthController.cs` |

---

## Definition of done

- [ ] LoginQuery accepts email and password
- [ ] LoginQueryHandler uses UserManager to find user by email (case-insensitive)
- [ ] Validates user exists and EmailConfirmed is true; returns clear error otherwise
- [ ] Validates password using UserManager.CheckPasswordAsync()
- [ ] On success: generates JWT (15min), refresh token (7day), stores refresh token in DB
- [ ] TokenDto includes accessToken, refreshToken, expiresIn, tokenType
- [ ] LoginQueryValidator checks email format, password not empty
- [ ] POST /api/auth/login returns 200 with TokenDto on success
- [ ] POST /api/auth/login returns 401 for invalid credentials or unverified account
- [ ] No plain text credentials logged; errors don't leak whether email exists
- [ ] All tests pass; no compilation errors

---

## Implementation notes

- Create ITokenService interface for JWT generation (injected into handler); implement in JwtTokenService
- ITokenService.GenerateAccessToken(user) returns string (JWT), ITokenService.GenerateRefreshToken() returns string
- JWT should include: sub (user ID), email, exp (15min from now), iat, iss, aud
- Refresh token: store as random GUID string in RefreshToken table, link to user, set ExpiryDate (7 days)
- Use IUserManager or UserManager directly (from DI)
- Return 401 for both "user not found" and "wrong password" (don't enumerate accounts)
- Link to [API Contracts](../../shared/api-contracts.md) for endpoint specs
- Consider: Use IDateTimeProvider for consistent time handling

---

## References

- [Story: AUTH-02](story.md)
- [Domain Model](../../shared/domain-model.md)
- [Architecture](../../shared/architecture.md) — JWT design, token service patterns
- [API Contracts](../../shared/api-contracts.md)
- System.IdentityModel.Tokens.Jwt NuGet package
