# TASK: DESK-01-T02 — Frontend: CSS Responsive Breakpoints & Global Styles

**Story:** [DESK-01](../STORY-DESK-01.md)
**Layer:** Frontend
**Status:** Pending
**Agent:** Frontend Team

---

## What to Build

Define global CSS custom properties (variables) and responsive breakpoints that establish the foundation for responsive design across the entire application. This includes:
- SCSS variables for breakpoints (mobile, tablet, desktop)
- CSS custom properties for spacing, typography, and component sizing
- Media query mixins for easy breakpoint usage
- Global typography baseline
- Touch target baseline styles (min 44×44px for interactive elements)
- Responsive grid/flexbox utility classes

All components inherit breakpoint definitions and spacing scale, ensuring consistency and reducing repetition across the codebase.

---

## Files

| File Path | Type | Purpose |
|-----------|------|---------|
| `src/styles.scss` | Global Styles | Breakpoint variables, CSS custom properties, utility classes |
| `src/styles/variables.scss` | SCSS Variables | Breakpoints, spacing scale, color tokens |
| `src/styles/mixins.scss` | SCSS Mixins | Responsive media query helpers |
| `src/styles/typography.scss` | Styles | Font sizes, line heights, responsive type scale |
| `src/styles/accessibility.scss` | Styles | Touch target helpers, focus states, high contrast mode support |

---

## Definition of Done

- [ ] Breakpoint variables defined: mobile (<768px), tablet (768–1023px), desktop (≥1024px)
- [ ] CSS custom properties defined for colors, spacing (8px scale), typography
- [ ] SCSS mixin `@mixin respond-to($breakpoint)` simplifies media queries
- [ ] Global styles applied: base font size 16px, line height 1.5, text color
- [ ] Touch target utility class `.touch-target` or similar ensures ≥44×44px minimum
- [ ] Responsive utility classes: `.flex-mobile`, `.grid-desktop`, etc.
- [ ] Typography responsive: font sizes increase on larger screens
- [ ] All breakpoints tested in browser (Chrome DevTools, Lighthouse mobile/desktop)
- [ ] No hardcoded pixel values in component styles; all use variables

---

## Implementation Notes

**Breakpoint Variables (SCSS):**
```scss
$breakpoint-mobile-max: 767px;
$breakpoint-tablet-min: 768px;
$breakpoint-tablet-max: 1023px;
$breakpoint-desktop-min: 1024px;
```

**Responsive Mixin:**
```scss
@mixin respond-to($breakpoint) {
  @if $breakpoint == 'mobile' {
    @media (max-width: $breakpoint-mobile-max) { @content; }
  } @else if $breakpoint == 'tablet' {
    @media (min-width: $breakpoint-tablet-min) and (max-width: $breakpoint-tablet-max) { @content; }
  } @else if $breakpoint == 'desktop' {
    @media (min-width: $breakpoint-desktop-min) { @content; }
  }
}
```

**Touch Target:**
```scss
.touch-target {
  min-width: 44px;
  min-height: 44px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
}
```

**Spacing Scale (CSS Custom Properties):**
```scss
:root {
  --spacing-xs: 4px;
  --spacing-sm: 8px;
  --spacing-md: 16px;
  --spacing-lg: 24px;
  --spacing-xl: 32px;
  --spacing-2xl: 48px;
}
```

**Typography Scale:**
- Mobile: base 16px
- Tablet: base 16px
- Desktop: base 16px (type scale adjusts via custom properties or component-specific overrides)

**Accessibility:**
- Support `prefers-reduced-motion` for animations
- Support `prefers-color-scheme` for dark mode (defer to PWA-02)
- Support high contrast mode (Windows High Contrast)

---

## References

- [`../../shared/architecture.md`](../../shared/architecture.md) — CSS architecture, variable strategy
- [`../../shared/nfrs.md`](../../shared/nfrs.md) — Accessibility, touch targets, responsive design
- SCSS Documentation: https://sass-lang.com/documentation
- WCAG 2.1 Level AA: Target Size, Motion
