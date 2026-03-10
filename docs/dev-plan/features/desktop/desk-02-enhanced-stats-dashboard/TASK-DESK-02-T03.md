# TASK: DESK-02-T03 — Frontend: Chart Zoom/Pan Functionality

**Story:** [DESK-02](../STORY-DESK-02.md)
**Layer:** Frontend
**Status:** Pending
**Agent:** Frontend Team

---

## What to Build

Extend the trend chart component to support zoom and pan interactions:
- Zoom via mouse wheel scroll: scroll up to zoom in, scroll down to zoom out
- Pan via click-and-drag: click and hold on chart, drag to pan left/right
- Keyboard support: arrow keys to pan, +/- keys to zoom (when chart focused)
- Reset zoom button to return to original view
- Touch support on mobile: pinch to zoom, two-finger pan (optional, nice-to-have)

Integrates `chartjs-plugin-zoom` library for Chart.js. Smooth animations on zoom/pan transitions.

---

## Files

| File Path | Type | Purpose |
|-----------|------|---------|
| `src/shared/charts/trend-chart/trend-chart.component.ts` | Angular Component | Chart initialization with zoom plugin |
| `src/shared/charts/trend-chart/trend-chart.component.html` | Template | Chart canvas + zoom controls |
| `src/shared/charts/trend-chart/trend-chart.component.scss` | Styles | Chart container, reset button styling |

---

## Definition of Done

- [ ] Chart renders with `chartjs-plugin-zoom` plugin initialized
- [ ] Mouse scroll: scroll up zooms in (max 5x), scroll down zooms out (min 1x original)
- [ ] Click-and-drag pans chart left/right smoothly
- [ ] Reset zoom button appears when zoomed in, returns chart to original view
- [ ] Keyboard navigation: arrow keys pan, +/- keys zoom (when chart has focus)
- [ ] Tab navigation: user can tab to reset button and press Enter to activate
- [ ] Chart interaction doesn't interfere with page scroll
- [ ] Zoom/pan state persists during metric/date filter changes (optional, nice-to-have)
- [ ] Unit tests verify zoom/pan event handling
- [ ] Accessibility: zoom controls are keyboard accessible, focus visible

---

## Implementation Notes

**Chart.js Zoom Plugin Setup:**
```typescript
import * as ChartJsZoomPlugin from 'chartjs-plugin-zoom';

export class TrendChartComponent implements OnInit {
  @ViewChild('chartCanvas') chartCanvas: ElementRef<HTMLCanvasElement>;
  chart: Chart;
  isZoomed = false;

  ngOnInit() {
    Chart.register(ChartJsZoomPlugin);

    const ctx = this.chartCanvas.nativeElement.getContext('2d');
    this.chart = new Chart(ctx, {
      type: 'line',
      data: this.chartData,
      options: {
        plugins: {
          zoom: {
            zoom: {
              wheel: {
                enabled: true,
                speed: 0.1,
                modifierKey: null // No modifier needed
              },
              pinch: {
                enabled: true
              },
              mode: 'x' // Zoom on x-axis only
            },
            pan: {
              enabled: true,
              mode: 'x',
              modifierKey: 'ctrl' // Hold Ctrl to pan
            },
            limits: {
              x: { min: 'original', max: 'original' },
              y: { min: 'original', max: 'original' }
            }
          }
        }
      }
    });
  }

  resetZoom() {
    this.chart.resetZoom();
    this.isZoomed = false;
  }

  onKeyDown(event: KeyboardEvent) {
    if (!this.chart) return;

    switch (event.key) {
      case 'ArrowRight':
        this.panChart(20, 0); // Pan right
        break;
      case 'ArrowLeft':
        this.panChart(-20, 0); // Pan left
        break;
      case '+':
        this.chart.zoom(1.1);
        this.isZoomed = true;
        break;
      case '-':
        this.chart.zoom(0.9);
        this.isZoomed = true;
        break;
      case 'Escape':
        this.resetZoom();
        break;
    }
    event.preventDefault();
  }

  private panChart(dx: number, dy: number) {
    // Implement pan logic if manual control needed
    this.chart.pan({ x: dx, y: dy });
  }
}
```

**HTML Template:**
```html
<div class="chart-container" (keydown)="onKeyDown($event)" tabindex="0">
  <canvas #chartCanvas></canvas>
  <button *ngIf="isZoomed" (click)="resetZoom()" class="reset-zoom-btn">
    Reset Zoom
  </button>
  <p class="chart-hint">Scroll to zoom, Ctrl+drag to pan. Arrow keys to pan.</p>
</div>
```

**SCSS:**
```scss
.chart-container {
  position: relative;
  width: 100%;
  height: 400px;
  border: 1px solid var(--border-color);
  border-radius: 8px;
  overflow: hidden;
  outline: none;

  &:focus {
    border-color: var(--primary-color);
    box-shadow: 0 0 0 3px rgba(var(--primary-color), 0.1);
  }
}

.reset-zoom-btn {
  position: absolute;
  top: var(--spacing-sm);
  right: var(--spacing-sm);
  padding: var(--spacing-sm) var(--spacing-md);
  background: var(--primary-color);
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
  z-index: 10;

  &:hover {
    background: var(--primary-color-dark);
  }

  &:focus {
    outline: 2px solid var(--focus-color);
    outline-offset: 2px;
  }
}

.chart-hint {
  position: absolute;
  bottom: var(--spacing-sm);
  left: var(--spacing-sm);
  font-size: 12px;
  color: var(--text-muted);
  margin: 0;
}
```

**Package.json:**
- Add dependency: `chartjs-plugin-zoom@^2.1.0`

---

## References

- [`../../shared/architecture.md`](../../shared/architecture.md) — Chart.js integration, plugin patterns
- [`../../shared/nfrs.md`](../../shared/nfrs.md) — Keyboard navigation, accessibility
- chartjs-plugin-zoom: https://www.chartjs.org/chartjs-plugin-zoom/latest/
- Chart.js: https://www.chartjs.org/docs/latest/
