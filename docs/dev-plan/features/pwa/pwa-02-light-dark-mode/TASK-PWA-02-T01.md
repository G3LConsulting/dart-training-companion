# TASK: PWA-02-T01 — Frontend: CSS Variables for Theming & prefers-color-scheme

**Story:** [PWA-02](../STORY-PWA-02.md)
**Layer:** Frontend
**Status:** Pending
**Agent:** Frontend Team

---

## What to Build

Implement CSS custom properties (variables) and prefers-color-scheme media query for light/dark mode:

**CSS Variables:**
- Colors: primary, secondary, success, warning, danger, info
- Text: text-primary, text-secondary, text-muted
- Background: bg-primary, bg-secondary, bg-tertiary
- Borders: border-color, border-light, border-dark
- Chart colors: for light and dark modes

**prefers-color-scheme:**
- Light mode: default light backgrounds, dark text (light colors)
- Dark mode: dark backgrounds, light text (dark colors)
- System preference respected automatically
- All components use CSS variables, no hardcoded colors

---

## Files

| File Path | Type | Purpose |
|-----------|------|---------|
| `src/styles.scss` | Global Styles | CSS variables, prefers-color-scheme |
| `src/styles/variables.scss` | SCSS Variables | Color tokens, breakpoints |
| `src/styles/dark-mode.scss` | Styles | Dark mode CSS variables (if separate file) |
| All component `.scss` files | Component Styles | Use CSS variables instead of hardcoded colors |

---

## Definition of Done

- [ ] CSS variables defined for colors: primary, secondary, text, background, border
- [ ] prefers-color-scheme: light supported with light backgrounds, dark text
- [ ] prefers-color-scheme: dark supported with dark backgrounds, light text
- [ ] Chart colors adjust for dark mode (readable in both modes)
- [ ] All hardcoded color values replaced with CSS variables in components
- [ ] Transition between light/dark mode is smooth (no flashing)
- [ ] Text contrast meets WCAG 2.1 AA (min 4.5:1) in both modes
- [ ] Button backgrounds visible in both modes
- [ ] Form inputs readable in both modes
- [ ] Links understandable in both modes (not just color-dependent)
- [ ] Charts use contrasting colors in dark mode
- [ ] Icons visible in both modes
- [ ] Unit tests verify CSS variable syntax
- [ ] Manual testing: light mode readable, dark mode readable

---

## Implementation Notes

**Global CSS Variables (src/styles.scss):**
```scss
// Define CSS variables at :root level
:root {
  // Light mode (default)
  --color-primary: #1976d2;
  --color-primary-dark: #1565c0;
  --color-primary-light: #42a5f5;
  --color-secondary: #ff4081;
  --color-success: #4caf50;
  --color-warning: #ff9800;
  --color-danger: #f44336;
  --color-info: #2196f3;

  --text-primary: #212121;
  --text-secondary: #757575;
  --text-muted: #bdbdbd;

  --bg-primary: #ffffff;
  --bg-secondary: #f5f5f5;
  --bg-tertiary: #eeeeee;

  --border-color: #e0e0e0;
  --border-light: #f0f0f0;
  --border-dark: #bdbdbd;

  // Chart colors (light mode)
  --chart-line-primary: #1976d2;
  --chart-line-secondary: #ff4081;
  --chart-grid: #e0e0e0;
  --chart-text: #212121;
}

// Dark mode
@media (prefers-color-scheme: dark) {
  :root {
    --color-primary: #42a5f5;
    --color-primary-dark: #2196f3;
    --color-primary-light: #64b5f6;
    --color-secondary: #ff80ab;

    --text-primary: #e0e0e0;
    --text-secondary: #b0b0b0;
    --text-muted: #757575;

    --bg-primary: #121212;
    --bg-secondary: #1e1e1e;
    --bg-tertiary: #2c2c2c;

    --border-color: #3f3f3f;
    --border-light: #2c2c2c;
    --border-dark: #5f5f5f;

    // Chart colors (dark mode)
    --chart-line-primary: #64b5f6;
    --chart-line-secondary: #ff80ab;
    --chart-grid: #3f3f3f;
    --chart-text: #e0e0e0;
  }
}
```

**Component Styling (example - src/features/stats/dashboard/stats-dashboard.component.scss):**
```scss
.stats-container {
  background-color: var(--bg-primary);
  color: var(--text-primary);
  border: 1px solid var(--border-color);

  .header {
    background-color: var(--bg-secondary);
    border-bottom: 1px solid var(--border-color);
  }

  .card {
    background-color: var(--bg-secondary);
    border: 1px solid var(--border-light);
    color: var(--text-primary);

    .label {
      color: var(--text-secondary);
    }

    .value {
      color: var(--color-primary);
      font-weight: bold;
    }
  }

  .button {
    background-color: var(--color-primary);
    color: white;
    border: none;

    &:hover {
      background-color: var(--color-primary-dark);
    }

    &:focus {
      outline: 2px solid var(--color-primary-light);
      outline-offset: 2px;
    }
  }
}
```

**Chart Component with Dark Mode (src/shared/charts/trend-chart/trend-chart.component.ts):**
```typescript
export class TrendChartComponent implements OnInit {
  @ViewChild('chartCanvas') chartCanvas: ElementRef<HTMLCanvasElement>;
  chart: Chart;

  constructor(private elementRef: ElementRef) {}

  ngOnInit() {
    const isDarkMode = window.matchMedia('(prefers-color-scheme: dark)').matches;
    const chartConfig = this.getChartConfig(isDarkMode);

    const ctx = this.chartCanvas.nativeElement.getContext('2d');
    this.chart = new Chart(ctx, chartConfig);

    // Listen for system color scheme changes
    window.matchMedia('(prefers-color-scheme: dark)').addListener((e) => {
      this.updateChartColors(e.matches);
    });
  }

  private getChartConfig(isDarkMode: boolean) {
    const textColor = isDarkMode ? '#e0e0e0' : '#212121';
    const gridColor = isDarkMode ? '#3f3f3f' : '#e0e0e0';
    const lineColor = isDarkMode ? '#64b5f6' : '#1976d2';

    return {
      type: 'line',
      data: this.chartData,
      options: {
        plugins: {
          legend: {
            labels: {
              color: textColor
            }
          }
        },
        scales: {
          x: {
            ticks: { color: textColor },
            grid: { color: gridColor }
          },
          y: {
            ticks: { color: textColor },
            grid: { color: gridColor }
          }
        }
      }
    };
  }

  private updateChartColors(isDarkMode: boolean) {
    const textColor = isDarkMode ? '#e0e0e0' : '#212121';
    const gridColor = isDarkMode ? '#3f3f3f' : '#e0e0e0';

    this.chart.options.plugins.legend.labels.color = textColor;
    this.chart.options.scales.x.ticks.color = textColor;
    this.chart.options.scales.x.grid.color = gridColor;
    this.chart.options.scales.y.ticks.color = textColor;
    this.chart.options.scales.y.grid.color = gridColor;
    this.chart.update();
  }
}
```

**Color Contrast Verification:**
- Light mode text (#212121) on light background (#ffffff): contrast 16:1 ✓
- Dark mode text (#e0e0e0) on dark background (#121212): contrast 13:1 ✓
- Primary color (#1976d2) on light background: contrast 5.5:1 ✓
- Primary color (#42a5f5) on dark background: contrast 7:1 ✓

**No Manual Mode Toggle (Phase 1):**
- System preference respected automatically
- No UI toggle (reserved for phase 2)
- CSS handles all styling via prefers-color-scheme

---

## References

- [`../../shared/architecture.md`](../../shared/architecture.md) — CSS architecture, theming strategy
- [`../../shared/nfrs.md`](../../shared/nfrs.md) — Color contrast, accessibility
- MDN prefers-color-scheme: https://developer.mozilla.org/en-US/docs/Web/CSS/@media/prefers-color-scheme
- WCAG 2.1 Level AA Color Contrast: https://www.w3.org/WAI/WCAG21/Understanding/contrast-minimum
- CSS Custom Properties: https://developer.mozilla.org/en-US/docs/Web/CSS/--*
