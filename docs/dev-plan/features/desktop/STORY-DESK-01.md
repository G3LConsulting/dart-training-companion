# STORY: DESK-01 — Responsive Layout & Desktop Navigation

**Feature:** Desktop Experience
**Phase:** MVP
**Status:** Pending
**Agent:** Frontend Team
**Output:** Responsive shell layout with sidebar (desktop) + bottom nav (mobile), CSS breakpoints, collapsible sidebar
**Notes:** Foundation for all desktop features. Establishes responsive breakpoints and primary navigation patterns.

---

## Context

### Implements
- **FA §11.2** — Responsive layout across device sizes
- **FA §FR-D-01** — Desktop navigation structure

### Acceptance Criteria

- [ ] Below 768px: single-column mobile layout with large touch targets
- [ ] 768–1023px: two-column tablet layout
- [ ] ≥1024px: multi-column dashboard with persistent left sidebar
- [ ] Sidebar displays: Home, Game Modes, Statistics, Profile & Settings
- [ ] Active section highlighted in sidebar with visual indicator
- [ ] Sidebar collapsible to icon-only rail on desktop
- [ ] Mobile shows bottom navigation bar instead of sidebar
- [ ] All touch targets meet WCAG 2.1 AA minimum of 44×44px

---

## Tasks

| Task ID | Title | File Changes | Assigned | Status |
|---------|-------|-------------|----------|--------|
| [DESK-01-T01](./desk-01-responsive-layout/TASK-DESK-01-T01.md) | Frontend: Responsive shell layout with sidebar + bottom nav | `shared/components/sidebar/`, `shared/components/bottom-nav/`, `app.component.ts` | Frontend | Pending |
| [DESK-01-T02](./desk-01-responsive-layout/TASK-DESK-01-T02.md) | Frontend: CSS responsive breakpoints & global styles | `src/styles.scss`, breakpoint definitions | Frontend | Pending |

---

## Dependencies

- **INFRA-01** — Angular project scaffold with @angular/cdk (layout detection)
- **Shared References:** Architecture (Angular component structure), NFRs (usability, accessibility)

---

## Shared References

See [`../../shared/architecture.md`](../../shared/architecture.md) for Angular structure and CDK layout module usage.
See [`../../shared/nfrs.md`](../../shared/nfrs.md) for touch target and accessibility requirements.
