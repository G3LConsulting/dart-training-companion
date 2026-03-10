# INFRA-01-T03 — EF Core DbContext & Initial Migration

| Metadata | Value |
|----------|-------|
| Story | [INFRA-01](../infra-01-solution-scaffolding.md) — Solution Scaffolding & Domain Model |
| Layer | DB |
| Status | 🔲 Not started |
| Agent | Backend Lead |

## What to Build

Create AppDbContext, entity configurations using IEntityTypeConfiguration<T> pattern per entity, and generate the initial database migration targeting PostgreSQL.

## Files to Create or Modify

| File Path | Purpose | Type |
|-----------|---------|------|
| src/DartsCompanion.Infrastructure/Persistence/AppDbContext.cs | EF Core DbContext | Create |
| src/DartsCompanion.Infrastructure/Persistence/Configurations/ApplicationUserConfiguration.cs | ApplicationUser mapping | Create |
| src/DartsCompanion.Infrastructure/Persistence/Configurations/RefreshTokenConfiguration.cs | RefreshToken mapping | Create |
| src/DartsCompanion.Infrastructure/Persistence/Configurations/GameSessionConfiguration.cs | GameSession mapping | Create |
| src/DartsCompanion.Infrastructure/Persistence/Configurations/TurnConfiguration.cs | Turn mapping | Create |
| src/DartsCompanion.Infrastructure/Persistence/Configurations/CricketTurnConfiguration.cs | CricketTurn mapping | Create |
| src/DartsCompanion.Infrastructure/Persistence/Configurations/DartEntryConfiguration.cs | DartEntry mapping | Create |
| src/DartsCompanion.Infrastructure/Persistence/Configurations/UserStatsConfiguration.cs | UserStats mapping | Create |
| src/DartsCompanion.Infrastructure/Persistence/Configurations/PersonalBestConfiguration.cs | PersonalBest mapping | Create |
| src/DartsCompanion.Infrastructure/Persistence/Configurations/ExportJobConfiguration.cs | ExportJob mapping | Create |
| Migrations/[timestamp]_InitialCreate.cs | Initial migration | Create |
| Migrations/AppDbContextModelSnapshot.cs | EF Core model snapshot | Create |

## Definition of Done

- [ ] AppDbContext compiles and extends `IdentityDbContext<ApplicationUser, IdentityRole<Guid>, Guid>`
- [ ] All DbSet<T> properties are defined for each entity
- [ ] `OnModelCreating` uses `ApplyConfigurationsFromAssembly(typeof(AppDbContext).Assembly)` — feature agents will create configuration files that are auto-discovered
- [ ] Each entity has its own `IEntityTypeConfiguration<T>` implementation in `Persistence/Configurations/`
- [ ] `dotnet ef migrations add InitialCreate` runs without error
- [ ] `dotnet ef database update` applies to local PostgreSQL without error
- [ ] All JSONB columns configured properly (e.g., game state, statistics as JSON)
- [ ] Composite indexes created where needed (e.g., UserId + GameType on GameSession)
- [ ] Foreign key constraints properly defined
- [ ] Temporal/audit columns (CreatedAt, UpdatedAt) configured with automatic value generation
- [ ] PostgreSQL-specific features used appropriately (e.g., uuid, jsonb, array types)

## Implementation Notes

1. **DbContext Setup — Critical for Parallel Development**:
   - Extend `IdentityDbContext<ApplicationUser, IdentityRole<Guid>, Guid>`
   - Register all DbSet<T> properties for INFRA-01 entities
   - **Use `ApplyConfigurationsFromAssembly` in `OnModelCreating`** — this auto-discovers all `IEntityTypeConfiguration<T>` implementations in the Infrastructure assembly, so feature agents never need to touch `OnModelCreating`

   ```csharp
   public class AppDbContext : IdentityDbContext<ApplicationUser, IdentityRole<Guid>, Guid>
   {
       public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

       // DbSet properties — feature agents add their own here
       public DbSet<GameSession> GameSessions => Set<GameSession>();
       public DbSet<Turn> Turns => Set<Turn>();
       public DbSet<CricketTurn> CricketTurns => Set<CricketTurn>();
       public DbSet<DartEntry> DartEntries => Set<DartEntry>();
       public DbSet<UserStats> UserStats => Set<UserStats>();
       public DbSet<PersonalBest> PersonalBests => Set<PersonalBest>();
       public DbSet<ExportJob> ExportJobs => Set<ExportJob>();
       public DbSet<RefreshToken> RefreshTokens => Set<RefreshToken>();

       protected override void OnModelCreating(ModelBuilder builder)
       {
           base.OnModelCreating(builder);
           // Auto-discovers ALL IEntityTypeConfiguration<T> in this assembly
           builder.ApplyConfigurationsFromAssembly(typeof(AppDbContext).Assembly);
       }

       public override Task<int> SaveChangesAsync(CancellationToken ct = default)
       {
           // Auto-set UpdatedAt for modified entities
           foreach (var entry in ChangeTracker.Entries<BaseEntity>()
               .Where(e => e.State == EntityState.Modified))
           {
               entry.Entity.UpdatedAt = DateTime.UtcNow;
           }
           return base.SaveChangesAsync(ct);
       }
   }
   ```

2. **Entity Configurations (one file per entity)**:
   - Create in `Persistence/Configurations/{EntityName}Configuration.cs`
   - Use `builder.HasKey()` for primary keys
   - Configure relationships with HasOne/WithMany
   - Set indexes using HasIndex()
   - Configure value conversions for enums
   - **Each config file is owned by one feature** — no merge conflicts

3. **PostgreSQL Specific**:
   - Use `.HasColumnType("jsonb")` for JSON fields
   - Use `.HasColumnType("uuid")` for Guid columns
   - Enable UUID generation with `.HasDefaultValueSql("gen_random_uuid()")`

4. **Audit Columns**:
   - Define `BaseEntity` with `CreatedAt` and `UpdatedAt`
   - Configure `CreatedAt` with `.HasDefaultValueSql("CURRENT_TIMESTAMP")`
   - `UpdatedAt` set via `SaveChangesAsync` override (see above)

5. **Migration Workflow — INFRA-01 Only**:
   - INFRA-01 is the only story that creates a migration (Wave 0, runs alone)
   - Add Microsoft.EntityFrameworkCore.Tools NuGet package
   - Add Npgsql.EntityFrameworkCore.PostgreSQL NuGet package
   - Run: `dotnet ef migrations add InitialCreate --project src/DartsCompanion.Infrastructure`
   - Verify migration SQL before applying
   - Run: `dotnet ef database update` to apply
   - **All subsequent migrations are created by the migration agent after each wave merges** — see [Parallel Development Guide](../../../shared/parallel-development-guide.md#ef-core-migration-protocol)

## References

- [Domain Model](../../../shared/domain-model.md)
- [Architecture](../../../shared/architecture.md)
- [Parallel Development Guide](../../../shared/parallel-development-guide.md)
