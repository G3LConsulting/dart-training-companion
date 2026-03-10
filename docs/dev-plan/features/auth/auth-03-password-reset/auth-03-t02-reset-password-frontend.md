# AUTH-03-T02 — Frontend: Reset Password Components

**Story:** [AUTH-03 — Password Reset](story.md)  **Layer:** UI  **Status:** 🔲 Not started  **Agent:** —

---

## What to build

Create ForgotPasswordComponent with email input form that submits to POST /api/auth/forgot-password and shows "Check your email for reset instructions" message. Create ResetPasswordComponent that extracts token and email from URL query params, displays form with new password and password confirm fields, submits to POST /api/auth/reset-password, and redirects to login on success. Include error handling, form validation, and responsive styling.

---

## Files to create or modify

| Action | Path |
|--------|------|
| Create | `src/DartsCompanion.Web/src/app/features/auth/forgot-password/forgot-password.component.ts` |
| Create | `src/DartsCompanion.Web/src/app/features/auth/forgot-password/forgot-password.component.html` |
| Create | `src/DartsCompanion.Web/src/app/features/auth/forgot-password/forgot-password.component.scss` |
| Create | `src/DartsCompanion.Web/src/app/features/auth/reset-password/reset-password.component.ts` |
| Create | `src/DartsCompanion.Web/src/app/features/auth/reset-password/reset-password.component.html` |
| Create | `src/DartsCompanion.Web/src/app/features/auth/reset-password/reset-password.component.scss` |
| Modify | `src/DartsCompanion.Web/src/app/features/auth/auth-routing.module.ts` |

---

## Definition of done

- [ ] ForgotPasswordComponent: form with email input (required, valid format)
- [ ] ForgotPasswordComponent: submits to POST /api/auth/forgot-password
- [ ] Shows "Check your email" message on submit (always, even if email not found)
- [ ] ResetPasswordComponent: extracts token and email from URL query params
- [ ] ResetPasswordComponent: form with password (min 8 chars), passwordConfirm (must match), displays current email as read-only
- [ ] ResetPasswordComponent: submits to POST /api/auth/reset-password with token in body
- [ ] On success: displays "Password reset! Redirecting to login..." and navigates to login
- [ ] On error: displays "Invalid or expired reset link" or "Password does not meet requirements"
- [ ] Both components show loading state during API request
- [ ] Both components responsive on mobile and desktop
- [ ] Accessible form labels and validation feedback
- [ ] No compilation errors; unit tests pass

---

## Implementation notes

- ForgotPasswordComponent always displays success (don't reveal whether email exists)
- ResetPasswordComponent should handle missing query params gracefully (show error)
- Use ActivatedRoute to extract token and email from query params
- Validate URL params before submitting (email format, token not empty)
- Add link to login page from both pages
- Add link to forgot-password from login page
- Style with project's CSS framework (Tailwind, Material, etc.)
- Consider UX: password strength indicator, toggle show/hide password
- Link to [API Contracts](../../shared/api-contracts.md) for endpoint response formats

---

## References

- [Story: AUTH-03](story.md)
- [API Contracts](../../shared/api-contracts.md)
- Angular Router: https://angular.io/guide/router
- Angular Query Params: https://angular.io/guide/router#accessing-query-parameters-and-fragments
