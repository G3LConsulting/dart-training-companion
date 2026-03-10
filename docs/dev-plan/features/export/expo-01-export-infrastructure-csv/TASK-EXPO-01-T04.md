# TASK: EXPO-01-T04 — Frontend: Export Page with Scope Selector, Format Picker, Download Poller

**Story:** [EXPO-01](../STORY-EXPO-01.md)
**Layer:** Frontend
**Status:** Pending
**Agent:** Frontend Team

---

## What to Build

Create export page component with user-friendly export workflow:

**Features:**
- Scope selector: radio buttons for All Data, Game Mode, Date Range, Current View
- Format picker: checkboxes for CSV, Excel, JSON (user can select multiple)
- Submit button triggers export, POST to /api/export
- Status polling: continuously polls GET /api/export/{jobId} every 2 seconds
- Progress display: status (Pending/Processing/Completed/Failed), progress bar
- Download button: appears when export completes, triggers file download
- Error handling: displays error message if export fails
- Offline detection: export buttons disabled with tooltip when offline
- Success message: "Export complete" toast notification

---

## Files

| File Path | Type | Purpose |
|-----------|------|---------|
| `src/features/export/export.component.ts` | Angular Component | Export workflow orchestration |
| `src/features/export/export.component.html` | Template | Form UI, progress display, download button |
| `src/features/export/export.component.scss` | Styles | Form styling, progress bar, responsive layout |
| `src/features/export/services/export.service.ts` | Service | HTTP calls to export API |

---

## Definition of Done

- [ ] Export page renders with scope selector (radio buttons)
- [ ] Scope options: All Data, Game Mode (with filter input), Date Range (date pickers), Current View
- [ ] Format picker displays checkboxes: CSV, Excel, JSON
- [ ] Submit button calls export.service.requestExport()
- [ ] On success, polling starts: GET /api/export/{jobId} every 2 seconds
- [ ] Progress bar updates based on returned percentage (25%, 75%, 100%)
- [ ] Status text updates: Pending → Processing → Completed/Failed
- [ ] Download button enabled when status = Completed
- [ ] Click download triggers GET /api/export/{jobId}/download, saves file
- [ ] If status = Failed, error message displays
- [ ] Submit button disabled offline with tooltip "Internet required for export"
- [ ] Unit tests verify form submission, polling logic, download triggering
- [ ] Error handling tests verify failed export display

---

## Implementation Notes

**ExportService:**
```typescript
export interface ExportRequest {
  format: ExportFormat[];
  scope: ExportScope;
  gameModeFilter?: string;
  startDate?: Date;
  endDate?: Date;
}

export interface ExportJobResponse {
  jobId: string;
  status: string; // Pending, Processing, Completed, Failed
}

export interface ExportStatus {
  jobId: string;
  status: string;
  progressPercentage: number;
  errorMessage?: string;
  createdAt: Date;
  updatedAt: Date;
}

@Injectable()
export class ExportService {
  constructor(private http: HttpClient) {}

  requestExport(request: ExportRequest): Observable<ExportJobResponse> {
    return this.http.post<ExportJobResponse>('/api/export', request);
  }

  getExportStatus(jobId: string): Observable<ExportStatus> {
    return this.http.get<ExportStatus>(`/api/export/${jobId}`);
  }

  downloadExport(jobId: string): Observable<Blob> {
    return this.http.get(`/api/export/${jobId}/download`, { responseType: 'blob' });
  }
}
```

**ExportComponent:**
```typescript
export class ExportComponent implements OnInit, OnDestroy {
  exportForm: FormGroup;
  jobId: string;
  status: ExportStatus;
  isLoading = false;
  isOffline = false;
  pollSubscription: Subscription;

  readonly ExportScope = ExportScope;
  readonly ExportFormat = ExportFormat;

  constructor(
    private fb: FormBuilder,
    private exportService: ExportService,
    private connectivityService: ConnectivityService,
    private toastr: ToastrService
  ) {
    this.exportForm = this.fb.group({
      scope: [ExportScope.All, Validators.required],
      gameModeFilter: [''],
      startDate: [null],
      endDate: [null],
      formats: [[], Validators.required]
    });
  }

  ngOnInit() {
    this.connectivityService.online$.subscribe(online => {
      this.isOffline = !online;
      if (!online) {
        this.exportForm.disable();
      } else {
        this.exportForm.enable();
      }
    });
  }

  ngOnDestroy() {
    if (this.pollSubscription) {
      this.pollSubscription.unsubscribe();
    }
  }

  onSubmit() {
    if (!this.exportForm.valid || this.isOffline) return;

    this.isLoading = true;
    const request = this.buildRequest();

    this.exportService.requestExport(request).subscribe(
      response => {
        this.jobId = response.jobId;
        this.startPolling();
      },
      error => {
        this.isLoading = false;
        this.toastr.error('Failed to start export');
      }
    );
  }

  private startPolling() {
    this.pollSubscription = interval(2000)
      .pipe(
        switchMap(() => this.exportService.getExportStatus(this.jobId)),
        takeUntil(this.pollComplete$)
      )
      .subscribe(
        status => {
          this.status = status;
          if (status.status === 'Completed') {
            this.isLoading = false;
            this.toastr.success('Export complete');
            this.pollSubscription.unsubscribe();
          } else if (status.status === 'Failed') {
            this.isLoading = false;
            this.toastr.error(`Export failed: ${status.errorMessage}`);
            this.pollSubscription.unsubscribe();
          }
        },
        error => {
          this.isLoading = false;
          this.toastr.error('Error checking export status');
          this.pollSubscription.unsubscribe();
        }
      );
  }

  downloadExport() {
    this.exportService.downloadExport(this.jobId).subscribe(
      blob => {
        const fileName = `darts-companion_${new Date().toISOString().split('T')[0]}.csv`;
        const url = window.URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = fileName;
        a.click();
        window.URL.revokeObjectURL(url);
      },
      error => {
        this.toastr.error('Failed to download export');
      }
    );
  }

  private buildRequest(): ExportRequest {
    const form = this.exportForm.value;
    return {
      format: form.formats,
      scope: form.scope,
      gameModeFilter: form.gameModeFilter,
      startDate: form.startDate,
      endDate: form.endDate
    };
  }

  get progressPercentage(): number {
    return this.status?.progressPercentage || 0;
  }

  get isCompleted(): boolean {
    return this.status?.status === 'Completed';
  }

  get isFailed(): boolean {
    return this.status?.status === 'Failed';
  }

  private pollComplete$ = new Subject<void>();
}
```

**HTML Template:**
```html
<div class="export-container">
  <h1>Export Your Data</h1>

  <form [formGroup]="exportForm" (ngSubmit)="onSubmit()">
    <!-- Scope Selector -->
    <fieldset>
      <legend>Export Scope</legend>
      <label>
        <input type="radio" value="all" formControlName="scope" />
        All Data
      </label>
      <label>
        <input type="radio" value="gameMode" formControlName="scope" />
        Game Mode
        <input type="text" placeholder="e.g., X01" formControlName="gameModeFilter"
               [disabled]="exportForm.get('scope').value !== 'gameMode'" />
      </label>
      <label>
        <input type="radio" value="dateRange" formControlName="scope" />
        Date Range
        <input type="date" formControlName="startDate"
               [disabled]="exportForm.get('scope').value !== 'dateRange'" />
        to
        <input type="date" formControlName="endDate"
               [disabled]="exportForm.get('scope').value !== 'dateRange'" />
      </label>
      <label>
        <input type="radio" value="currentView" formControlName="scope" />
        Current View
      </label>
    </fieldset>

    <!-- Format Picker -->
    <fieldset>
      <legend>Export Formats</legend>
      <label>
        <input type="checkbox" value="csv" formControlName="formats" />
        CSV (Spreadsheet)
      </label>
      <label>
        <input type="checkbox" value="excel" formControlName="formats" />
        Excel (.xlsx)
      </label>
      <label>
        <input type="checkbox" value="json" formControlName="formats" />
        JSON (Data)
      </label>
    </fieldset>

    <!-- Submit -->
    <button type="submit" [disabled]="!exportForm.valid || isOffline || isLoading">
      {{ isLoading ? 'Exporting...' : 'Start Export' }}
    </button>
    <span *ngIf="isOffline" class="offline-hint">Internet required for export</span>
  </form>

  <!-- Status Polling -->
  <div *ngIf="status" class="status-section">
    <h2>Export Progress</h2>
    <p>Status: {{ status.status }}</p>
    <div class="progress-bar">
      <div class="progress-fill" [style.width.%]="progressPercentage"></div>
    </div>
    <p>{{ progressPercentage }}%</p>

    <!-- Error Display -->
    <div *ngIf="isFailed" class="error-message">
      {{ status.errorMessage }}
    </div>

    <!-- Download Button -->
    <button *ngIf="isCompleted" (click)="downloadExport()" class="download-btn">
      Download Export
    </button>
  </div>
</div>
```

**SCSS:**
```scss
.export-container {
  max-width: 600px;
  margin: var(--spacing-lg) auto;
  padding: var(--spacing-lg);

  fieldset {
    border: 1px solid var(--border-color);
    border-radius: 6px;
    padding: var(--spacing-md);
    margin-bottom: var(--spacing-lg);

    legend {
      padding: 0 var(--spacing-sm);
      font-weight: bold;
    }

    label {
      display: block;
      margin-bottom: var(--spacing-sm);
      align-items: center;

      input[type="text"],
      input[type="date"] {
        margin-left: var(--spacing-sm);
        padding: 6px 8px;
      }
    }
  }

  .progress-bar {
    width: 100%;
    height: 20px;
    background: var(--bg-tertiary);
    border-radius: 4px;
    overflow: hidden;
    margin: var(--spacing-md) 0;

    .progress-fill {
      height: 100%;
      background: var(--color-green);
      transition: width 0.3s;
    }
  }

  .error-message {
    color: var(--color-red);
    margin: var(--spacing-md) 0;
    padding: var(--spacing-sm);
    background: rgba(255, 0, 0, 0.1);
    border-radius: 4px;
  }

  .offline-hint {
    display: inline-block;
    color: var(--color-orange);
    font-size: 12px;
    margin-left: var(--spacing-sm);
  }
}
```

---

## References

- [`../../shared/architecture.md`](../../shared/architecture.md) — Service composition, HTTP client patterns
- [`../../shared/nfrs.md`](../../shared/nfrs.md) — Offline constraint, polling strategy
- Angular Forms: https://angular.io/guide/reactive-forms
- RxJS interval: https://rxjs.dev/api/index/function/interval
