# PROF-06 — Guest Mode

**Feature:** Player Profiles
**Phase:** Post-MVP
**Status:** 🔲 Not started
**Agent:** —
**Output:** —
**Notes:** —

---

## Context

Allows users to play and track stats locally without creating an account, with an option to convert the local data into a full account later. All data stored locally; no server sync or leaderboard features until account creation.

> Implements: FA §FR-P-05

> ⚠️ This story is Post-MVP and should not be started until MVP is complete and approved.

---

## Acceptance Criteria

- [ ] User can start the app without registering and play any game mode
- [ ] All data stored locally (localStorage / IndexedDB) with no server calls
- [ ] "Convert to account" flow: registers account and migrates all local data to server
- [ ] Guest data clearly labelled in UI; no sync, no leaderboard, no export (online features disabled)
- [ ] Guest mode can be exited by logging in (converts to full account or logs into existing account)
- [ ] Stats calculated locally for guest sessions (average, PBs, etc.)
- [ ] Local data persists across browser sessions until explicit conversion or deletion

---

## Technical Implementation Notes

**Guest Session Management (Angular):**
- Location: `src/app/core/auth/guest.service.ts`
- Tracks isGuest$ BehaviorSubject
- Generates guest UUID on first visit (stored in localStorage)
- All game sessions, stats stored under guest UUID in IndexedDB
- Local stats calculation service mirrors server stats logic

**Guest Mode Flag in State:**
- Auth state includes isGuest: boolean
- All API calls check isGuest before making HTTP request
- All leaderboard, sync, export features disabled (UI hidden or redirects to login)

**Local Data Storage:**
- IndexedDB schema mirrors server schema for GameSession, UserStats
- Guest sessions tagged with guestUuid instead of userId
- Stats recalculation runs locally on session completion

**Account Conversion Flow:**
- Route: /auth/convert-to-account (accessible only to guests)
- UI: Enter email, password, display name (standard registration form)
- Backend:
  - POST /auth/register/guest → accepts email, password, displayName
  - Creates ApplicationUser with account active (no email verification for guest conversion)
  - Issues JWT + refresh token immediately
  - Returns migrationToken (short-lived JWT claiming guest session)
- Frontend (post-registration):
  - IndexedDB: reads all guest sessions
  - POST /api/sessions/sync with guestSessions[] + migrationToken
  - Server validates migrationToken, associates sessions with new user
  - Clears localStorage guest flag and guestUuid
  - Navigates to home screen

**Login Redirect for Guests:**
- Guest user clicks "Sign In" anywhere in app
- Redirects to /auth/login-or-convert
- If email matches guest account email: auto-register as guest (no backend call needed)
- If email is new: standard login (which auto-converts if no account exists)

**UI Labeling & Restrictions:**
- Banner at top: "Playing as Guest — no account required" with action button "Create Account"
- Disable: leaderboard routes, export features, device sync, notifications settings
- History and stats views work but show "Guest Mode — data local only"
- Game play fully functional; no restrictions

**Local Stats Calculation Service:**
- Location: `src/app/core/stats/local-stats.service.ts` (post-MVP, mirrors server logic)
- On each session completion: recalculates UserStats for guest
- Stores in IndexedDB under guestUuid

**Conversion Endpoint:**
- POST /api/auth/register/guest: { email, password, displayName, guestUuid, guestSessions[] }
  - Handler: creates ApplicationUser, returns migrationToken
- POST /api/sessions/sync with migrationToken header: accepts guest sessions, associates with new user

---

## Dependencies

None — this story can be started post-MVP in parallel with other features, as it only requires PROF-01 and basic game session structure.

---

## Shared References

- [Domain Model](../../shared/domain-model.md) — GameSession, UserStats entities (guest mode uses same schema locally)
- [Architecture](../../shared/architecture.md) — offline-first architecture, local storage and IndexedDB patterns
