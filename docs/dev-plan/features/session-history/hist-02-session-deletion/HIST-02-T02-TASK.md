# HIST-02-T02 — API: StatsRecalculationService (BackgroundService)

**Story:** [HIST-02](../HIST-02-STORY.md)
**Layer:** Backend (Infrastructure)
**Status:** Not Started
**Assigned To:** —
**Complexity:** L

---

## What to Build

Implement a BackgroundService that consumes from the recalculation queue (Channel<Guid>), calculates updated stats for each user, and persists them. The service maintains an IsRecalculating flag per user to allow the frontend to track progress.

---

## Files to Create/Modify

| Path | Purpose | Status |
|------|---------|--------|
| `Infrastructure/BackgroundServices/StatsRecalculationService.cs` | BackgroundService implementation | To Create |
| `Infrastructure/BackgroundServices/RecalculationState.cs` | In-memory state tracking (IsRecalculating per user) | To Create |
| `Application/Stats/Services/StatsCalculationService.cs` | Core stats calculation logic (aggregates, PBs) | To Create |

---

## Implementation Notes

### BackgroundService

**StatsRecalculationService.cs:**
```csharp
public class StatsRecalculationService : BackgroundService
{
    private readonly IServiceProvider _serviceProvider;
    private readonly IRecalculationQueue _recalculationQueue;
    private readonly RecalculationState _recalculationState;
    private readonly ILogger<StatsRecalculationService> _logger;

    public StatsRecalculationService(
        IServiceProvider serviceProvider,
        IRecalculationQueue recalculationQueue,
        RecalculationState recalculationState,
        ILogger<StatsRecalculationService> logger)
    {
        _serviceProvider = serviceProvider;
        _recalculationQueue = recalculationQueue;
        _recalculationState = recalculationState;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("StatsRecalculationService started.");

        try
        {
            await foreach (var userId in _recalculationQueue.DequeueAsync(stoppingToken))
            {
                try
                {
                    _logger.LogInformation("Processing recalculation for user {UserId}", userId);

                    // Mark user as recalculating
                    _recalculationState.SetIsRecalculating(userId, true);

                    // Process in a separate scope to avoid issues with DbContext lifetime
                    using (var scope = _serviceProvider.CreateScope())
                    {
                        var statsService = scope.ServiceProvider.GetRequiredService<IStatsCalculationService>();
                        await statsService.RecalculateUserStatsAsync(userId, stoppingToken);
                    }

                    _logger.LogInformation("Recalculation completed for user {UserId}", userId);
                }
                catch (Exception ex)
                {
                    _logger.LogError(
                        ex,
                        "Error recalculating stats for user {UserId}",
                        userId);
                    // Continue processing queue; log error but don't crash service
                }
                finally
                {
                    // Mark user as done recalculating
                    _recalculationState.SetIsRecalculating(userId, false);
                }
            }
        }
        catch (OperationCanceledException)
        {
            _logger.LogInformation("StatsRecalculationService is shutting down.");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "StatsRecalculationService encountered an unexpected error.");
            throw;
        }
    }
}
```

### Recalculation State Tracker

**RecalculationState.cs:**
```csharp
public class RecalculationState
{
    private readonly ConcurrentDictionary<Guid, bool> _isRecalculatingMap = new();

    public void SetIsRecalculating(Guid userId, bool isRecalculating)
    {
        if (isRecalculating)
        {
            _isRecalculatingMap[userId] = true;
        }
        else
        {
            _isRecalculatingMap.Remove(userId, out _);
        }
    }

    public bool GetIsRecalculating(Guid userId)
    {
        return _isRecalculatingMap.ContainsKey(userId) && _isRecalculatingMap[userId];
    }

    public IEnumerable<Guid> GetRecalculatingUsers()
    {
        return _isRecalculatingMap.Keys.ToList();
    }
}
```

### Stats Calculation Service Interface

**IStatsCalculationService.cs:**
```csharp
public interface IStatsCalculationService
{
    Task RecalculateUserStatsAsync(Guid userId, CancellationToken cancellationToken);
}

public class StatsCalculationService : IStatsCalculationService
{
    private readonly IApplicationDbContext _context;
    private readonly ILogger<StatsCalculationService> _logger;

    public StatsCalculationService(
        IApplicationDbContext context,
        ILogger<StatsCalculationService> logger)
    {
        _context = context;
        _logger = logger;
    }

    public async Task RecalculateUserStatsAsync(Guid userId, CancellationToken cancellationToken)
    {
        // 1. Get all non-deleted sessions for user
        var sessions = await _context.Sessions
            .Where(s => s.UserId == userId && !s.IsDeleted)
            .Include(s => s.Turns)
            .ThenInclude(t => t.DartEntries)
            .ToListAsync(cancellationToken);

        _logger.LogInformation(
            "Recalculating stats for user {UserId} with {SessionCount} sessions",
            userId,
            sessions.Count);

        if (sessions.Count == 0)
        {
            // User has no sessions; clear their stats
            await ClearUserStatsAsync(userId, cancellationToken);
            return;
        }

        // 2. Calculate aggregates per game mode
        var stats = new Dictionary<GameMode, UserStats>();

        foreach (var mode in Enum.GetValues<GameMode>())
        {
            var modeSessions = sessions.Where(s => s.GameMode == mode).ToList();
            if (modeSessions.Count == 0)
                continue;

            var aggregated = CalculateAggregates(modeSessions, mode);
            stats[mode] = aggregated;
        }

        // 3. Calculate overall stats (all modes combined)
        var overallStats = CalculateAggregates(sessions, null);
        stats[GameMode.Overall] = overallStats;

        // 4. Persist updated stats
        foreach (var (mode, userStats) in stats)
        {
            var existing = await _context.UserStats
                .FirstOrDefaultAsync(us => us.UserId == userId && us.GameMode == mode, cancellationToken);

            if (existing != null)
            {
                existing.GamesPlayed = userStats.GamesPlayed;
                existing.Avg3Dart = userStats.Avg3Dart;
                existing.CheckoutPercentage = userStats.CheckoutPercentage;
                existing.TotalDarts = userStats.TotalDarts;
                existing.HighestCheckout = userStats.HighestCheckout;
                existing.LastUpdated = DateTime.UtcNow;
                _context.UserStats.Update(existing);
            }
            else
            {
                userStats.UserId = userId;
                userStats.GameMode = mode;
                userStats.LastUpdated = DateTime.UtcNow;
                await _context.UserStats.AddAsync(userStats, cancellationToken);
            }
        }

        // 5. Recalculate personal bests
        await RecalculatePersonalBestsAsync(userId, sessions, cancellationToken);

        // 6. Persist all changes
        await _context.SaveChangesAsync(cancellationToken);

        _logger.LogInformation(
            "Stats recalculation completed for user {UserId}. Updated {ModeCount} stat records.",
            userId,
            stats.Count);
    }

    private UserStats CalculateAggregates(List<GameSession> sessions, GameMode? mode)
    {
        var stats = new UserStats
        {
            GamesPlayed = sessions.Count,
            TotalDarts = sessions.Sum(s => s.Turns.Sum(t => t.DartEntries.Count)),
        };

        // Calculate 3-dart average
        var totalPoints = sessions.Sum(s => s.Turns.Sum(t =>
            t.DartEntries.Sum(d => d.Value * (int)d.Multiplier)));
        var totalDarts = stats.TotalDarts;
        stats.Avg3Dart = totalDarts > 0 ? Math.Round((double)totalPoints / totalDarts * 3, 2) : 0;

        // Calculate checkout percentage (if applicable)
        var checkoutGames = sessions.Where(s =>
            (s.GameMode == GameMode.Standard501 || s.GameMode == GameMode.Standard301) &&
            s.IsCompleted).Count();
        stats.CheckoutPercentage = sessions.Count > 0
            ? Math.Round((double)checkoutGames / sessions.Count * 100, 1)
            : 0;

        return stats;
    }

    private async Task RecalculatePersonalBestsAsync(Guid userId, List<GameSession> sessions, CancellationToken cancellationToken)
    {
        // 1. Clear existing personal bests for this user
        var existingPBs = await _context.PersonalBests
            .Where(pb => pb.UserId == userId)
            .ToListAsync(cancellationToken);
        _context.PersonalBests.RemoveRange(existingPBs);

        // 2. Calculate new personal bests from remaining sessions
        var pbsToCreate = new List<PersonalBest>();

        foreach (var session in sessions)
        {
            // High score (for applicable modes)
            if (session.GameMode == GameMode.Standard501 || session.GameMode == GameMode.Standard301)
            {
                var highScore = session.Turns
                    .OrderByDescending(t => t.TurnNumber)
                    .FirstOrDefault()?. DartEntries.Sum(d => d.Value * (int)d.Multiplier) ?? 0;

                pbsToCreate.Add(new PersonalBest
                {
                    UserId = userId,
                    MetricType = PersonalBestMetric.HighestScore,
                    GameMode = session.GameMode,
                    Value = highScore,
                    AchievedAt = session.CreatedAt
                });
            }

            // Average (3-dart or per-turn)
            var avg = CalculateSessionAverage(session);
            pbsToCreate.Add(new PersonalBest
            {
                UserId = userId,
                MetricType = PersonalBestMetric.ThreeDartAverage,
                GameMode = session.GameMode,
                Value = (int)avg,
                AchievedAt = session.CreatedAt
            });
        }

        // 3. Keep only the best of each metric per mode
        var deduplicatedPBs = pbsToCreate
            .GroupBy(pb => (pb.MetricType, pb.GameMode))
            .Select(g => g.OrderByDescending(pb => pb.Value).First())
            .ToList();

        await _context.PersonalBests.AddRangeAsync(deduplicatedPBs, cancellationToken);
    }

    private async Task ClearUserStatsAsync(Guid userId, CancellationToken cancellationToken)
    {
        var stats = await _context.UserStats
            .Where(us => us.UserId == userId)
            .ToListAsync(cancellationToken);
        _context.UserStats.RemoveRange(stats);

        var pbs = await _context.PersonalBests
            .Where(pb => pb.UserId == userId)
            .ToListAsync(cancellationToken);
        _context.PersonalBests.RemoveRange(pbs);

        await _context.SaveChangesAsync(cancellationToken);
    }

    private double CalculateSessionAverage(GameSession session)
    {
        var totalPoints = session.Turns.Sum(t =>
            t.DartEntries.Sum(d => d.Value * (int)d.Multiplier));
        var totalDarts = session.Turns.Sum(t => t.DartEntries.Count);
        return totalDarts > 0 ? (double)totalPoints / totalDarts * 3 : 0;
    }
}
```

### Dependency Injection Setup

Add to Program.cs or Startup.cs:

```csharp
services.AddSingleton<RecalculationState>();
services.AddSingleton<IRecalculationQueue, RecalculationQueue>();
services.AddScoped<IStatsCalculationService, StatsCalculationService>();
services.AddHostedService<StatsRecalculationService>();
```

---

## Definition of Done

- [ ] StatsRecalculationService BackgroundService implemented
- [ ] Service consumes from IRecalculationQueue (Channel<Guid>)
- [ ] RecalculationState singleton tracks IsRecalculating per user
- [ ] IStatsCalculationService interface defined
- [ ] StatsCalculationService recalculates all stats for a user
- [ ] Personal bests recalculated from remaining (non-deleted) sessions
- [ ] All changes persisted atomically via SaveChangesAsync
- [ ] Proper logging at key points (start, per-user, completion, errors)
- [ ] Error handling: errors logged but don't crash service
- [ ] Service properly registered in DI container
- [ ] Handles empty user state (no sessions)
- [ ] Unit tests verify recalculation logic and state management
- [ ] Integration tests verify full deletion-to-recalculation flow

---

## References

- [BackgroundService Documentation](https://docs.microsoft.com/en-us/dotnet/api/microsoft.extensions.hosting.backgroundservice)
- [System.Threading.Channels](https://docs.microsoft.com/en-us/dotnet/api/system.threading.channels)
- [Hosted Services in .NET](https://docs.microsoft.com/en-us/dotnet/core/extensions/generic-host)
