# STORY: PWA-01 — Service Worker, Offline Caching & Installability

**Feature:** PWA & Offline Support
**Phase:** MVP
**Status:** Pending
**Agent:** Frontend Team
**Output:** Service worker configuration, offline caching strategy, PWA manifest, offline indicator
**Notes:** Enables offline-first experience and installability on mobile/desktop. Foundation for PWA features.

---

## Context

### Implements
- **FA §12.2** — Offline functionality and support
- **FA §12.4** — Installability and app-like experience
- **TA §3** — Service worker architecture and caching strategy

### Acceptance Criteria

- [ ] Service worker caches static assets (cache-first strategy) and select API GETs (network-first)
- [ ] App fully functional offline for all features except leaderboards/sharing/export
- [ ] Subsequent loads interactive within 1 second (service worker cache hit)
- [ ] PWA manifest present with app name, icons, display mode, theme colors
- [ ] App meets Chrome/Safari installability criteria (HTTPS, manifest, icon, service worker)
- [ ] Clear offline indicator shown in UI when user disconnected
- [ ] Service worker updates in background without disrupting user

---

## Tasks

| Task ID | Title | File Changes | Assigned | Status |
|---------|-------|-------------|----------|--------|
| [PWA-01-T01](./pwa-01-offline-installability/TASK-PWA-01-T01.md) | Frontend: ngsw-config.json cache strategy configuration | `src/ngsw-config.json` | Frontend | Pending |
| [PWA-01-T02](./pwa-01-offline-installability/TASK-PWA-01-T02.md) | Frontend: PWA manifest configuration | `src/manifest.webmanifest`, app shell | Frontend | Pending |
| [PWA-01-T03](./pwa-01-offline-installability/TASK-PWA-01-T03.md) | Tests: Offline functionality smoke tests | Manual or Playwright tests | QA/Frontend | Pending |

---

## Dependencies

- **INFRA-01** — Angular project scaffold with @angular/pwa module
- **DESK-01** — App shell and layout established
- **Shared References:** Architecture (service worker, offline-first), NFRs (performance, offline, installability)

---

## Shared References

See [`../../shared/architecture.md`](../../shared/architecture.md) for service worker strategy and offline-first patterns.
See [`../../shared/nfrs.md`](../../shared/nfrs.md) for performance targets and installability requirements.
