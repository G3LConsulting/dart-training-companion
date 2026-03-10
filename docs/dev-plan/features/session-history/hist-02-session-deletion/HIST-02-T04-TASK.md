# HIST-02-T04 — Frontend: Delete Confirmation + Recalculation Polling

**Story:** [HIST-02](../HIST-02-STORY.md)
**Layer:** Frontend (Angular)
**Status:** Not Started
**Assigned To:** —
**Complexity:** M

---

## What to Build

Add delete button to session detail component with confirmation modal. After deletion, poll recalculation status endpoint and show "Updating stats..." indicator until complete. Navigate back to history list when done.

---

## Files to Create/Modify

| Path | Purpose | Status |
|------|---------|--------|
| `src/app/features/history/session-detail/session-detail.component.ts` | Add delete button + confirmation | To Modify |
| `src/app/features/history/session-detail/session-detail.component.html` | Add delete button + modal | To Modify |
| `src/app/core/api/sessions-api.service.ts` | Add deleteSession method | To Modify |
| `src/app/core/api/stats-api.service.ts` | Add getRecalculationStatus method | To Create |
| `src/app/shared/components/confirmation-modal/confirmation-modal.component.ts` | Reusable modal component | To Create |

---

## Implementation Notes

### Session Detail Component Updates

**session-detail.component.ts (modifications):**
```typescript
export class SessionDetailComponent implements OnInit, OnDestroy {
  // ... existing properties ...
  isDeleting: boolean = false;
  showDeleteConfirmation: boolean = false;
  isRecalculating: boolean = false;
  recalculationPollInterval: any;

  constructor(
    private route: ActivatedRoute,
    private router: Router,
    private sessionsApi: SessionsApiService,
    private statsApi: StatsApiService,
    private dialog: MatDialog  // or your modal service
  ) {}

  onDeleteClick(): void {
    this.showDeleteConfirmation = true;
  }

  onConfirmDelete(): void {
    this.isDeleting = true;
    this.showDeleteConfirmation = false;

    this.sessionsApi.deleteSession(this.session!.id)
      .pipe(
        finalize(() => this.isDeleting = false)
      )
      .subscribe({
        next: () => {
          // Deletion successful, start polling recalculation status
          this.startRecalculationPolling();
        },
        error: (err) => {
          console.error('Failed to delete session', err);
          // Show error toast/snackbar
        }
      });
  }

  private startRecalculationPolling(): void {
    this.isRecalculating = true;

    // Poll every 500ms until recalculation completes
    this.recalculationPollInterval = setInterval(() => {
      this.statsApi.getRecalculationStatus()
        .subscribe({
          next: (status) => {
            if (!status.isRecalculating) {
              // Recalculation complete!
              this.stopRecalculationPolling();
              // Show success message and navigate back
              setTimeout(() => {
                this.router.navigate(['/history']);
              }, 500);
            }
          },
          error: (err) => {
            console.error('Failed to check recalculation status', err);
            // Continue polling on error
          }
        });
    }, 500);
  }

  private stopRecalculationPolling(): void {
    if (this.recalculationPollInterval) {
      clearInterval(this.recalculationPollInterval);
      this.recalculationPollInterval = null;
    }
    this.isRecalculating = false;
  }

  onCancelDelete(): void {
    this.showDeleteConfirmation = false;
  }

  ngOnDestroy(): void {
    this.stopRecalculationPolling();
  }
}
```

**session-detail.component.html (modifications):**
```html
<!-- Replace existing action buttons with: -->
<div class="actions">
  <button class="btn-secondary" (click)="onBackClick()" [disabled]="isDeleting || isRecalculating">
    Back to History
  </button>
  <button
    class="btn-danger"
    (click)="onDeleteClick()"
    [disabled]="isDeleting || isRecalculating">
    {{ isDeleting ? 'Deleting...' : 'Delete Session' }}
  </button>
</div>

<!-- Delete Confirmation Modal -->
<app-confirmation-modal
  *ngIf="showDeleteConfirmation"
  title="Delete Session?"
  message="Deleting this session will update your statistics. This cannot be undone."
  confirmButtonText="Delete"
  cancelButtonText="Cancel"
  (confirm)="onConfirmDelete()"
  (cancel)="onCancelDelete()">
</app-confirmation-modal>

<!-- Recalculation Indicator -->
<div *ngIf="isRecalculating" class="recalculation-indicator">
  <div class="spinner"></div>
  <p>Updating statistics...</p>
  <p class="subtitle">Your stats are being recalculated. Please wait.</p>
</div>
```

**session-detail.component.scss (add):**
```scss
.recalculation-indicator {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  color: white;
  text-align: center;

  .spinner {
    width: 40px;
    height: 40px;
    border: 4px solid rgba(255, 255, 255, 0.3);
    border-top-color: white;
    border-radius: 50%;
    animation: spin 1s linear infinite;
    margin-bottom: 1rem;
  }

  @keyframes spin {
    to { transform: rotate(360deg); }
  }

  p {
    margin: 0.5rem 0;
    font-size: 1rem;

    &.subtitle {
      font-size: 0.9rem;
      opacity: 0.9;
    }
  }
}

.actions {
  button[disabled] {
    opacity: 0.6;
    cursor: not-allowed;
  }
}
```

### StatsApiService

**stats-api.service.ts (create):**
```typescript
@Injectable({ providedIn: 'root' })
export class StatsApiService {
  private apiUrl = '/api/stats';

  constructor(private http: HttpClient) {}

  getRecalculationStatus(): Observable<RecalculationStatusDto> {
    return this.http.get<RecalculationStatusDto>(`${this.apiUrl}/recalculation-status`);
  }

  getStatsDashboard(range?: string, mode?: GameMode): Observable<StatsDashboardDto> {
    let params = new HttpParams();
    if (range) params = params.set('range', range);
    if (mode) params = params.set('mode', mode.toString());
    return this.http.get<StatsDashboardDto>(this.apiUrl, { params });
  }

  getTrendData(metric: string, range?: string): Observable<TrendDataDto> {
    let params = new HttpParams().set('metric', metric);
    if (range) params = params.set('range', range);
    return this.http.get<TrendDataDto>(`${this.apiUrl}/trends`, { params });
  }
}
```

### Confirmation Modal Component

**confirmation-modal.component.ts:**
```typescript
@Component({
  selector: 'app-confirmation-modal',
  templateUrl: './confirmation-modal.component.html',
  styleUrls: ['./confirmation-modal.component.scss']
})
export class ConfirmationModalComponent {
  @Input() title: string = 'Confirm';
  @Input() message: string = '';
  @Input() confirmButtonText: string = 'Confirm';
  @Input() cancelButtonText: string = 'Cancel';
  @Output() confirm = new EventEmitter<void>();
  @Output() cancel = new EventEmitter<void>();

  onConfirm(): void {
    this.confirm.emit();
  }

  onCancel(): void {
    this.cancel.emit();
  }
}
```

**confirmation-modal.component.html:**
```html
<div class="modal-overlay" (click)="onCancel()">
  <div class="modal-content" (click)="$event.stopPropagation()">
    <h2>{{ title }}</h2>
    <p class="message">{{ message }}</p>
    <div class="modal-actions">
      <button class="btn-secondary" (click)="onCancel()">
        {{ cancelButtonText }}
      </button>
      <button class="btn-danger" (click)="onConfirm()">
        {{ confirmButtonText }}
      </button>
    </div>
  </div>
</div>
```

**confirmation-modal.component.scss:**
```scss
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 999;

  .modal-content {
    background: white;
    border-radius: 8px;
    padding: 1.5rem;
    max-width: 400px;
    width: 90%;
    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);

    h2 {
      margin-top: 0;
      margin-bottom: 1rem;
      font-size: 1.2rem;
    }

    .message {
      color: #666;
      margin-bottom: 1.5rem;
      line-height: 1.5;
    }

    .modal-actions {
      display: flex;
      gap: 1rem;
      justify-content: flex-end;

      button {
        padding: 0.5rem 1rem;
        border: none;
        border-radius: 4px;
        cursor: pointer;
        font-weight: 600;
        transition: background 0.2s;

        &:active {
          opacity: 0.8;
        }

        &.btn-secondary {
          background: #e0e0e0;
          color: #333;
        }

        &.btn-danger {
          background: #f44336;
          color: white;
        }
      }
    }
  }
}
```

### SessionsApiService Update

Add to existing service:

```typescript
deleteSession(sessionId: Guid): Observable<void> {
  return this.http.delete<void>(`${this.apiUrl}/${sessionId}`);
}
```

---

## Definition of Done

- [ ] Delete button added to session detail component
- [ ] Delete confirmation modal shows proper warning message
- [ ] Delete button calls API endpoint
- [ ] On successful deletion, polling starts
- [ ] Polling checks recalculation status every 500ms
- [ ] "Updating stats..." indicator shown during polling
- [ ] Polling stops when recalculation completes
- [ ] User navigated back to history after completion
- [ ] Error handling for delete API failure
- [ ] Error handling for polling failures (continues polling)
- [ ] All buttons disabled during deletion/recalculation
- [ ] Component properly cleans up polling interval on destroy
- [ ] ConfirmationModal is reusable and works on mobile
- [ ] Spinner animation smooth and visible
- [ ] Unit tests cover: delete flow, polling logic, cleanup
- [ ] No console errors or warnings

---

## References

- [Angular HTTP Client Delete](https://angular.io/guide/http#deleting-data)
- [Angular Polling Pattern](../../shared/ARCHITECTURE.md#polling)
- [Material Dialog Alternative](https://material.angular.io/components/dialog/overview)
- [RxJS finalize operator](https://rxjs.dev/api/operators/finalize)
