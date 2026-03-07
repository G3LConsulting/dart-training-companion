# INFRA-02 — Database Setup & EF Core Configuration

**Feature:** Infrastructure
**Phase:** MVP
**Status:** 🔲 Not started
**Agent:** —
**Output:** —
**Notes:** —

---

## Context

Sets up AppDbContext, all entity configurations, initial EF Core migration, and database seeding. This enables all subsequent data operations across the application.

> Implements: TA §5, §11

---

## Acceptance Criteria

- [ ] AppDbContext inherits from IdentityDbContext<ApplicationUser, IdentityRole<Guid>, Guid>
- [ ] All 9 entities configured with IEntityTypeConfiguration<T> classes in Infrastructure/Persistence/Configurations/
- [ ] ConfigurationJson and StatsJson mapped as PostgreSQL jsonb columns via EF Core value conversion
- [ ] Composite unique index on (UserId, GameMode) for UserStats
- [ ] Composite index on (UserId, IsDeleted, CompletedAt DESC) on GameSession
- [ ] Initial migration created and applies cleanly via `dotnet ef migrations add InitialCreate`
- [ ] `dbContext.Database.MigrateAsync()` called in Program.cs on startup
- [ ] All IsDeleted soft-delete flags defaulting to false in DB schema

---

## Technical Implementation Notes

**AppDbContext Setup:**
- Location: `Infrastructure/Persistence/AppDbContext.cs`
- Inherits from IdentityDbContext<ApplicationUser, IdentityRole<Guid>, Guid>
- Applies all IEntityTypeConfiguration<T> via ModelBuilder.ApplyConfigurationsFromAssembly()
- Global query filter applied to all soft-deletable entities: `.HasQueryFilter(e => !e.IsDeleted)`

**Entity Configurations:**
- Location: `Infrastructure/Persistence/Configurations/` — one file per entity (e.g., GameSessionConfiguration.cs, UserStatsConfiguration.cs)
- Each implements IEntityTypeConfiguration<T> and configures primary keys, relationships, constraints, and indexes

**JSON Column Mapping:**
- ConfigurationJson and StatsJson properties use `.HasColumnType("jsonb")` and `.HasConversion()` to serialize/deserialize
- Avoid N+1 queries by loading entire JSON objects; filtering within JSON is post-query in C#

**Indexes:**
- UserStats: unique index on (UserId, GameMode)
- GameSession: composite index on (UserId, IsDeleted, CompletedAt DESC) for efficient history queries
- Additional indexes as needed per query patterns identified in TA §5

**Migration & Startup:**
- Initial migration generated via `dotnet ef migrations add InitialCreate`
- Program.cs calls `using var scope = app.Services.CreateScope(); await scope.ServiceProvider.GetRequiredService<AppDbContext>().Database.MigrateAsync();`

---

## Dependencies

- INFRA-01 — Solution Scaffold & Project Setup — AppDbContext must exist within the Infrastructure project structure

---

## Shared References

- [Domain Model](../../shared/domain-model.md) — all 9 entities and their relationships
- [Architecture](../../shared/architecture.md) — §5 (persistence layer design), §11 (database configuration)
