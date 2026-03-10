# AUTH-04-T02 — Frontend: Account Deletion Modal

**Story:** [AUTH-04 — Account Deletion](story.md)  **Layer:** UI  **Status:** 🔲 Not started  **Agent:** —

---

## What to build

Create AccountDeletionModalComponent that is triggered by a "Delete Account" button in profile settings. Modal displays warning message explaining consequences of deletion. Modal includes email input field for confirmation (user must type their email to enable delete button). On click, submits DELETE /api/profile with email, shows loading state, and on success logs user out and redirects to login page. Include error handling for mismatched email or API failure.

---

## Files to create or modify

| Action | Path |
|--------|------|
| Create | `src/DartsCompanion.Web/src/app/features/profile/account-deletion-modal/account-deletion-modal.component.ts` |
| Create | `src/DartsCompanion.Web/src/app/features/profile/account-deletion-modal/account-deletion-modal.component.html` |
| Create | `src/DartsCompanion.Web/src/app/features/profile/account-deletion-modal/account-deletion-modal.component.scss` |
| Modify | `src/DartsCompanion.Web/src/app/features/profile/profile-settings.component.ts` (add delete account button) |
| Modify | `src/DartsCompanion.Web/src/app/features/profile/profile-settings.component.html` (add delete account button) |

---

## Definition of done

- [ ] "Delete Account" button in profile settings page opens modal
- [ ] Modal displays warning: "This action cannot be undone. All your data will be permanently deleted."
- [ ] Modal includes email input field labeled "Type your email to confirm deletion"
- [ ] "Delete Account" button disabled until email field matches user's email
- [ ] On click, submits DELETE /api/profile with {email: userEmail}
- [ ] Shows loading spinner during request
- [ ] On success: displays "Account deleted" message, logs out user (clears tokens), redirects to login after 2 seconds
- [ ] On error (400): displays "Email doesn't match" error
- [ ] On error (401): user is not authenticated (shouldn't occur if guard works)
- [ ] Modal can be closed (Cancel button)
- [ ] Email confirmation is case-insensitive
- [ ] Responsive on mobile and desktop
- [ ] Accessible: proper ARIA labels, keyboard navigation
- [ ] No compilation errors; unit tests pass

---

## Implementation notes

- Use Angular Material Dialog or custom modal component
- Modal is destructive action; make confirmation clear and difficult to accidentally trigger
- Email field: validate on input change to enable/disable delete button
- Real-time feedback: show/hide "Emails match" or "Emails don't match" message
- Link to AuthService.logout() after successful deletion
- Use Router.navigate() to redirect to login page
- Consider: Add delay before redirect (2-3 seconds) so user sees success message
- Button styling: use warning/danger color (red) to indicate destructive action
- Link to [API Contracts](../../shared/api-contracts.md) for endpoint spec

---

## References

- [Story: AUTH-04](story.md)
- [API Contracts](../../shared/api-contracts.md)
- Angular Dialog: https://material.angular.io/components/dialog/overview
