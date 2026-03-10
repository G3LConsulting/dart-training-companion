# AUTH-03-T03 — Tests: Password Reset Tests

**Story:** [AUTH-03 — Password Reset](story.md)  **Layer:** Testing  **Status:** 🔲 Not started  **Agent:** —

---

## What to build

Write comprehensive unit tests for RequestPasswordResetCommand and ResetPasswordCommand handlers and validators. Test error cases (invalid token, expired token, weak password, user not found). Test security: POST /api/auth/forgot-password always returns 200 regardless of email existence. Test token generation and validation. Test email content sent to user.

---

## Files to create or modify

| Action | Path |
|--------|------|
| Create | `tests/DartsCompanion.UnitTests/Auth/Commands/RequestPasswordResetCommandHandlerTests.cs` |
| Create | `tests/DartsCompanion.UnitTests/Auth/Commands/RequestPasswordResetCommandValidatorTests.cs` |
| Create | `tests/DartsCompanion.UnitTests/Auth/Commands/ResetPasswordCommandHandlerTests.cs` |
| Create | `tests/DartsCompanion.UnitTests/Auth/Commands/ResetPasswordCommandValidatorTests.cs` |

---

## Definition of done

- [ ] RequestPasswordResetCommandHandlerTests: valid email generates token and sends email
- [ ] RequestPasswordResetCommandHandlerTests: invalid email still returns success (no enumeration)
- [ ] RequestPasswordResetCommandHandlerTests: email contains reset link with token and email params
- [ ] ResetPasswordCommandHandlerTests: valid token and password reset account
- [ ] ResetPasswordCommandHandlerTests: invalid token returns clear error
- [ ] ResetPasswordCommandHandlerTests: expired token returns clear error
- [ ] ResetPasswordCommandHandlerTests: weak password (< 8 chars) rejected
- [ ] ResetPasswordCommandValidatorTests: email required, token required, password required, password length validation
- [ ] Tests verify all refresh tokens revoked after password reset
- [ ] All tests pass; coverage >= 80%
- [ ] No compilation errors

---

## Implementation notes

- RequestPasswordResetCommandHandlerTests: mock UserManager.GeneratePasswordResetTokenAsync() and IEmailSender
- Verify email is sent with correct reset link format
- Test both user found and user not found scenarios (but same response)
- ResetPasswordCommandHandlerTests: mock UserManager.ResetPasswordAsync() with various outcomes
- Test token validation: invalid token, expired token (mock token validation failure)
- Test password requirements: < 8 chars, special chars requirement (if configured)
- Verify password is actually updated in database (or mocked UserManager confirms reset call)
- Consider: Test that refresh tokens are revoked after reset
- Link to [Architecture](../../shared/architecture.md) for testing patterns

---

## References

- [Story: AUTH-03](story.md)
- [Architecture](../../shared/architecture.md)
- xUnit: https://xunit.net/
- Moq: https://github.com/moq/moq4
