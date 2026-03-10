# SYNC-01-T03 — Frontend: Sync Banner + Offline Indicator

**Story:** [SYNC-01](../SYNC-01-STORY.md)
**Layer:** Frontend (Angular)
**Status:** Not Started
**Assigned To:** —
**Complexity:** M

---

## What to Build

Create a reusable sync banner component that displays offline/online status and provides manual sync trigger. Component subscribes to SyncService observables to show current state and queue count.

---

## Files to Create/Modify

| Path | Purpose | Status |
|------|---------|--------|
| `src/app/shared/components/sync-banner/sync-banner.component.ts` | Sync banner component | To Create |
| `src/app/shared/components/sync-banner/sync-banner.component.html` | Banner template | To Create |
| `src/app/shared/components/sync-banner/sync-banner.component.scss` | Banner styles | To Create |
| `src/app/app.component.html` | Include banner at root | To Modify |

---

## Implementation Notes

### Sync Banner Component

**sync-banner.component.ts:**
```typescript
@Component({
  selector: 'app-sync-banner',
  templateUrl: './sync-banner.component.html',
  styleUrls: ['./sync-banner.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class SyncBannerComponent implements OnInit {
  isOnline$: Observable<boolean>;
  isSyncing$: Observable<boolean>;
  queueCount$: Observable<number>;
  showBanner$: Observable<boolean>;

  constructor(
    private syncService: SyncService,
    private logger: LoggerService,
    private cdr: ChangeDetectorRef
  ) {
    this.isOnline$ = this.syncService.getIsOnline$();
    this.isSyncing$ = this.syncService.getIsSyncing$();
    this.queueCount$ = this.createQueueCountObservable();
    this.showBanner$ = this.createShowBannerObservable();
  }

  private createQueueCountObservable(): Observable<number> {
    return combineLatest([
      this.isOnline$,
      this.isSyncing$,
      timer(0, 5000)  // Check queue every 5 seconds when offline
    ]).pipe(
      switchMap(([isOnline]) => {
        if (!isOnline) {
          return from(this.syncService.getQueueCount());
        }
        return of(0);
      }),
      startWith(0),
      shareReplay(1)
    );
  }

  private createShowBannerObservable(): Observable<boolean> {
    return combineLatest([this.isOnline$, this.queueCount$]).pipe(
      map(([isOnline, queueCount]) => !isOnline || queueCount > 0),
      distinctUntilChanged(),
      shareReplay(1)
    );
  }

  async onManualSync(): Promise<void> {
    try {
      await this.syncService.manualSync();
      this.logger.info('Manual sync completed');
    } catch (error) {
      this.logger.error('Manual sync failed', error);
    }
  }

  getBannerMessage$(isOnline: boolean, isSyncing: boolean, queueCount: number): string {
    if (isSyncing) {
      return 'Syncing sessions...';
    }
    if (!isOnline) {
      return queueCount > 0
        ? `Offline • ${queueCount} session${queueCount === 1 ? '' : 's'} waiting to sync`
        : 'You are offline';
    }
    if (queueCount > 0) {
      return `Ready to sync ${queueCount} session${queueCount === 1 ? '' : 's'}`;
    }
    return '';
  }
}
```

**sync-banner.component.html:**
```html
<div *ngIf="showBanner$ | async" class="sync-banner" [class.offline]="(isOnline$ | async) === false">
  <div class="banner-content">
    <div class="banner-status">
      <span class="status-indicator" [class.online]="isOnline$ | async" [class.offline]="!(isOnline$ | async)"></span>
      <span class="status-text">
        {{ getBannerMessage$(isOnline$ | async, isSyncing$ | async, queueCount$ | async) }}
      </span>
    </div>

    <button
      class="sync-button"
      (click)="onManualSync()"
      [disabled]="(isSyncing$ | async) || (isOnline$ | async)">
      <span *ngIf="!(isSyncing$ | async)">Sync Now</span>
      <span *ngIf="isSyncing$ | async">Syncing...</span>
    </button>
  </div>
</div>
```

**sync-banner.component.scss:**
```scss
.sync-banner {
  padding: 0.75rem 1rem;
  background: linear-gradient(135deg, #fff3cd 0%, #ffe69c 100%);
  border-bottom: 2px solid #ffc107;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  z-index: 100;
  position: sticky;
  top: 0;

  &.offline {
    background: linear-gradient(135deg, #f8d7da 0%, #f5c6cb 100%);
    border-bottom-color: #dc3545;
  }

  .banner-content {
    max-width: 1200px;
    margin: 0 auto;
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 1rem;

    @media (max-width: 600px) {
      flex-direction: column;
      align-items: flex-start;
    }
  }

  .banner-status {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    flex: 1;

    .status-indicator {
      width: 8px;
      height: 8px;
      border-radius: 50%;
      animation: pulse 2s infinite;

      &.online {
        background: #28a745;
        animation: pulse-green 2s infinite;
      }

      &.offline {
        background: #dc3545;
        animation: pulse-red 2s infinite;
      }
    }

    .status-text {
      font-size: 0.9rem;
      font-weight: 600;
      color: #333;
    }
  }

  .sync-button {
    padding: 0.5rem 1rem;
    background: #007bff;
    color: white;
    border: none;
    border-radius: 4px;
    font-weight: 600;
    cursor: pointer;
    transition: background 0.2s;
    white-space: nowrap;

    &:hover:not(:disabled) {
      background: #0056b3;
    }

    &:active:not(:disabled) {
      transform: scale(0.98);
    }

    &:disabled {
      background: #6c757d;
      cursor: not-allowed;
      opacity: 0.7;
    }

    @media (max-width: 600px) {
      width: 100%;
    }
  }

  @keyframes pulse-green {
    0%, 100% { opacity: 1; }
    50% { opacity: 0.6; }
  }

  @keyframes pulse-red {
    0%, 100% { opacity: 1; }
    50% { opacity: 0.6; }
  }
}
```

### App Component Integration

**app.component.html (top-level):**
```html
<app-sync-banner></app-sync-banner>

<!-- Rest of app content -->
<main class="app-main">
  <router-outlet></router-outlet>
</main>
```

### Component Lifecycle Notes

- Component uses ChangeDetectionStrategy.OnPush for performance
- Observables are created in constructor and subscribed via async pipe
- Queue count checked periodically when offline (reduces overhead when online)
- Status indicator pulses for visual feedback
- Manual sync button disabled when already syncing or online

---

## Definition of Done

- [ ] SyncBannerComponent created with proper styling
- [ ] Offline indicator displays when navigator.onLine = false
- [ ] Queue count displayed when sessions pending sync
- [ ] Manual sync button triggers SyncService.manualSync()
- [ ] Button disabled while syncing or when online
- [ ] Responsive design works on mobile
- [ ] Banner sticky at top of page
- [ ] Status indicator pulses with visual feedback
- [ ] Messages clear and informative
- [ ] Component properly integrated in app.component
- [ ] ChangeDetectionStrategy.OnPush for performance
- [ ] Unit tests verify component logic
- [ ] No memory leaks (subscriptions cleaned up)
- [ ] Accessible (proper contrast, readable text)

---

## References

- [Angular Observables & Async Pipe](https://angular.io/guide/observables-in-angular)
- [RxJS combineLatest & switchMap](https://rxjs.dev/api)
- [Web Offline Detection](https://developer.mozilla.org/en-US/docs/Web/API/NavigatorOnLine)
