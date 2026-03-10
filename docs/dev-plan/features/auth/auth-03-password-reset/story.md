# AUTH-03 — Password Reset

**Feature:** Authentication  **Phase:** MVP  **Status:** 🔲 Not started  **Agent:** —  **Output:** —  **Notes:** —

---

## Context

Password reset allows users to recover account access if they forget their password. This story implements a secure reset flow: user requests reset via email, reset link sent with 1-hour expiry token, user validates token and sets new password. Implements ASP.NET Core Identity's built-in password reset token generation, prevents email enumeration attacks (always return 200), and validates token expiry.

> Implements: FA §FR-P-01 (password reset flow), TA §10 (Security)

---

## Acceptance Criteria

- [ ] User can request password reset via email
- [ ] Reset link sent via email with 1-hour expiry
- [ ] User can set new password using valid reset token
- [ ] POST /api/auth/forgot-password always returns 200 (no email enumeration)
- [ ] Invalid or expired token returns clear error

---

## Tasks

| Task | Layer | Status | Agent |
|------|-------|--------|-------|
| [AUTH-03-T01 — API: Password reset commands](auth-03-t01-password-reset-commands.md) | Application | 🔲 Not started | — |
| [AUTH-03-T02 — Frontend: Reset password components](auth-03-t02-reset-password-frontend.md) | UI | 🔲 Not started | — |
| [AUTH-03-T03 — Tests: Password reset tests](auth-03-t03-password-reset-tests.md) | Testing | 🔲 Not started | — |

---

## Dependencies

- AUTH-01 — User Registration & Email Verification — reason: Email sending infrastructure and user entity required

---

## Shared References

- [API Contracts](../../shared/api-contracts.md) — POST /api/auth/forgot-password, POST /api/auth/reset-password
- [Architecture](../../shared/architecture.md) — Identity password reset token patterns, security practices
- [NFRs](../../shared/nfrs.md) — security requirements, token expiry policies
