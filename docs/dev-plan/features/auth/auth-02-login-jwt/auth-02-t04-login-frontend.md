# AUTH-02-T04 — Frontend: Login Component & Auth Service

**Story:** [AUTH-02 — Login & JWT Token Management](story.md)  **Layer:** UI  **Status:** 🔲 Not started  **Agent:** —

---

## What to build

Create AuthService in core layer to handle login, logout, and token refresh API calls. Implement secure token storage (localStorage or sessionStorage with appropriate security considerations). Create LoginComponent with email and password form, submit to AuthService.login(), show loading state, display errors. Create AuthGuard to protect routes. Create HttpInterceptor to attach JWT Bearer token to all requests, intercept 401 responses, automatically refresh token via RefreshTokenCommand, and retry original request. Store authentication state in BehaviorSubject for reactive components.

---

## Files to create or modify

| Action | Path |
|--------|------|
| Create | `src/DartsCompanion.Web/src/app/core/auth/auth.service.ts` |
| Create | `src/DartsCompanion.Web/src/app/core/auth/auth.guard.ts` |
| Create | `src/DartsCompanion.Web/src/app/core/auth/token.interceptor.ts` |
| Create | `src/DartsCompanion.Web/src/app/core/auth/auth-state.ts` |
| Create | `src/DartsCompanion.Web/src/app/features/auth/login/login.component.ts` |
| Create | `src/DartsCompanion.Web/src/app/features/auth/login/login.component.html` |
| Create | `src/DartsCompanion.Web/src/app/features/auth/login/login.component.scss` |
| Modify | `src/DartsCompanion.Web/src/app/features/auth/auth-routing.module.ts` |
| Modify | `src/DartsCompanion.Web/src/app/app.module.ts` or routing module (add interceptor provider) |

---

## Definition of done

- [ ] AuthService.login(email, password) calls POST /api/auth/login, stores tokens
- [ ] AuthService.logout() calls POST /api/auth/logout and clears tokens
- [ ] AuthService.refreshToken() calls POST /api/auth/refresh with refresh token
- [ ] Tokens stored in localStorage (consider security; httpOnly not available in browser)
- [ ] AuthService exposes isAuthenticated$ BehaviorSubject for reactive UI
- [ ] AuthGuard protects routes; redirects unauthenticated users to login
- [ ] TokenInterceptor adds "Authorization: Bearer {accessToken}" header to requests
- [ ] TokenInterceptor intercepts 401, calls refresh, retries original request
- [ ] TokenInterceptor handles refresh failure (clear tokens, redirect to login)
- [ ] LoginComponent form: email (required, valid format), password (required)
- [ ] LoginComponent shows loading spinner during login request
- [ ] LoginComponent displays error message from API on failure
- [ ] On success: navigates to home page
- [ ] Responsive layout; accessible labels and validation feedback
- [ ] No compilation errors; unit tests pass

---

## Implementation notes

- Use HttpClientModule and provide HTTP_INTERCEPTORS for token interceptor
- Store accessToken and refreshToken separately
- Consider token expiry: decode JWT (jwt-decode library) to check exp before sending
- Implement token refresh retry logic carefully: prevent infinite loops on refresh failure
- Use RxJS combineLatest or mergeMap for token refresh flow
- AuthGuard implements CanActivate interface
- BehaviorSubject initialization: check if token in storage on app bootstrap
- Decode JWT to extract user info (email, userId) if needed by components
- Don't store sensitive user data in localStorage; rely on JWT claims
- Consider: Add logout on token refresh failure (security best practice)
- Link to [Architecture](../../shared/architecture.md) for auth patterns

---

## References

- [Story: AUTH-02](story.md)
- [API Contracts](../../shared/api-contracts.md)
- [Architecture](../../shared/architecture.md)
- Angular HttpClientModule: https://angular.io/guide/http
- Angular Guards: https://angular.io/guide/router#preventing-unauthorized-access
- jwt-decode: https://github.com/auth0/jwt-decode
