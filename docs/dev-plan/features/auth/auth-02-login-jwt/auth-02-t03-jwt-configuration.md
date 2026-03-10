# AUTH-02-T03 — API: JWT Configuration in Program.cs

**Story:** [AUTH-02 — Login & JWT Token Management](story.md)  **Layer:** Infrastructure  **Status:** 🔲 Not started  **Agent:** —

---

## What to build

Configure ASP.NET Core authentication and authorization in Program.cs to use JWT Bearer scheme. Load JWT settings from environment variables (secret key, issuer, audience, expiry in minutes). Register authentication middleware with AddAuthentication and AddJwtBearer. Configure JwtBearerOptions: validate issuer, audience, lifetime, signature key. Configure authorization policies if needed. Ensure 401 Unauthorized response for expired/invalid tokens on protected endpoints. Add ITokenService and related services to DI container.

---

## Files to create or modify

| Action | Path |
|--------|------|
| Modify | `src/DartsCompanion.Api/Program.cs` |
| Create | `src/DartsCompanion.Api/Configuration/JwtSettings.cs` |
| Modify | `src/DartsCompanion.Infrastructure/DependencyInjection.cs` (add JWT services if not already there) |
| Modify | `.env` or `appsettings.json` (JWT configuration) |

---

## Definition of done

- [ ] AddAuthentication("Bearer") configured in Program.cs
- [ ] AddJwtBearer configured with: ValidateIssuer, ValidateAudience, ValidateLifetime, IssuerSigningKey
- [ ] JWT_SECRET_KEY, JWT_ISSUER, JWT_AUDIENCE, JWT_EXPIRY_MINUTES loaded from environment
- [ ] Secret key is at least 32 bytes (256 bits) for HS256
- [ ] UseAuthentication() and UseAuthorization() middleware added to pipeline
- [ ] Protected endpoints return 401 when token expired or invalid
- [ ] JwtSettings class binds configuration values
- [ ] ITokenService and JwtTokenService registered in DI
- [ ] Test: valid JWT token accepted, expired JWT returns 401, invalid signature returns 401
- [ ] No compilation errors; application starts without errors

---

## Implementation notes

- Use symmetrical key (HS256) or asymmetrical (RS256); HS256 simpler for MVP
- Secret key must be stored securely (environment variable, not in code)
- JWT issuer and audience should match what's generated in ITokenService
- ValidateLifetime = true ensures expired tokens are rejected
- Consider: Add [Authorize] attribute to protected endpoints; add [AllowAnonymous] to public ones
- For local dev: generate dummy JWT_SECRET_KEY, e.g., `openssl rand -hex 32`
- Link to [Architecture](../../shared/architecture.md) for JWT design
- Link to [Security NFRs](../../shared/nfrs.md) for compliance requirements

---

## References

- [Story: AUTH-02](story.md)
- [Architecture](../../shared/architecture.md)
- [NFRs](../../shared/nfrs.md) — security requirements
- ASP.NET Core Authentication: https://docs.microsoft.com/en-us/aspnet/core/security/authentication/
- JWT Bearer Handler: https://github.com/dotnet/aspnetcore/tree/main/src/Security
