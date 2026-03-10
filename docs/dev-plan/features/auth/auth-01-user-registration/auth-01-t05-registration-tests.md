# AUTH-01-T05 — Tests: Registration Unit & Integration Tests

**Story:** [AUTH-01 — User Registration & Email Verification](story.md)  **Layer:** Testing  **Status:** 🔲 Not started  **Agent:** —

---

## What to build

Write comprehensive unit tests for RegisterUserCommand, VerifyEmailCommand, and ResendVerificationEmailCommand handlers and validators. Write integration tests covering full registration flow: user registration → email sent → verification link clicked → account activated. Test error cases (duplicate email, invalid token, missing fields, weak password). Use xUnit and Moq for unit tests; use TestContainers or in-memory database for integration tests.

---

## Files to create or modify

| Action | Path |
|--------|------|
| Create | `tests/DartsCompanion.UnitTests/Auth/Commands/RegisterUserCommandHandlerTests.cs` |
| Create | `tests/DartsCompanion.UnitTests/Auth/Commands/RegisterUserCommandValidatorTests.cs` |
| Create | `tests/DartsCompanion.UnitTests/Auth/Commands/VerifyEmailCommandHandlerTests.cs` |
| Create | `tests/DartsCompanion.UnitTests/Auth/Commands/VerifyEmailCommandValidatorTests.cs` |
| Create | `tests/DartsCompanion.UnitTests/Auth/Commands/ResendVerificationEmailCommandHandlerTests.cs` |
| Create | `tests/DartsCompanion.IntegrationTests/Auth/RegistrationFlowTests.cs` |
| Create | `tests/DartsCompanion.IntegrationTests/Auth/RegistrationApiTests.cs` |

---

## Definition of done

- [ ] RegisterUserCommandHandlerTests: success (user created, email sent), duplicate email (throws exception), password hashed (not plain text)
- [ ] RegisterUserCommandValidatorTests: valid email, password >= 8 chars, displayName required, invalid email format rejected
- [ ] VerifyEmailCommandHandlerTests: valid token activates account, invalid token throws, expired token throws
- [ ] VerifyEmailCommandValidatorTests: email required, token required
- [ ] ResendVerificationEmailCommandHandlerTests: user not found throws, email sent, new token generated
- [ ] RegistrationFlowTests: end-to-end flow (register → verify → login works)
- [ ] RegistrationApiTests: POST /api/auth/register returns 201, POST /api/auth/verify-email returns 200, POST /api/auth/resend-verification returns 200
- [ ] All tests pass; coverage >= 80% for auth commands
- [ ] No compilation errors

---

## Implementation notes

- Unit tests use mocked IUserManager, IEmailSender, ILogger
- Mock email sender to avoid sending real emails in tests
- Integration tests use real DbContext (with in-memory or test database)
- Test validator rules separately from handler logic
- Test error responses: 400 for duplicate email, 404 for invalid token
- Use [Theory] with [InlineData] for parameterized tests (multiple password lengths, email formats)
- Assert that password is PBKDF2 hashed (not stored plain); use UserManager.CheckPasswordAsync to validate
- For RegistrationFlowTests: create user, generate token manually (or use UserManager), verify account, attempt login (prepare for AUTH-02-T05)
- Link to [Architecture](../../shared/architecture.md) for testing patterns

---

## References

- [Story: AUTH-01](story.md)
- [Architecture](../../shared/architecture.md) — testing strategies
- xUnit: https://xunit.net/
- Moq: https://github.com/moq/moq4
