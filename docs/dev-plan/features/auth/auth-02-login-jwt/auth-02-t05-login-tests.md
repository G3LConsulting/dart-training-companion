# AUTH-02-T05 — Tests: Login & Token Refresh Tests

**Story:** [AUTH-02 — Login & JWT Token Management](story.md)  **Layer:** Testing  **Status:** 🔲 Not started  **Agent:** —

---

## What to build

Write comprehensive unit tests for LoginQuery, RefreshTokenCommand, and RevokeRefreshTokenCommand handlers and validators. Write integration tests for full login flow, token refresh, and logout. Test error cases (invalid credentials, unverified account, expired token, invalid refresh token). Test JWT token structure (includes correct claims, correct expiry). Test token interceptor (attaches Bearer header, refreshes on 401, retries request).

---

## Files to create or modify

| Action | Path |
|--------|------|
| Create | `tests/DartsCompanion.UnitTests/Auth/Queries/LoginQueryHandlerTests.cs` |
| Create | `tests/DartsCompanion.UnitTests/Auth/Queries/LoginQueryValidatorTests.cs` |
| Create | `tests/DartsCompanion.UnitTests/Auth/Commands/RefreshTokenCommandHandlerTests.cs` |
| Create | `tests/DartsCompanion.UnitTests/Auth/Commands/RevokeRefreshTokenCommandHandlerTests.cs` |
| Create | `tests/DartsCompanion.IntegrationTests/Auth/LoginTests.cs` |
| Create | `tests/DartsCompanion.IntegrationTests/Auth/TokenRefreshTests.cs` |
| Create | `tests/DartsCompanion.UnitTests/Auth/TokenInterceptorTests.ts` (Angular, using Jasmine) |

---

## Definition of done

- [ ] LoginQueryHandlerTests: valid credentials return TokenDto with accessToken and refreshToken, invalid credentials return 401, unverified account returns clear error
- [ ] LoginQueryHandlerTests: JWT includes sub (userId), email, exp claim
- [ ] LoginQueryHandlerTests: refresh token stored in DB with correct expiry (7 days)
- [ ] LoginQueryValidatorTests: email required, password required, email format validation
- [ ] RefreshTokenCommandHandlerTests: valid token issues new JWT and refresh token, old token marked revoked
- [ ] RefreshTokenCommandHandlerTests: expired token rejected, revoked token rejected, invalid token returns 401
- [ ] RevokeRefreshTokenCommandHandlerTests: valid token marked revoked, invalid token returns 404
- [ ] LoginTests integration: register user → verify email → login → receive tokens
- [ ] TokenRefreshTests integration: login → wait/mock time → refresh token → receive new JWT
- [ ] TokenRefreshTests: cannot use revoked refresh token
- [ ] TokenInterceptorTests: JWT attached to outgoing requests, 401 response triggers refresh, retried request succeeds, refresh failure redirects to login
- [ ] All tests pass; coverage >= 80%
- [ ] No compilation errors

---

## Implementation notes

- Unit tests use mocked UserManager, ITokenService, DbContext
- Mock time provider (IDateTimeProvider) to test token expiry
- Integration tests use real DbContext (in-memory or test database)
- Test JWT decoding: decode token and verify claims (use jwt-decode or System.IdentityModel.Tokens.Jwt)
- RefreshToken tests: verify old token marked IsRevoked = true, new token has different Id
- TokenInterceptor tests (Angular): use HttpTestingController to mock HTTP requests
- Mock 401 response from first request, successful response from second (after refresh)
- Test retry logic: ensure original request is retried with new token
- Test error handling: refresh fails (network error, 401 on refresh) → clear tokens and logout
- Link to [Architecture](../../shared/architecture.md) for testing patterns

---

## References

- [Story: AUTH-02](story.md)
- [Architecture](../../shared/architecture.md)
- xUnit: https://xunit.net/
- Moq: https://github.com/moq/moq4
- Jasmine: https://jasmine.github.io/
- Angular HttpTestingController: https://angular.io/guide/http#testing-http-requests
