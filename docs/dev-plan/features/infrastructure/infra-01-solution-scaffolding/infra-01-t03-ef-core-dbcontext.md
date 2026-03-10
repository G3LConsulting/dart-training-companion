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

- [ ] AppDbContext compiles and extends DbContext
- [ ] All DbSet<T> properties are defined for each entity
- [ ] IEntityTypeConfiguration<T> implementations configured via AddEntityTypesFromAssembly() or explicit configuration
- [ ] dotnet ef migrations add InitialCreate runs without error
- [ ] dotnet ef database update applies to local PostgreSQL without error
- [ ] All JSONB columns configured properly (e.g., game state, statistics as JSON)
- [ ] Composite indexes created where needed (e.g., UserId + GameType on GameSession)
- [ ] Foreign key constraints properly defined
- [ ] Temporal/audit columns (CreatedAt, UpdatedAt) configured with automatic value generation
- [ ] PostgreSQL-specific features used appropriately (e.g., uuid, jsonb, array types)

## Implementation Notes

1. **DbContext Setup**:
   - Configure PostgreSQL provider with NpgsqlConnection
   - Register all DbSet<T> properties
   - Override OnModelCreating to apply configurations
   - Add seed data for any required static data (e.g., game modes)

2. **Entity Configurations**:
   - Use builder.Entity<T>().HasKey() for primary keys
   - Configure one-to-many relationships with HasOne/WithMany
   - Configure many-to-many relationships if needed
   - Set indexes using HasIndex()
   - Configure value conversions for enums

3. **PostgreSQL Specific**:
   - Use .HasColumnType("jsonb") for JSON fields
   - Use .HasColumnType("uuid") for Guid columns
   - Use .HasColumnType("text[]") for array types if needed
   - Enable UUID generation with .HasDefaultValueSql("gen_random_uuid()")

4. **Audit Columns**:
   - Add CreatedAt and UpdatedAt to base entity
   - Configure with .HasDefaultValueSql("CURRENT_TIMESTAMP")
   - UpdatedAt should be set on model changes (may require a SaveChanges override)

5. **Migration Workflow**:
   - Add Microsoft.EntityFrameworkCore.Tools NuGet package
   - Add Npgsql.EntityFrameworkCore.PostgreSQL NuGet package
   - Ensure DartsCompanion.Api has Program.cs with DbContext registration
   - Run: dotnet ef migrations add InitialCreate --project src/DartsCompanion.Infrastructure
   - Verify migration SQL before applying
   - Run: dotnet ef database update to apply

## References

- [Domain Model](../../../shared/domain-model.md)
- [Technical Approach §5](../../../shared/technical-approach.md#section-5-domain-model)
- [Technical Approach §11](../../../shared/technical-approach.md#section-11-infrastructure--deployment)
