# AUTH-01-T02 — API: Registration & Email Commands

**Story:** [AUTH-01 — User Registration & Email Verification](story.md)  **Layer:** Application  **Status:** 🔲 Not started  **Agent:** —

---

## What to build

Implement three CQRS commands for registration workflow: RegisterUserCommand (creates account with verification email), VerifyEmailCommand (activates account via token), and ResendVerificationEmailCommand (resends token). Each command includes a Fluent Validation validator. Handlers enforce business rules (duplicate email, token expiry, unverified account blocking). Create AuthController with three POST endpoints to expose commands. Return appropriate HTTP status codes (201 Created, 400 Bad Request, 404 Not Found).

---

## Files to create or modify

| Action | Path |
|--------|------|
| Create | `src/DartsCompanion.Application/Auth/Commands/RegisterUser/RegisterUserCommand.cs` |
| Create | `src/DartsCompanion.Application/Auth/Commands/RegisterUser/RegisterUserCommandHandler.cs` |
| Create | `src/DartsCompanion.Application/Auth/Commands/RegisterUser/RegisterUserCommandValidator.cs` |
| Create | `src/DartsCompanion.Application/Auth/Commands/VerifyEmail/VerifyEmailCommand.cs` |
| Create | `src/DartsCompanion.Application/Auth/Commands/VerifyEmail/VerifyEmailCommandHandler.cs` |
| Create | `src/DartsCompanion.Application/Auth/Commands/VerifyEmail/VerifyEmailCommandValidator.cs` |
| Create | `src/DartsCompanion.Application/Auth/Commands/ResendVerificationEmail/ResendVerificationEmailCommand.cs` |
| Create | `src/DartsCompanion.Application/Auth/Commands/ResendVerificationEmail/ResendVerificationEmailCommandHandler.cs` |
| Create | `src/DartsCompanion.Application/Auth/Commands/ResendVerificationEmail/ResendVerificationEmailCommandValidator.cs` |
| Create | `src/DartsCompanion.Api/Controllers/AuthController.cs` |

---

## Definition of done

- [ ] RegisterUserCommand accepts email, password, displayName; handler creates user via UserManager, generates token, sends email via IEmailSender
- [ ] VerifyEmailCommand accepts email and token; handler confirms token and activates account
- [ ] ResendVerificationEmailCommand accepts email; handler generates new token and resends email
- [ ] All validators check: email format, password >= 8 chars, displayName not empty, duplicate email returns clear error
- [ ] POST /api/auth/register returns 201 with userId
- [ ] POST /api/auth/verify-email returns 200 on success
- [ ] POST /api/auth/resend-verification returns 200 and sends email
- [ ] Duplicate email returns 400 with message "Email already in use"
- [ ] All tests pass; no compilation errors

---

## Implementation notes

- Use IUserStore<ApplicationUser> (via UserManager) to create users; let ASP.NET Core Identity handle PBKDF2 hashing
- Generate email verification tokens via UserManager.GenerateEmailConfirmationTokenAsync()
- Validate tokens via UserManager.VerifyEmailTokenAsync()
- Inject IEmailSender to send verification emails (created in AUTH-01-T03)
- Use MediatR to dispatch commands from AuthController
- Return 400 for duplicate email; 404 for invalid token or email on verify/resend
- Link to [API Contracts](../../shared/api-contracts.md) for endpoint specs

---

## References

- [Story: AUTH-01](story.md)
- [Domain Model](../../shared/domain-model.md)
- [Architecture](../../shared/architecture.md) — CQRS pattern, validators
- [API Contracts](../../shared/api-contracts.md)
- ASP.NET Core Identity API Reference
