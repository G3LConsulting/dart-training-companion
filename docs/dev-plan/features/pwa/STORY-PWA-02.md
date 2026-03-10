# STORY: PWA-02 — Light & Dark Mode

**Feature:** PWA & Offline Support
**Phase:** MVP
**Status:** Pending
**Agent:** Frontend Team
**Output:** CSS custom properties for theming, prefers-color-scheme media query support, dark mode styles
**Notes:** Follows device system preference. Charts, components readable in both modes.

---

## Context

### Implements
- **FA §12.3** — Light and dark mode support

### Acceptance Criteria

- [ ] App follows device system preference for light/dark mode (prefers-color-scheme)
- [ ] All screens readable and usable in both light and dark modes
- [ ] Charts render correctly in both modes (contrast ≥4.5:1, colors visible)
- [ ] User can manually override system preference (optional, nice-to-have for phase 2)
- [ ] Dark mode toggle (if implemented) persists in localStorage
- [ ] Transition between modes is smooth (no flashing)

---

## Tasks

| Task ID | Title | File Changes | Assigned | Status |
|---------|-------|-------------|----------|--------|
| [PWA-02-T01](./pwa-02-light-dark-mode/TASK-PWA-02-T01.md) | Frontend: CSS variables for theming & prefers-color-scheme | `src/styles.scss`, component stylesheets | Frontend | Pending |
| [PWA-02-T02](./pwa-02-light-dark-mode/TASK-PWA-02-T02.md) | Tests: Visual regression for light/dark mode | Manual or Playwright visual tests | QA/Frontend | Pending |

---

## Dependencies

- **DESK-01** — Layout and global styles established
- **Shared References:** NFRs (usability, accessibility, color contrast)

---

## Shared References

See [`../../shared/architecture.md`](../../shared/architecture.md) for CSS architecture and theming patterns.
See [`../../shared/nfrs.md`](../../shared/nfrs.md) for color contrast and accessibility requirements.
