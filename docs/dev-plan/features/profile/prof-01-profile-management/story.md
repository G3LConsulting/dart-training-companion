# PROF-01 — Profile Management

**Feature:** Player Profiles  **Phase:** MVP  **Status:** 🔲 Not started  **Agent:** —  **Output:** —  **Notes:** —

---

## Context

Profile management enables players to customize their account and game preferences. This story implements user-editable profile fields (display name, avatar, dominant hand, preferred game mode, target average, week start day) and configurable fourth personal best metric. Profile changes persist across devices via API. Uses CQRS pattern with UpdateProfileCommand and GetProfileQuery.

> Implements: FA §FR-P-02 (profile editing, preferences), TA §6 (UpdateProfileCommand)

---

## Acceptance Criteria

- [ ] User can edit display name and avatar (upload or preset icons)
- [ ] User can set dominant hand (left/right) and preferred game mode
- [ ] User can set target average
- [ ] User can set preferred week start day (Monday/Sunday)
- [ ] User can configure 4th personal best slot from full metrics list
- [ ] Profile changes persist and sync across devices

---

## Tasks

| Task | Layer | Status | Agent |
|------|-------|--------|-------|
| [PROF-01-T01 — API: Profile query & update commands](prof-01-t01-profile-commands.md) | Application | 🔲 Not started | — |
| [PROF-01-T02 — Frontend: Profile settings page](prof-01-t02-profile-settings-frontend.md) | UI | 🔲 Not started | — |
| [PROF-01-T03 — Tests: Profile management tests](prof-01-t03-profile-tests.md) | Testing | 🔲 Not started | — |

---

## Dependencies

- AUTH-01 — User Registration & Email Verification — reason: User entity and email verification required
- AUTH-02 — Login & JWT Token Management — reason: Authentication context required for profile endpoint

---

## Shared References

- [Domain Model](../../shared/domain-model.md) — ApplicationUser profile fields (DisplayName, DominantHand, PreferredGameMode, TargetAverage, PreferredWeekStartDay, CustomMetricSlot)
- [API Contracts](../../shared/api-contracts.md) — GET /api/profile, PUT /api/profile
- [Architecture](../../shared/architecture.md) — CQRS pattern, DTOs
