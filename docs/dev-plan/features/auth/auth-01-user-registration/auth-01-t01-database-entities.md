# AUTH-01-T01 — DB: ApplicationUser & RefreshToken Entities

**Story:** [AUTH-01 — User Registration & Email Verification](story.md)  **Layer:** Data  **Status:** 🔲 Not started  **Agent:** —

---

## What to build

Set up ASP.NET Core Identity integration with the application DbContext. Create ApplicationUser entity extending IdentityUser with custom fields (DisplayName, DominantHand, PreferredGameMode, TargetAverage, PreferredWeekStartDay, CustomMetricSlot, IsDeleted, DeletedAt). Create RefreshToken entity to store issued refresh tokens with expiry tracking. Create database migrations to initialize Identity tables and custom tables. Seed initial data if needed via IdentitySeeder.

---

## Files to create or modify

| Action | Path |
|--------|------|
| Modify | `src/DartsCompanion.Domain/Entities/ApplicationUser.cs` |
| Modify | `src/DartsCompanion.Domain/Entities/RefreshToken.cs` |
| Modify | `src/DartsCompanion.Infrastructure/Persistence/Data/AppDbContext.cs` |
| Create | `src/DartsCompanion.Infrastructure/Persistence/Seeders/IdentitySeeder.cs` |
| Create | `src/DartsCompanion.Infrastructure/Persistence/Migrations/[timestamp]_InitialIdentity.cs` |

---

## Definition of done

- [ ] ApplicationUser extends IdentityUser with custom properties
- [ ] RefreshToken entity created with ExpiryDate and IsRevoked properties
- [ ] AppDbContext inherits from IdentityDbContext<ApplicationUser>
- [ ] All DbSet<T> mappings configured in OnModelCreating
- [ ] Migration created and applied successfully
- [ ] IdentitySeeder can run to initialize any seed data
- [ ] No compilation errors; migrations apply cleanly to fresh database

---

## Implementation notes

- ApplicationUser should include: Id (from IdentityUser), Email, NormalizedEmail, DisplayName (max 100), DominantHand (left/right enum), PreferredGameMode (string, default 501), TargetAverage (decimal, nullable), PreferredWeekStartDay (DayOfWeek), CustomMetricSlot (string, nullable), IsDeleted (bool, default false), DeletedAt (DateTime?, nullable), CreatedAt (DateTime), UpdatedAt (DateTime)
- RefreshToken: Id (Guid), ApplicationUserId (string, FK), Token (string, unique), ExpiryDate (DateTime), IsRevoked (bool, default false), CreatedAt (DateTime)
- Use Fluent API in OnModelCreating to enforce: Email is unique, DisplayName is required, RefreshToken.Token has unique index
- Link to [Domain Model](../../shared/domain-model.md) for entity specifications

---

## References

- [Story: AUTH-01](story.md)
- [Domain Model](../../shared/domain-model.md)
- [Architecture](../../shared/architecture.md)
- ASP.NET Core Identity Documentation
