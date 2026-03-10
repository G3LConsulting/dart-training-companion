# HIST-02-T05 — Tests: Deletion and Recalculation Tests

**Story:** [HIST-02](../HIST-02-STORY.md)
**Layer:** Backend (Unit & Integration Tests)
**Status:** Not Started
**Assigned To:** —
**Complexity:** L

---

## What to Build

Comprehensive tests for session deletion, recalculation queue, stats recalculation service, and integration tests covering the full deletion-to-recalculation flow.

---

## Files to Create/Modify

| Path | Purpose | Status |
|------|---------|--------|
| `UnitTests/Sessions/DeleteSessionCommandHandlerTests.cs` | Unit tests for delete command | To Create |
| `UnitTests/Stats/StatsRecalculationServiceTests.cs` | Unit tests for recalculation service | To Create |
| `UnitTests/Stats/RecalculationStateTests.cs` | Unit tests for state tracking | To Create |
| `IntegrationTests/Sessions/DeleteAndRecalculateTests.cs` | Full flow integration tests | To Create |

---

## Implementation Notes

### DeleteSessionCommandHandler Tests

```csharp
public class DeleteSessionCommandHandlerTests
{
    private readonly Mock<IApplicationDbContext> _mockDbContext;
    private readonly Mock<IRecalculationQueue> _mockQueue;
    private readonly Mock<ILogger<DeleteSessionCommandHandler>> _mockLogger;
    private readonly DeleteSessionCommandHandler _handler;

    public DeleteSessionCommandHandlerTests()
    {
        _mockDbContext = new Mock<IApplicationDbContext>();
        _mockQueue = new Mock<IRecalculationQueue>();
        _mockLogger = new Mock<ILogger<DeleteSessionCommandHandler>>();
        _handler = new DeleteSessionCommandHandler(_mockDbContext.Object, _mockQueue.Object, _mockLogger.Object);
    }

    [Fact]
    public async Task Handle_WithValidCommand_SoftDeletesSessionAndEnqueuesUser()
    {
        // Arrange
        var sessionId = Guid.NewGuid();
        var userId = Guid.NewGuid();
        var session = new GameSession { Id = sessionId, UserId = userId, IsDeleted = false };

        var command = new DeleteSessionCommand { SessionId = sessionId, UserId = userId };

        _mockDbContext.Setup(x => x.Sessions)
            .Returns(new List<GameSession> { session }.AsQueryable().BuildMockDbSet().Object);
        _mockQueue.Setup(x => x.EnqueueAsync(userId, It.IsAny<CancellationToken>()))
            .Returns(Task.CompletedTask);

        // Act
        await _handler.Handle(command, CancellationToken.None);

        // Assert
        Assert.True(session.IsDeleted);
        Assert.NotNull(session.DeletedAt);
        _mockDbContext.Verify(x => x.SaveChangesAsync(It.IsAny<CancellationToken>()), Times.Once);
        _mockQueue.Verify(x => x.EnqueueAsync(userId, It.IsAny<CancellationToken>()), Times.Once);
    }

    [Fact]
    public async Task Handle_WithNonexistentSession_ThrowsNotFoundException()
    {
        // Arrange
        var sessionId = Guid.NewGuid();
        var userId = Guid.NewGuid();
        var command = new DeleteSessionCommand { SessionId = sessionId, UserId = userId };

        var sessions = new List<GameSession>().AsQueryable();
        _mockDbContext.Setup(x => x.Sessions)
            .Returns(sessions.BuildMockDbSet().Object);

        // Act & Assert
        await Assert.ThrowsAsync<NotFoundException>(() => _handler.Handle(command, CancellationToken.None));
    }

    [Fact]
    public async Task Handle_WithUnauthorizedUser_ThrowsUnauthorizedAccessException()
    {
        // Arrange
        var sessionId = Guid.NewGuid();
        var userId = Guid.NewGuid();
        var otherUserId = Guid.NewGuid();
        var session = new GameSession { Id = sessionId, UserId = otherUserId };
        var command = new DeleteSessionCommand { SessionId = sessionId, UserId = userId };

        _mockDbContext.Setup(x => x.Sessions)
            .Returns(new List<GameSession> { session }.AsQueryable().BuildMockDbSet().Object);

        // Act & Assert
        await Assert.ThrowsAsync<UnauthorizedAccessException>(() => _handler.Handle(command, CancellationToken.None));
    }

    [Fact]
    public async Task Handle_WhenQueueEnqueueFails_DoesNotThrowButLogsError()
    {
        // Arrange
        var sessionId = Guid.NewGuid();
        var userId = Guid.NewGuid();
        var session = new GameSession { Id = sessionId, UserId = userId, IsDeleted = false };
        var command = new DeleteSessionCommand { SessionId = sessionId, UserId = userId };

        _mockDbContext.Setup(x => x.Sessions)
            .Returns(new List<GameSession> { session }.AsQueryable().BuildMockDbSet().Object);
        _mockQueue.Setup(x => x.EnqueueAsync(userId, It.IsAny<CancellationToken>()))
            .ThrowsAsync(new Exception("Queue failure"));

        // Act
        var ex = await Record.ExceptionAsync(() => _handler.Handle(command, CancellationToken.None));

        // Assert
        Assert.Null(ex);  // Should not throw
        Assert.True(session.IsDeleted);  // Deletion should have succeeded
        _mockLogger.Verify(
            x => x.Log(
                LogLevel.Error,
                It.IsAny<EventId>(),
                It.IsAny<It.IsAnyType>(),
                It.IsAny<Exception>(),
                It.IsAny<Func<It.IsAnyType, Exception, string>>()),
            Times.Once);
    }

    [Fact]
    public async Task Handle_SetsDeletedAtTimestamp()
    {
        // Arrange
        var sessionId = Guid.NewGuid();
        var userId = Guid.NewGuid();
        var beforeDelete = DateTime.UtcNow;
        var session = new GameSession { Id = sessionId, UserId = userId, IsDeleted = false };
        var command = new DeleteSessionCommand { SessionId = sessionId, UserId = userId };

        _mockDbContext.Setup(x => x.Sessions)
            .Returns(new List<GameSession> { session }.AsQueryable().BuildMockDbSet().Object);

        // Act
        await _handler.Handle(command, CancellationToken.None);
        var afterDelete = DateTime.UtcNow;

        // Assert
        Assert.NotNull(session.DeletedAt);
        Assert.True(session.DeletedAt >= beforeDelete && session.DeletedAt <= afterDelete);
    }
}
```

### StatsRecalculationService Tests

```csharp
public class StatsRecalculationServiceTests
{
    [Fact]
    public async Task RecalculateUserStatsAsync_WithSessions_CalculatesCorrectAggregates()
    {
        // Arrange
        var userId = Guid.NewGuid();
        var mockDbContext = new Mock<IApplicationDbContext>();
        var mockLogger = new Mock<ILogger<StatsCalculationService>>();

        var sessions = new List<GameSession>
        {
            new GameSession
            {
                Id = Guid.NewGuid(),
                UserId = userId,
                GameMode = GameMode.Standard501,
                IsDeleted = false,
                Turns = new List<Turn>
                {
                    new Turn
                    {
                        TurnNumber = 1,
                        DartEntries = new List<DartEntry>
                        {
                            new DartEntry { Value = 20, Multiplier = Multiplier.Triple },  // 60
                            new DartEntry { Value = 20, Multiplier = Multiplier.Double },  // 40
                            new DartEntry { Value = 19, Multiplier = Multiplier.Single }   // 19
                        }
                    }
                }
            }
        }.AsQueryable();

        mockDbContext.Setup(x => x.Sessions)
            .Returns(sessions.BuildMockDbSet().Object);
        mockDbContext.Setup(x => x.UserStats)
            .Returns(new List<UserStats>().AsQueryable().BuildMockDbSet().Object);
        mockDbContext.Setup(x => x.PersonalBests)
            .Returns(new List<PersonalBest>().AsQueryable().BuildMockDbSet().Object);

        var service = new StatsCalculationService(mockDbContext.Object, mockLogger.Object);

        // Act
        await service.RecalculateUserStatsAsync(userId, CancellationToken.None);

        // Assert
        mockDbContext.Verify(x => x.SaveChangesAsync(It.IsAny<CancellationToken>()), Times.Once);
        // Verify stats were calculated (119 points / 3 darts * 3 = 119)
    }

    [Fact]
    public async Task RecalculateUserStatsAsync_WithNoSessions_ClearsStats()
    {
        // Arrange
        var userId = Guid.NewGuid();
        var mockDbContext = new Mock<IApplicationDbContext>();
        var mockLogger = new Mock<ILogger<StatsCalculationService>>();

        mockDbContext.Setup(x => x.Sessions)
            .Returns(new List<GameSession>().AsQueryable().BuildMockDbSet().Object);

        var existingStats = new List<UserStats>
        {
            new UserStats { UserId = userId, GameMode = GameMode.Standard501 }
        };
        mockDbContext.Setup(x => x.UserStats)
            .Returns(existingStats.AsQueryable().BuildMockDbSet().Object);

        var service = new StatsCalculationService(mockDbContext.Object, mockLogger.Object);

        // Act
        await service.RecalculateUserStatsAsync(userId, CancellationToken.None);

        // Assert
        mockDbContext.Verify(x => x.UserStats.RemoveRange(It.IsAny<IEnumerable<UserStats>>()), Times.Once);
    }

    [Fact]
    public async Task RecalculateUserStatsAsync_FiltersDeletedSessions()
    {
        // Arrange
        var userId = Guid.NewGuid();
        var mockDbContext = new Mock<IApplicationDbContext>();
        var mockLogger = new Mock<ILogger<StatsCalculationService>>();

        var sessions = new List<GameSession>
        {
            new GameSession { Id = Guid.NewGuid(), UserId = userId, IsDeleted = false, GameMode = GameMode.Standard501, Turns = new List<Turn>() },
            new GameSession { Id = Guid.NewGuid(), UserId = userId, IsDeleted = true, GameMode = GameMode.Standard501, Turns = new List<Turn>() }  // Should be ignored
        }.AsQueryable();

        mockDbContext.Setup(x => x.Sessions)
            .Returns(sessions.BuildMockDbSet().Object);

        var service = new StatsCalculationService(mockDbContext.Object, mockLogger.Object);

        // Act
        await service.RecalculateUserStatsAsync(userId, CancellationToken.None);

        // Assert
        // Verify only 1 session was processed (the non-deleted one)
    }
}
```

### RecalculationState Tests

```csharp
public class RecalculationStateTests
{
    [Fact]
    public void SetIsRecalculating_WithTrue_UserAppearsRecalculating()
    {
        // Arrange
        var state = new RecalculationState();
        var userId = Guid.NewGuid();

        // Act
        state.SetIsRecalculating(userId, true);

        // Assert
        Assert.True(state.GetIsRecalculating(userId));
    }

    [Fact]
    public void SetIsRecalculating_WithFalse_UserNotRecalculating()
    {
        // Arrange
        var state = new RecalculationState();
        var userId = Guid.NewGuid();
        state.SetIsRecalculating(userId, true);

        // Act
        state.SetIsRecalculating(userId, false);

        // Assert
        Assert.False(state.GetIsRecalculating(userId));
    }

    [Fact]
    public void GetRecalculatingUsers_ReturnsOnlyActiveUsers()
    {
        // Arrange
        var state = new RecalculationState();
        var user1 = Guid.NewGuid();
        var user2 = Guid.NewGuid();
        var user3 = Guid.NewGuid();

        state.SetIsRecalculating(user1, true);
        state.SetIsRecalculating(user2, true);
        state.SetIsRecalculating(user3, false);

        // Act
        var recalculating = state.GetRecalculatingUsers().ToList();

        // Assert
        Assert.Equal(2, recalculating.Count);
        Assert.Contains(user1, recalculating);
        Assert.Contains(user2, recalculating);
        Assert.DoesNotContain(user3, recalculating);
    }

    [Fact]
    public void GetIsRecalculating_WithNeverSetUser_ReturnsFalse()
    {
        // Arrange
        var state = new RecalculationState();
        var userId = Guid.NewGuid();

        // Act
        var isRecalculating = state.GetIsRecalculating(userId);

        // Assert
        Assert.False(isRecalculating);
    }

    [Fact]
    public void ConcurrentAccess_IsThreadSafe()
    {
        // Arrange
        var state = new RecalculationState();
        var userIds = Enumerable.Range(0, 100).Select(_ => Guid.NewGuid()).ToList();

        // Act
        Parallel.ForEach(userIds, userId =>
        {
            state.SetIsRecalculating(userId, true);
            Thread.Sleep(Random.Shared.Next(1, 10));
            var result = state.GetIsRecalculating(userId);
            state.SetIsRecalculating(userId, false);
        });

        // Assert
        var remaining = state.GetRecalculatingUsers().ToList();
        Assert.Empty(remaining);
    }
}
```

### Integration Tests

```csharp
public class DeleteAndRecalculateTests : IAsyncLifetime
{
    private readonly WebApplicationFactory<Program> _factory;
    private HttpClient _client;
    private readonly TestAuthenticator _authenticator;

    public DeleteAndRecalculateTests()
    {
        _factory = new WebApplicationFactory<Program>()
            .WithWebHostBuilder(builder =>
            {
                builder.ConfigureTestServices(services =>
                {
                    var descriptor = services.SingleOrDefault(d => d.ServiceType == typeof(DbContextOptions<ApplicationDbContext>));
                    if (descriptor != null)
                        services.Remove(descriptor);

                    services.AddDbContext<ApplicationDbContext>(options =>
                        options.UseInMemoryDatabase("TestDb"));
                });
            });
        _client = _factory.CreateClient();
        _authenticator = new TestAuthenticator(_factory.Services);
    }

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
    public async Task DeleteSession_Returns204NoContent()
    {
        // Arrange
        var userId = _authenticator.CurrentUserId;
        var session = await SeedTestSession(userId);

        // Act
        var response = await _client.DeleteAsync($"/api/sessions/{session.Id}");

        // Assert
        Assert.Equal(HttpStatusCode.NoContent, response.StatusCode);
    }

    [Fact]
    public async Task DeleteSession_SoftDeletesInDatabase()
    {
        // Arrange
        var userId = _authenticator.CurrentUserId;
        var session = await SeedTestSession(userId);

        // Act
        await _client.DeleteAsync($"/api/sessions/{session.Id}");

        // Assert (check database directly)
        using var scope = _factory.Services.CreateScope();
        var dbContext = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        var deletedSession = await dbContext.Sessions.FirstOrDefaultAsync(s => s.Id == session.Id);
        Assert.NotNull(deletedSession);
        Assert.True(deletedSession.IsDeleted);
        Assert.NotNull(deletedSession.DeletedAt);
    }

    [Fact]
    public async Task DeleteSession_EnqueuesUserForRecalculation()
    {
        // Arrange
        var userId = _authenticator.CurrentUserId;
        var session = await SeedTestSession(userId);

        // Act
        await _client.DeleteAsync($"/api/sessions/{session.Id}");

        // Assert
        await Task.Delay(100);  // Give service time to process
        var statusResponse = await _client.GetAsync("/api/stats/recalculation-status");
        Assert.Equal(HttpStatusCode.OK, statusResponse.StatusCode);
    }

    [Fact]
    public async Task DeleteSessionOfOtherUser_Returns403Forbidden()
    {
        // Arrange
        var otherUserId = Guid.NewGuid();
        var session = await SeedTestSession(otherUserId);

        // Act
        var response = await _client.DeleteAsync($"/api/sessions/{session.Id}");

        // Assert
        Assert.Equal(HttpStatusCode.Forbidden, response.StatusCode);
    }

    [Fact]
    public async Task DeleteNonexistentSession_Returns404NotFound()
    {
        // Act
        var response = await _client.DeleteAsync($"/api/sessions/{Guid.NewGuid()}");

        // Assert
        Assert.Equal(HttpStatusCode.NotFound, response.StatusCode);
    }

    [Fact]
    public async Task GetRecalculationStatus_ReturnsFalseWhenNotRecalculating()
    {
        // Act
        var response = await _client.GetAsync("/api/stats/recalculation-status");

        // Assert
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        var content = await response.Content.ReadAsAsync<RecalculationStatusDto>();
        Assert.False(content.IsRecalculating);
    }

    [Fact]
    public async Task DeletedSessionNotReturnedInHistory()
    {
        // Arrange
        var userId = _authenticator.CurrentUserId;
        var session = await SeedTestSession(userId);

        // Act
        await _client.DeleteAsync($"/api/sessions/{session.Id}");

        // Assert
        var historyResponse = await _client.GetAsync("/api/sessions");
        Assert.Equal(HttpStatusCode.OK, historyResponse.StatusCode);
        var content = await historyResponse.Content.ReadAsAsync<PagedResult<SessionSummaryDto>>();
        Assert.DoesNotContain(session.Id, content.Items.Select(s => s.Id));
    }

    private async Task<GameSession> SeedTestSession(Guid userId)
    {
        using var scope = _factory.Services.CreateScope();
        var dbContext = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();

        var session = new GameSession
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            GameMode = GameMode.Standard501,
            Turns = new List<Turn>
            {
                new Turn
                {
                    TurnNumber = 1,
                    DartEntries = new List<DartEntry>
                    {
                        new DartEntry { Value = 20, Multiplier = Multiplier.Triple }
                    }
                }
            }
        };

        await dbContext.Sessions.AddAsync(session);
        await dbContext.SaveChangesAsync();
        return session;
    }
}
```

---

## Test Coverage Target

- **Delete Command:** All authorization scenarios, queue failure handling, soft delete mechanics
- **Recalculation Service:** Stats calculation accuracy, filtered session handling, empty state, PB calculation
- **State Tracking:** Thread-safety, concurrent access, state transitions
- **Integration:** Full HTTP flow, database persistence, soft delete visibility

---

## Definition of Done

- [ ] All unit tests pass
- [ ] All integration tests pass
- [ ] Code coverage >80% for command handler and service
- [ ] Authorization verified (prevent unauthorized deletion)
- [ ] Soft-delete behavior verified (IsDeleted flag set, DeletedAt timestamp)
- [ ] Queue enqueue verified (user properly enqueued)
- [ ] Queue failure doesn't break deletion
- [ ] Stats calculation verified (aggregates accurate)
- [ ] Deleted sessions filtered from all queries
- [ ] Recalculation status endpoint tested
- [ ] Thread-safety verified for RecalculationState
- [ ] No flaky tests

---

## References

- [xUnit Documentation](https://xunit.net/)
- [Moq Framework](https://github.com/moq/moq4)
- [Integration Testing Setup](../../shared/INTEGRATION-TEST-SETUP.md)
