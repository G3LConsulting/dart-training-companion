> **Shared reference document** — Non-functional requirements and security standards. All features must adhere to these constraints and guarantees.

# Non-Functional Requirements & Security

## Performance

### Load & Responsiveness
| Requirement | Target | Measurement |
|-------------|--------|-------------|
| **Initial page load** (first visit, cold cache, 4G throttle) | ≤ 3 seconds | Time to interactive (TTI) on Lighthouse |
| **Subsequent loads** (cached assets, 4G) | ≤ 1 second | TTI from service worker cache |
| **Score entry interaction** | ≤ 100 ms | Keystroke to visual feedback on dartboard/scoreboard |
| **Page navigation** (feature transitions) | ≤ 200 ms | Route change to component render complete |
| **API response time** (p95) | ≤ 500 ms | Measured under normal load (excluding external services) |
| **Stats recalculation** (up to 1000 sessions) | ≤ 30 seconds | Background job completion time |

### Optimization Strategies
- **Code splitting:** Feature-lazy-load with Angular lazy routes
- **Tree-shaking:** Remove unused code in production builds
- **Image optimization:** WebP with PNG fallback; lazy-load with intersection observer
- **Service worker:** Cache static assets; precache critical paths
- **Compression:** gzip/brotli on all text responses (API + PWA assets)
- **CDN:** Serve static assets from CDN edge locations (production)
- **API batching:** Combine multiple queries when possible (e.g., sync multiple sessions in one POST)

---

## Offline Support

### Core Requirement
**All features except leaderboards and user-sharing fully functional offline.**

| Feature | Offline Support | Notes |
|---------|-----------------|-------|
| **New game entry** | ✅ Yes | Stored in localStorage + IndexedDB sync queue |
| **Score entry** | ✅ Yes | Real-time on client; synced on reconnect |
| **Game completion** | ✅ Yes | Session saved locally, queued for sync |
| **Session history** | ✅ Yes (cached) | Recent sessions available; older sessions require network |
| **Personal stats** | ✅ Yes (stale) | Last-calculated stats shown; refresh on reconnect |
| **Leaderboards** | ❌ No | Requires live server data; show offline message |
| **User sharing** | ❌ No | Requires server verification; disabled offline |
| **Export** | ⚠️ Partial | Request queued offline; download requires network |

### Technical Implementation
- **localStorage:** In-progress game (< 100 KB typical); persists across browser close
- **IndexedDB:** Sync queue of completed sessions; supports large payloads; persistent
- **Service Worker:** Caches HTML, CSS, JS, images; handles offline requests
- **Conflict Detection:** Compare local timestamps with server; prompt user on conflict
- **Auto-Sync:** Triggered on navigator.online event; retry with exponential backoff

### User Experience
- **Offline Indicator:** Persistent banner when connection lost; shows in header/footer
- **Sync Status:** Badge or spinner during active sync; "Last synced: 2 mins ago"
- **Error Handling:** Toast notifications for sync failures; manual retry button
- **Graceful Degradation:** UI updates reflect offline state; buttons disabled for network-dependent actions

---

## Usability & Accessibility

### Mobile-First Design
| Requirement | Target | Measurement |
|-------------|--------|-------------|
| **One-handed thumb reach** | 5–6" phones | Content within thumb zone; critical buttons ≤ 60px from bottom |
| **Tap target size** | 44×44 px minimum | WCAG 2.1 AA standard |
| **From home to score entry** | ≤ 3 taps | Optimize navigation depth on mobile |
| **From home to any feature (desktop)** | ≤ 2 clicks | Desktop user workflow |
| **Responsive breakpoints** | Mobile, tablet, desktop | Tested at 360px, 768px, 1024px+ widths |

### Accessibility (WCAG 2.1 Level AA)
| Standard | Implementation | Details |
|----------|----------------|---------|
| **Color contrast** | 4.5:1 text/background | Ensure text readable; test with WebAIM contrast checker |
| **Keyboard navigation** | Full keyboard support | Tab order, focus indicators, skip links |
| **Screen readers** | ARIA labels on interactive elements | aria-label, aria-describedby, role attributes |
| **Focus indicators** | Visible, high-contrast | Outline ≥ 3px, never removed |
| **Alt text** | All images captioned | Descriptive; use aria-label for icons |
| **Form labels** | <label> associated with <input> | Not placeholder-only |
| **Motion** | Respect prefers-reduced-motion | Disable animations if system preference set |
| **Video captions** | All video content captioned | Or provide transcript |
| **Font size** | Min 16px base, scalable to 200% | No fixed px; use rem units |

### Theme Support
- **Light Mode:** Default; high contrast for readability
- **Dark Mode:** Reduces eye strain in low light; respects prefers-color-scheme
- **Theme toggle:** User preference saved to localStorage; persists across sessions
- **Auto-detect:** Honor system preference on first visit (window.matchMedia)

### Export Performance
- **Time limit:** Export ≤ 5 seconds for up to 1000 sessions
- **Formats:** CSV (minimal), JSON (full detail), Excel (formatted)
- **Streaming:** Large files streamed to avoid memory issues
- **Progress feedback:** POST returns 202 Accepted; polling via GET shows progress

---

## Browser & Device Compatibility

### Target Browsers (Latest 2 Major Versions)

| Browser | Platform | Min Version | Notes |
|---------|----------|-------------|-------|
| **Chrome/Chromium** | Android | 120 | PWA installable, service worker, IndexedDB |
| **Chrome** | Desktop | 120 | Desktop PWA, full functionality |
| **Safari** | iOS | 15 | Limited PWA (iOS 16.3+); Web Manifest not full featured |
| **Safari** | macOS | 15 | Desktop, full functionality |
| **Firefox** | Desktop | 120 | Service worker, local storage, IndexedDB |
| **Edge** | Desktop | 120 | Chromium-based, parity with Chrome |

### Device Support
- **Phones:** 4–7" screens; portrait & landscape orientations
- **Tablets:** 7–13" screens; document-like experience
- **Desktops:** 13"+ monitors; multi-window, external display support
- **Screen readers:** NVDA (Windows), JAWS (Windows), VoiceOver (macOS/iOS)
- **Touch:** Primary input; minimum 44×44 px targets
- **Keyboard:** Full support; Tab, Enter, Escape, arrow keys

### PWA Installation
- **Web Manifest:** Installable via "Add to Home Screen" on Android Chrome
- **iOS:** Via Share → Add to Home Screen (Web Clips)
- **Desktop:** Install button in browser address bar (Chrome, Edge)
- **App Icon:** 192×192 px, 512×512 px provided; supports dark/light variants
- **Splash Screen:** Custom splash image on launch (iOS + Android)

---

## Data, Privacy & GDPR Compliance

### Password Security
- **Algorithm:** PBKDF2-HMAC-SHA512 (ASP.NET Core Identity default)
- **Iterations:** ≥ 10,000
- **Never transmitted:** Only hash stored in database; always over HTTPS
- **Reset tokens:** Single-use, time-limited (15 minutes), cryptographically secure

### Data Export & Deletion
- **User-initiated export:** CSV, JSON, or Excel format; includes all personal data
- **Account deletion:** Hard delete of ApplicationUser + related game sessions; soft-delete flag set for audit trail
- **Right to be forgotten:** Upon deletion, user data inaccessible within 24 hours
- **Export retention:** Downloads available for 30 days; automatic cleanup

### Third-Party Data Sharing
- **No tracking:** No Google Analytics, no Facebook Pixel, no third-party cookies
- **No ads:** Ad-free experience; no ad networks
- **No resale:** User data never sold or shared with third parties
- **OAuth only if:** SSO integrations (e.g., Sign-in with Google) optional; user grants explicit consent

### Leaderboard & Privacy
- **Display name only:** Leaderboards show user's display name, not email
- **Opt-in:** LeaderboardOptIn flag; default false
- **Stats anonymization:** Remove identifiable data if aggregating for public stats

### GDPR Compliance (EU users)
- **Consent:** Explicit opt-in for email, analytics, leaderboard inclusion
- **Data retention:** Clear policy on how long data retained (30-day soft-delete grace period)
- **Portability:** Export feature enables GDPR Article 20 compliance
- **Erasure:** Deletion request processed within 30 days
- **DPA:** Data processing agreement with infrastructure providers (cloud hosts, email services)
- **Transparency:** Privacy Policy accessible, plaintext not legalese

---

## Internationalization (i18n)

### v1.0 Scope
- **Primary Language:** English (en-GB)
- **Locale-specific:** Number formats, date formats, currency (GBP)
- **Timezone:** User timezone inferred from browser or set in profile

### Architecture for Future Locales
- **String externalization:** All UI text in JSON translation files; never hardcoded
- **Number formatting:** Use Intl.NumberFormat API (browser-native)
- **Date formatting:** Use Intl.DateTimeFormat API; respect locale preference
- **Backend:** Support Accept-Language header; return locale-aware strings in API responses
- **Frontend:** Module structure ready for lazy-loading additional language files

### Example Structure
```
src/assets/i18n/
├── en-GB.json         # English (v1.0)
├── en-US.json         # English (USA, future)
├── de-DE.json         # German (future)
└── fr-FR.json         # French (future)
```

---

## Security & Authentication

### Identity & Access Management
- **Framework:** ASP.NET Core Identity with custom user model (ApplicationUser)
- **Token-based auth:** JWT access tokens (stateless, no server session)
- **Email verification:** Required before account usable; opt-in to leaderboard

### JWT Token Lifecycle
| Token | Lifetime | Stored | Rotation |
|-------|----------|--------|----------|
| **Access Token** | 15 minutes | Memory (Frontend) | Refreshed via refresh token |
| **Refresh Token** | 7 days | Secure HttpOnly cookie (Backend) | Rotated on every refresh; old token invalidated |

### Password Policy
- **Minimum length:** 8 characters
- **Complexity:** At least 1 uppercase, 1 digit (configurable, ASP.NET Identity defaults)
- **Hashing:** PBKDF2-HMAC-SHA512 via IdentityUser default
- **Reset:** Email-based; single-use token valid for 15 minutes

### HTTPS & Transport Security
- **Enforcement:** HTTPS only; no HTTP fallback
- **HSTS:** Strict-Transport-Security header; 1-year max-age
- **TLS:** TLS 1.2 minimum; TLS 1.3 preferred
- **Certificates:** Let's Encrypt (auto-renewal via nginx)
- **nginx:** Reverse proxy; terminates TLS, applies security headers

### CORS Policy
- **Allowed origins:** Production domain only; no wildcard (*)
- **Credentials:** Cookies allowed in cross-origin requests (if SSO)
- **Methods:** GET, POST, PUT, DELETE, OPTIONS
- **Headers:** Content-Type, Authorization, X-Requested-With
- **Expose headers:** Content-Disposition (for file downloads)

### Secrets Management
- **Development:** .env file (never committed, .gitignore protected)
- **Production:** Azure Key Vault (managed identity, no hardcoded credentials)
- **Rotation:** Annual key rotation; alert 30 days before expiry
- **Audit:** All secret access logged via Azure Monitor

### CSP (Content Security Policy)
```
Content-Security-Policy:
  default-src 'self';
  script-src 'self' 'nonce-{random}';
  style-src 'self' 'unsafe-inline' fonts.googleapis.com;
  font-src fonts.gstatic.com;
  img-src 'self' data:;
  connect-src 'self' api.dartcompanion.app seq.dartcompanion.app;
  frame-ancestors 'none';
  base-uri 'self';
  form-action 'self'
```

### SQL Injection Prevention
- **ORM:** Entity Framework Core parameterized queries; no dynamic SQL
- **Input validation:** FluentValidation on all commands
- **JSONB:** Safe via EF Core value converters; never raw SQL concatenation

### CSRF Protection
- **Tokens:** ASP.NET Core anti-CSRF middleware (automatic on SPA)
- **Same-site cookies:** SameSite=Strict on secure cookies
- **Double-submit:** Verify token matches in form + header

---

## Observability & Logging

### OpenTelemetry Stack

| Layer | Tool | Purpose |
|-------|------|---------|
| **Structured logs** | Serilog | Application events, errors, traces |
| **Log aggregation** | Seq | Centralized log search; trace correlation |
| **Metrics** | Prometheus | System health (CPU, memory, requests/sec) |
| **Metrics dashboards** | Grafana | Visual monitoring; alerting thresholds |
| **Distributed traces** | OpenTelemetry SDK | Request flow across services (API, DB) |

### Logging Strategy
- **Log level:** Info (default), Debug (dev), Warn (errors), Error (exceptions)
- **Structured properties:** Include user ID, session ID, request ID; no PII
- **Examples:**
  ```
  logger.LogInformation("User {UserId} logged in from {IPAddress}", userId, ipAddress);
  logger.LogError("Stats recalculation failed for user {UserId}. Error: {Exception}", userId, ex);
  ```
- **No PII:** Never log passwords, email, credit cards, sensitive data
- **Performance:** Use lazy evaluation for expensive log operations

### Metrics Monitored
| Metric | Threshold | Action |
|--------|-----------|--------|
| **API response time (p95)** | > 1s | Investigate slow queries, cache misses |
| **Error rate** | > 1% | Page owner alerted; escalate if > 5% |
| **Database connection pool** | > 80% utilization | Scale up; add replicas if needed |
| **Memory usage** | > 85% | Heap dump; analyze for leaks |
| **Disk space** | < 10% free | Archive/delete old logs, expand volume |

### Alerting Rules
- **Critical:** API unavailable, database down, 5xx errors > 10/min
- **High:** Error rate > 5%, response time p95 > 2s, job queue backlog > 100
- **Medium:** Warning logs > 100/min, cache hit rate < 80%
- **Notification:** Slack (immediate), PagerDuty (on-call engineer), email (summary)

### Tracing
- **Instrumentation:** OpenTelemetry SDK automatically traces HTTP requests, EF Core queries
- **Trace context:** Propagated via W3C Trace Context headers; visible in Seq UI
- **Sampling:** Trace 100% in dev, 10% in prod (adjustable)
- **Retention:** Seq retains traces for 7 days; data warehouse archives for audit

---

## Summary Table: NFR Compliance Checklist

| Category | Requirement | Status | Owner |
|----------|-------------|--------|-------|
| **Performance** | First load ≤ 3s, subsequent ≤ 1s | In Progress | Frontend Lead |
| **Performance** | Score entry ≤ 100ms | In Progress | Game Feature Owner |
| **Offline** | All features except leaderboards offline | Pending | Backend + Frontend |
| **Usability** | WCAG 2.1 AA compliance | Pending | Accessibility Lead |
| **Usability** | One-handed on 5–6" phone | Pending | UX/Design |
| **Compatibility** | Chrome, Safari, Firefox, Edge (latest 2) | Pending | QA + Dev |
| **Privacy** | GDPR compliance, data export | Pending | Legal + Backend |
| **Security** | HTTPS, HSTS, CSP headers | In Progress | Infra |
| **Security** | Password hashing PBKDF2 | Done | Identity |
| **Security** | JWT + refresh token rotation | Done | Auth Feature Owner |
| **Observability** | OpenTelemetry + Seq + Prometheus + Grafana | In Progress | DevOps Lead |
| **i18n** | English (en-GB) v1.0; architecture extensible | Pending | Localization Owner |

