# GUEST-01 — Guest Mode

**Feature:** Guest Mode
**Phase:** Post-MVP
**Status:** 🔲 Not started
**Agent:** —
**Output:** —
**Notes:** —

> ⚠️ This story is Post-MVP and should not be started until MVP is complete and approved.

---

## Context

Requiring account creation before any app usage creates friction and loses potential users. Offering guest mode allows players to try the app immediately, building confidence and engagement before they commit to signing up. Guest data stored locally can be migrated to a full account when the user eventually creates one, preserving their practice history and progress.

> Implements: FA §FR-P-05

---

## Acceptance Criteria

- [ ] User can use app without creating account
- [ ] Guest data stored locally only
- [ ] Prompted to create account for sync/leaderboards/sharing
- [ ] Guest can convert local data to full account

---

## Technical Implementation Notes

> ⚠️ No detailed TA spec exists for this feature yet. The following is derived from the FA and general architecture patterns.

- Guest mode state management:
  - LocalStorage flag `isGuest=true` for anonymous users
  - All game sessions and stats stored in IndexedDB/localStorage, keyed by local user ID
  - No API calls to backend (except optional analytics)
- Authentication flow modification:
  - Splash screen with "Play as guest" and "Sign in" buttons
  - Guest path skips login/signup entirely
  - Full app functionality available (all game modes, stats, drills)
- Feature gating for authenticated-only features:
  - Leaderboards: Hidden or show "Sign up to compete" prompt
  - Sync: Not available in guest mode (show "Create account to sync" prompt)
  - Sharing: Not available (show "Create account to share" prompt)
  - Profile/settings: Limited (no profile picture, no display name visible publicly)
- Guest-to-full-account conversion flow:
  - "Create account" button/prompt appears in key locations (home, settings, leaderboard)
  - New `CreateAccountFromGuestCommand` migrates local session data to backend:
    - User creates credentials/account
    - All local sessions uploaded as GameSession entities
    - All local stats computed and persisted
    - Local data cleared, user logged in
  - Optional: Show upload progress during migration
- Service layer:
  - Abstract base session storage interface (LocalStorage vs API)
  - Conditional injection based on `isGuest` flag
  - Conversion service to serialize/upload local data

---

## Dependencies

- AUTH-01 — User Registration & Login (MVP) — Account creation flow
- SYNC-01 — Data Sync & Offline Support (MVP) — Data persistence patterns
- GAME-01 — Game Recording (MVP) — Game session recording for offline play

---

## Shared References

- ../../shared/architecture.md
- ../../shared/entities.md
