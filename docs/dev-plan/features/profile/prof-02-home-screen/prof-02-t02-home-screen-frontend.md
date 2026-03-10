# PROF-02-T02 — Frontend: Home Screen Component

**Story:** [PROF-02 — Home Screen](story.md)  **Layer:** UI  **Status:** 🔲 Not started  **Agent:** —

---

## What to build

Create HomeComponent that fetches home screen data via GET /api/home and renders four sections: QuickStartPanelComponent (4 game mode cards with icons and labels, clickable to launch game setup), RecentSessionsComponent (horizontal scrollable strip of last 3-5 session cards showing game type, score, date), PersonalBestHighlightsComponent (grid of 4 metric cards showing metric name, value, achievement date), and WeeklySummaryComponent (card showing session count, average, and trend indicator). Implement responsive layout: stacked sections on mobile, two-column grid on desktop (quick-start + highlights in left column, recent sessions + weekly summary in right column). Include loading state and error handling.

---

## Files to create or modify

| Action | Path |
|--------|------|
| Create | `src/DartsCompanion.Web/src/app/features/home/home.component.ts` |
| Create | `src/DartsCompanion.Web/src/app/features/home/home.component.html` |
| Create | `src/DartsCompanion.Web/src/app/features/home/home.component.scss` |
| Create | `src/DartsCompanion.Web/src/app/features/home/quick-start-panel/quick-start-panel.component.ts` |
| Create | `src/DartsCompanion.Web/src/app/features/home/quick-start-panel/quick-start-panel.component.html` |
| Create | `src/DartsCompanion.Web/src/app/features/home/quick-start-panel/quick-start-panel.component.scss` |
| Create | `src/DartsCompanion.Web/src/app/features/home/recent-sessions/recent-sessions.component.ts` |
| Create | `src/DartsCompanion.Web/src/app/features/home/recent-sessions/recent-sessions.component.html` |
| Create | `src/DartsCompanion.Web/src/app/features/home/recent-sessions/recent-sessions.component.scss` |
| Create | `src/DartsCompanion.Web/src/app/features/home/personal-bests/personal-bests.component.ts` |
| Create | `src/DartsCompanion.Web/src/app/features/home/personal-bests/personal-bests.component.html` |
| Create | `src/DartsCompanion.Web/src/app/features/home/personal-bests/personal-bests.component.scss` |
| Create | `src/DartsCompanion.Web/src/app/features/home/weekly-summary/weekly-summary.component.ts` |
| Create | `src/DartsCompanion.Web/src/app/features/home/weekly-summary/weekly-summary.component.html` |
| Create | `src/DartsCompanion.Web/src/app/features/home/weekly-summary/weekly-summary.component.scss` |
| Create | `src/DartsCompanion.Web/src/app/core/services/home.service.ts` |
| Modify | `src/DartsCompanion.Web/src/app/features/home/home-routing.module.ts` |

---

## Definition of done

- [ ] HomeComponent calls HomeService.getHomeData(), displays loading spinner while fetching
- [ ] HomeComponent renders four sections: QuickStartPanel, RecentSessions, PersonalBests, WeeklySummary
- [ ] QuickStartPanelComponent displays 4 cards (501, 301, Cricket, NumberFocus) with game mode icon/image, label, and "Play" button
- [ ] Clicking game mode card navigates to game setup (e.g., /game/setup?mode=501)
- [ ] RecentSessionsComponent displays last 3-5 sessions as compact cards in horizontal scrollable list (horizontal scroll on mobile, grid on desktop)
- [ ] Each recent session card shows: game mode icon, score, average (darts per round), date, duration
- [ ] PersonalBestHighlightsComponent displays 4 metric cards (3 fixed + 1 configurable): metric name, value, and date achieved
- [ ] WeeklySummaryComponent shows: "Sessions this week: X", "Sessions last week: Y", trend indicator (up/down arrow or percentage change), average comparison
- [ ] Responsive layout: mobile = stacked sections, desktop = grid (2 columns with specific card grouping)
- [ ] Loading state: skeleton loaders or spinner while fetching
- [ ] Error state: displays error message with retry button
- [ ] Empty states: "No recent sessions" message if list empty
- [ ] Responsive on mobile, tablet, desktop
- [ ] Accessible: proper heading levels, ARIA labels, keyboard navigation
- [ ] No compilation errors; unit tests pass

---

## Implementation notes

- HomeService: create getHomeData() method that calls GET /api/home
- QuickStartPanelComponent: each card navigates to game setup; could emit event or use Router.navigate()
- RecentSessionsComponent: use horizontal scroll container (CSS scroll-snap or native scrolling); consider swipe gestures for mobile
- Session cards: compact design; consider showing game duration and average darts per round
- PersonalBestHighlightsComponent: grid of 4 cards; configurable 4th slot already applied by backend
- WeeklySummaryComponent: show "This week" vs "Last week" comparison; trend indicator (icon + text like "+5 sessions vs last week")
- Skeleton loaders for better UX during loading
- Error handling: retry button calls getHomeData() again
- Link to [API Contracts](../../shared/api-contracts.md) for response structure
- Responsive grid: use Tailwind CSS media queries or CSS Grid

---

## References

- [Story: PROF-02](story.md)
- [API Contracts](../../shared/api-contracts.md)
- [Domain Model](../../shared/domain-model.md)
- Angular Component: https://angular.io/guide/component-overview
- Responsive Design: https://developer.mozilla.org/en-US/docs/Learn/CSS/CSS_layout/Responsive_Design
