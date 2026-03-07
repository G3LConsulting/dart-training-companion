# LEAD-02 — Leaderboard Opt-Out

**Feature:** Leaderboards
**Phase:** Post-MVP
**Status:** 🔲 Not started
**Agent:** —
**Output:** —
**Notes:** —

---

## Context
Leaderboard participation is opt-in. Toggle in profile settings. Default is opted-out (LeaderboardOptIn=false).
> Implements: FA FR-L-02
> ⚠️ This story is Post-MVP and should not be started until MVP is complete and approved.

---

## Acceptance Criteria
- [ ] Toggle available in profile settings (settings/preferences panel)
- [ ] Default state: OFF (LeaderboardOptIn=false, user not visible on leaderboards)
- [ ] When toggled ON: user appears on leaderboards (if ≥5 games in window)
- [ ] When toggled OFF: user removed from all leaderboards
- [ ] No retroactive data deletion when opting out (privacy-safe)
- [ ] Toggle persists across sessions (stored in ApplicationUser)
- [ ] Confirmation message shown after toggle (optional: "You are now visible on leaderboards")
- [ ] No leaderboard data shown to opted-out users (UI hides leaderboards feature)

---

## Technical Implementation Notes

**Backend:**
- ApplicationUser entity: LeaderboardOptIn: bool (default = false)
- UpdateProfileCommand extended: add LeaderboardOptIn parameter
- Validation: allow any bool value
- No data deletion on opt-out (data remains in database for historical stats)
- Query filtering: GetLeaderboardQuery filters by LeaderboardOptIn = true
- No retroactive audit trail needed (privacy-compliant approach)

**Angular:**
- Integration in features/profile/settings/ (PROF-01/PROF-02 settings screen)
- Toggle component: simple on/off switch in "Privacy" section
- Label: "Show my stats on global leaderboards"
- Helper text: "When enabled, your display name and top scores will be visible to other players. You must have at least 5 games in a mode to appear."
- Toggle state tied to ApplicationUser.LeaderboardOptIn
- Click handler: emit update event; call UpdateProfileCommand via service
- Success message: "Settings saved" toast or inline confirmation
- Error handling: show error toast if update fails
- UI behavior: if LeaderboardOptIn=false, hide Leaderboards nav item or show "Coming soon" (or "Disabled - enable in settings")

---

## Dependencies
- Depends on PROF-01 (profile settings context)
- Depends on LEAD-01 (leaderboard feature)
- Requires ApplicationUser.LeaderboardOptIn field already in domain model
- Requires UpdateProfileCommand extended to handle toggle

---

## Shared References
- [Domain Model](../../shared/domain-model.md) — ApplicationUser.LeaderboardOptIn field
- [Architecture](../../shared/architecture.md) — Command handler pattern, settings update pattern
- [API Contracts](../../shared/api-contracts.md) — PUT /api/profile endpoint accepts LeaderboardOptIn boolean
- [NFRs](../../shared/non-functional-requirements.md) — §12.1 (responsive settings), privacy compliance, toggle update in <1s
