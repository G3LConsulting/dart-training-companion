# TASK: PWA-01-T01 — Frontend: ngsw-config.json Cache Strategy Configuration

**Story:** [PWA-01](../STORY-PWA-01.md)
**Layer:** Frontend
**Status:** Pending
**Agent:** Frontend Team

---

## What to Build

Configure Angular Service Worker (NGSW) with cache strategies for offline support:

**Cache Strategies:**
- **Static Assets (Cache-First):** app shell, CSS, fonts, images cached indefinitely
- **API Data (Network-First):** GET /api/stats, /api/game-modes cached on first fetch, network requests bypass cache if available
- **Fallback:** offline page shown if network unavailable and no cache hit
- **Max Age:** stats/game data cached for 1 hour, then fresh fetch attempted

**Offline Support:**
- Leaderboards: disabled offline (online required)
- Sharing: disabled offline
- Export: disabled offline
- Score entry, history, stats: fully functional offline with sync queue

---

## Files

| File Path | Type | Purpose |
|-----------|------|---------|
| `src/ngsw-config.json` | Configuration | Service worker caching strategy |
| `src/assets/offline.html` | Fallback Page | Offline placeholder (optional) |

---

## Definition of Done

- [ ] ngsw-config.json compiles without errors
- [ ] Static asset group configured with cache-first strategy
- [ ] API data group configured with network-first strategy and 1-hour max age
- [ ] API GET endpoints for stats, game modes, profile included in cache policy
- [ ] Fallback offline page configured (if browser requests offline page)
- [ ] Service worker registers successfully in production build
- [ ] Cache versioning implemented: bumped version on each build
- [ ] Browser DevTools Network tab shows service worker cache hits
- [ ] Unit tests verify cache configuration syntax
- [ ] Manual testing: app loads offline from cache, shows offline indicator

---

## Implementation Notes

**ngsw-config.json Structure:**
```json
{
  "version": 1,
  "extends": "~2023.0.0",
  "routing": [],
  "assetGroups": [
    {
      "name": "app",
      "installMode": "prefetch",
      "updateMode": "prefetch",
      "urls": [
        "/favicon.ico",
        "/index.html",
        "/*.css",
        "/*.js"
      ]
    },
    {
      "name": "assets",
      "installMode": "lazy",
      "updateMode": "lazy",
      "urls": [
        "/assets/**/*"
      ]
    }
  ],
  "dataGroups": [
    {
      "name": "stats-api",
      "urls": [
        "/api/stats/**",
        "/api/game-modes/**",
        "/api/profile/**"
      ],
      "cacheConfig": {
        "strategy": "network-first",
        "maxAge": "1h",
        "maxSize": 100
      }
    },
    {
      "name": "leaderboards-api",
      "urls": [
        "/api/leaderboards/**"
      ],
      "cacheConfig": {
        "strategy": "network-only",
        "maxAge": "1h"
      }
    }
  ]
}
```

**Breakdown:**

**Asset Groups:**
- `app`: Critical shell files (HTML, CSS, JS) prefetched on install, always updated
- `assets`: Images, fonts, static content lazy-loaded on demand

**Data Groups:**
- `stats-api`: Stats, game modes, profile cached with network-first (try network, fallback to cache)
- `leaderboards-api`: Network-only (offline not supported)

**Cache Strategies:**
- `network-first`: Try network, fall back to cache (best for data that changes)
- `network-only`: Never cache (for real-time data like leaderboards)
- `cache-first`: Use cache always, refresh in background (best for static assets)

**MaxAge:** Time before cached response is considered stale (1h for stats data)

**MaxSize:** Max entries in cache (100 responses per data group)

---

## References

- Angular Service Worker: https://angular.io/guide/service-worker-intro
- ngsw-config.json: https://angular.io/guide/service-worker-config
- Cache Strategies: https://www.npmjs.com/package/@angular/service-worker
- [`../../shared/architecture.md`](../../shared/architecture.md) — Service worker patterns
