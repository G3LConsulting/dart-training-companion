# PROF-05 — Home Screen

**Feature:** Player Profiles
**Phase:** MVP
**Status:** 🔲 Not started
**Agent:** —
**Output:** —
**Notes:** —

---

## Context

The landing page after login. Shows four sections: quick-start game buttons, recent sessions, personal best highlights (including the configurable 4th slot), and weekly summary card. All sections load offline using cached data.

> Implements: FA §FR-P-06

---

## Acceptance Criteria

- [ ] Four quick-start buttons: 501, 301, Cricket, Number Focus — each navigates directly to game setup
- [ ] Recent sessions section: 3–5 most recent sessions shown with game mode icon, date, top metric
- [ ] Personal best highlights: at least 3 fixed PB metrics + 1 configurable slot (set in PROF-02)
- [ ] Weekly summary card: sessions played, average score, improvement vs prior week (percentage)
- [ ] All sections load offline using cached data from previous session
- [ ] Desktop layout: 2-column grid (quick-start + weekly summary left, recent sessions + PBs right)
- [ ] Mobile layout: stacked single column
- [ ] Loading states for each section when data is fresh-fetching
- [ ] Empty states: placeholder UI when no recent sessions or no stats yet

---

## Technical Implementation Notes

**Angular Home Component:**
- Location: `src/app/features/home/` (standalone component, lazy-loaded)
- Template uses Angular Material Grid or CSS Grid for responsive layout
- Sections:
  1. **Quick Start Buttons** (always present)
     - Four buttons (501, 301, Cricket, Number Focus) with game-mode icons
     - Router link to /game-setup?mode=[MODE]
  2. **Weekly Summary Card**
     - GET /api/stats/weekly
     - Shows: sessions played, total points, average per session, improvement % vs prior week
     - Card styling: accent color, highlighted metric
  3. **Recent Sessions**
     - GET /api/sessions?pageSize=5 (no pagination, just top 5)
     - Card or row per session: mode icon, date, key metric
     - "View History" link to /history
  4. **Personal Bests**
     - GET /api/stats/personal-bests
     - Displays at least 3 fixed metrics: best average, checkout %, highest score
     - Plus 1 configurable slot (key from user profile HomeScreenPbMetricKey)
     - Each PB shows: metric name, value, date achieved, improvement vs baseline

**Data Fetching & Caching:**
- Use HttpClient + tap(data => cache.set(key, data))
- On offline, return cached data from localStorage or service cache
- Loading spinner for fresh data; cached data shows immediately with "cached" badge if stale
- Smart cache: invalidate on specific events (session completed, stats updated)

**Offline Support:**
- Services use takeUntilDestroyed() to clean up subscriptions
- Cache strategy: eager cache on load, serve from cache if offline
- Show connection status at top of home page (gray indicator when offline)

**Weekly Stats Query:**
- GET /api/stats/weekly
  - Handler: GetWeeklyStatsQuery
  - Returns: { sessionsThisWeek, totalPointsThisWeek, averagePerSession, improvementPercentageVsPriorWeek, priorWeekAverage }
  - Calculation: today's date, determine week start (per user's WeekStartDay setting)

**Responsive Layout:**
- Desktop (≥1200px): 2-column grid
  - Left column: Quick Start (full width), Weekly Summary (full width below)
  - Right column: Recent Sessions (full height) above, Personal Bests (full height below)
- Tablet (768px–1199px): 2-column grid, adjust widths
- Mobile (<768px): Single column, stacked order: Quick Start → Weekly Summary → Recent Sessions → Personal Bests

**Styling:**
- Material Design or Tailwind CSS per project setup
- Color-code sections: quick-start blue, recent sessions gray, PBs gold/accent, weekly summary green
- Icons for game modes and metrics
- Consistent padding and spacing

**Empty States:**
- No recent sessions: "Start a game to see your recent matches" + quick-start buttons
- No stats yet: "Complete a game to see your personal bests and weekly summary"
- Both states use placeholder skeletons during first load

**Animations:**
- Card entrance animations (fade-in stagger)
- Number transitions for metric values (angular animations)
- Smooth transitions for responsive layout changes

---

## Dependencies

- PROF-01 — User Registration & Authentication — user must be logged in to view home screen
- PROF-02 — Profile Management & Account Deletion — home screen must read user's HomeScreenPbMetricKey
- STATS-03 — Personal Bests Calculation — personal best data must be available
- STATS-06 — Weekly Summary Calculation — weekly summary metrics must be available
- GAME-04 — Game Session Recording — recent sessions must be stored to display

---

## Shared References

- [Domain Model](../../shared/domain-model.md) — UserStats, GameSession entities
- [Architecture](../../shared/architecture.md) — offline-first caching strategy
- [API Contracts](../../shared/api-contracts.md) — stats endpoints (weekly, personal-bests) and session listing
