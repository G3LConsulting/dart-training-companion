# Non-Functional Requirements — Darts Training Companion

> **Shared reference document.** Do not duplicate this content in story files — link to it instead.

---

## Overview

Non-functional requirements (NFRs) define system qualities and constraints. These apply to all features unless explicitly overridden by story-level acceptance criteria. All NFRs are binding for v1.0 release on the private server; post-MVP enhancements are noted.

---

## Performance (FA §12.1)

### First Interactive Load

**Requirement:** Initial page load to interactive state ≤ 3 seconds on mid-range smartphone (4G network).

**Definition:**
- Time from navigation to first contentful paint (FCP)
- First input delay (FID) or interaction to next paint (INP) ≤ 100ms
- Home page, login page, and session list (first 20 items) must all meet 3s target

**Measurement:**
- Lighthouse performance score ≥ 80
- Simulated 4G throttling (1.6 Mbps down, 750 Kbps up, 40ms latency)
- Real device testing on Samsung Galaxy A50 or equivalent

**Implementation Notes:**
- Bundle size target: <500 KB main JavaScript (gzip)
- Lazy-load stats pages and charts on demand
- Service worker precache critical routes only (home, auth, session list)
- Defer non-critical CSS and scripts

### Subsequent Loads

**Requirement:** Repeat visits ≤ 1 second to interactive (service worker cache hit).

**Definition:**
- Service worker caches HTML shell, CSS, and common JS chunks
- Cache invalidation via versioning; update cache on app version change
- Cold cache (after clear) should still meet 3s target

**Implementation Notes:**
- ngsw-config.json precaches home, login, session list templates
- Hash-based cache busting for assets
- IndexedDB cache for API responses (optional; localStorage sufficient for MVP)

### Score Entry Interactions

**Requirement:** User interactions (button click to visual feedback) ≤ 100ms.

**Definition:**
- Tap/click score button → visual state change (highlight, disable, enable next button) ≤ 100ms
- Spinners or loaders must appear immediately; no blank/frozen UI
- All dartboard input interactions must be responsive and immediate

**Implementation Notes:**
- Use Angular ChangeDetectionStrategy.OnPush for input components
- Debounce API calls (e.g., auto-save) to avoid thrashing
- Show optimistic UI updates locally before server confirmation
- Avoid long-running computations on main thread; move to Web Worker if needed

---

## Offline Support (FA §12.2)

### Feature Availability Offline

**Requirement:** All features except leaderboards and sharing are fully functional offline.

**Offline Features:**
- Start, play, and complete game sessions (all modes: 501, 301, Cricket, NumberFocus)
- View session history (from cache)
- View personal statistics (cached, last-calculated state)
- Enter scores and turns with immediate local persistence
- Access all configuration options
- Generate data exports (queued for sync)

**Offline-Unavailable Features:**
- Leaderboards (post-MVP; requires server ranking)
- Sharing sessions or stats with other users (post-MVP)
- Real-time notifications

**Implementation Notes:**
- localStorage caches in-progress sessions (max 50 KB)
- IndexedDB caches completed offline queue (optional; localStorage sufficient for MVP)
- SyncService detects offline state via GET /api/health ping
- All offline state cleared after successful sync

### Auto-Sync on Reconnect

**Requirement:** Automatically sync all offline changes to server without user intervention.

**Definition:**
- SyncService detects online state (GET /api/health succeeds)
- Triggers POST /api/sessions/sync automatically
- Resolves conflicts if present (prompt user)
- Clears offline cache upon successful sync
- No manual sync button required, but optional for user control

**Implementation Notes:**
- Connectivity detection: GET /api/health every 10 seconds (when app active)
- Retry logic: exponential backoff (1s, 2s, 4s, 8s) for failed syncs
- Max 100 sessions per batch; split larger queues across multiple requests
- ConflictResolverComponent prompts user on conflicts

### Offline Mode Indicator

**Requirement:** Clear, persistent UI indicator showing offline state.

**Component:** SyncBannerComponent at top of app
- Red/orange banner: "You are offline. Changes will sync when reconnected."
- Green banner: "Syncing…" during active sync
- Hidden when online and no pending sync
- Manual "Sync Now" button for user control

**Implementation Notes:**
- Bind to ConnectivityService.isOnline$ BehaviorSubject
- Toast notification on successful sync completion
- Error toast if sync fails with retry button

### Export Disabled Offline

**Requirement:** Export feature disabled with explanatory tooltip when offline.

**Definition:**
- Export button grayed out
- Tooltip: "Export is not available offline. Please connect to the internet."
- POST /api/export returns 503 Service Unavailable if server unreachable
- Client prevents request submission if offline

**Implementation Notes:**
- ExportComponent checks ConnectivityService.isOnline$ before enabling submit
- Disable export UI in offline mode

---

## Usability (FA §12.3)

### One-Handed Mobile Usability

**Requirement:** App is fully usable with one hand on 5–6 inch smartphone (in portrait or landscape).

**Definition:**
- All primary action buttons reachable from bottom half of screen (thumbable zone)
- Touch targets ≥ 44px × 44px (WCAG 2.1)
- No essential functions require two-handed operation (e.g., pinch-to-zoom)
- Responsive design: 320px width (iPhone SE) minimum supported
- Text readable at default zoom (no <12px fonts)

**Primary Actions by Screen:**
- Home: tap score entry button, tap start game, swipe to session list
- Session Input: tap number pad buttons, tap finish turn button, swipe back
- Stats: tap chart (mobile) or click (desktop), tap date range filter
- Profile: tap settings button, tap logout

**Implementation Notes:**
- Safe area insets respected on iOS notch/Dynamic Island
- Flex layout (not fixed positioning) for responsive reflow
- Bottom sheet or modal dialogs instead of top/center modals
- No horizontal scrolling on primary content areas
- Test on iPhone SE (375px) and Galaxy A50 (360px)

### Primary Actions Within 3 Taps

**Requirement:** All primary user journeys achievable within 3 taps from home screen.

**Journeys:**
1. Start a 501 game: Home → Select Mode → Start (2 taps)
2. Enter score: Home → Current Game → Score (2 taps)
3. View stats: Home → Stats (1 tap)
4. View personal bests: Home → Stats → Personal Bests (2 taps)
5. Export data: Home → Export (1 tap)

**Implementation Notes:**
- Home screen shows quick-start buttons for preferred mode
- Session input accessible from home via floating action button (FAB) or top tab
- Secondary actions (settings, help) accessible within 2–3 additional taps

### WCAG 2.1 AA Compliance

**Requirement:** App meets WCAG 2.1 Level AA accessibility standards.

**Key Criteria:**
- **Contrast:** Text ≥ 4.5:1 (normal), ≥ 3:1 (large) against background
- **Touch Targets:** All interactive elements ≥ 44px × 44px
- **Keyboard Navigation:** All features accessible via keyboard (no mouse required)
- **Screen Reader Support:** Semantic HTML, ARIA labels, alt text for icons
- **Color Blind:** Critical information not conveyed by color alone (e.g., charts use patterns or text labels)
- **Motion:** Animations respect prefers-reduced-motion; no auto-playing videos
- **Focus Indicators:** Visible keyboard focus rings on all interactive elements

**Implementation Notes:**
- Angular: use semantic HTML5 (button, nav, article, section)
- Icons: pair with text labels or aria-label
- Forms: associate labels with inputs via <label for="id">
- Charts: provide data table fallback or detailed legend
- Test with JAWS, NVDA, and VoiceOver
- Axe DevTools accessibility audit in CI/CD (post-MVP)

### Light and Dark Mode

**Requirement:** App automatically switches light/dark mode based on device system preference.

**Definition:**
- Detect prefers-color-scheme CSS media query
- Store user preference in localStorage
- System preference used as default; user can override in Settings
- All colors, contrast ratios, and images adapt to mode

**Color Palettes:**
- Light: white backgrounds, dark text/icons, subtle shadows
- Dark: dark backgrounds (#1e1e1e or #121212), light text (#ffffff), elevated surface colors

**Implementation Notes:**
- ThemeService wraps CSS classes or CSS variables (--primary-color, --bg-color)
- Define SCSS variables for both modes
- Test contrast ratios for both modes (AA compliance)
- Icons use currentColor or themed SVG fills
- Avoid hardcoded colors in component styles; use theme variables

### Desktop Usability (1024px+)

**Requirement:** All stats, export, and settings features accessible within 2 clicks from persistent sidebar.

**Layout (Desktop):**
- Left sidebar: navigation (Home, Sessions, Stats, Export, Profile, Settings)
- Top navbar: user menu, theme toggle, offline indicator
- Main content area: wide layout for charts and tables
- Right sidebar (optional): chart filters or quick stats

**Interactions:**
- Sidebar always visible (not hamburger menu)
- Charts fully interactive: click to drill down, hover for tooltips
- Data tables sortable by column click
- Export dialogs modal or inline

**Implementation Notes:**
- NgClass on components to adjust layout for md, lg, xl breakpoints
- Sidebar sticky (position: sticky) on scroll
- Consider sidebar collapse toggle for ultra-wide screens

### Chart Interactions (Mouse & Keyboard)

**Requirement:** All charts are interactive with mouse and keyboard controls.

**Mouse:**
- Click data point → drill down or show details
- Hover → tooltip with values
- Drag to select range (for trend charts; post-MVP)

**Keyboard:**
- Tab to chart → arrows to navigate data points → Enter to select
- Space/Enter to activate chart controls (zoom, reset, export)
- Escape to close tooltips/details

**Implementation Notes:**
- Chart wrapper components (TrendChartComponent, etc.) expose keyboard handlers
- Chart.js plugins handle interactive events
- ARIA labels for chart title, axes, legend items
- Provide text-based data table as fallback

### Data Export Performance

**Requirement:** Export ≤ 5 seconds for ≤ 1000 sessions; larger exports async with progress indicator.

**Definition:**
- CSV: ≤ 5s for 1000 sessions
- Excel (xlsx): ≤ 5s for 1000 sessions
- JSON: ≤ 5s for 1000 sessions
- Larger exports (>1000 sessions): background job with progress UI (ExportProgressComponent)

**Implementation Notes:**
- ExcelExportWriter: batch rows via DocumentFormat.OpenXml; stream to file
- CsvExportWriter: use TextWriter to stream to file
- JsonExportWriter: serialize to JsonWriter to avoid memory overhead
- Progress tracking: estimate % based on records processed / total
- Show estimated time remaining

---

## Compatibility (FA §12.4)

### Browser Support

**Desktop Browsers:**
- Chrome: latest 2 major versions (e.g., v131–130)
- Firefox: latest 2 major versions
- Safari: latest 2 major versions
- Edge: latest 2 major versions
- IE 11: not supported

**Mobile Browsers:**
- Chrome (Android): latest 2 major versions
- Safari (iOS 15+): latest 2 major versions
- Firefox (Android): latest 2 major versions
- Samsung Internet: latest 1 major version

**Minimum Requirements:**
- JavaScript ES2020 support (no IE 11)
- CSS Grid and Flexbox support
- Service Workers support
- LocalStorage and IndexedDB

**Implementation Notes:**
- Build target: ES2020 in tsconfig.json
- Polyfills for older APIs (post-MVP; unnecessary for stated targets)
- Test on BrowserStack or equivalent (post-MVP)

### PWA Installability

**Requirement:** App installable as standalone PWA on all supported browsers.

**Requirements:**
- HTTPS (enforced at nginx)
- Service worker (generated by @angular/pwa)
- Web app manifest (manifest.webmanifest)
- Responsive design
- Icons (192px and 512px) in manifest
- Display mode: standalone

**Implementation Notes:**
- ng add @angular/pwa auto-generates ngsw-config.json
- manifest.webmanifest includes name, short_name, icons, start_url, display, theme_color
- Custom install prompts (post-MVP; rely on browser install UI for MVP)
- Icon file: favicon.ico + manifest icons in src/assets/icons/

---

## Data & Privacy (FA §12.5)

### Secure Storage

**Requirement:** Passwords hashed; user data encrypted in transit and at rest (production).

**Password Hashing:**
- Algorithm: PBKDF2 + HMAC-SHA512 (ASP.NET Core Identity default)
- Iterations: 1000+ (automatic, non-configurable for MVP)
- Salt: auto-generated per password

**Data in Transit:**
- HTTPS enforced at nginx (self-signed cert for POC)
- All API calls over HTTPS
- No sensitive data in URLs or unencrypted logs

**Data at Rest:**
- PostgreSQL: encryption at storage level (post-MVP; TDE or equivalent)
- LocalStorage: client-side, no encryption (acceptable for non-sensitive data; post-MVP: encrypt via libsodium.js)
- RefreshToken table: hash only (plaintext never stored)

**Implementation Notes:**
- API: enforce HTTPS in Program.cs (UseHttpsRedirection middleware)
- Frontend: detect non-HTTPS and warn user
- Secrets: never log JWT tokens, passwords, or API keys
- Database backups: encrypted (post-MVP)

### GDPR Compliance

**Data Export (FR-D-06):**
- Command: ExportUserDataCommand
- Scope: all user data (sessions, stats, personal bests, profile)
- Formats: CSV, Excel, JSON
- Delivery: download from ExportProgressComponent
- Timing: within 30 days of request
- No cost to user

**Account Deletion (FR-P-02):**
- Command: DeleteAccountCommand
- Action: soft delete (IsDeleted = true) of ApplicationUser and related entities
- Timing: immediate
- Data Recovery: not offered for MVP
- Notification: confirmation email sent

**Consent & Processing:**
- All users must accept Terms & Privacy Policy on register
- Explicit opt-in for leaderboard visibility (LeaderboardOptIn flag)
- Email communications: marketing emails post-MVP (unsubscribe link required)

**Implementation Notes:**
- Privacy policy linked on login and register pages
- Data processing basis stored in database (post-MVP: consent table)
- Audit log of exports and deletions (post-MVP)

### No Third-Party Data Sharing

**Requirement:** No sharing of user data with third parties except as required for authentication.

**Exceptions:**
- Google OAuth (post-MVP): email and display name via OAuth2 flow
- Email provider (Mailhog/SMTP): email address for verification/password reset

**Data Sharing Restrictions:**
- No analytics cookies (post-MVP: opt-in analytics only)
- No tracking pixels
- No third-party ads
- No data brokers
- No session recordings (post-MVP: opt-in session replay for debugging)

**Implementation Notes:**
- Disable Google Analytics by default
- Review all npm dependencies for hidden trackers (npm audit)
- Do not use Facebook Pixel, Mixpanel, or equivalent
- Privacy policy transparent about data sharing

### Leaderboards (Post-MVP) - Privacy

**Requirement:** Leaderboards show display name only; never email address.

**Definition:**
- Public leaderboard shows: rank, display name, metric value (e.g., avg_3dart_501), achievement date
- No email addresses, user IDs, or IP addresses visible
- Users opt-in via LeaderboardOptIn flag
- Regional/friend leaderboards (post-MVP): restrict by geography or friend group

**Implementation Notes:**
- SELECT query joins PersonalBest to ApplicationUser, projects only DisplayName and MetricValue
- Filter WHERE LeaderboardOptIn = true
- Order by Value DESC, AchievedAt DESC

### PII in Logs and Traces

**Requirement:** No personally identifiable information (PII) in trace attributes or log field values.

**PII Definition:**
- Email addresses
- Phone numbers
- Passwords
- API keys or tokens
- Session IDs (JWT)
- Display names (in some contexts)

**Restrictions:**
- Log statements: never include email, password, or full token
- Trace attributes: use userId (GUID), request ID, status code only
- Error messages: generic text; details logged separately
- Database connection strings: never logged

**Implementation Notes:**
- Use structured logging via Serilog
- Destructure objects selectively (e.g., {User.Id} but not {User.Email})
- Implement log filtering middleware to redact sensitive values
- Seq dashboard: restrict access to authorized staff only

---

## Internationalization (FA §12.6)

### Language Support (MVP)

**Requirement:** English (en-GB) for v1.0; architecture supports future languages.

**English (en-GB) Specification:**
- Date format: DD/MM/YYYY (not MM/DD/YYYY)
- Time format: 24-hour (15:30, not 3:30 PM)
- Number format: 45.50 (not 45,50)
- Currency: GBP £ (if needed; post-MVP)

**Implementation Notes:**
- Angular i18n (ngx-translate) configured for future language support
- All user-visible strings in i18n files (src/assets/i18n/en-GB.json)
- No hardcoded strings in components

### Locale-Aware Formatting

**Requirement:** Scores, numbers, and dates format according to locale.

**Date Formatting:**
- Session list: "7 Mar 2025, 14:22"
- Charts: "7 Mar" on X-axis
- Filters: "From 01/01/2025 to 07/03/2025"

**Number Formatting:**
- Averages: "45.50" (2 decimals)
- Darts: "123" (no decimals)
- Percentages: "68.75%"
- Large numbers: "1,234" (comma separator, not 1.234)

**Implementation Notes:**
- Angular DatePipe: {{ date | date: 'dd MMM yyyy, HH:mm' }}
- DecimalPipe: {{ avg | number: '1.2-2' }}
- PercentPipe: {{ accuracy | percent: '1.1-2' }}
- Locale-aware comparison operations (e.g., sort)

### Future Language Support

**Architecture:**
- i18n files: src/assets/i18n/{locale}.json
- Angular i18n or ngx-translate for runtime translation
- Font support: ensure chosen font supports future languages (Latin, Cyrillic, etc.)
- RTL support (post-MVP): if adding Arabic or Hebrew

**Implementation Notes:**
- String keys: descriptive (e.g., session.startedLabel, stats.avgDarts) not screen names
- Translator instructions: context provided for ambiguous terms
- Testing: validate date/number/currency formatting for each locale
- Character encoding: UTF-8 throughout

---

## Implementation Constraints (from TA §1)

### HTTPS Enforcement

**Requirement:** All traffic over HTTPS; enforced at nginx reverse proxy.

**Definition:**
- HTTP requests → 301 redirect to HTTPS
- HSTS header: Strict-Transport-Security: max-age=31536000 (1 year)
- Cert: self-signed for POC, valid CA cert for production

**Implementation Notes:**
- nginx.conf: server listen 443 ssl; redirect 80 to 443
- ASP.NET Core API: UseHttpsRedirection middleware in Program.cs
- SPA: absolute URLs use https:// protocol

### Soft Deletes

**Requirement:** All user-owned data uses soft-delete (IsDeleted flag); no hard deletes for MVP.

**Entities with soft delete:**
- ApplicationUser
- GameSession
- UserStats
- PersonalBest
- ExportJob (optional; cleanup strategy deferred)

**Queries:**
- All reads must filter: WHERE IsDeleted = false
- Deleted records not returned in list endpoints
- Deleted records hidden from stats, charts, exports

**Implementation Notes:**
- EF Core query filter: modelBuilder.Entity<GameSession>().HasQueryFilter(e => !e.IsDeleted)
- No hard delete endpoints; soft delete only
- Audit logging of soft deletes (post-MVP)

### No Data Purging for MVP

**Requirement:** Soft-deleted records remain indefinitely; no purge job for MVP.

**Definition:**
- DeletedAt timestamps recorded but not used to auto-purge
- Database size grows over time; acceptable for POC
- Purge strategy: planned for post-MVP or on-demand admin operation

**Implementation Notes:**
- No scheduled job to hard delete old records
- Database backups include all soft-deleted data
- Consider cleanup strategy for production (e.g., 7-year retention per GDPR)

### Single Environment (POC)

**Requirement:** All services run on private server in single environment (prod-like).

**Definition:**
- No separate dev/staging/prod environments for POC
- All GitHub Actions CI/CD deploys to single server
- Configuration via .env file (Docker Compose)
- Secrets managed via Docker secrets or Key Vault (post-MVP)

**Implementation Notes:**
- docker-compose.yml: single file for all services
- Environment variables: same for all services (no per-environment overrides for MVP)
- Monitoring: single Grafana dashboard
- Backups: daily to external storage (post-MVP)

---

## Quality Gates

All acceptance criteria below must pass for v1.0 release:

- [ ] Lighthouse performance score ≥ 80 (4G, desktop, mobile)
- [ ] WCAG 2.1 AA accessibility audit: 0 critical errors
- [ ] Service worker caching verified (offline functionality tested)
- [ ] All endpoints return ProblemDetails on error (RFC 7807)
- [ ] Soft-delete filtering applied to all queries (no data leakage)
- [ ] HTTPS enforced in production (nginx + .NET)
- [ ] Rate limiting placeholders in code (implementation deferred post-MVP)
- [ ] Unit test coverage ≥ 80% (API, Application layers)
- [ ] Integration tests for sync and export workflows
- [ ] Real device testing: iOS 15+ Safari, Chrome latest 2 versions (desktop & mobile)

---

## Post-MVP Enhancements

These NFRs are deferred beyond v1.0:

1. **Analytics:** opt-in Google Analytics for feature adoption tracking
2. **Performance Optimization:** HTTP/2 server push, aggressive caching, code splitting per route
3. **Security Hardening:** rate limiting, DDoS protection, WAF rules, pen testing
4. **Data Purging:** scheduled job to hard-delete soft-deleted records after 7 years (GDPR compliance)
5. **Database Encryption:** TDE or equivalent for PostgreSQL at rest
6. **Observability:** distributed tracing across microservices (if scaled beyond monolith)
7. **Accessibility:** WCAG 2.1 AAA (post-MVP; AA sufficient for v1.0)
8. **Internationalization:** support for additional languages (de, fr, es, etc.)
9. **RTL Support:** Arabic, Hebrew, and other RTL languages
10. **Mobile App:** native iOS/Android apps (post-MVP; PWA sufficient for v1.0)
