# HIST-01-T02 — Frontend: Session History List Component

**Story:** [HIST-01](../HIST-01-STORY.md)
**Layer:** Frontend (Angular)
**Status:** Not Started
**Assigned To:** —
**Complexity:** M

---

## What to Build

Create a reusable Angular component that displays a paginated, filterable list of completed sessions. Users can tap sessions to navigate to the detail view.

---

## Files to Create/Modify

| Path | Purpose | Status |
|------|---------|--------|
| `src/app/features/history/history-list/history-list.component.ts` | Main list component | To Create |
| `src/app/features/history/history-list/history-list.component.html` | Template | To Create |
| `src/app/features/history/history-list/history-list.component.scss` | Styles | To Create |
| `src/app/features/history/history-list/history-list.component.spec.ts` | Unit tests | To Create |
| `src/app/core/api/sessions-api.service.ts` | HTTP service for session API | To Create |

---

## Implementation Notes

### Component Structure

**history-list.component.ts:**
```typescript
@Component({
  selector: 'app-history-list',
  templateUrl: './history-list.component.html',
  styleUrls: ['./history-list.component.scss']
})
export class HistoryListComponent implements OnInit {
  sessions: SessionSummaryDto[] = [];
  selectedGameMode: GameMode | null = null;
  currentPageNumber: number = 1;
  pageSize: number = 20;
  totalPages: number = 0;
  isLoading: boolean = false;
  error: string | null = null;

  gameModes = [
    { label: '501', value: GameMode.Standard501 },
    { label: '301', value: GameMode.Standard301 },
    { label: 'Cricket', value: GameMode.Cricket },
    { label: 'Number Focus', value: GameMode.NumberFocus }
  ];

  constructor(
    private sessionsApi: SessionsApiService,
    private router: Router
  ) {}

  ngOnInit(): void {
    this.loadSessions();
  }

  loadSessions(): void {
    this.isLoading = true;
    this.error = null;
    this.sessionsApi.getSessionHistory(this.currentPageNumber, this.pageSize, this.selectedGameMode)
      .pipe(
        finalize(() => this.isLoading = false)
      )
      .subscribe({
        next: (result) => {
          this.sessions = result.items;
          this.totalPages = result.totalPages;
        },
        error: (err) => {
          this.error = 'Failed to load sessions. Please try again.';
          console.error(err);
        }
      });
  }

  onGameModeChange(mode: GameMode | null): void {
    this.selectedGameMode = mode;
    this.currentPageNumber = 1;  // Reset to first page
    this.loadSessions();
  }

  onSessionTap(sessionId: Guid): void {
    this.router.navigate(['/history', sessionId]);
  }

  onPreviousPage(): void {
    if (this.currentPageNumber > 1) {
      this.currentPageNumber--;
      this.loadSessions();
    }
  }

  onNextPage(): void {
    if (this.currentPageNumber < this.totalPages) {
      this.currentPageNumber++;
      this.loadSessions();
    }
  }

  get canPreviousPage(): boolean {
    return this.currentPageNumber > 1;
  }

  get canNextPage(): boolean {
    return this.currentPageNumber < this.totalPages;
  }
}
```

**history-list.component.html:**
```html
<div class="history-container">
  <h1>Session History</h1>

  <!-- Game Mode Filter -->
  <div class="filter-section">
    <button
      [class.active]="selectedGameMode === null"
      (click)="onGameModeChange(null)">
      All Modes
    </button>
    <button
      *ngFor="let mode of gameModes"
      [class.active]="selectedGameMode === mode.value"
      (click)="onGameModeChange(mode.value)">
      {{ mode.label }}
    </button>
  </div>

  <!-- Loading State -->
  <div *ngIf="isLoading" class="loading">
    <p>Loading sessions...</p>
  </div>

  <!-- Error State -->
  <div *ngIf="error" class="error-message">
    {{ error }}
    <button (click)="loadSessions()">Retry</button>
  </div>

  <!-- Sessions List -->
  <div *ngIf="!isLoading && !error && sessions.length > 0" class="sessions-list">
    <div
      *ngFor="let session of sessions"
      class="session-item"
      (click)="onSessionTap(session.id)">
      <div class="session-header">
        <span class="date">{{ session.createdAt | date: 'MMM d, yyyy' }}</span>
        <span class="mode-badge" [class]="'mode-' + session.gameMode | lowercase">
          {{ session.gameMode }}
        </span>
      </div>
      <div class="session-stat">
        <span class="stat-label">{{ session.keyStatLabel }}:</span>
        <span class="stat-value">{{ session.keyStat }}</span>
      </div>
    </div>
  </div>

  <!-- Empty State -->
  <div *ngIf="!isLoading && !error && sessions.length === 0" class="empty-state">
    <p>No sessions found. Start playing to build your history!</p>
  </div>

  <!-- Pagination -->
  <div *ngIf="totalPages > 1" class="pagination">
    <button
      [disabled]="!canPreviousPage"
      (click)="onPreviousPage()">
      ← Previous
    </button>
    <span class="page-info">
      Page {{ currentPageNumber }} of {{ totalPages }}
    </span>
    <button
      [disabled]="!canNextPage"
      (click)="onNextPage()">
      Next →
    </button>
  </div>
</div>
```

**history-list.component.scss:**
```scss
.history-container {
  padding: 1rem;
  max-width: 600px;
  margin: 0 auto;

  h1 {
    margin-bottom: 1.5rem;
    font-size: 1.5rem;
  }

  .filter-section {
    display: flex;
    gap: 0.5rem;
    margin-bottom: 1.5rem;
    overflow-x: auto;
    padding-bottom: 0.5rem;

    button {
      padding: 0.5rem 1rem;
      border: 1px solid #ccc;
      border-radius: 20px;
      background: white;
      cursor: pointer;
      white-space: nowrap;

      &.active {
        background: #1e88e5;
        color: white;
        border-color: #1e88e5;
      }
    }
  }

  .sessions-list {
    .session-item {
      padding: 1rem;
      margin-bottom: 0.5rem;
      border: 1px solid #e0e0e0;
      border-radius: 8px;
      cursor: pointer;
      transition: background 0.2s;

      &:active {
        background: #f5f5f5;
      }

      .session-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 0.5rem;

        .date {
          font-weight: 500;
        }

        .mode-badge {
          padding: 0.25rem 0.75rem;
          border-radius: 12px;
          font-size: 0.75rem;
          font-weight: 600;

          &.mode-standard501 { background: #e3f2fd; color: #1565c0; }
          &.mode-standard301 { background: #f3e5f5; color: #6a1b9a; }
          &.mode-cricket { background: #e8f5e9; color: #2e7d32; }
          &.mode-numberfocus { background: #fff3e0; color: #e65100; }
        }
      }

      .session-stat {
        font-size: 0.9rem;

        .stat-label {
          color: #666;
          margin-right: 0.5rem;
        }

        .stat-value {
          font-weight: 600;
          color: #333;
        }
      }
    }
  }

  .empty-state {
    text-align: center;
    padding: 2rem 1rem;
    color: #999;
  }

  .loading,
  .error-message {
    padding: 1rem;
    text-align: center;

    button {
      margin-top: 0.5rem;
      padding: 0.5rem 1rem;
      background: #1e88e5;
      color: white;
      border: none;
      border-radius: 4px;
      cursor: pointer;
    }
  }

  .pagination {
    display: flex;
    justify-content: center;
    align-items: center;
    gap: 1rem;
    margin-top: 1.5rem;
    padding-top: 1rem;
    border-top: 1px solid #e0e0e0;

    button {
      padding: 0.5rem 1rem;
      background: #1e88e5;
      color: white;
      border: none;
      border-radius: 4px;
      cursor: pointer;

      &:disabled {
        background: #ccc;
        cursor: not-allowed;
      }
    }

    .page-info {
      font-size: 0.9rem;
      color: #666;
    }
  }
}
```

### SessionsApiService

```typescript
@Injectable({ providedIn: 'root' })
export class SessionsApiService {
  private apiUrl = '/api/sessions';

  constructor(private http: HttpClient) {}

  getSessionHistory(
    pageNumber: number,
    pageSize: number,
    gameMode?: GameMode | null
  ): Observable<PagedResult<SessionSummaryDto>> {
    let params = new HttpParams()
      .set('pageNumber', pageNumber.toString())
      .set('pageSize', pageSize.toString());

    if (gameMode) {
      params = params.set('gameMode', gameMode.toString());
    }

    return this.http.get<PagedResult<SessionSummaryDto>>(this.apiUrl, { params });
  }

  getSessionDetail(sessionId: Guid): Observable<SessionDetailDto> {
    return this.http.get<SessionDetailDto>(`${this.apiUrl}/${sessionId}`);
  }
}
```

---

## Definition of Done

- [ ] Component renders paginated list of sessions with proper styling
- [ ] Game mode filter works correctly (all combinations tested)
- [ ] Pagination buttons work (previous/next disabled appropriately)
- [ ] Tapping a session navigates to detail view
- [ ] Loading state displays while fetching
- [ ] Error state shows with retry button
- [ ] Empty state shown when no sessions exist
- [ ] Responsive design works on mobile (tested on iPhone/Android)
- [ ] Unit tests cover: pagination logic, filtering, error states
- [ ] No console errors or warnings
- [ ] Component correctly calls SessionsApiService

---

## References

- [SessionsApiService API Contracts](../../../shared/API-CONTRACTS.md#sessions)
- [Angular HTTP Client Docs](https://angular.io/guide/http)
- [Angular Router Navigation](https://angular.io/guide/router)
