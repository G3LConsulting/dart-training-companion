# HIST-01-T03 — Frontend: Session Detail Component

**Story:** [HIST-01](../HIST-01-STORY.md)
**Layer:** Frontend (Angular)
**Status:** Not Started
**Assigned To:** —
**Complexity:** M

---

## What to Build

Create an Angular component that displays the full details of a single completed session in read-only mode. Shows all turns and darts thrown, with clear visualization of the game progression.

---

## Files to Create/Modify

| Path | Purpose | Status |
|------|---------|--------|
| `src/app/features/history/session-detail/session-detail.component.ts` | Main detail component | To Create |
| `src/app/features/history/session-detail/session-detail.component.html` | Template | To Create |
| `src/app/features/history/session-detail/session-detail.component.scss` | Styles | To Create |
| `src/app/features/history/session-detail/session-detail.component.spec.ts` | Unit tests | To Create |

---

## Implementation Notes

### Component Structure

**session-detail.component.ts:**
```typescript
@Component({
  selector: 'app-session-detail',
  templateUrl: './session-detail.component.html',
  styleUrls: ['./session-detail.component.scss']
})
export class SessionDetailComponent implements OnInit {
  session: SessionDetailDto | null = null;
  isLoading: boolean = false;
  error: string | null = null;

  constructor(
    private route: ActivatedRoute,
    private router: Router,
    private sessionsApi: SessionsApiService
  ) {}

  ngOnInit(): void {
    this.route.params.pipe(
      switchMap(params => {
        const sessionId = params['id'] as string;
        this.isLoading = true;
        this.error = null;
        return this.sessionsApi.getSessionDetail(sessionId);
      }),
      finalize(() => this.isLoading = false)
    ).subscribe({
      next: (session) => {
        this.session = session;
      },
      error: (err) => {
        this.error = 'Failed to load session details. Please try again.';
        console.error(err);
      }
    });
  }

  onBackClick(): void {
    this.router.navigate(['/history']);
  }

  onDeleteClick(): void {
    // Handled by HIST-02
  }

  getDartTotal(dart: DartDto): number {
    return dart.value * (dart.multiplier === 'Double' ? 2 : dart.multiplier === 'Triple' ? 3 : 1);
  }

  getTurnTotal(darts: DartDto[]): number {
    return darts.reduce((sum, dart) => sum + this.getDartTotal(dart), 0);
  }

  formatDart(dart: DartDto): string {
    const multiplierLabel = dart.multiplier === 'Single' ? '' : dart.multiplier === 'Double' ? 'D' : 'T';
    return `${multiplierLabel}${dart.value}`;
  }
}
```

**session-detail.component.html:**
```html
<div class="session-detail-container">
  <!-- Header -->
  <div class="header">
    <button class="back-btn" (click)="onBackClick()">← Back</button>
    <h1>Session Details</h1>
  </div>

  <!-- Loading State -->
  <div *ngIf="isLoading" class="loading">
    <p>Loading session...</p>
  </div>

  <!-- Error State -->
  <div *ngIf="error" class="error-message">
    {{ error }}
    <button (click)="onBackClick()">Back to History</button>
  </div>

  <!-- Session Content -->
  <div *ngIf="!isLoading && !error && session" class="session-content">
    <!-- Session Metadata -->
    <div class="session-meta">
      <div class="meta-item">
        <span class="label">Date</span>
        <span class="value">{{ session.createdAt | date: 'MMM d, yyyy hh:mm a' }}</span>
      </div>
      <div class="meta-item">
        <span class="label">Game Mode</span>
        <span class="value mode-badge" [class]="'mode-' + session.gameMode | lowercase">
          {{ session.gameMode }}
        </span>
      </div>
      <div class="meta-item">
        <span class="label">Total Darts</span>
        <span class="value">{{ session.totalDarts }}</span>
      </div>
    </div>

    <!-- Turns List -->
    <div class="turns-section">
      <h2>Turns</h2>
      <div *ngIf="session.turns.length === 0" class="no-data">
        No turn data available.
      </div>

      <div *ngFor="let turn of session.turns; let i = index" class="turn-card">
        <div class="turn-header">
          <span class="turn-number">Turn {{ turn.turnNumber }}</span>
          <span class="turn-total">
            {{ getTurnTotal(turn.darts) }} points
          </span>
        </div>

        <div class="darts-list">
          <div *ngFor="let dart of turn.darts; let dartIdx = index" class="dart-item">
            <span class="dart-number">Dart {{ dartIdx + 1 }}</span>
            <span class="dart-value">{{ formatDart(dart) }}</span>
            <span class="dart-total">{{ getDartTotal(dart) }}</span>
          </div>
        </div>
      </div>
    </div>

    <!-- Actions -->
    <div class="actions">
      <button class="btn-secondary" (click)="onBackClick()">Back to History</button>
      <button class="btn-danger" (click)="onDeleteClick()">Delete Session</button>
    </div>
  </div>
</div>
```

**session-detail.component.scss:**
```scss
.session-detail-container {
  padding: 1rem;
  max-width: 600px;
  margin: 0 auto;
  min-height: 100vh;

  .header {
    display: flex;
    align-items: center;
    gap: 1rem;
    margin-bottom: 1.5rem;

    .back-btn {
      background: none;
      border: none;
      font-size: 1rem;
      cursor: pointer;
      color: #1e88e5;
      padding: 0;

      &:active {
        opacity: 0.7;
      }
    }

    h1 {
      margin: 0;
      font-size: 1.5rem;
      flex: 1;
    }
  }

  .session-meta {
    background: #f9f9f9;
    border-radius: 8px;
    padding: 1rem;
    margin-bottom: 1.5rem;

    .meta-item {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 0.5rem 0;
      border-bottom: 1px solid #e0e0e0;

      &:last-child {
        border-bottom: none;
      }

      .label {
        color: #666;
        font-size: 0.9rem;
      }

      .value {
        font-weight: 600;
        color: #333;

        &.mode-badge {
          padding: 0.25rem 0.75rem;
          border-radius: 12px;
          font-size: 0.75rem;

          &.mode-standard501 { background: #e3f2fd; color: #1565c0; }
          &.mode-standard301 { background: #f3e5f5; color: #6a1b9a; }
          &.mode-cricket { background: #e8f5e9; color: #2e7d32; }
          &.mode-numberfocus { background: #fff3e0; color: #e65100; }
        }
      }
    }
  }

  .turns-section {
    margin-bottom: 2rem;

    h2 {
      font-size: 1.1rem;
      margin-bottom: 1rem;
      margin-top: 0;
    }

    .no-data {
      text-align: center;
      color: #999;
      padding: 1rem;
    }

    .turn-card {
      border: 1px solid #e0e0e0;
      border-radius: 8px;
      margin-bottom: 1rem;
      overflow: hidden;

      .turn-header {
        background: #f5f5f5;
        padding: 0.75rem 1rem;
        display: flex;
        justify-content: space-between;
        align-items: center;
        border-bottom: 1px solid #e0e0e0;

        .turn-number {
          font-weight: 600;
          color: #333;
        }

        .turn-total {
          background: #e3f2fd;
          color: #1565c0;
          padding: 0.25rem 0.5rem;
          border-radius: 4px;
          font-size: 0.85rem;
          font-weight: 600;
        }
      }

      .darts-list {
        padding: 0.75rem 1rem;

        .dart-item {
          display: grid;
          grid-template-columns: 80px 60px 60px;
          gap: 1rem;
          padding: 0.5rem 0;
          border-bottom: 1px solid #f0f0f0;
          font-size: 0.9rem;

          &:last-child {
            border-bottom: none;
          }

          .dart-number {
            color: #666;
            font-size: 0.8rem;
          }

          .dart-value {
            font-weight: 600;
            color: #333;
            text-align: center;
          }

          .dart-total {
            font-weight: 600;
            color: #2e7d32;
            text-align: right;
          }
        }
      }
    }
  }

  .actions {
    display: flex;
    gap: 1rem;
    margin-bottom: 2rem;

    button {
      flex: 1;
      padding: 0.75rem 1rem;
      border: none;
      border-radius: 4px;
      font-size: 0.9rem;
      font-weight: 600;
      cursor: pointer;
      transition: background 0.2s;

      &:active {
        opacity: 0.8;
      }
    }

    .btn-secondary {
      background: #e0e0e0;
      color: #333;
    }

    .btn-danger {
      background: #f44336;
      color: white;
    }
  }

  .loading,
  .error-message {
    padding: 2rem 1rem;
    text-align: center;

    button {
      margin-top: 1rem;
      padding: 0.5rem 1rem;
      background: #1e88e5;
      color: white;
      border: none;
      border-radius: 4px;
      cursor: pointer;
    }
  }
}
```

### Key Features

1. **Route Parameters:** Component reads session ID from route params and fetches data
2. **Read-Only Display:** All data displayed without edit capability
3. **Dart Formatting:** Converts multiplier enum to display format (D20, T20, etc.)
4. **Turn Totals:** Calculates and displays per-turn point totals
5. **Mobile-Friendly Layout:** Single column, touch-friendly spacing
6. **Back Navigation:** Back button and secondary button both navigate to history list
7. **Delete Placeholder:** Delete button scaffolded for HIST-02 implementation

---

## Definition of Done

- [ ] Component loads session detail from API based on route ID
- [ ] All session metadata displays correctly (date, mode, total darts)
- [ ] All turns and darts render with correct formatting
- [ ] Turn totals calculated and displayed correctly
- [ ] Back navigation works from header button and secondary button
- [ ] Delete button present (implementation in HIST-02)
- [ ] Loading state shows while fetching
- [ ] Error state shows with back button
- [ ] Responsive design works on mobile viewports
- [ ] No horizontal scrolling needed
- [ ] Unit tests cover: data loading, calculations, navigation
- [ ] No console errors or warnings

---

## References

- [Angular Route Parameters](https://angular.io/guide/router#accessing-query-parameters-and-fragments)
- [Angular ActivatedRoute](https://angular.io/api/router/ActivatedRoute)
- [SessionDetailDto Contract](../../../shared/API-CONTRACTS.md#session-detail)
