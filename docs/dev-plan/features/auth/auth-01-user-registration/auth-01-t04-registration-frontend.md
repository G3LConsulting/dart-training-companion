# AUTH-01-T04 — Frontend: Register & Verify Email Components

**Story:** [AUTH-01 — User Registration & Email Verification](story.md)  **Layer:** UI  **Status:** 🔲 Not started  **Agent:** —

---

## What to build

Create two Angular components: RegisterComponent (user registration form with email, password, password confirm, display name fields) and VerifyEmailComponent (confirmation page after user clicks verification link in email). RegisterComponent submits form to POST /api/auth/register, shows loading state during request, displays success message and redirects to verify-email page. VerifyEmailComponent extracts token and email from URL query params, calls POST /api/auth/verify-email, and confirms account activation. Include error messaging, form validation feedback, and responsive styling.

---

## Files to create or modify

| Action | Path |
|--------|------|
| Create | `src/DartsCompanion.Web/src/app/features/auth/register/register.component.ts` |
| Create | `src/DartsCompanion.Web/src/app/features/auth/register/register.component.html` |
| Create | `src/DartsCompanion.Web/src/app/features/auth/register/register.component.scss` |
| Create | `src/DartsCompanion.Web/src/app/features/auth/verify-email/verify-email.component.ts` |
| Create | `src/DartsCompanion.Web/src/app/features/auth/verify-email/verify-email.component.html` |
| Create | `src/DartsCompanion.Web/src/app/features/auth/verify-email/verify-email.component.scss` |
| Modify | `src/DartsCompanion.Web/src/app/features/auth/auth-routing.module.ts` |

---

## Definition of done

- [ ] RegisterComponent: form has email (required, valid email format), password (required, min 8 chars), passwordConfirm (required, must match), displayName (required, max 100)
- [ ] Register form submits to POST /api/auth/register; loading spinner shown during request
- [ ] On success: display "Check your email to verify" message, redirect to verify-email page
- [ ] On error: show error message (duplicate email, validation errors, etc.)
- [ ] VerifyEmailComponent: extracts token and email from query params
- [ ] VerifyEmailComponent displays "Verifying..." message, calls POST /api/auth/verify-email
- [ ] On success: show "Email verified! Redirecting to login..." and redirect to login page
- [ ] On error: show "Verification failed" with option to resend verification email
- [ ] Resend verification link: calls POST /api/auth/resend-verification, shows "Email sent" confirmation
- [ ] Both components responsive on mobile and desktop; accessible form labels and error messages
- [ ] No compilation errors; unit tests pass

---

## Implementation notes

- Use ReactiveFormsModule for form validation
- Create custom validators for passwordConfirm matching
- Call AuthService (to be created in AUTH-02-T04) for API calls
- Display clear error messages from API (400 response body)
- VerifyEmailComponent should handle missing query params gracefully (show error)
- Add navigation to login page on success (via Router)
- Style with Tailwind CSS or Material Design as per project conventions
- Consider UX: disabled register button while submitting, clear password strength indicator
- Link to [API Contracts](../../shared/api-contracts.md) for endpoint response formats

---

## References

- [Story: AUTH-01](story.md)
- [API Contracts](../../shared/api-contracts.md)
- Angular Reactive Forms: https://angular.io/guide/reactive-forms
- Angular Router: https://angular.io/guide/router
