# AUTH-04 — Account Deletion

**Feature:** Authentication  **Phase:** MVP  **Status:** 🔲 Not started  **Agent:** —  **Output:** —  **Notes:** —

---

## Context

Account deletion enables users to remove their profiles and data from the system. This story implements a secure deletion flow: user confirms deletion via email input, account is soft-deleted immediately (IsDeleted = true), user is logged out, and display name is removed from leaderboards. Hard deletion (purging from database) is a post-MVP background job. Implements CQRS DeleteAccountCommand with validation.

> Implements: FA §FR-P-02 (account deletion), TA §6 (DeleteAccountCommand)

---

## Acceptance Criteria

- [ ] "Delete account" button in Profile & Settings opens confirmation modal
- [ ] User must type their email to confirm deletion
- [ ] On confirm: account immediately deactivated, user logged out
- [ ] Display name removed from leaderboard entries immediately
- [ ] Soft-delete in DB; server-side purge within 30 days (purge job is post-MVP, soft delete is MVP)

---

## Tasks

| Task | Layer | Status | Agent |
|------|-------|--------|-------|
| [AUTH-04-T01 — API: Delete account command](auth-04-t01-delete-account-command.md) | Application | 🔲 Not started | — |
| [AUTH-04-T02 — Frontend: Account deletion modal](auth-04-t02-account-deletion-frontend.md) | UI | 🔲 Not started | — |
| [AUTH-04-T03 — Tests: Account deletion tests](auth-04-t03-account-deletion-tests.md) | Testing | 🔲 Not started | — |

---

## Dependencies

- AUTH-01 — User Registration & Email Verification — reason: User entity and email verification required
- AUTH-02 — Login & JWT Token Management — reason: Authentication context required for deletion endpoint

---

## Shared References

- [Domain Model](../../shared/domain-model.md) — ApplicationUser.IsDeleted, DeletedAt fields
- [API Contracts](../../shared/api-contracts.md) — DELETE /api/profile
- [Architecture](../../shared/architecture.md) — CQRS command pattern, soft delete patterns
- [NFRs](../../shared/nfrs.md) — GDPR compliance, data retention policies
