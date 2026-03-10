# AUTH-02 — Login & JWT Token Management

**Feature:** Authentication  **Phase:** MVP  **Status:** 🔲 Not started  **Agent:** —  **Output:** —  **Notes:** —

---

## Context

Login enables users to access the application with JWT-based stateless authentication. This story implements credential validation via ASP.NET Core Identity, JWT token generation (15-minute access, 7-day refresh), refresh token rotation, and logout via revocation. Frontend includes secure token storage and automatic token refresh on expiry via HTTP interceptor.

> Implements: FA §FR-P-01, TA §10 (Security — JWT + refresh tokens)

---

## Acceptance Criteria

- [ ] User can login with email and password
- [ ] Successful login returns JWT (15min) and refresh token (7day)
- [ ] Login fails for unverified accounts with clear error message
- [ ] Refresh token endpoint issues new JWT without re-authentication
- [ ] Logout revokes the refresh token
- [ ] Expired JWT returns 401; client uses refresh token automatically

---

## Tasks

| Task | Layer | Status | Agent |
|------|-------|--------|-------|
| [AUTH-02-T01 — API: Login query handler](auth-02-t01-login-query.md) | Application | 🔲 Not started | — |
| [AUTH-02-T02 — API: Refresh & revoke token commands](auth-02-t02-token-refresh-revoke.md) | Application | 🔲 Not started | — |
| [AUTH-02-T03 — API: JWT configuration in Program.cs](auth-02-t03-jwt-configuration.md) | Infrastructure | 🔲 Not started | — |
| [AUTH-02-T04 — Frontend: Login component & auth service](auth-02-t04-login-frontend.md) | UI | 🔲 Not started | — |
| [AUTH-02-T05 — Tests: Login & token refresh tests](auth-02-t05-login-tests.md) | Testing | 🔲 Not started | — |

---

## Dependencies

- AUTH-01 — User Registration & Email Verification — reason: User must be registered and verified before login

---

## Shared References

- [Domain Model](../../shared/domain-model.md) — RefreshToken entity, ApplicationUser verification status
- [Architecture](../../shared/architecture.md) — JWT implementation, token refresh flow, security patterns
- [API Contracts](../../shared/api-contracts.md) — POST /api/auth/login, POST /api/auth/refresh, POST /api/auth/logout
- [NFRs](../../shared/nfrs.md) — security requirements, token expiry, refresh token rotation
