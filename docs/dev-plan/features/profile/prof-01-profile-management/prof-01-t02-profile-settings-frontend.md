# PROF-01-T02 — Frontend: Profile Settings Page

**Story:** [PROF-01 — Profile Management](story.md)  **Layer:** UI  **Status:** 🔲 Not started  **Agent:** —

---

## What to build

Create ProfileSettingsComponent that displays a form with all user editable profile fields: display name (text input), avatar (file upload or preset icon picker), dominant hand (radio buttons or dropdown), preferred game mode (dropdown), target average (number input), week start day (radio buttons), and 4th personal best metric (dropdown). On load, fetch current profile via GET /api/profile and populate form. On submit, sends updated fields via PUT /api/profile, shows loading state, displays success message, and prevents accidental changes (dirty form check).

---

## Files to create or modify

| Action | Path |
|--------|------|
| Create | `src/DartsCompanion.Web/src/app/features/profile/profile-settings.component.ts` |
| Create | `src/DartsCompanion.Web/src/app/features/profile/profile-settings.component.html` |
| Create | `src/DartsCompanion.Web/src/app/features/profile/profile-settings.component.scss` |
| Modify | `src/DartsCompanion.Web/src/app/features/profile/profile-routing.module.ts` |

---

## Definition of done

- [ ] Component loads profile on init via ProfileService.getProfile()
- [ ] Form fields: Display Name (text, required, max 100), Avatar (upload or icon picker), Dominant Hand (Left/Right radio), Preferred Game Mode (dropdown), Target Average (number, optional, > 0), Week Start Day (Monday/Sunday radio), 4th Personal Best Metric (dropdown)
- [ ] Form populated with current profile data on load
- [ ] Form displays "Unsaved changes" warning if user tries to navigate away with unsaved changes
- [ ] Avatar field: file upload with preview (supported formats: jpg, png, gif) OR preset icon picker with visual selection
- [ ] Dominant hand and week start day use radio buttons (clear choices)
- [ ] Game mode and metric dropdowns with visual indicators or descriptions
- [ ] Submit button disabled until form is dirty
- [ ] On submit, calls PUT /api/profile with changed fields
- [ ] Shows loading spinner during submission
- [ ] On success: displays "Profile updated" success message, form marked as pristine
- [ ] On error: displays validation error messages
- [ ] Responsive on mobile and desktop
- [ ] Accessible form labels, help text for non-obvious fields
- [ ] All fields optional except Display Name (if validation requires it)
- [ ] No compilation errors; unit tests pass

---

## Implementation notes

- Use ReactiveFormsModule with FormBuilder for complex form
- ProfileService: create get/update methods that call GET and PUT /api/profile endpoints
- Avatar upload: consider base64 encoding for small files, or multipart form data (depends on API design)
- For MVP, preset icon picker simpler than full file upload (can store avatar URL or icon name in profile)
- Game mode options: ["501", "301", "Cricket", "NumberFocus"] (from domain)
- Metric options: dynamically fetch from shared constants or backend (e.g., "Highest Checkout", "180s", "180s Rate", "Average Dart Value")
- Week start day: use DayOfWeek enum values (0=Sunday, 1=Monday, etc.)
- Dirty form check: use canDeactivate guard or warn before navigation
- Target average: decimal number input, optional, display validation (if < 0, show error)
- Link to [API Contracts](../../shared/api-contracts.md) for endpoint response format

---

## References

- [Story: PROF-01](story.md)
- [API Contracts](../../shared/api-contracts.md)
- [Domain Model](../../shared/domain-model.md)
- Angular Reactive Forms: https://angular.io/guide/reactive-forms
- Angular File Upload: https://angular.io/guide/http#uploading-files
