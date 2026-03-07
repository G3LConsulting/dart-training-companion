# DESK-01 — Desktop Navigation & Responsive Layout

**Feature:** Desktop & Export
**Phase:** MVP
**Status:** 🔲 Not started
**Agent:** —
**Output:** —
**Notes:** —

---

## Context
Implements the responsive navigation shell. Desktop (≥1024px) uses a persistent collapsible left sidebar. Mobile uses a bottom navigation bar. The layout adapts seamlessly between breakpoints.
> Implements: FA FR-D-01, TA §4 (Angular app structure), TA NFR §12.3 (desktop ≥1024px)

---

## Acceptance Criteria
- [ ] Desktop layout (≥1024px): persistent left sidebar with items (Home, Game Modes, Stats, Profile & Settings)
- [ ] Sidebar collapsible: icon-only state when collapsed; full label state when expanded
- [ ] Mobile layout (<1024px): bottom navigation bar with same items
- [ ] Layout responsive: smooth transition between desktop/mobile at 1024px breakpoint
- [ ] All primary actions reachable within 3 taps from home screen (NFR)
- [ ] Desktop stats/export features reachable within 2 clicks from sidebar (NFR)
- [ ] "Drills" and "Leaderboards" nav items visible but labelled "Coming soon" (post-MVP placeholder)
- [ ] Active route highlighted in nav (visual indicator)
- [ ] Nav items: Home, Game Modes, Stats, Drills (Coming soon), Leaderboards (Coming soon), Profile & Settings
- [ ] Sidebar toggle: hamburger icon on desktop (when collapsed)
- [ ] Mobile: bottom nav scrollable if more than 5 items

---

## Technical Implementation Notes

**Backend:**
- No backend changes required for navigation shell

**Angular:**
- Root layout component: app.component.ts with responsive navigation shell
- Breakpoint detection: BreakpointObserver from Angular CDK
- Breakpoint: 1024px (using theme breakpoint from Material Design)
- Observable: layout$ = breakpointObserver.observe('(min-width: 1024px)')
- State management: BehaviorSubject for sidebar expanded/collapsed state (toggleSidebar action)
- Sidebar component: features/shared/layout/sidebar/ (standalone)
  - @Input() isExpanded: bool
  - @Output() toggleSidebar: EventEmitter<void>
  - Template: nav items with routerLink directives; active route highlighted via routerLinkActive
  - Icons: Material Icons for consistency
  - Items: Home, Game Modes, Stats, Drills (disabled), Leaderboards (disabled)
  - Disabled items: opacity 0.5, cursor: not-allowed, tooltip "Coming soon"
  - Collapsed state: only icons visible; labels hidden
- Bottom nav component: features/shared/layout/bottom-nav/ (standalone)
  - Same items as sidebar
  - Material BottomAppBar or custom flex layout
  - Icons + labels (always visible, no collapse)
  - Active item highlighted with background color
- Main content: router-outlet resizes based on layout
- CSS Grid layout: desktop = sidebar (variable width) + main content; mobile = full width + bottom nav
- Responsive helper: .desktop-only, .mobile-only classes for conditional rendering
- Sidebar toggle button: desktop only, positioned in top app bar

---

## Dependencies
- Depends on PROF-01 (profile/settings route)
- Depends on GAME-01 (game modes route)
- Depends on STATS-01 (stats route)
- Requires Angular CDK BreakpointObserver
- Requires Angular Material (optional, for consistent theming)

---

## Shared References
- [Domain Model](../../shared/domain-model.md) — Route definitions, nav structure
- [Architecture](../../shared/architecture.md) — Component architecture, layout patterns, responsive design
- [API Contracts](../../shared/api-contracts.md) — N/A (shell component)
- [NFRs](../../shared/non-functional-requirements.md) — §12.3 (desktop ≥1024px), §12.1 (responsive), navigation accessible within 3 taps/clicks
