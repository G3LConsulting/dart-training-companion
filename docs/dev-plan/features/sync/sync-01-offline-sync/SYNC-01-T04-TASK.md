# SYNC-01-T04 — Tests: Sync Service + API Tests

**Story:** [SYNC-01](../SYNC-01-STORY.md)
**Layer:** Backend/Frontend
**Status:** Not Started
**Assigned To:** —
**Complexity:** M

---

## What to Build

Comprehensive tests for sync service (offline queue, health check, auto-sync) and API endpoint (bulk session upload, atomicity, validation).

---

## Files to Create/Modify

| Path | Purpose | Status |
|------|---------|--------|
| `UnitTests/Sessions/SyncSessionsCommandHandlerTests.cs` | Unit tests for sync command | To Create |
| `IntegrationTests/Sessions/SyncApiTests.cs` | Integration tests for sync endpoint | To Create |
| `src/app/core/sync/sync.service.spec.ts` | Angular unit tests for SyncService | To Create |
| `src/app/core/sync/indexed-db.service.spec.ts` | Angular unit tests for IndexedDbService | To Create |

---

## Implementation Notes

### Backend: SyncSessionsCommandHandler Tests

```csharp
public class SyncSessionsCommandHandlerTests
{
    private readonly Mock<IApplicationDbContext> _mockDbContext;
    private readonly SyncSessionsCommandHandler _handler;

    public SyncSessionsCommandHandlerTests()
    {
        _mockDbContext = new Mock<IApplicationDbContext>();
        _handler = new SyncSessionsCommandHandler(_mockDbContext.Object, new Mock<ILogger<SyncSessionsCommandHandler>>().Object);
    }

    [Fact]
    public async Task Handle_WithValidSessions_SavesAllAtomically()
    {
        // Arrange
        var userId = Guid.NewGuid();
        var command = new SyncSessionsCommand
        {
            UserId = userId,
            Sessions = new List<CreateSessionDto>
            {
                CreateValidSessionDto(GameMode.Standard501),
                CreateValidSessionDto(GameMode.Cricket)
            }
        };

        _mockDbContext.Setup(x => x.Sessions)
            .Returns(new List<GameSession>().AsQueryable().BuildMockDbSet().Object);
        _mockDbContext.Setup(x => x.SaveChangesAsync(It.IsAny<CancellationToken>()))
            .ReturnsAsync(2);

        // Act
        var result = await _handler.Handle(command, CancellationToken.None);

        // Assert
        Assert.Equal(2, result.SessionsProcessed);
        Assert.True(result.Success);
        _mockDbContext.Verify(x => x.Sessions.AddRangeAsync(It.IsAny<IEnumerable<GameSession>>(), It.IsAny<CancellationToken>()), Times.Once);
    }

    [Fact]
    public async Task Handle_WithEmptySessionList_ReturnsEmptyResult()
    {
        // Arrange
        var command = new SyncSessionsCommand
        {
            UserId = Guid.NewGuid(),
            Sessions = new List<CreateSessionDto>()
        };

        // Act
        var result = await _handler.Handle(command, CancellationToken.None);

        // Assert
        Assert.Equal(0, result.SessionsProcessed);
        Assert.True(result.Success);
    }

    [Fact]
    public async Task Handle_WithInvalidDartValue_ThrowsValidationException()
    {
        // Arrange
        var command = new SyncSessionsCommand
        {
            UserId = Guid.NewGuid(),
            Sessions = new List<CreateSessionDto>
            {
                new CreateSessionDto
                {
                    GameMode = GameMode.Standard501,
                    Turns = new List<TurnDto>
                    {
                        new TurnDto
                        {
                            TurnNumber = 1,
                            DartEntries = new List<DartEntryDto>
                            {
                                new DartEntryDto { Value = 50, Multiplier = Multiplier.Single }  // Invalid
                            }
                        }
                    }
                }
            }
        };

        // Act & Assert
        await Assert.ThrowsAsync<ValidationException>(() => _handler.Handle(command, CancellationToken.None));
    }

    [Fact]
    public async Task Handle_WithTooManyDarts_ThrowsValidationException()
    {
        // Arrange
        var command = new SyncSessionsCommand
        {
            UserId = Guid.NewGuid(),
            Sessions = new List<CreateSessionDto>
            {
                new CreateSessionDto
                {
                    GameMode = GameMode.Standard501,
                    Turns = new List<TurnDto>
                    {
                        new TurnDto
                        {
                            TurnNumber = 1,
                            DartEntries = new List<DartEntryDto>
                            {
                                new DartEntryDto { Value = 20, Multiplier = Multiplier.Single },
                                new DartEntryDto { Value = 20, Multiplier = Multiplier.Single },
                                new DartEntryDto { Value = 20, Multiplier = Multiplier.Single },
                                new DartEntryDto { Value = 20, Multiplier = Multiplier.Single }  // 4 darts - invalid
                            }
                        }
                    }
                }
            }
        };

        // Act & Assert
        await Assert.ThrowsAsync<ValidationException>(() => _handler.Handle(command, CancellationToken.None));
    }

    [Fact]
    public async Task Handle_WithPersonalBestSessions_DetectsNewPBs()
    {
        // Arrange
        var userId = Guid.NewGuid();
        var existingPBs = new List<PersonalBest>();  // No existing PBs

        var command = new SyncSessionsCommand
        {
            UserId = userId,
            Sessions = new List<CreateSessionDto>
            {
                CreateValidSessionDto(GameMode.Standard501)
            }
        };

        _mockDbContext.Setup(x => x.Sessions)
            .Returns(new List<GameSession>().AsQueryable().BuildMockDbSet().Object);
        _mockDbContext.Setup(x => x.PersonalBests)
            .Returns(existingPBs.AsQueryable().BuildMockDbSet().Object);

        // Act
        var result = await _handler.Handle(command, CancellationToken.None);

        // Assert
        Assert.Equal(1, result.SessionsProcessed);
        Assert.Single(result.NewPersonalBests);  // Should detect first session as new PB
    }

    [Fact]
    public async Task Handle_WithBatchExceedingLimit_ThrowsValidationException()
    {
        // Arrange
        var command = new SyncSessionsCommand
        {
            UserId = Guid.NewGuid(),
            Sessions = Enumerable.Range(0, 101)
                .Select(_ => CreateValidSessionDto(GameMode.Standard501))
                .ToList()
        };

        // Act & Assert
        await Assert.ThrowsAsync<ValidationException>(() => _handler.Handle(command, CancellationToken.None));
    }

    private CreateSessionDto CreateValidSessionDto(GameMode mode)
    {
        return new CreateSessionDto
        {
            GameMode = mode,
            Turns = new List<TurnDto>
            {
                new TurnDto
                {
                    TurnNumber = 1,
                    DartEntries = new List<DartEntryDto>
                    {
                        new DartEntryDto { Value = 20, Multiplier = Multiplier.Triple },
                        new DartEntryDto { Value = 20, Multiplier = Multiplier.Double },
                        new DartEntryDto { Value = 19, Multiplier = Multiplier.Single }
                    }
                }
            }
        };
    }
}
```

### Backend: Integration Tests

```csharp
public class SyncApiTests : IAsyncLifetime
{
    private readonly WebApplicationFactory<Program> _factory;
    private HttpClient _client;
    private readonly TestAuthenticator _authenticator;

    public async Task InitializeAsync()
    {
        await _authenticator.AuthenticateAsync(_client);
    }

    public async Task DisposeAsync()
    {
        _client.Dispose();
        _factory.Dispose();
    }

    [Fact]
    public async Task SyncSessions_WithValidSessions_Returns200WithResults()
    {
        // Arrange
        var request = new SyncSessionsRequestDto
        {
            Sessions = new List<CreateSessionDto>
            {
                CreateValidSessionDto(GameMode.Standard501),
                CreateValidSessionDto(GameMode.Cricket)
            }
        };

        // Act
        var response = await _client.PostAsJsonAsync("/api/sessions/sync", request);

        // Assert
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        var content = await response.Content.ReadAsAsync<SyncResultDto>();
        Assert.Equal(2, content.SessionsProcessed);
        Assert.True(content.Success);
    }

    [Fact]
    public async Task SyncSessions_WithNoSessions_Returns200WithZeroProcessed()
    {
        // Arrange
        var request = new SyncSessionsRequestDto { Sessions = new List<CreateSessionDto>() };

        // Act
        var response = await _client.PostAsJsonAsync("/api/sessions/sync", request);

        // Assert
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        var content = await response.Content.ReadAsAsync<SyncResultDto>();
        Assert.Equal(0, content.SessionsProcessed);
    }

    [Fact]
    public async Task SyncSessions_WithoutAuthentication_Returns401()
    {
        // Arrange
        var unauthenticatedClient = _factory.CreateClient();
        var request = new SyncSessionsRequestDto
        {
            Sessions = new List<CreateSessionDto> { CreateValidSessionDto(GameMode.Standard501) }
        };

        // Act
        var response = await unauthenticatedClient.PostAsJsonAsync("/api/sessions/sync", request);

        // Assert
        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }

    [Fact]
    public async Task SyncSessions_WithInvalidData_Returns400BadRequest()
    {
        // Arrange
        var request = new SyncSessionsRequestDto
        {
            Sessions = new List<CreateSessionDto>
            {
                new CreateSessionDto
                {
                    GameMode = GameMode.Standard501,
                    Turns = new List<TurnDto>()  // No turns - invalid
                }
            }
        };

        // Act
        var response = await _client.PostAsJsonAsync("/api/sessions/sync", request);

        // Assert
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Fact]
    public async Task SyncSessions_PersistsSessions()
    {
        // Arrange
        var userId = _authenticator.CurrentUserId;
        var request = new SyncSessionsRequestDto
        {
            Sessions = new List<CreateSessionDto> { CreateValidSessionDto(GameMode.Standard501) }
        };

        // Act
        await _client.PostAsJsonAsync("/api/sessions/sync", request);

        // Assert (check database)
        using var scope = _factory.Services.CreateScope();
        var dbContext = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        var savedSessions = await dbContext.Sessions.Where(s => s.UserId == userId).ToListAsync();
        Assert.Single(savedSessions);
    }

    [Fact]
    public async Task SyncSessions_WithBatchExceeding100_Returns400()
    {
        // Arrange
        var request = new SyncSessionsRequestDto
        {
            Sessions = Enumerable.Range(0, 101)
                .Select(_ => CreateValidSessionDto(GameMode.Standard501))
                .ToList()
        };

        // Act
        var response = await _client.PostAsJsonAsync("/api/sessions/sync", request);

        // Assert
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }
}
```

### Frontend: SyncService Tests

```typescript
describe('SyncService', () => {
  let service: SyncService;
  let indexedDbService: jasmine.SpyObj<IndexedDbService>;
  let sessionsApi: jasmine.SpyObj<SessionsApiService>;
  let loggerService: jasmine.SpyObj<LoggerService>;

  beforeEach(() => {
    const indexedDbSpy = jasmine.createSpyObj('IndexedDbService', [
      'addSession',
      'getQueuedSessions',
      'getQueueCount',
      'clearQueue'
    ]);
    const sessionsApiSpy = jasmine.createSpyObj('SessionsApiService', ['syncSessions']);
    const loggerSpy = jasmine.createSpyObj('LoggerService', ['info', 'debug', 'error']);

    TestBed.configureTestingModule({
      providers: [
        SyncService,
        { provide: IndexedDbService, useValue: indexedDbSpy },
        { provide: SessionsApiService, useValue: sessionsApiSpy },
        { provide: LoggerService, useValue: loggerSpy }
      ]
    });

    service = TestBed.inject(SyncService);
    indexedDbService = TestBed.inject(IndexedDbService) as jasmine.SpyObj<IndexedDbService>;
    sessionsApi = TestBed.inject(SessionsApiService) as jasmine.SpyObj<SessionsApiService>;
    loggerService = TestBed.inject(LoggerService) as jasmine.SpyObj<LoggerService>;
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });

  it('should queue session offline', fakeAsync(async () => {
    // Arrange
    indexedDbService.addSession.and.returnValue(Promise.resolve());
    spyOnProperty(navigator, 'onLine', 'get').and.returnValue(false);

    // Act
    await service.queueSession(createMockSessionDto());

    // Assert
    expect(indexedDbService.addSession).toHaveBeenCalled();
  }));

  it('should sync immediately when online', fakeAsync(async () => {
    // Arrange
    indexedDbService.addSession.and.returnValue(Promise.resolve());
    indexedDbService.getQueueCount.and.returnValue(Promise.resolve(1));
    indexedDbService.getQueuedSessions.and.returnValue(Promise.resolve([createMockSessionDto()]));
    indexedDbService.clearQueue.and.returnValue(Promise.resolve());

    const syncResult: SyncResultDto = { sessionsProcessed: 1, success: true, newPersonalBests: [] };
    sessionsApi.syncSessions.and.returnValue(of(syncResult));

    spyOnProperty(navigator, 'onLine', 'get').and.returnValue(true);

    // Act
    await service.queueSession(createMockSessionDto());
    tick();

    // Assert
    expect(sessionsApi.syncSessions).toHaveBeenCalled();
  }));

  it('should detect offline status', (done) => {
    service.getIsOnline$().subscribe(isOnline => {
      expect(typeof isOnline).toBe('boolean');
      done();
    });
  });

  it('should expose syncing state', (done) => {
    service.getIsSyncing$().subscribe(isSyncing => {
      expect(typeof isSyncing).toBe('boolean');
      done();
    });
  });

  it('should not throw on queue failure in manual sync', fakeAsync(async () => {
    // Arrange
    indexedDbService.getQueueCount.and.returnValue(Promise.resolve(1));
    indexedDbService.getQueuedSessions.and.returnValue(Promise.reject(new Error('DB error')));

    // Act & Assert
    expect(() => {
      service.manualSync();
      tick();
    }).not.toThrow();
  }));
});

function createMockSessionDto(): CreateSessionDto {
  return {
    gameMode: GameMode.Standard501,
    turns: [
      {
        turnNumber: 1,
        dartEntries: [
          { value: 20, multiplier: Multiplier.Triple, segment: null }
        ]
      }
    ]
  };
}
```

### Frontend: IndexedDbService Tests

```typescript
describe('IndexedDbService', () => {
  let service: IndexedDbService;
  let loggerService: jasmine.SpyObj<LoggerService>;

  beforeEach(() => {
    const loggerSpy = jasmine.createSpyObj('LoggerService', ['debug', 'error']);

    TestBed.configureTestingModule({
      providers: [
        IndexedDbService,
        { provide: LoggerService, useValue: loggerSpy }
      ]
    });

    service = TestBed.inject(IndexedDbService);
    loggerService = TestBed.inject(LoggerService) as jasmine.SpyObj<LoggerService>;
  });

  it('should add session to queue', fakeAsync(async () => {
    // Arrange
    const session = createMockSessionDto();

    // Act
    await service.addSession(session);
    tick();

    // Assert
    expect(loggerService.debug).toHaveBeenCalledWith('Session queued for sync');
  }));

  it('should retrieve queued sessions', fakeAsync(async () => {
    // Arrange
    const session = createMockSessionDto();
    await service.addSession(session);
    tick();

    // Act
    const retrieved = await service.getQueuedSessions();
    tick();

    // Assert
    expect(retrieved.length).toBeGreaterThan(0);
  }));

  it('should get queue count', fakeAsync(async () => {
    // Arrange
    await service.addSession(createMockSessionDto());
    await service.addSession(createMockSessionDto());
    tick();

    // Act
    const count = await service.getQueueCount();
    tick();

    // Assert
    expect(count).toBe(2);
  }));

  it('should clear queue', fakeAsync(async () => {
    // Arrange
    await service.addSession(createMockSessionDto());
    tick();

    // Act
    await service.clearQueue();
    tick();

    // Assert
    const count = await service.getQueueCount();
    tick();
    expect(count).toBe(0);
  }));
});
```

---

## Test Coverage Target

- **Backend:** Validation, PB detection, batch atomicity, authorization
- **Frontend:** Queue operations, sync state, connectivity detection, error handling

---

## Definition of Done

- [ ] All backend unit tests pass
- [ ] All backend integration tests pass
- [ ] All frontend unit tests pass
- [ ] Code coverage >80% for sync service and handler
- [ ] Atomicity verified (all-or-nothing behavior)
- [ ] Validation verified (invalid data rejected)
- [ ] PB detection verified
- [ ] Queue operations tested (add, retrieve, clear)
- [ ] Sync state transitions tested
- [ ] Connectivity detection tested
- [ ] Error handling verified
- [ ] No flaky tests

---

## References

- [xUnit Documentation](https://xunit.net/)
- [Jasmine Testing Framework](https://jasmine.github.io/)
- [Angular Testing Guide](https://angular.io/guide/testing)
