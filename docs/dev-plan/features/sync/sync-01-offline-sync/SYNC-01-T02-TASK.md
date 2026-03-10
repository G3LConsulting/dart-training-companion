# SYNC-01-T02 — Frontend: SyncService + IndexedDB Queue

**Story:** [SYNC-01](../SYNC-01-STORY.md)
**Layer:** Frontend (Angular)
**Status:** Not Started
**Assigned To:** —
**Complexity:** L

---

## What to Build

Create SyncService that manages offline session queue using IndexedDB. Service should detect connectivity via health ping, store completed sessions offline, auto-sync on reconnect, and expose methods for manual sync trigger.

---

## Files to Create/Modify

| Path | Purpose | Status |
|------|---------|--------|
| `src/app/core/sync/sync.service.ts` | Main SyncService with health ping + auto-sync | To Create |
| `src/app/core/sync/indexed-db.service.ts` | IndexedDB queue management | To Create |
| `src/app/core/api/sessions-api.service.ts` | Add syncSessions method | To Modify |

---

## Implementation Notes

### IndexedDBService

**indexed-db.service.ts:**
```typescript
@Injectable({ providedIn: 'root' })
export class IndexedDbService {
  private dbName = 'darts-app';
  private storeName = 'sessions-queue';
  private db: IDBDatabase | null = null;

  constructor(private logger: LoggerService) {
    this.initializeDatabase();
  }

  private initializeDatabase(): void {
    const request = indexedDB.open(this.dbName, 1);

    request.onupgradeneeded = (event) => {
      const db = (event.target as IDBOpenDBRequest).result;
      if (!db.objectStoreNames.contains(this.storeName)) {
        db.createObjectStore(this.storeName, { keyPath: 'id', autoIncrement: true });
      }
    };

    request.onsuccess = () => {
      this.db = request.result;
      this.logger.debug('IndexedDB initialized successfully');
    };

    request.onerror = () => {
      this.logger.error('Failed to initialize IndexedDB', request.error);
    };
  }

  async addSession(session: CreateSessionDto): Promise<void> {
    if (!this.db) {
      await this.waitForDb();
    }

    return new Promise((resolve, reject) => {
      const transaction = this.db!.transaction([this.storeName], 'readwrite');
      const store = transaction.objectStore(this.storeName);
      const request = store.add(session);

      request.onsuccess = () => {
        this.logger.debug('Session queued for sync');
        resolve();
      };

      request.onerror = () => {
        reject(new Error(`Failed to add session to queue: ${request.error}`));
      };
    });
  }

  async getQueuedSessions(): Promise<CreateSessionDto[]> {
    if (!this.db) {
      await this.waitForDb();
    }

    return new Promise((resolve, reject) => {
      const transaction = this.db!.transaction([this.storeName], 'readonly');
      const store = transaction.objectStore(this.storeName);
      const request = store.getAll();

      request.onsuccess = () => {
        resolve(request.result);
      };

      request.onerror = () => {
        reject(new Error(`Failed to read queue: ${request.error}`));
      };
    });
  }

  async clearQueue(): Promise<void> {
    if (!this.db) {
      await this.waitForDb();
    }

    return new Promise((resolve, reject) => {
      const transaction = this.db!.transaction([this.storeName], 'readwrite');
      const store = transaction.objectStore(this.storeName);
      const request = store.clear();

      request.onsuccess = () => {
        this.logger.debug('Queue cleared');
        resolve();
      };

      request.onerror = () => {
        reject(new Error(`Failed to clear queue: ${request.error}`));
      };
    });
  }

  async getQueueCount(): Promise<number> {
    if (!this.db) {
      await this.waitForDb();
    }

    return new Promise((resolve, reject) => {
      const transaction = this.db!.transaction([this.storeName], 'readonly');
      const store = transaction.objectStore(this.storeName);
      const request = store.count();

      request.onsuccess = () => {
        resolve(request.result);
      };

      request.onerror = () => {
        reject(new Error(`Failed to count queue: ${request.error}`));
      };
    });
  }

  private waitForDb(): Promise<void> {
    return new Promise((resolve) => {
      const maxWait = 5000;
      const startTime = Date.now();

      const checkDb = () => {
        if (this.db) {
          resolve();
        } else if (Date.now() - startTime < maxWait) {
          setTimeout(checkDb, 100);
        } else {
          this.logger.error('Timeout waiting for IndexedDB');
          resolve();  // Don't reject, allow app to continue
        }
      };

      checkDb();
    });
  }
}
```

### SyncService

**sync.service.ts:**
```typescript
@Injectable({ providedIn: 'root' })
export class SyncService {
  private isOnline$ = new BehaviorSubject<boolean>(navigator.onLine);
  private isSyncing$ = new BehaviorSubject<boolean>(false);
  private healthCheckInterval = 10000;  // 10 seconds
  private healthCheckTimer: any;
  private lastSyncTime: Date | null = null;

  constructor(
    private indexedDb: IndexedDbService,
    private sessionsApi: SessionsApiService,
    private logger: LoggerService
  ) {
    this.setupConnectivityListeners();
    this.startHealthCheck();
  }

  private setupConnectivityListeners(): void {
    window.addEventListener('online', () => {
      this.logger.info('Online detected');
      this.isOnline$.next(true);
      this.autoSync();
    });

    window.addEventListener('offline', () => {
      this.logger.info('Offline detected');
      this.isOnline$.next(false);
    });
  }

  private startHealthCheck(): void {
    this.healthCheckTimer = setInterval(async () => {
      const isHealthy = await this.checkHealth();
      const wasOnline = this.isOnline$.value;
      this.isOnline$.next(isHealthy);

      // Transition from offline to online: auto-sync
      if (isHealthy && !wasOnline) {
        this.logger.info('Connectivity restored via health check');
        this.autoSync();
      }
    }, this.healthCheckInterval);
  }

  private async checkHealth(): Promise<boolean> {
    try {
      const response = await fetch('/api/health', { method: 'GET' });
      return response.ok;
    } catch (error) {
      this.logger.debug('Health check failed (expected when offline)');
      return false;
    }
  }

  async queueSession(session: CreateSessionDto): Promise<void> {
    try {
      await this.indexedDb.addSession(session);

      if (this.isOnline$.value) {
        // If online, sync immediately
        await this.sync();
      }
    } catch (error) {
      this.logger.error('Failed to queue session', error);
      throw error;
    }
  }

  private autoSync(): void {
    if (this.isSyncing$.value) {
      this.logger.debug('Sync already in progress');
      return;
    }

    this.sync().catch(error => {
      this.logger.error('Auto-sync failed', error);
      // Don't throw; allow app to continue. User can retry manually.
    });
  }

  async sync(): Promise<void> {
    const queueCount = await this.indexedDb.getQueueCount();

    if (queueCount === 0) {
      this.logger.debug('No sessions to sync');
      return;
    }

    this.isSyncing$.next(true);

    try {
      const sessions = await this.indexedDb.getQueuedSessions();
      this.logger.info(`Syncing ${sessions.length} sessions`);

      const result = await this.sessionsApi.syncSessions(sessions).toPromise();

      if (result && result.success) {
        await this.indexedDb.clearQueue();
        this.lastSyncTime = new Date();
        this.logger.info(
          `Synced ${result.sessionsProcessed} sessions. ${result.newPersonalBests.length} new PBs.`
        );
      } else {
        throw new Error(result?.errors?.join(', ') || 'Sync failed');
      }
    } catch (error) {
      this.logger.error('Sync failed', error);
      // Queue remains intact for retry
      throw error;
    } finally {
      this.isSyncing$.next(false);
    }
  }

  getIsOnline$(): Observable<boolean> {
    return this.isOnline$.asObservable();
  }

  getIsSyncing$(): Observable<boolean> {
    return this.isSyncing$.asObservable();
  }

  async manualSync(): Promise<void> {
    return this.sync();
  }

  async getQueueCount(): Promise<number> {
    return this.indexedDb.getQueueCount();
  }

  ngOnDestroy(): void {
    if (this.healthCheckTimer) {
      clearInterval(this.healthCheckTimer);
    }
  }
}
```

### SessionsApiService Update

Add to existing service:

```typescript
syncSessions(sessions: CreateSessionDto[]): Observable<SyncResultDto> {
  const request: SyncSessionsRequestDto = { sessions };
  return this.http.post<SyncResultDto>(`${this.apiUrl}/sync`, request);
}
```

### Integration with GameService

When a game completes, the GameService should queue the session:

```typescript
async completeGame(session: GameSession): Promise<void> {
  // Convert to DTO for queueing
  const sessionDto = this.mapToCreateSessionDto(session);

  try {
    await this.syncService.queueSession(sessionDto);
  } catch (error) {
    this.logger.error('Failed to queue session', error);
    // Show user-friendly error
  }
}
```

---

## Definition of Done

- [ ] IndexedDBService created and tested
- [ ] Database initialization working
- [ ] Session queueing and retrieval working
- [ ] SyncService health check implemented (10s interval)
- [ ] Connectivity detection via health ping
- [ ] Auto-sync on reconnect implemented
- [ ] Manual sync trigger exposed
- [ ] Queue persists across browser sessions
- [ ] Batch size handled (up to 100 sessions)
- [ ] Error handling: sync failures don't clear queue
- [ ] Observables expose sync state to UI
- [ ] SessionsApiService.syncSessions implemented
- [ ] Unit tests verify IndexedDB operations
- [ ] Unit tests verify sync logic and error handling
- [ ] Integration tests confirm end-to-end sync flow
- [ ] No memory leaks (timers/listeners cleaned up)

---

## References

- [IndexedDB API Documentation](https://developer.mozilla.org/en-US/docs/Web/API/IndexedDB_API)
- [Web Offline API](https://developer.mozilla.org/en-US/docs/Web/API/NavigatorOnLine/onLine)
- [Offline-First Patterns](../../shared/ARCHITECTURE.md#offline-first)
- [RxJS BehaviorSubject](https://rxjs.dev/api/index/class/BehaviorSubject)
