# AUTH-01 — User Registration & Email Verification

**Feature:** Authentication  **Phase:** MVP  **Status:** 🔲 Not started  **Agent:** —  **Output:** —  **Notes:** —

---

## Context

User registration is the entry point for new players. This story establishes user accounts with email-based verification, ensuring only valid email addresses activate accounts. Implements CQRS command pattern for registration workflow, validation via Fluent Validation, and security via ASP.NET Core Identity with PBKDF2 hashing.

> Implements: FA §FR-P-01, TA §6 (CQRS), TA §8 (Validation), TA §10 (Security)

---

## Acceptance Criteria

- [ ] User can register with email, password (min 8 chars), and display name
- [ ] Verification email is sent after registration
- [ ] Account is pending until email verified; login fails for unverified accounts
- [ ] Duplicate email returns 400 error with clear message
- [ ] User can resend verification email
- [ ] Password is stored as PBKDF2 hash via ASP.NET Core Identity

---

## Tasks

| Task | Layer | Status | Agent |
|------|-------|--------|-------|
| [AUTH-01-T01 — DB: ApplicationUser & RefreshToken entities](auth-01-t01-database-entities.md) | Data | 🔲 Not started | — |
| [AUTH-01-T02 — API: Registration & Email commands](auth-01-t02-registration-commands.md) | Application | 🔲 Not started | — |
| [AUTH-01-T03 — API: Email sender service](auth-01-t03-email-service.md) | Infrastructure | 🔲 Not started | — |
| [AUTH-01-T04 — Frontend: Register & verify-email components](auth-01-t04-registration-frontend.md) | UI | 🔲 Not started | — |
| [AUTH-01-T05 — Tests: Registration unit & integration tests](auth-01-t05-registration-tests.md) | Testing | 🔲 Not started | — |

---

## Dependencies

- INFRA-01 — Solution scaffolding — reason: Project structure, DbContext, dependency injection setup required

---

## Shared References

- [Domain Model](../../shared/domain-model.md) — ApplicationUser entity, RefreshToken entity, IsEmailVerified flag
- [Architecture](../../shared/architecture.md) — CQRS pattern, ASP.NET Core Identity integration, email service architecture
- [API Contracts](../../shared/api-contracts.md) — POST /api/auth/register, POST /api/auth/verify-email, POST /api/auth/resend-verification
