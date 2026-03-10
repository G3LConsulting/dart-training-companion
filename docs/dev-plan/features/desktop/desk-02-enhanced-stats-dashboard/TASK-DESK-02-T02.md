# TASK: DESK-02-T02 — Frontend: Metric Overlay Toggle & Custom Date Picker

**Story:** [DESK-02](../STORY-DESK-02.md)
**Layer:** Frontend
**Status:** Pending
**Agent:** Frontend Team

---

## What to Build

Create two new components to enhance stats dashboard interactivity:

**Metric Overlay Component:**
- Checkbox list of available metrics (3-dart average, checkout %, round average, legs won, etc.)
- User toggles metrics on/off to show/hide data series on primary chart
- Selected metrics persist in component state
- Chart updates reactively when metric selection changes

**Custom Date Range Picker:**
- Preset buttons: Today, This Week, This Month, This Year, All Time
- Custom range input: two date pickers (start date, end date) for arbitrary ranges
- Applied filter updates chart data automatically
- Current selected range displayed in header

---

## Files

| File Path | Type | Purpose |
|-----------|------|---------|
| `src/features/stats/dashboard/metric-overlay/metric-overlay.component.ts` | Angular Component | Metric selection and filter logic |
| `src/features/stats/dashboard/metric-overlay/metric-overlay.component.html` | Template | Checkbox list of metrics |
| `src/features/stats/dashboard/metric-overlay/metric-overlay.component.scss` | Styles | Overlay styling, checkbox layout |
| `src/features/stats/dashboard/date-range-picker/date-range-picker.component.ts` | Angular Component | Date range selection logic |
| `src/features/stats/dashboard/date-range-picker/date-range-picker.component.html` | Template | Preset buttons + custom date inputs |
| `src/features/stats/dashboard/date-range-picker/date-range-picker.component.scss` | Styles | Button styling, date input layout |

---

## Definition of Done

- [ ] MetricOverlayComponent renders checkbox list of available metrics
- [ ] Toggling metric checkbox emits `@Output() metricsChanged: EventEmitter<string[]>`
- [ ] Chart data updates when metrics change (primary chart receives new data series)
- [ ] DateRangePickerComponent renders 5 preset buttons (Today, Week, Month, Year, All Time)
- [ ] Custom date range inputs (startDate, endDate) accept user input
- [ ] Selecting preset or custom range emits `@Output() dateRangeChanged: EventEmitter<DateRange>`
- [ ] Stats dashboard subscribes to both outputs and updates chart/data accordingly
- [ ] Date picker validates that startDate ≤ endDate
- [ ] Custom date range persists in component state
- [ ] Unit tests verify metric selection, date range validation, and event emissions

---

## Implementation Notes

**Metric Overlay:**
```typescript
export class MetricOverlayComponent {
  @Input() availableMetrics: MetricDefinition[] = [];
  @Output() metricsChanged = new EventEmitter<string[]>();

  selectedMetrics: Set<string> = new Set();

  toggleMetric(metricId: string) {
    if (this.selectedMetrics.has(metricId)) {
      this.selectedMetrics.delete(metricId);
    } else {
      this.selectedMetrics.add(metricId);
    }
    this.metricsChanged.emit(Array.from(this.selectedMetrics));
  }
}
```

**Date Range Picker:**
```typescript
export interface DateRange {
  startDate: Date;
  endDate: Date;
}

export class DateRangePickerComponent {
  @Output() dateRangeChanged = new EventEmitter<DateRange>();

  selectedPreset: 'today' | 'week' | 'month' | 'year' | 'all' | 'custom' = 'all';
  customStartDate: Date;
  customEndDate: Date;

  selectPreset(preset: string) {
    const range = this.getPresetRange(preset);
    this.selectedPreset = preset as any;
    this.dateRangeChanged.emit(range);
  }

  applyCustomRange() {
    if (this.validateRange()) {
      this.dateRangeChanged.emit({
        startDate: this.customStartDate,
        endDate: this.customEndDate
      });
    }
  }

  private validateRange(): boolean {
    return this.customStartDate <= this.customEndDate;
  }

  private getPresetRange(preset: string): DateRange {
    const today = new Date();
    // Calculate start/end dates based on preset
  }
}
```

**Stats Dashboard Integration:**
```typescript
export class StatsDashboardComponent {
  @ViewChild(DateRangePickerComponent) dateRangePicker: DateRangePickerComponent;
  @ViewChild(MetricOverlayComponent) metricOverlay: MetricOverlayComponent;

  selectedMetrics: string[] = [];
  dateRange: DateRange;

  onMetricsChanged(metrics: string[]) {
    this.selectedMetrics = metrics;
    this.refreshChartData();
  }

  onDateRangeChanged(range: DateRange) {
    this.dateRange = range;
    this.refreshChartData();
  }

  private refreshChartData() {
    // Fetch data filtered by dateRange and selectedMetrics
  }
}
```

---

## References

- [`../../shared/architecture.md`](../../shared/architecture.md) — Component composition, reactive data patterns
- [`../../shared/nfrs.md`](../../shared/nfrs.md) — Accessibility, keyboard navigation for date inputs
- Angular Reactive Forms: https://angular.io/guide/reactive-forms
- HTML Date Input: https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input/date
