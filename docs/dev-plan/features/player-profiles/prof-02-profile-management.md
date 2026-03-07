# PROF-02 — Profile Management & Account Deletion

**Feature:** Player Profiles
**Phase:** MVP
**Status:** 🔲 Not started
**Agent:** —
**Output:** —
**Notes:** —

---

## Context

Allows users to view and update their profile preferences, configure the fourth PB slot, and permanently delete their account with email confirmation. Deleted accounts are soft-deleted and immediately logged out.

> Implements: FA §FR-P-02, TA §10

---

## Acceptance Criteria

- [ ] User can update: display name (max 100), dominant hand, preferred game mode, target average, week start day (Monday/Sunday)
- [ ] User can configure the fourth home screen PB slot (HomeScreenPbMetricKey)
- [ ] Account deletion requires email confirmation in request body; sets IsDeleted=true, DeletedAt=now
- [ ] Deleted account is immediately logged out (all refresh tokens revoked)
- [ ] Profile data returned correctly on GET /api/profile
- [ ] LeaderboardOptIn defaults to false; user can toggle (post-MVP feature but field persisted in MVP)
- [ ] Validation: DisplayName NotEmpty, MaxLength(100); TargetAverage GreaterThan(0) when provided; DominantHand IsInEnum
- [ ] Soft-deleted users cannot log in or refresh tokens

---

## Technical Implementation Notes

**Backend Command/Query Structure:**
- Location: `Application/Profile/Commands/` and `Application/Profile/Queries/`
- Commands:
  - UpdateProfileCommand: displayName, dominantHand, preferredGameMode, targetAverage, weekStartDay, homeScreenPbMetricKey, leaderboardOptIn
  - DeleteAccountCommand: confirmationEmail (must match account email for confirmation)
- Queries:
  - GetProfileQuery: returns ProfileDto with all profile fields
- FluentValidation validators for each command in same folder

**UpdateProfileCommandValidator:**
- DisplayName: NotEmpty(), MaxLength(100)
- TargetAverage: GreaterThan(0) when provided
- DominantHand: IsInEnum() (Left/Right/Ambidextrous)
- WeekStartDay: IsInEnum() (Monday/Sunday)
- PreferredGameMode: IsInEnum() when provided (501/301/Cricket/NumberFocus)
- HomeScreenPbMetricKey: nullable, can be any UserStats metric key or null

**DeleteAccountCommandValidator:**
- ConfirmationEmail: NotEmpty(), Must equal user's current email (case-insensitive)

**API Controller:**
- Location: `Api/Controllers/ProfileController.cs`
- Endpoints: GET /api/profile, PUT /api/profile, DELETE /api/profile

**Delete Account Implementation:**
- DeleteAccountCommand handler:
  - Validates email matches
  - Sets user.IsDeleted = true, user.DeletedAt = now
  - Revokes all RefreshTokens for user (RevokedAt = now)
  - Audit log: account deleted by user
  - Returns 200 OK
- No data restoration; soft delete allows admin audit if needed

**Profile Data Transfer:**
- ProfileDto includes: UserId, Email, DisplayName, DominantHand, PreferredGameMode, TargetAverage, WeekStartDay, HomeScreenPbMetricKey, LeaderboardOptIn, CreatedAt
- GET /api/profile returns ProfileDto for authenticated user
- PUT /api/profile accepts profile update fields and returns updated ProfileDto

**Angular Frontend:**
- Location: `src/app/features/profile/` (standalone component)
- Reactive form with fields: displayName, dominantHand (radio/select), preferredGameMode, targetAverage, weekStartDay, homeScreenPbMetricKey (dropdown of available metrics), leaderboardOptIn (toggle)
- Delete account button opens confirmation dialog: "Enter your email to confirm deletion" → validates email matches → calls DELETE /api/profile → redirects to logout page

---

## Dependencies

- PROF-01 — User Registration & Authentication — user must be authenticated to manage profile
- INFRA-02 — Database Setup & EF Core Configuration — ApplicationUser schema must support all profile fields

---

## Shared References

- [Domain Model](../../shared/domain-model.md) — ApplicationUser entity and profile fields
- [Architecture](../../shared/architecture.md) — §10 (profile management patterns)
- [API Contracts](../../shared/api-contracts.md) — profile endpoints and ProfileDto schema
