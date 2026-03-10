# TASK: DESK-03-T01 — Frontend: Heat Grid Component with Tooltips & Click Navigation

**Story:** [DESK-03](../STORY-DESK-03.md)
**Layer:** Frontend
**Status:** Pending
**Agent:** Frontend Team

---

## What to Build

Create a responsive heat grid component that displays Number Focus accuracy data for all 21 darts targets:

**Desktop (≥1024px):**
- Grid layout showing all 21 targets in 3 rows × 7 columns
- Each cell color-coded by weighted accuracy (Green/Yellow/Orange/Red)
- Hover tooltip displays: best accuracy %, best weighted accuracy, total sets, last set date
- Click navigates to Number Focus detail page for that number
- Mouse pointer changes to pointer on hover

**Mobile (<768px):**
- Scrollable list sorted by weighted accuracy (worst accuracy first for practice focus)
- Each list item shows target number, weighted accuracy bar, tooltip on tap
- Touch-friendly spacing (≥44px height)

**Empty State:**
- Message: "No Number Focus sessions yet. Start a game to collect data."

---

## Files

| File Path | Type | Purpose |
|-----------|------|---------|
| `src/shared/charts/number-focus-heat-grid/number-focus-heat-grid.component.ts` | Angular Component | Heat grid logic, data binding, click handlers |
| `src/shared/charts/number-focus-heat-grid/number-focus-heat-grid.component.html` | Template | Grid/list layout with tooltips |
| `src/shared/charts/number-focus-heat-grid/number-focus-heat-grid.component.scss` | Styles | Grid layout, color coding, responsive |
| `src/shared/charts/number-focus-heat-grid/number-focus-heat-grid.component.spec.ts` | Tests | Grid rendering, click navigation, color mapping |

---

## Definition of Done

- [ ] Desktop grid renders all 21 targets in 3×7 layout
- [ ] Each cell is color-coded: Green (≥80%), Yellow (50–79%), Orange (25–49%), Red (<25%/no data)
- [ ] Hover tooltip displays all 4 pieces of info: best accuracy, best weighted accuracy, total sets, last date
- [ ] Click on cell emits navigation event or navigates to `/stats/number-focus/{number}`
- [ ] Mobile shows scrollable list sorted by weighted accuracy (worst first)
- [ ] List items are ≥44px tall for touch targets
- [ ] Empty state displays when no data exists
- [ ] Color contrast meets WCAG 2.1 AA (min 4.5:1 for text, 3:1 for graphics)
- [ ] Keyboard navigation: Tab through cells, Enter to navigate to detail
- [ ] Tooltip accessible via keyboard (ArrowUp/Down to navigate, Space to show tooltip)
- [ ] Unit tests verify: grid layout, color mapping, data sorting, empty state

---

## Implementation Notes

**Data Structure:**
```typescript
export interface NumberFocusStats {
  number: number; // 1-20, 25 (bullseye)
  bestAccuracy: number; // percentage 0-100
  bestWeightedAccuracy: number; // percentage 0-100
  totalSets: number;
  lastSetDate: Date;
}
```

**Color Mapping Function:**
```typescript
getAccuracyColor(accuracy: number | null): string {
  if (accuracy === null || accuracy === undefined) return 'var(--color-red)';
  if (accuracy >= 80) return 'var(--color-green)';
  if (accuracy >= 50) return 'var(--color-yellow)';
  if (accuracy >= 25) return 'var(--color-orange)';
  return 'var(--color-red)';
}
```

**Component Structure:**
```typescript
export class NumberFocusHeatGridComponent implements OnInit {
  @Input() stats: NumberFocusStats[] = [];
  @Output() cellClicked = new EventEmitter<number>();

  layout$: Observable<'desktop' | 'mobile'>;
  gridData: NumberFocusStats[];
  listData: NumberFocusStats[]; // sorted by accuracy ascending

  ngOnInit() {
    this.layout$ = this.breakpointObserver.observe([
      `(min-width: 1024px)`,
      `(max-width: 1023px)`
    ]).pipe(
      map(result => result.breakpoints['(min-width: 1024px)'] ? 'desktop' : 'mobile')
    );

    this.gridData = this.stats;
    this.listData = [...this.stats].sort((a, b) => a.bestWeightedAccuracy - b.bestWeightedAccuracy);
  }

  onCellClick(number: number) {
    this.cellClicked.emit(number);
    this.router.navigate(['/stats/number-focus', number]);
  }

  formatDate(date: Date): string {
    return new Intl.DateTimeFormat('en-US', { dateStyle: 'medium' }).format(date);
  }
}
```

**Desktop Grid HTML:**
```html
<div class="heat-grid-container" *ngIf="layout$ | async as layout">
  <div *ngIf="gridData.length === 0" class="empty-state">
    <p>No Number Focus sessions yet. Start a game to collect data.</p>
  </div>

  <div *ngIf="layout === 'desktop' && gridData.length > 0" class="grid-layout">
    <div class="heat-grid">
      <div *ngFor="let stat of gridData"
           class="grid-cell"
           [style.background-color]="getAccuracyColor(stat.bestWeightedAccuracy)"
           (click)="onCellClick(stat.number)"
           [attr.aria-label]="'Target ' + stat.number + ', accuracy ' + stat.bestWeightedAccuracy + '%'"
           tabindex="0"
           (keydown.enter)="onCellClick(stat.number)">
        <span class="number">{{ stat.number }}</span>
        <div class="tooltip" *ngIf="stat.bestWeightedAccuracy !== null">
          <p><strong>Best Accuracy:</strong> {{ stat.bestAccuracy }}%</p>
          <p><strong>Best Weighted:</strong> {{ stat.bestWeightedAccuracy }}%</p>
          <p><strong>Total Sets:</strong> {{ stat.totalSets }}</p>
          <p><strong>Last Set:</strong> {{ formatDate(stat.lastSetDate) }}</p>
        </div>
      </div>
    </div>
  </div>

  <div *ngIf="layout === 'mobile' && listData.length > 0" class="list-layout">
    <div *ngFor="let stat of listData" class="list-item" (click)="onCellClick(stat.number)">
      <span class="number">{{ stat.number }}</span>
      <div class="accuracy-bar">
        <div class="bar-fill" [style.width.%]="stat.bestWeightedAccuracy"></div>
      </div>
      <span class="accuracy-text">{{ stat.bestWeightedAccuracy }}%</span>
    </div>
  </div>
</div>
```

**Desktop Grid SCSS:**
```scss
.heat-grid {
  display: grid;
  grid-template-columns: repeat(7, 1fr);
  gap: var(--spacing-sm);
  padding: var(--spacing-md);
  background: var(--bg-secondary);
  border-radius: 8px;
}

.grid-cell {
  aspect-ratio: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 6px;
  cursor: pointer;
  position: relative;
  transition: transform 0.2s, box-shadow 0.2s;
  border: 1px solid rgba(0, 0, 0, 0.1);

  &:hover {
    transform: scale(1.05);
    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
  }

  &:focus {
    outline: 2px solid var(--focus-color);
    outline-offset: 2px;
  }

  .number {
    font-weight: bold;
    font-size: 18px;
    color: white;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.3);
  }

  .tooltip {
    position: absolute;
    bottom: 100%;
    left: 50%;
    transform: translateX(-50%);
    background: rgba(0, 0, 0, 0.9);
    color: white;
    padding: var(--spacing-sm);
    border-radius: 4px;
    font-size: 12px;
    white-space: nowrap;
    z-index: 10;
    opacity: 0;
    pointer-events: none;
    transition: opacity 0.2s;
    margin-bottom: var(--spacing-sm);
  }

  &:hover .tooltip {
    opacity: 1;
  }
}

@include respond-to('mobile') {
  .heat-grid {
    display: none;
  }
}
```

**Mobile List SCSS:**
```scss
.list-layout {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-sm);
  padding: var(--spacing-md);
}

.list-item {
  display: flex;
  align-items: center;
  gap: var(--spacing-md);
  padding: var(--spacing-md);
  background: var(--bg-secondary);
  border-radius: 6px;
  cursor: pointer;
  min-height: 44px;

  .number {
    font-weight: bold;
    min-width: 40px;
    text-align: center;
  }

  .accuracy-bar {
    flex: 1;
    height: 8px;
    background: var(--bg-tertiary);
    border-radius: 4px;
    overflow: hidden;

    .bar-fill {
      height: 100%;
      background: var(--color-green);
      transition: width 0.3s;
    }
  }

  .accuracy-text {
    min-width: 50px;
    text-align: right;
    font-size: 14px;
  }
}
```

---

## References

- [`../../shared/architecture.md`](../../shared/architecture.md) — Component composition, responsive patterns
- [`../../shared/domain-model.md`](../../shared/domain-model.md) — PersonalBest, UserStats entities
- [`../../shared/nfrs.md`](../../shared/nfrs.md) — Accessibility, color contrast, keyboard navigation
- WCAG 2.1 Level AA Color Contrast: https://www.w3.org/WAI/WCAG21/Understanding/contrast-minimum
