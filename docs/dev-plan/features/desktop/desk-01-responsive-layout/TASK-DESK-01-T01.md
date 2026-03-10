# TASK: DESK-01-T01 — Frontend: Responsive Shell Layout with Sidebar + Bottom Nav

**Story:** [DESK-01](../STORY-DESK-01.md)
**Layer:** Frontend
**Status:** Pending
**Agent:** Frontend Team

---

## What to Build

Create responsive navigation shell that adapts layout based on viewport size:
- Desktop (≥1024px): persistent left sidebar with main content area
- Tablet (768–1023px): collapsible sidebar or compact navigation
- Mobile (<768px): bottom navigation bar, dismiss sidebar if present

The sidebar component displays navigation items (Home, Game Modes, Statistics, Profile & Settings) with active state highlighting. A collapsible button allows sidebar to collapse to icon-only rail on desktop. Bottom nav appears only on mobile devices with touch-friendly spacing.

---

## Files

| File Path | Type | Purpose |
|-----------|------|---------|
| `src/shared/components/sidebar/sidebar.component.ts` | Angular Component | Desktop sidebar nav with collapse toggle |
| `src/shared/components/sidebar/sidebar.component.html` | Template | Sidebar markup with nav items |
| `src/shared/components/sidebar/sidebar.component.scss` | Styles | Sidebar styling, animations, collapse states |
| `src/shared/components/bottom-nav/bottom-nav.component.ts` | Angular Component | Mobile bottom nav bar |
| `src/shared/components/bottom-nav/bottom-nav.component.html` | Template | Bottom nav markup with items |
| `src/shared/components/bottom-nav/bottom-nav.component.scss` | Styles | Bottom nav styling, touch-friendly |
| `src/app/app.component.ts` | Angular Component | Main app shell, layout orchestration |
| `src/app/app.component.html` | Template | Conditional sidebar/bottom-nav rendering based on viewport |
| `src/app/app.component.scss` | Styles | Shell layout grid/flexbox |

---

## Definition of Done

- [ ] Sidebar renders on desktop and tablet with navigation items (Home, Game Modes, Statistics, Profile & Settings)
- [ ] Active nav item is visually highlighted
- [ ] Sidebar collapse button works; collapses to icon-only rail with smooth animation
- [ ] Bottom nav renders only on mobile (<768px) with same nav items
- [ ] Bottom nav items are touch-friendly (≥44px tall)
- [ ] Layout switches at breakpoints without layout shift
- [ ] Sidebar is pushed off-screen or dimmed on mobile until explicitly toggled
- [ ] Responsive unit tests pass (MediaQueryList mock for breakpoint detection)
- [ ] Accessibility: nav landmarks used, active states announced to screen readers

---

## Implementation Notes

**BreakPoint Detection:**
- Use `BreakpointObserver` from `@angular/cdk/layout` to detect viewport changes
- Define breakpoints: `(max-width: 767px)`, `(min-width: 768px, max-width: 1023px)`, `(min-width: 1024px)`
- Listen for changes and update layout state in component

**Sidebar Component:**
- Accept `@Input() navigationItems: NavItem[]`
- Track `@Output() itemSelected: EventEmitter<NavItem>`
- Track internal state: `isCollapsed: boolean`
- CSS class toggles: `sidebar--collapsed` for icon-only mode
- Collapse animation: CSS transition on width and opacity

**Bottom Nav Component:**
- Accept `@Input() navigationItems: NavItem[]`
- Accept `@Output() itemSelected: EventEmitter<NavItem>`
- Use flexbox layout with equal-width items
- No scrolling; items visible without horizontal scroll

**App Shell Integration:**
- `app.component.ts` subscribes to `BreakpointObserver`
- Condition renders: sidebar if desktop/tablet, bottom-nav if mobile
- On mobile, sidebar (if toggled open) appears as overlay or drawer

**Touch Targets:**
- Sidebar items: min 44px height
- Bottom nav items: min 44px tall, equal width
- Sidebar collapse toggle: 48×48px button

---

## References

- [`../../shared/architecture.md`](../../shared/architecture.md) — Angular component structure, layout patterns
- [`../../shared/nfrs.md`](../../shared/nfrs.md) — Touch target sizing (44×44px), accessibility standards
- Angular CDK Layout: https://material.angular.io/cdk/layout/overview
- WCAG 2.1 Level AA: Touch Target Size
