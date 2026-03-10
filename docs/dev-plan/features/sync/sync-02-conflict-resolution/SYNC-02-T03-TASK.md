# SYNC-02-T03 — Frontend: Conflict Resolution Screen

**Story:** [SYNC-02](../SYNC-02-STORY.md)
**Layer:** Frontend (Angular)
**Status:** Not Started
**Assigned To:** —
**Complexity:** M

---

## What to Build

Create conflict resolution screen showing conflicting sessions side-by-side with their key stats. Users can select which session to keep or choose to keep both.

---

## Files to Create/Modify

| Path | Purpose | Status |
|------|---------|--------|
| `src/app/features/sync/conflict-resolution/conflict-resolution.component.ts` | Main component | To Create |
| `src/app/features/sync/conflict-resolution/conflict-resolution.component.html` | Template | To Create |
| `src/app/features/sync/conflict-resolution/conflict-resolution.component.scss` | Styles | To Create |
| `src/app/core/api/sessions-api.service.ts` | Add conflict methods | To Modify |

---

## Implementation Notes

### Component Structure

```typescript
@Component({
  selector: 'app-conflict-resolution',
  templateUrl: './conflict-resolution.component.html',
  styleUrls: ['./conflict-resolution.component.scss']
})
export class ConflictResolutionComponent implements OnInit {
  conflicts$: Observable<ConflictDto[]>;
  resolving: { [conflictId: string]: boolean } = {};

  constructor(
    private sessionsApi: SessionsApiService,
    private router: Router
  ) {}

  ngOnInit(): void {
    this.conflicts$ = this.sessionsApi.getPendingConflicts();
  }

  async resolveConflict(conflictId: string, resolution: ConflictResolution): Promise<void> {
    this.resolving[conflictId] = true;

    try {
      await this.sessionsApi.resolveConflict(conflictId, resolution).toPromise();
      // Reload conflicts list
      this.conflicts$ = this.sessionsApi.getPendingConflicts();
    } catch (error) {
      console.error('Failed to resolve conflict', error);
    } finally {
      this.resolving[conflictId] = false;
    }
  }

  onAllResolved(): void {
    this.router.navigate(['/stats']);
  }
}
```

### Template

Shows side-by-side comparison with action buttons:

```html
<div class="conflict-resolution-container">
  <h1>Resolve Sync Conflicts</h1>
  <p class="subtitle">Choose which sessions to keep</p>

  <div *ngIf="(conflicts$ | async) as conflicts">
    <div *ngIf="conflicts.length === 0" class="success-message">
      All conflicts resolved! Your stats have been updated.
      <button (click)="onAllResolved()">Continue to Stats</button>
    </div>

    <div *ngFor="let conflict of conflicts" class="conflict-card">
      <div class="conflict-header">
        <span class="mode-badge">{{ conflict.gameMode }}</span>
      </div>

      <div class="sessions-comparison">
        <div class="session-panel">
          <h3>Device A</h3>
          <p class="date">{{ conflict.sessionA.createdAt | date }}</p>
          <p class="stat">Avg: {{ conflict.sessionA.keyStat }}</p>
        </div>

        <div class="action-buttons">
          <button (click)="resolveConflict(conflict.id, 'KeepBoth')">
            Keep Both
          </button>
          <button (click)="resolveConflict(conflict.id, 'KeepA')">
            Keep A Only
          </button>
        </div>

        <div class="session-panel">
          <h3>Device B</h3>
          <p class="date">{{ conflict.sessionB.createdAt | date }}</p>
          <p class="stat">Avg: {{ conflict.sessionB.keyStat }}</p>
        </div>
      </div>

      <div class="additional-actions">
        <button (click)="resolveConflict(conflict.id, 'KeepB')">Keep B Only</button>
        <button (click)="resolveConflict(conflict.id, 'KeepNeither')">Keep Neither</button>
      </div>
    </div>
  </div>
</div>
```

---

## Definition of Done

- [ ] Component loads pending conflicts on init
- [ ] Conflicts displayed side-by-side with key info
- [ ] Action buttons for all resolution options
- [ ] Buttons disabled while resolving
- [ ] Conflicts list refreshes after resolution
- [ ] Success message shown when all resolved
- [ ] Mobile-friendly layout
- [ ] Error handling and user feedback
- [ ] Unit tests verify component logic

---

## References

- [Angular Router Navigation](https://angular.io/guide/router)
- [SYNC-02-T02: Conflict Resolution API](./SYNC-02-T02-TASK.md)
