# HIST-01-T04 — Tests: History Query Tests

**Story:** [HIST-01](../HIST-01-STORY.md)
**Layer:** Backend (Unit & Integration Tests)
**Status:** Not Started
**Assigned To:** —
**Complexity:** M

---

## What to Build

Comprehensive unit and integration tests for GetSessionHistoryQuery and GetSessionDetailQuery handlers. Tests verify pagination, filtering, user scoping, and data accuracy.

---

## Files to Create/Modify

| Path | Purpose | Status |
|------|---------|--------|
| `UnitTests/Sessions/GetSessionHistoryQueryHandlerTests.cs` | Unit tests for history query | To Create |
| `UnitTests/Sessions/GetSessionDetailQueryHandlerTests.cs` | Unit tests for detail query | To Create |
| `IntegrationTests/Sessions/SessionsApiTests.cs` | Integration tests for HTTP endpoints | To Create |

---

## Implementation Notes

### Unit Tests: GetSessionHistoryQueryHandler

```csharp
public class GetSessionHistoryQueryHandlerTests
{
    private readonly Mock<IApplicationDbContext> _mockDbContext;
    private readonly GetSessionHistoryQueryHandler _handler;

    public GetSessionHistoryQueryHandlerTests()
    {
        _mockDbContext = new Mock<IApplicationDbContext>();
        _handler = new GetSessionHistoryQueryHandler(_mockDbContext.Object);
    }

    [Fact]
    public async Task Handle_WithValidQuery_ReturnsPaginatedResults()
    {
        // Arrange
        var userId = Guid.NewGuid();
        var query = new GetSessionHistoryQuery
        {
            UserId = userId,
            PageNumber = 1,
            PageSize = 20,
            GameMode = null
        };

        var sessions = new List<GameSession>
        {
            new GameSession { Id = Guid.NewGuid(), UserId = userId, GameMode = GameMode.Standard501, CreatedAt = DateTime.UtcNow.AddDays(-1) },
            new GameSession { Id = Guid.NewGuid(), UserId = userId, GameMode = GameMode.Cricket, CreatedAt = DateTime.UtcNow.AddDays(-2) },
            new GameSession { Id = Guid.NewGuid(), UserId = userId, GameMode = GameMode.Standard301, CreatedAt = DateTime.UtcNow.AddDays(-3) },
        }.AsQueryable();

        _mockDbContext.Setup(x => x.Sessions).Returns(CreateMockDbSet(sessions));

        // Act
        var result = await _handler.Handle(query, CancellationToken.None);

        // Assert
        Assert.NotNull(result);
        Assert.Equal(3, result.Items.Count);
        Assert.Equal(3, result.TotalCount);
        Assert.Equal(1, result.TotalPages);
        Assert.False(result.HasPreviousPage);
        Assert.False(result.HasNextPage);
    }

    [Fact]
    public async Task Handle_WithPagination_ReturnsCorrectPage()
    {
        // Arrange
        var userId = Guid.NewGuid();
        var sessions = Enumerable.Range(1, 45)
            .Select(i => new GameSession
            {
                Id = Guid.NewGuid(),
                UserId = userId,
                GameMode = GameMode.Standard501,
                CreatedAt = DateTime.UtcNow.AddDays(-i)
            })
            .OrderByDescending(x => x.CreatedAt)
            .ToList()
            .AsQueryable();

        var query = new GetSessionHistoryQuery
        {
            UserId = userId,
            PageNumber = 2,
            PageSize = 20,
            GameMode = null
        };

        _mockDbContext.Setup(x => x.Sessions).Returns(CreateMockDbSet(sessions));

        // Act
        var result = await _handler.Handle(query, CancellationToken.None);

        // Assert
        Assert.Equal(20, result.Items.Count);
        Assert.Equal(45, result.TotalCount);
        Assert.Equal(3, result.TotalPages);
        Assert.True(result.HasPreviousPage);
        Assert.True(result.HasNextPage);
        // Verify page 2 items (skip 20, take 20)
    }

    [Fact]
    public async Task Handle_WithGameModeFilter_ReturnsFilteredResults()
    {
        // Arrange
        var userId = Guid.NewGuid();
        var sessions = new List<GameSession>
        {
            new GameSession { Id = Guid.NewGuid(), UserId = userId, GameMode = GameMode.Standard501, CreatedAt = DateTime.UtcNow },
            new GameSession { Id = Guid.NewGuid(), UserId = userId, GameMode = GameMode.Cricket, CreatedAt = DateTime.UtcNow },
            new GameSession { Id = Guid.NewGuid(), UserId = userId, GameMode = GameMode.Standard501, CreatedAt = DateTime.UtcNow },
        }.AsQueryable();

        var query = new GetSessionHistoryQuery
        {
            UserId = userId,
            PageNumber = 1,
            PageSize = 20,
            GameMode = GameMode.Standard501
        };

        _mockDbContext.Setup(x => x.Sessions).Returns(CreateMockDbSet(sessions));

        // Act
        var result = await _handler.Handle(query, CancellationToken.None);

        // Assert
        Assert.Equal(2, result.Items.Count);
        Assert.All(result.Items, item => Assert.Equal(GameMode.Standard501, item.GameMode));
    }

    [Fact]
    public async Task Handle_WithDifferentUser_ReturnsOnlyTheirSessions()
    {
        // Arrange
        var userId = Guid.NewGuid();
        var otherUserId = Guid.NewGuid();
        var sessions = new List<GameSession>
        {
            new GameSession { Id = Guid.NewGuid(), UserId = userId, GameMode = GameMode.Standard501, CreatedAt = DateTime.UtcNow },
            new GameSession { Id = Guid.NewGuid(), UserId = otherUserId, GameMode = GameMode.Standard501, CreatedAt = DateTime.UtcNow },
            new GameSession { Id = Guid.NewGuid(), UserId = userId, GameMode = GameMode.Cricket, CreatedAt = DateTime.UtcNow },
        }.AsQueryable();

        var query = new GetSessionHistoryQuery
        {
            UserId = userId,
            PageNumber = 1,
            PageSize = 20,
            GameMode = null
        };

        _mockDbContext.Setup(x => x.Sessions).Returns(CreateMockDbSet(sessions));

        // Act
        var result = await _handler.Handle(query, CancellationToken.None);

        // Assert
        Assert.Equal(2, result.Items.Count);
        Assert.All(result.Items, item => Assert.Equal(userId, item.UserId));
    }

    [Fact]
    public async Task Handle_WithNoSessions_ReturnsEmptyList()
    {
        // Arrange
        var userId = Guid.NewGuid();
        var sessions = new List<GameSession>().AsQueryable();

        var query = new GetSessionHistoryQuery
        {
            UserId = userId,
            PageNumber = 1,
            PageSize = 20,
            GameMode = null
        };

        _mockDbContext.Setup(x => x.Sessions).Returns(CreateMockDbSet(sessions));

        // Act
        var result = await _handler.Handle(query, CancellationToken.None);

        // Assert
        Assert.Empty(result.Items);
        Assert.Equal(0, result.TotalCount);
    }

    [Theory]
    [InlineData(0)]
    [InlineData(-1)]
    public async Task Handle_WithInvalidPageNumber_Throws(int pageNumber)
    {
        // Arrange
        var query = new GetSessionHistoryQuery
        {
            UserId = Guid.NewGuid(),
            PageNumber = pageNumber,
            PageSize = 20,
            GameMode = null
        };

        // Act & Assert
        await Assert.ThrowsAsync<ValidationException>(() => _handler.Handle(query, CancellationToken.None));
    }

    [Fact]
    public async Task Handle_OrdersByCreatedAtDescending()
    {
        // Arrange
        var userId = Guid.NewGuid();
        var sessions = new List<GameSession>
        {
            new GameSession { Id = Guid.NewGuid(), UserId = userId, GameMode = GameMode.Standard501, CreatedAt = DateTime.UtcNow.AddDays(-1) },
            new GameSession { Id = Guid.NewGuid(), UserId = userId, GameMode = GameMode.Cricket, CreatedAt = DateTime.UtcNow },
            new GameSession { Id = Guid.NewGuid(), UserId = userId, GameMode = GameMode.Standard301, CreatedAt = DateTime.UtcNow.AddDays(-2) },
        }.AsQueryable();

        var query = new GetSessionHistoryQuery
        {
            UserId = userId,
            PageNumber = 1,
            PageSize = 20,
            GameMode = null
        };

        _mockDbContext.Setup(x => x.Sessions).Returns(CreateMockDbSet(sessions));

        // Act
        var result = await _handler.Handle(query, CancellationToken.None);

        // Assert
        Assert.True(result.Items[0].CreatedAt > result.Items[1].CreatedAt);
        Assert.True(result.Items[1].CreatedAt > result.Items[2].CreatedAt);
    }

    private IDbSet<T> CreateMockDbSet<T>(IQueryable<T> data) where T : class
    {
        var mockSet = new Mock<IDbSet<T>>();
        mockSet.As<IQueryable<T>>().Setup(m => m.Provider).Returns(data.Provider);
        mockSet.As<IQueryable<T>>().Setup(m => m.Expression).Returns(data.Expression);
        mockSet.As<IQueryable<T>>().Setup(m => m.ElementType).Returns(data.ElementType);
        mockSet.As<IQueryable<T>>().Setup(m => m.GetEnumerator()).Returns(data.GetEnumerator());
        return mockSet.Object;
    }
}
```

### Unit Tests: GetSessionDetailQueryHandler

```csharp
public class GetSessionDetailQueryHandlerTests
{
    private readonly Mock<IApplicationDbContext> _mockDbContext;
    private readonly GetSessionDetailQueryHandler _handler;

    public GetSessionDetailQueryHandlerTests()
    {
        _mockDbContext = new Mock<IApplicationDbContext>();
        _handler = new GetSessionDetailQueryHandler(_mockDbContext.Object);
    }

    [Fact]
    public async Task Handle_WithValidSessionId_ReturnsSessionDetail()
    {
        // Arrange
        var sessionId = Guid.NewGuid();
        var userId = Guid.NewGuid();
        var session = new GameSession
        {
            Id = sessionId,
            UserId = userId,
            GameMode = GameMode.Standard501,
            CreatedAt = DateTime.UtcNow,
            Turns = new List<Turn>
            {
                new Turn
                {
                    TurnNumber = 1,
                    DartEntries = new List<DartEntry>
                    {
                        new DartEntry { Value = 20, Multiplier = Multiplier.Triple },
                        new DartEntry { Value = 20, Multiplier = Multiplier.Double },
                        new DartEntry { Value = 19, Multiplier = Multiplier.Single }
                    }
                }
            }
        };

        var query = new GetSessionDetailQuery { SessionId = sessionId, UserId = userId };

        _mockDbContext.Setup(x => x.Sessions)
            .Returns(new List<GameSession> { session }.AsQueryable().BuildMockDbSet().Object);

        // Act
        var result = await _handler.Handle(query, CancellationToken.None);

        // Assert
        Assert.NotNull(result);
        Assert.Equal(sessionId, result.Id);
        Assert.Equal(GameMode.Standard501, result.GameMode);
        Assert.Single(result.Turns);
        Assert.Equal(3, result.Turns[0].Darts.Count);
    }

    [Fact]
    public async Task Handle_WithUnauthorizedUser_Throws()
    {
        // Arrange
        var sessionId = Guid.NewGuid();
        var userId = Guid.NewGuid();
        var otherUserId = Guid.NewGuid();
        var session = new GameSession
        {
            Id = sessionId,
            UserId = otherUserId,
            GameMode = GameMode.Standard501
        };

        var query = new GetSessionDetailQuery { SessionId = sessionId, UserId = userId };

        _mockDbContext.Setup(x => x.Sessions)
            .Returns(new List<GameSession> { session }.AsQueryable().BuildMockDbSet().Object);

        // Act & Assert
        await Assert.ThrowsAsync<UnauthorizedAccessException>(() => _handler.Handle(query, CancellationToken.None));
    }

    [Fact]
    public async Task Handle_WithNonexistentSession_Throws()
    {
        // Arrange
        var sessionId = Guid.NewGuid();
        var userId = Guid.NewGuid();
        var sessions = new List<GameSession>().AsQueryable();

        var query = new GetSessionDetailQuery { SessionId = sessionId, UserId = userId };

        _mockDbContext.Setup(x => x.Sessions)
            .Returns(sessions.BuildMockDbSet().Object);

        // Act & Assert
        await Assert.ThrowsAsync<NotFoundException>(() => _handler.Handle(query, CancellationToken.None));
    }

    [Fact]
    public async Task Handle_LoadsAllTurnsAndDarts()
    {
        // Arrange
        var sessionId = Guid.NewGuid();
        var userId = Guid.NewGuid();
        var session = new GameSession
        {
            Id = sessionId,
            UserId = userId,
            GameMode = GameMode.Standard501,
            Turns = Enumerable.Range(1, 5)
                .Select(turnNum => new Turn
                {
                    TurnNumber = turnNum,
                    DartEntries = Enumerable.Range(1, 3)
                        .Select(dartNum => new DartEntry { Value = 20, Multiplier = Multiplier.Single })
                        .ToList()
                })
                .ToList()
        };

        var query = new GetSessionDetailQuery { SessionId = sessionId, UserId = userId };

        _mockDbContext.Setup(x => x.Sessions)
            .Returns(new List<GameSession> { session }.AsQueryable().BuildMockDbSet().Object);

        // Act
        var result = await _handler.Handle(query, CancellationToken.None);

        // Assert
        Assert.Equal(5, result.Turns.Count);
        Assert.All(result.Turns, turn => Assert.Equal(3, turn.Darts.Count));
    }
}
```

### Integration Tests: SessionsApiTests

```csharp
public class SessionsApiTests : IAsyncLifetime
{
    private readonly WebApplicationFactory<Program> _factory;
    private HttpClient _client;
    private readonly TestAuthenticator _authenticator;

    public SessionsApiTests()
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
    public async Task GetSessionHistory_WithValidRequest_Returns200WithPaginatedData()
    {
        // Arrange
        var userId = _authenticator.CurrentUserId;
        await SeedTestSessions(userId, 25);

        // Act
        var response = await _client.GetAsync("/api/sessions?pageNumber=1&pageSize=20");

        // Assert
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        var content = await response.Content.ReadAsAsync<PagedResult<SessionSummaryDto>>();
        Assert.Equal(20, content.Items.Count);
        Assert.Equal(25, content.TotalCount);
        Assert.Equal(2, content.TotalPages);
    }

    [Fact]
    public async Task GetSessionHistory_WithGameModeFilter_Returns200WithFilteredData()
    {
        // Arrange
        var userId = _authenticator.CurrentUserId;
        await SeedTestSessions(userId, 10, new[] { GameMode.Standard501, GameMode.Cricket });

        // Act
        var response = await _client.GetAsync("/api/sessions?pageNumber=1&pageSize=20&gameMode=Cricket");

        // Assert
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        var content = await response.Content.ReadAsAsync<PagedResult<SessionSummaryDto>>();
        Assert.All(content.Items, item => Assert.Equal(GameMode.Cricket, item.GameMode));
    }

    [Fact]
    public async Task GetSessionDetail_WithValidSessionId_Returns200WithFullData()
    {
        // Arrange
        var userId = _authenticator.CurrentUserId;
        var session = await SeedTestSession(userId);

        // Act
        var response = await _client.GetAsync($"/api/sessions/{session.Id}");

        // Assert
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        var content = await response.Content.ReadAsAsync<SessionDetailDto>();
        Assert.Equal(session.Id, content.Id);
        Assert.NotEmpty(content.Turns);
    }

    [Fact]
    public async Task GetSessionDetail_WithUnauthorizedSession_Returns403()
    {
        // Arrange
        var otherUserId = Guid.NewGuid();
        var session = await SeedTestSession(otherUserId);

        // Act
        var response = await _client.GetAsync($"/api/sessions/{session.Id}");

        // Assert
        Assert.Equal(HttpStatusCode.Forbidden, response.StatusCode);
    }

    [Fact]
    public async Task GetSessionDetail_WithNonexistentSession_Returns404()
    {
        // Act
        var response = await _client.GetAsync($"/api/sessions/{Guid.NewGuid()}");

        // Assert
        Assert.Equal(HttpStatusCode.NotFound, response.StatusCode);
    }

    [Fact]
    public async Task GetSessionHistory_WithoutAuthentication_Returns401()
    {
        // Arrange
        var unauthenticatedClient = _factory.CreateClient();

        // Act
        var response = await unauthenticatedClient.GetAsync("/api/sessions");

        // Assert
        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }

    private async Task SeedTestSessions(Guid userId, int count, GameMode[] modes = null)
    {
        modes ??= new[] { GameMode.Standard501, GameMode.Cricket, GameMode.Standard301, GameMode.NumberFocus };
        using var scope = _factory.Services.CreateScope();
        var dbContext = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();

        var sessions = Enumerable.Range(0, count)
            .Select(i => new GameSession
            {
                Id = Guid.NewGuid(),
                UserId = userId,
                GameMode = modes[i % modes.Length],
                CreatedAt = DateTime.UtcNow.AddDays(-(count - i))
            })
            .ToList();

        await dbContext.Sessions.AddRangeAsync(sessions);
        await dbContext.SaveChangesAsync();
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
            CreatedAt = DateTime.UtcNow,
            Turns = new List<Turn>
            {
                new Turn
                {
                    TurnNumber = 1,
                    DartEntries = new List<DartEntry>
                    {
                        new DartEntry { Value = 20, Multiplier = Multiplier.Triple },
                        new DartEntry { Value = 20, Multiplier = Multiplier.Double },
                        new DartEntry { Value = 19, Multiplier = Multiplier.Single }
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

- **Unit Tests:** >80% coverage of handler logic
- **Pagination:** All page number scenarios (first, middle, last, invalid)
- **Filtering:** All game modes individually and combined
- **User Scoping:** Verify users cannot access other users' sessions
- **Edge Cases:** Empty results, large datasets, invalid inputs
- **Integration:** Full HTTP request/response cycle

---

## Definition of Done

- [ ] All unit tests pass
- [ ] All integration tests pass
- [ ] Code coverage >80% for query handlers
- [ ] Pagination logic fully tested (edge cases included)
- [ ] User scoping verified (unauthorized access prevented)
- [ ] Both queries tested with real HTTP requests
- [ ] Authentication required verified (401 for unauthenticated)
- [ ] Authorization verified (403 for unauthorized users)
- [ ] Happy path and error paths covered
- [ ] No flaky tests

---

## References

- [xUnit Documentation](https://xunit.net/)
- [Moq Documentation](https://github.com/moq/moq4)
- [CQRS Query Testing Patterns](../../shared/TESTING-GUIDE.md)
- [Integration Test Setup](../../shared/INTEGRATION-TEST-SETUP.md)
