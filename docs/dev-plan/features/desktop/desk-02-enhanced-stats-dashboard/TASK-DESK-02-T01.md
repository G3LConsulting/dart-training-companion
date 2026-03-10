# TASK: DESK-02-T01 — Frontend: Desktop Stats Layout with Multi-Panel Grid

**Story:** [DESK-02](../STORY-DESK-02.md)
**Layer:** Frontend
**Status:** Pending
**Agent:** Frontend Team

---

## What to Build

Modify the stats dashboard component to render a responsive multi-panel layout on desktop:
- Desktop (≥1024px): KPI header bar + primary chart (2/3 width) + secondary stats panel (1/3 width)
- Tablet (768–1023px): stacked single-column layout with primary chart above secondary
- Mobile (<768px): single-column layout, simplified chart display

The layout uses CSS Grid on desktop to achieve the 2:1 ratio, flexbox fallback for older browsers. Header KPIs display key statistics (e.g., average, checkout %, sessions played). Primary chart shows trend data. Secondary panel shows breakdown by game mode or recent sessions.

---

## Files

| File Path | Type | Purpose |
|-----------|------|---------|
| `src/features/stats/dashboard/stats-dashboard.component.ts` | Angular Component | Main stats dashboard, responsive layout logic |
| `src/features/stats/dashboard/stats-dashboard.component.html` | Template | Multi-panel layout with grid/flexbox |
| `src/features/stats/dashboard/stats-dashboard.component.scss` | Styles | Responsive grid, panel sizing, breakpoints |

---

## Definition of Done

- [ ] Desktop (≥1024px): multi-panel layout renders with correct 2:1 ratio
- [ ] KPI header displays minimum 4 cards: total sessions, avg score, checkout %, best leg
- [ ] Primary chart occupies left 2/3, responsive to content
- [ ] Secondary panel occupies right 1/3, shows game mode breakdown or recent sessions
- [ ] Tablet (768–1023px): single-column stacked layout renders without errors
- [ ] Mobile (<768px): single-column simplified layout renders, no horizontal scroll
- [ ] Layout switches smoothly at breakpoints using `BreakpointObserver`
- [ ] Unit tests verify layout rendering at each breakpoint
- [ ] Accessibility: panel headings use correct heading levels, landmark regions used

---

## Implementation Notes

**Desktop Grid Layout:**
```scss
@include respond-to('desktop') {
  .dashboard-container {
    display: grid;
    grid-template-columns: 2fr 1fr;
    gap: var(--spacing-lg);
    grid-template-areas:
      "header header"
      "primary secondary";
  }

  .kpi-header { grid-area: header; }
  .primary-chart { grid-area: primary; }
  .secondary-panel { grid-area: secondary; }
}
```

**KPI Cards:**
- Display 4 cards in a row on desktop (responsive to viewport width)
- Each card: metric name, value, optional trend indicator (↑/↓)
- Cards use flexbox with equal width on desktop, stack on mobile

**Component Structure:**
```typescript
export class StatsDashboardComponent implements OnInit {
  layout$: Observable<'mobile' | 'tablet' | 'desktop'>;
  kpiData$: Observable<KpiCard[]>;
  primaryChartData$: Observable<ChartData>;
  secondaryPanelData$: Observable<SecondaryStats>;

  ngOnInit() {
    this.layout$ = this.breakpointObserver.observe([
      Breakpoints.Mobile,
      Breakpoints.Tablet,
      Breakpoints.Web
    ]).pipe(
      map(result => this.determineLayout(result))
    );
  }
}
```

**Responsive Media Queries:**
- Desktop: `@media (min-width: 1024px)`
- Tablet: `@media (min-width: 768px) and (max-width: 1023px)`
- Mobile: `@media (max-width: 767px)`

---

## References

- [`../../shared/architecture.md`](../../shared/architecture.md) — Component structure, responsive patterns
- [`../../shared/nfrs.md`](../../shared/nfrs.md) — Accessibility, responsive requirements
- Angular CDK Layout: https://material.angular.io/cdk/layout/overview
- CSS Grid: https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_Grid_Layout
