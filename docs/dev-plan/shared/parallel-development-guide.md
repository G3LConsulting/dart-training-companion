> **Shared reference document** — Parallel development guide for multi-agent worktree execution. All agents must read this before starting work.

# Parallel Development Guide

This document describes how multiple development agents can work on this plan concurrently using **git worktrees** without creating merge conflicts. Every agent must follow these patterns.

---

## Core Principle

Each agent works in its own **git worktree** on a **feature branch**. Bottleneck files — files that multiple stories touch — are structured so that each feature contributes its own isolated file, which is then auto-discovered at runtime. This eliminates merge conflicts on shared files.

---

## Wave Execution Strategy

Stories should be executed in dependency waves. All stories within a wave can run in parallel.

### Wave 0 — Foundation (sequential)
| Story | Description |
|-------|-------------|
| INFRA-01 | Solution scaffolding, domain model, DbContext, Angular scaffold |

INFRA-01 **must complete and merge to `main` before any other work starts.** It establishes the patterns all other stories depend on.

### Wave 1 — Core Features (parallel)
| Story | Description |
|-------|-------------|
| INFRA-02 | Docker Compose & local dev |
| INFRA-03 | CI/CD pipeline |
| INFRA-04 | Observability setup |
| AUTH-01 | User registration |
| GAME-01 | Game setup & mode selection |
| DESK-01 | Responsive layout & desktop nav |
| PWA-01 | Service worker & installability |

### Wave 2 — Depends on AUTH-01 + GAME-01 (parallel)
| Story | Description |
|-------|-------------|
| AUTH-02 | Login & JWT |
| AUTH-03 | Password reset |
| GAME-02 | 501/301 score entry |
| GAME-07 | Number focus session |

### Wave 3 — Depends on AUTH-02 + GAME-02 (parallel)
| Story | Description |
|-------|-------------|
| AUTH-04 | Account deletion |
| PROF-01 | Profile management |
| GAME-03 | Checkout suggestions |
| GAME-04 | Game completion & post-game summary |
| GAME-05 | Cricket pass-and-play |

### Wave 4 — Depends on GAME-04 + PROF-01 (parallel)
| Story | Description |
|-------|-------------|
| PROF-02 | Home screen |
| GAME-06 | Cricket solo drill |
| GAME-08 | Session auto-save & resume |
| HIST-01 | Session history list |
| SYNC-01 | Offline session queue |
| STAT-01 | Stats dashboard & KPIs |
| EXPO-01 | Export infrastructure & CSV |

### Wave 5 — Final MVP (parallel)
| Story | Description |
|-------|-------------|
| HIST-02 | Session deletion & stats recalc |
| SYNC-02 | Sync conflict resolution |
| STAT-02 | Trend charts |
| STAT-03 | Personal bests |
| STAT-04 | Per-game-mode breakdown |
| STAT-05 | Scoring distribution |
| STAT-06 | Weekly summary |
| DESK-02 | Enhanced stats dashboard (desktop) |
| DESK-03 | Number focus heat grid (desktop) |
| EXPO-02 | Excel export |
| EXPO-03 | JSON export |
| PWA-02 | Light & dark mode |

---

## Bottleneck Files & Mitigation Patterns

These are files that multiple stories would normally need to modify. The patterns below ensure each agent only touches its own files.

### 1. `Program.cs` — DI Extension Methods

**Problem:** Every feature needs to register its services in `Program.cs`.

**Solution:** Each layer exposes a single `Add{Layer}Services()` extension method. Features register themselves inside their own `DependencyInjection.cs` file.

```csharp
// Program.cs — set up once in INFRA-01, never modified by feature agents
var builder = WebApplication.CreateBuilder(args);

builder.Services
    .AddDomainServices()
    .AddApplicationServices()
    .AddInfrastructureServices(builder.Configuration)
    .AddApiServices();

var app = builder.Build();
// middleware pipeline...
app.Run();
```

```csharp
// DartsCompanion.Application/DependencyInjection.cs
public static class DependencyInjection
{
    public static IServiceCollection AddApplicationServices(this IServiceCollection services)
    {
        services.AddMediatR(cfg => cfg.RegisterServicesFromAssembly(typeof(DependencyInjection).Assembly));
        services.AddValidatorsFromAssembly(typeof(DependencyInjection).Assembly);
        services.AddTransient(typeof(IPipelineBehavior<,>), typeof(ValidationBehaviour<,>));
        return services;
    }
}
```

```csharp
// DartsCompanion.Infrastructure/DependencyInjection.cs
public static class DependencyInjection
{
    public static IServiceCollection AddInfrastructureServices(
        this IServiceCollection services, IConfiguration configuration)
    {
        services.AddDbContext<AppDbContext>(options =>
            options.UseNpgsql(configuration.GetConnectionString("DefaultConnection")));

        services.AddIdentity<ApplicationUser, IdentityRole<Guid>>()
            .AddEntityFrameworkStores<AppDbContext>()
            .AddDefaultTokenProviders();

        // Feature agents add their services here, each in a clearly marked region
        return services;
    }
}
```

**Rule:** Feature agents **never touch `Program.cs`**. They register services by adding them to the appropriate `DependencyInjection.cs` file in their own feature folder, or to the layer-level `DependencyInjection.cs` if it's a cross-cutting concern.

---

### 2. `AppDbContext.cs` — Assembly-Scanned Entity Configurations

**Problem:** Every entity needs a `DbSet<T>` property and configuration in `AppDbContext`.

**Solution:**
- `DbSet<T>` properties are added to `AppDbContext` — but since each agent adds a **different property** on a **different line**, these merge cleanly as long as agents don't reformat the file.
- Entity configurations use `ApplyConfigurationsFromAssembly()` which auto-discovers all `IEntityTypeConfiguration<T>` implementations. Feature agents only create their own configuration file.

```csharp
// AppDbContext.cs — created in INFRA-01
public class AppDbContext : IdentityDbContext<ApplicationUser, IdentityRole<Guid>, Guid>
{
    // Each feature agent adds its DbSet<T> here — one property per line
    public DbSet<GameSession> GameSessions => Set<GameSession>();
    public DbSet<Turn> Turns => Set<Turn>();
    // ...

    protected override void OnModelCreating(ModelBuilder builder)
    {
        base.OnModelCreating(builder);

        // Auto-discovers ALL IEntityTypeConfiguration<T> in the Infrastructure assembly
        builder.ApplyConfigurationsFromAssembly(typeof(AppDbContext).Assembly);
    }
}
```

**Rule:** Feature agents create their entity configuration in `Persistence/Configurations/{EntityName}Configuration.cs`. The `ApplyConfigurationsFromAssembly` call picks them up automatically — no need to modify `AppDbContext.OnModelCreating`.

---

### 3. `app.routes.ts` — Feature-Scoped Lazy Routes

**Problem:** Every Angular feature needs routes registered in `app.routes.ts`.

**Solution:** Each feature defines its own route file. The root `app.routes.ts` only contains lazy-load pointers that are set up once in INFRA-01.

```typescript
// app.routes.ts — set up once in INFRA-01, rarely modified
import { Routes } from '@angular/router';

export const routes: Routes = [
  { path: '', redirectTo: 'home', pathMatch: 'full' },
  {
    path: 'auth',
    loadChildren: () => import('./features/auth/auth.routes').then(m => m.AUTH_ROUTES)
  },
  {
    path: 'game',
    loadChildren: () => import('./features/game/game.routes').then(m => m.GAME_ROUTES)
  },
  {
    path: 'stats',
    loadChildren: () => import('./features/stats/stats.routes').then(m => m.STATS_ROUTES)
  },
  {
    path: 'history',
    loadChildren: () => import('./features/history/history.routes').then(m => m.HISTORY_ROUTES)
  },
  {
    path: 'profile',
    loadChildren: () => import('./features/profile/profile.routes').then(m => m.PROFILE_ROUTES)
  },
  {
    path: 'export',
    loadChildren: () => import('./features/export/export.routes').then(m => m.EXPORT_ROUTES)
  },
  {
    path: 'home',
    loadComponent: () => import('./features/home/home.component').then(m => m.HomeComponent)
  },
  { path: '**', redirectTo: 'home' }
];
```

```typescript
// features/game/game.routes.ts — owned entirely by game feature agents
import { Routes } from '@angular/router';

export const GAME_ROUTES: Routes = [
  {
    path: 'new',
    loadComponent: () => import('./new-game/new-game.component').then(m => m.NewGameComponent)
  },
  {
    path: ':id',
    loadComponent: () => import('./game-board/game-board.component').then(m => m.GameBoardComponent)
  },
  // Feature agent adds routes here — no conflict with other features
];
```

**Rule:** Feature agents **never modify `app.routes.ts`**. They create/modify only their own `features/{feature}/feature.routes.ts` file.

---

### 4. `app.config.ts` — Provider Composition

**Problem:** Multiple features may need to register Angular providers.

**Solution:** Feature-specific providers are registered in feature-scoped files and composed in `app.config.ts` once during INFRA-01.

```typescript
// app.config.ts — set up once in INFRA-01
import { ApplicationConfig, provideZoneChangeDetection } from '@angular/core';
import { provideRouter } from '@angular/router';
import { provideHttpClient, withInterceptors } from '@angular/common/http';
import { provideServiceWorker } from '@angular/service-worker';
import { provideAnimations } from '@angular/platform-browser/animations';
import { routes } from './app.routes';
import { authInterceptor } from './core/auth/auth.interceptor';
import { environment } from '../environments/environment';

export const appConfig: ApplicationConfig = {
  providers: [
    provideZoneChangeDetection({ eventCoalescing: true }),
    provideRouter(routes),
    provideHttpClient(withInterceptors([authInterceptor])),
    provideAnimations(),
    provideServiceWorker('ngsw-worker.js', {
      enabled: environment.production,
      registrationStrategy: 'registerWhenStable:30000'
    }),
  ]
};
```

**Rule:** Feature agents do not modify `app.config.ts`. Feature-specific services are provided via `providedIn: 'root'` or route-level providers in the feature's own route file.

---

### 5. `docker-compose.yml` — Additive Service Blocks

**Problem:** INFRA-02 creates the base compose file, but later stories may need additional services.

**Solution:** INFRA-02 creates a complete `docker-compose.yml` with all 8 services upfront (API, Web, nginx, postgres, seq, prometheus, grafana, mailhog). No subsequent story should need to modify it. If a post-MVP feature requires a new service, use `docker-compose.override.yml`.

---

## EF Core Migration Protocol

EF Core migrations are the **highest-conflict-risk** area because the model snapshot file (`AppDbContextModelSnapshot.cs`) is a single auto-generated file that changes with every migration.

### Rules

1. **Only one agent creates migrations per wave.** At the end of each wave, a designated "migration agent" (or the human reviewer) consolidates all entity and configuration changes into a single migration.

2. **Feature agents do NOT run `dotnet ef migrations add`.** They create entity classes and `IEntityTypeConfiguration<T>` files only. The migration is generated after their PRs merge.

3. **Migration merge workflow:**
   ```
   1. All feature branches in the wave merge to `main`
   2. Migration agent checks out `main`
   3. Runs: dotnet ef migrations add Wave{N}_{Description}
   4. Commits the migration + snapshot as a separate commit
   5. All agents in the next wave pull `main` before starting
   ```

4. **If two agents accidentally create migrations:** The second one to merge will have a snapshot conflict. Resolution:
   ```bash
   # Delete the conflicting migration
   dotnet ef migrations remove
   # Re-create from the merged model
   dotnet ef migrations add {NewMigrationName}
   ```

5. **Emergency single-story migration:** If a story absolutely must create its own migration (e.g., INFRA-01 creating the initial schema), it should be the only story running at that time. This is already the case since INFRA-01 is in Wave 0 alone.

---

## Git Worktree Workflow

### Agent setup
```bash
# From the main repo checkout
git worktree add ../worktree-{story-id} -b feature/{story-id}
cd ../worktree-{story-id}
```

### Agent completion
```bash
# In the worktree
git add -A
git commit -m "feat({feature}): {story-id} — {description}"
git push -u origin feature/{story-id}
# Create PR targeting main
```

### Cleanup after merge
```bash
# From the main repo
git worktree remove ../worktree-{story-id}
git branch -d feature/{story-id}
```

---

## PR & Merge Rules

1. **One PR per story.** Each story maps to exactly one feature branch and one PR.
2. **PRs within the same wave can merge in any order** — the patterns above prevent conflicts.
3. **PRs must not modify bottleneck files** unless the story explicitly owns that file (e.g., INFRA-01 owns `Program.cs`).
4. **Squash merge to `main`** to keep history clean.
5. **After all PRs in a wave merge**, run the migration consolidation step before starting the next wave.
6. **CI must pass** on the feature branch before merge. The CI pipeline (INFRA-03) runs build + test on every PR.

---

## Checklist for Agents

Before starting work on a story:

- [ ] Pull latest `main`
- [ ] Create a new worktree and feature branch
- [ ] Read this guide and the story's task files
- [ ] Verify all dependency stories are marked `✅ Done`

Before creating a PR:

- [ ] All Definition of Done items in the task files pass
- [ ] No modifications to bottleneck files (`Program.cs`, `app.routes.ts`, `app.config.ts`)
- [ ] No EF Core migrations created (unless you are the migration agent)
- [ ] Entity configurations use `IEntityTypeConfiguration<T>` pattern
- [ ] Angular routes are in feature-scoped route files
- [ ] Services use `providedIn: 'root'` or feature route providers
- [ ] All tests pass locally
