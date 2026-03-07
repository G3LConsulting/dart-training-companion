# PROF-01 — User Registration & Authentication

**Feature:** Player Profiles
**Phase:** MVP
**Status:** 🔲 Not started
**Agent:** —
**Output:** —
**Notes:** —

---

## Context

Implements the full auth flow: registration with email verification, login, logout, password reset, and JWT + refresh token management. Users must verify their email before account activation, and tokens rotate on refresh.

> Implements: FA §FR-P-01, TA §10

---

## Acceptance Criteria

- [ ] User can register with email, password (min 8 chars), and display name
- [ ] Verification email sent via MailKit (Mailhog in POC); account inactive until verified
- [ ] User can log in and receive JWT (15-min) + refresh token (7-day)
- [ ] Refresh token rotates on use; old token revoked
- [ ] Logout revokes refresh token
- [ ] Forgot password sends reset link (1-hour expiry); reset-password sets new password
- [ ] Rate limiting on resend-verification endpoint (e.g., max 3 per hour)
- [ ] Password stored as PBKDF2/HMAC-SHA512 hash; never in logs or traces
- [ ] All anonymous endpoints return 200 even if email not found (no enumeration)

---

## Technical Implementation Notes

**Backend Command/Query Structure:**
- Location: `Application/Auth/Commands/` and `Application/Auth/Queries/`
- Commands:
  - RegisterUserCommand: email (must be unique), password (min 8), displayName (max 100)
  - VerifyEmailCommand: userId, verificationCode (6-digit or JWT token, 1-hour expiry)
  - ResendVerificationEmailCommand: email (rate limited)
  - RequestPasswordResetCommand: email (returns generic 200 always)
  - ResetPasswordCommand: email, resetCode (1-hour expiry), newPassword
  - RefreshTokenCommand: refreshToken (validates, revokes old, issues new JWT + RT)
  - RevokeRefreshTokenCommand: revokes all tokens for user
- Queries:
  - LoginQuery: email, password → (jwt, refreshToken, expiresIn)
- Each command has FluentValidation validator in same folder

**API Controller:**
- Location: `Api/Controllers/AuthController.cs`
- Endpoints: POST /auth/register, POST /auth/verify-email, POST /auth/resend-verification, POST /auth/login, POST /auth/refresh, POST /auth/logout, POST /auth/forgot-password, POST /auth/reset-password

**Email Service:**
- Location: `Infrastructure/Services/MailKitEmailSender.cs`
- Implements IEmailSender interface
- Uses MailKit to send via Mailhog (SMTP localhost:1025 in POC)
- Verification email includes 6-digit code or JWT token link
- Password reset email includes reset link with 1-hour-expiry token

**Token Management:**
- JWT: claims include UserId, Email, DisplayName, Roles; signed with HS256 secret
- Refresh Token: stored in RefreshToken entity (UserId, Token, ExpiresAt, RevokedAt, ReplaceByToken)
- Refresh endpoint validates refresh token exists, not expired, not revoked; creates new JWT + RT, marks old RT as RevokedAt=now, stores new RT with ReplaceByToken=old token ID
- Logout endpoint finds all non-revoked RefreshTokens for user and marks them RevokedAt=now

**Authentication & Authorization:**
- AddIdentity and AddJwtBearer in Program.cs per TA §10
- Jwt bearer token required for protected endpoints
- Anonymous endpoints for register, login, forgot-password, reset-password

**Security Practices:**
- Password hashing: IdentityUser password hasher (PBKDF2/HMAC-SHA512 by default)
- Verification codes: random 6-digit code OR JWT with 1-hour expiry, stored in SecurityStamp or VerificationCodeToken
- Rate limiting: middleware on RegisterUserCommand and ResendVerificationEmailCommand (e.g., 3 per hour per IP)
- No email enumeration: endpoints return 200 for unknown emails (user informed via email only)
- Secrets: JWT signing key stored in appsettings.json (POC) or Azure Key Vault (production)

**Angular Frontend:**
- Location: `src/app/features/auth/` (standalone components)
- Components: login/, register/, reset-password/, verify-email/
- AuthService: login, register, logout, refreshToken, resetPassword methods
- HTTP Interceptor (TokenInterceptor): adds Bearer token to all requests; on 401, calls refresh endpoint
- Auth Guard: redirects unauthenticated users to /login

---

## Dependencies

- INFRA-01 — Solution Scaffold & Project Setup — auth infrastructure (controllers, DI) must be in place
- INFRA-02 — Database Setup & EF Core Configuration — ApplicationUser and RefreshToken entities must be created

---

## Shared References

- [Domain Model](../../shared/domain-model.md) — ApplicationUser, RefreshToken entities
- [Architecture](../../shared/architecture.md) — §10 (authentication design and patterns)
- [API Contracts](../../shared/api-contracts.md) — authentication endpoints and JWT format
