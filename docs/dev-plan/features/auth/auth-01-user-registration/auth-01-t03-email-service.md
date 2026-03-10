# AUTH-01-T03 — API: Email Sender Service

**Story:** [AUTH-01 — User Registration & Email Verification](story.md)  **Layer:** Infrastructure  **Status:** 🔲 Not started  **Agent:** —

---

## What to build

Create email service interface (IEmailSender) in Application layer and implement using MailKit in Infrastructure layer. Configure SMTP client with environment variables (host, port, username, password). Implement SendVerificationEmailAsync method to compose and send HTML verification email with embedded link containing token. For local development, integrate with Mailhog (local email viewer on port 1025). Include proper error handling and logging.

---

## Files to create or modify

| Action | Path |
|--------|------|
| Create | `src/DartsCompanion.Application/Common/Interfaces/IEmailSender.cs` |
| Create | `src/DartsCompanion.Infrastructure/Email/MailKitEmailSender.cs` |
| Modify | `src/DartsCompanion.Infrastructure/DependencyInjection.cs` (register IEmailSender) |
| Modify | `.env` or `appsettings.json` (SMTP configuration) |

---

## Definition of done

- [ ] IEmailSender interface defines SendVerificationEmailAsync(email, verificationLink)
- [ ] MailKitEmailSender implements interface using MailKit.Net.Smtp.SmtpClient
- [ ] SMTP settings loaded from environment (SMTP_HOST, SMTP_PORT, SMTP_USER, SMTP_PASSWORD)
- [ ] Verification email sent with clickable link: `{baseUrl}/verify-email?token={token}&email={email}`
- [ ] Email is HTML formatted with clear call-to-action button
- [ ] Local dev: emails appear in Mailhog (port 1025)
- [ ] Errors logged via ILogger; exceptions handled gracefully
- [ ] No compilation errors; DI container registers service correctly

---

## Implementation notes

- IEmailSender should be in Application/Common/Interfaces (owned by application, not infra)
- MailKit package: `NuGet\Install-Package MailKit`
- For Mailhog local dev: configure SMTP_HOST=localhost, SMTP_PORT=1025, no auth required
- Verification link should be configurable (injected base URL, e.g., from app settings)
- Consider async/await patterns; don't block caller
- Log email send success/failure; include email address in logs (not full token)
- Use HTML template with branding; include fallback plain text
- Link to [Architecture](../../shared/architecture.md) for email service design pattern

---

## References

- [Story: AUTH-01](story.md)
- [Architecture](../../shared/architecture.md)
- MailKit GitHub: https://github.com/jstedfast/MailKit
- Mailhog: https://github.com/mailhog/MailHog
