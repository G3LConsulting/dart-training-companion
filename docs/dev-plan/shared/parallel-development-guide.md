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

## Centralised Logging

All logs are written to `/logs` in the **repo root** on the **main worktree**, not to the agent's own worktree. This ensures logs survive worktree cleanup and all activity is visible in one place. Agent activity and build output are separated into their own subdirectories.

### Log directory structure

```
/logs/                          # repo root — gitignored
├── agents/
│   ├── AGENT-LOG.md            # Append-only summary log (all agents write here)
│   ├── AUTH-01.log             # Per-story agent log (decisions, status, errors)
│   ├── GAME-02.log
│   └── ...
└── builds/
    ├── AUTH-01-build.log       # dotnet build / ng build output
    ├── AUTH-01-test.log        # dotnet test output
    ├── GAME-02-build.log
    ├── GAME-02-test.log
    └── ...
```

- **`/logs/agents/`** — agent activity: story start/stop, PR events, cleanup steps, decisions, errors.
- **`/logs/builds/`** — raw build and test output only. One file per story per type (build, test).

Both directories live in the main worktree and are **gitignored** — logs are local working artifacts, not committed to the repo.

### Setup (one-time, done by whoever starts the project)

```bash
# In the main repo checkout
mkdir -p logs/agents logs/builds
echo "# Agent Activity Log" > logs/agents/AGENT-LOG.md
echo "/logs/" >> .gitignore
```

### How agents log

Every agent resolves the **absolute path to the main worktree's log directories** at startup and writes all output there. The main worktree path is the directory where the original `git clone` lives — NOT the agent's own worktree.

```bash
# Resolve the main worktree path (always the first line of git worktree list)
MAIN_REPO=$(git worktree list | head -1 | awk '{print $1}')
AGENT_LOG_DIR="${MAIN_REPO}/logs/agents"
BUILD_LOG_DIR="${MAIN_REPO}/logs/builds"
STORY_LOG="${AGENT_LOG_DIR}/{story-id}.log"
BUILD_LOG="${BUILD_LOG_DIR}/{story-id}-build.log"
TEST_LOG="${BUILD_LOG_DIR}/{story-id}-test.log"
SUMMARY_LOG="${AGENT_LOG_DIR}/AGENT-LOG.md"
```

**Agent log** (`/logs/agents/{story-id}.log`) — agent activity: status changes, PR events, decisions, errors.

```bash
echo "[$(date -Iseconds)] Starting {story-id}" >> "$STORY_LOG"
echo "[$(date -Iseconds)] PR created" >> "$STORY_LOG"
echo "[$(date -Iseconds)] PR merged to main" >> "$STORY_LOG"
```

**Build log** (`/logs/builds/{story-id}-build.log`) — raw `dotnet build` / `ng build` output.

```bash
dotnet build 2>&1 | tee -a "$BUILD_LOG"
```

**Test log** (`/logs/builds/{story-id}-test.log`) — raw `dotnet test` output.

```bash
dotnet test 2>&1 | tee -a "$TEST_LOG"
```

**Summary log** (`/logs/agents/AGENT-LOG.md`) — one-line status entries, append-only, used for cross-agent visibility.

```bash
echo "| $(date -Iseconds) | {story-id} | 🔄 Started | Agent-{n} |" >> "$SUMMARY_LOG"
# ... after PR merge ...
echo "| $(date -Iseconds) | {story-id} | ✅ Done | Agent-{n} |" >> "$SUMMARY_LOG"
```

### Summary log format

```markdown
# Agent Activity Log

| Timestamp | Story | Status | Agent | Notes |
|-----------|-------|--------|-------|-------|
| 2026-03-10T09:00:00+01:00 | INFRA-01 | 🔄 Started | Agent-1 | Wave 0 |
| 2026-03-10T10:30:00+01:00 | INFRA-01 | ✅ Done | Agent-1 | Build + tests green |
| 2026-03-10T10:35:00+01:00 | AUTH-01 | 🔄 Started | Agent-1 | Wave 1 |
| 2026-03-10T10:35:00+01:00 | GAME-01 | 🔄 Started | Agent-2 | Wave 1 |
```

### Rules

1. **Always log to the main worktree** — never to the agent's own worktree. Files in the worktree are deleted on cleanup.
2. **Use absolute paths** — the `MAIN_REPO` variable resolved via `git worktree list` ensures correctness regardless of where the agent's working directory is.
3. **Append-only** — agents never truncate or overwrite existing log entries. Use `>>` not `>`.
4. **Agent activity goes to `/logs/agents/`** — build/test output goes to `/logs/builds/`. Do not mix them.
5. **Log before and after key steps** — at minimum: story start, build result, test result, PR created, PR merged, cleanup done.

---

## Git Worktree Workflow

Every agent follows this full lifecycle: **setup → work → PR → merge → cleanup → verify**. The story is not complete until the worktree is removed and all code lives on `main`.

### 1. Agent Setup
```bash
# From the main repo checkout
git checkout main
git pull origin main
git worktree add ../worktree-{story-id} -b feature/{story-id}
cd ../worktree-{story-id}

# Resolve log paths (pointing to the MAIN worktree, not this one)
MAIN_REPO=$(git worktree list | head -1 | awk '{print $1}')
AGENT_LOG_DIR="${MAIN_REPO}/logs/agents"
BUILD_LOG_DIR="${MAIN_REPO}/logs/builds"
STORY_LOG="${AGENT_LOG_DIR}/{story-id}.log"
BUILD_LOG="${BUILD_LOG_DIR}/{story-id}-build.log"
TEST_LOG="${BUILD_LOG_DIR}/{story-id}-test.log"
SUMMARY_LOG="${AGENT_LOG_DIR}/AGENT-LOG.md"
mkdir -p "$AGENT_LOG_DIR" "$BUILD_LOG_DIR"

echo "[$(date -Iseconds)] Starting {story-id}" >> "$STORY_LOG"
echo "| $(date -Iseconds) | {story-id} | 🔄 Started | $(whoami) |" >> "$SUMMARY_LOG"
```

### 2. Agent Work
```bash
# Work in the worktree — implement the story
# Build output goes to /logs/builds/, agent activity to /logs/agents/
dotnet build 2>&1 | tee -a "$BUILD_LOG"
dotnet test 2>&1 | tee -a "$TEST_LOG"

# Log key decisions and errors to the agent log
echo "[$(date -Iseconds)] Build passed" >> "$STORY_LOG"

# Commit regularly with meaningful messages
git add -A
git commit -m "feat({feature}): {story-id} — {description}"
```

### 3. Push & Create PR
```bash
# Push the feature branch to remote
git push -u origin feature/{story-id}

# Create PR targeting main (via GitHub CLI or web UI)
gh pr create --base main --title "feat({feature}): {story-id} — {description}" --body "..."

echo "[$(date -Iseconds)] PR created" >> "$STORY_LOG"
```

### 4. Merge to Main
```bash
# After CI passes and PR is approved, squash merge to main
gh pr merge --squash --delete-branch

echo "[$(date -Iseconds)] PR merged to main" >> "$STORY_LOG"
```

### 5. Mandatory Post-Merge Cleanup

**This step is not optional.** The agent must remove the worktree and confirm all code is on `main` before the story is considered done.

```bash
# Switch back to the main repo checkout
cd "$MAIN_REPO"

# Pull the merged changes
git pull origin main

# Remove the worktree
git worktree remove ../worktree-{story-id}

# Delete the local feature branch (remote branch was deleted by --delete-branch above)
git branch -D feature/{story-id}

# Verify cleanup is complete
git worktree list          # Should NOT show worktree-{story-id}
git branch                 # Should NOT show feature/{story-id}
git log --oneline -5       # Should show the squash-merged commit on main

echo "[$(date -Iseconds)] Worktree removed, branch deleted" >> "$STORY_LOG"
```

### 6. Verify Code on Main

The agent must run these verification steps to confirm the story's code is fully integrated. Build/test output goes to `/logs/builds/`, completion status to `/logs/agents/`.

```bash
# Ensure the solution still builds
dotnet build DartsCompanion.sln 2>&1 | tee -a "$BUILD_LOG"

# Ensure all tests pass
dotnet test 2>&1 | tee -a "$TEST_LOG"

# For frontend changes, also verify:
cd src/DartsCompanion.Web
ng build 2>&1 | tee -a "$BUILD_LOG"
cd "$MAIN_REPO"
```

**If verification passes** — log completion and mark the story done:

```bash
echo "| $(date -Iseconds) | {story-id} | ✅ Done | $(whoami) | Build + tests green |" >> "$SUMMARY_LOG"
echo "[$(date -Iseconds)] ✅ Story complete" >> "$STORY_LOG"
# Mark story as ✅ Done in the README — the agent loop ends here.
```

**If verification fails** — the agent loop does NOT stop. The work is routed back to the developer agent for a fix cycle. See step 7 below.

### 7. Fix Cycle (when verification fails)

When the build or tests fail on `main` after merge, the agent **must not stop**. Instead, it loops back into a fix cycle using a new worktree. The story status goes back to `🔄 In progress` and stays there until verification passes.

**Flow:** Verify fails → log failure → create fix worktree → fix → PR → merge → cleanup → verify again → repeat until green.

```
┌─────────────────────────────────────────────────────┐
│  Step 6: Verify on main                             │
│  ┌─────────┐     ┌──────────────────────────────┐   │
│  │  PASS   │────▶│  Log ✅ Done — agent loop ends│   │
│  └─────────┘     └──────────────────────────────┘   │
│  ┌─────────┐     ┌──────────────────────────────┐   │
│  │  FAIL   │────▶│  Step 7: Fix cycle            │   │
│  └─────────┘     │  ┌────────────────────────┐   │   │
│                  │  │ Create fix worktree     │   │   │
│                  │  │ Fix the issue           │   │   │
│                  │  │ PR → merge → cleanup    │   │   │
│                  │  │ Loop back to Step 6     │──┘   │
│                  │  └────────────────────────┘       │
│                  └──────────────────────────────┘    │
└─────────────────────────────────────────────────────┘
```

```bash
# 7a. Log the failure
echo "[$(date -Iseconds)] ❌ Verification failed — starting fix cycle" >> "$STORY_LOG"
echo "| $(date -Iseconds) | {story-id} | 🔧 Fix cycle | $(whoami) | Verification failed |" >> "$SUMMARY_LOG"

# Capture the failure output (already in BUILD_LOG / TEST_LOG from step 6)
# Analyse the logs to understand what broke:
tail -50 "$BUILD_LOG"
tail -50 "$TEST_LOG"

# 7b. Create a new fix worktree
FIX_BRANCH="fix/{story-id}-$(date +%Y%m%d%H%M%S)"
git worktree add ../worktree-fix-{story-id} -b "$FIX_BRANCH"
cd ../worktree-fix-{story-id}

echo "[$(date -Iseconds)] Fix worktree created: $FIX_BRANCH" >> "$STORY_LOG"

# 7c. Fix the issue
# ... developer agent investigates and applies the fix ...
dotnet build 2>&1 | tee -a "$BUILD_LOG"
dotnet test 2>&1 | tee -a "$TEST_LOG"

# 7d. Commit, push, PR, merge (same as steps 3-4)
git add -A
git commit -m "fix({feature}): {story-id} — fix post-merge verification failure"
git push -u origin "$FIX_BRANCH"
gh pr create --base main --title "fix({feature}): {story-id} — post-merge fix" --body "..."
gh pr merge --squash --delete-branch

echo "[$(date -Iseconds)] Fix PR merged" >> "$STORY_LOG"

# 7e. Cleanup the fix worktree (same as step 5)
cd "$MAIN_REPO"
git pull origin main
git worktree remove ../worktree-fix-{story-id}
git branch -D "$FIX_BRANCH"

echo "[$(date -Iseconds)] Fix worktree removed" >> "$STORY_LOG"

# 7f. Loop back to Step 6 — verify again
dotnet build DartsCompanion.sln 2>&1 | tee -a "$BUILD_LOG"
dotnet test 2>&1 | tee -a "$TEST_LOG"

# If PASS → log ✅ Done and end the loop
# If FAIL → repeat from 7a
```

**Key rules for fix cycles:**

1. **The agent does not stop on failure.** It creates a fix worktree and loops back.
2. **Each fix attempt gets its own branch** (`fix/{story-id}-{timestamp}`) so there is a clean audit trail.
3. **The story status stays at `🔄 In progress`** until verification passes. It never moves to `✅ Done` until the build and all tests are green on `main`.
4. **All fix cycle output is logged** to the same `{story-id}` log files, so there is a continuous record.
5. **Maximum 3 fix attempts.** If the agent cannot get verification to pass after 3 fix cycles, it sets the story status to `🚫 Blocked`, logs the details, and escalates for human review. Do not loop forever.

```bash
# After 3 failed fix cycles:
echo "[$(date -Iseconds)] ❌ 3 fix attempts failed — escalating to human review" >> "$STORY_LOG"
echo "| $(date -Iseconds) | {story-id} | 🚫 Blocked | $(whoami) | 3 fix attempts failed — needs human review |" >> "$SUMMARY_LOG"
# Set story status to 🚫 Blocked in README and stop.
```

---

## PR & Merge Rules

1. **One PR per story.** Each story maps to exactly one feature branch and one PR.
2. **PRs within the same wave can merge in any order** — the patterns above prevent conflicts.
3. **PRs must not modify bottleneck files** unless the story explicitly owns that file (e.g., INFRA-01 owns `Program.cs`).
4. **Squash merge to `main`** to keep history clean. Always use `--delete-branch` to remove the remote feature branch.
5. **After all PRs in a wave merge**, run the migration consolidation step before starting the next wave.
6. **CI must pass** on the feature branch before merge. The CI pipeline (INFRA-03) runs build + test on every PR.
7. **No orphaned worktrees or feature branches.** At the end of a wave, `git worktree list` must show only the main working tree, and `git branch` must show only `main`.

---

## Wave Completion Gate

A wave is only complete when **all** of the following are true:

- [ ] All story PRs in the wave are squash-merged to `main`
- [ ] All remote feature branches are deleted
- [ ] All local worktrees are removed (`git worktree list` shows only the main checkout)
- [ ] All local feature branches are deleted (`git branch` shows only `main`)
- [ ] `main` builds successfully (`dotnet build` + `ng build`)
- [ ] All tests pass on `main` (`dotnet test`)
- [ ] Migration consolidation is done (if any story in the wave added entities/configurations)
- [ ] `git log --oneline` on `main` shows all expected squash commits from the wave

Only after these checks pass should agents in the next wave create their worktrees.

---

## Checklist for Agents

### Before starting work on a story:

- [ ] Pull latest `main`
- [ ] Confirm no leftover worktrees from previous work (`git worktree list`)
- [ ] Create a new worktree and feature branch
- [ ] Set up log variables: `MAIN_REPO`, `AGENT_LOG_DIR`, `BUILD_LOG_DIR`, `STORY_LOG`, `BUILD_LOG`, `TEST_LOG`, `SUMMARY_LOG` (see "Centralised Logging" section)
- [ ] Log `🔄 Started` to `/logs/agents/AGENT-LOG.md` and `/logs/agents/{story-id}.log`
- [ ] Read this guide and the story's task files
- [ ] Verify all dependency stories are marked `✅ Done`

### During work:

- [ ] Build output piped to `/logs/builds/{story-id}-build.log` via `tee -a`
- [ ] Test output piped to `/logs/builds/{story-id}-test.log` via `tee -a`
- [ ] Agent decisions, errors, and status changes logged to `/logs/agents/{story-id}.log`

### Before creating a PR:

- [ ] All Definition of Done items in the task files pass
- [ ] No modifications to bottleneck files (`Program.cs`, `app.routes.ts`, `app.config.ts`)
- [ ] No EF Core migrations created (unless you are the migration agent)
- [ ] Entity configurations use `IEntityTypeConfiguration<T>` pattern
- [ ] Angular routes are in feature-scoped route files
- [ ] Services use `providedIn: 'root'` or feature route providers
- [ ] All tests pass locally

### After PR is merged — cleanup:

- [ ] `git pull origin main` — merged code is on local `main`
- [ ] `git worktree remove ../worktree-{story-id}` — worktree is deleted
- [ ] `git branch -D feature/{story-id}` — local feature branch is deleted
- [ ] `git worktree list` shows only the main working tree
- [ ] `git branch` shows only `main`

### After cleanup — verification (story is NOT done until this passes):

- [ ] `dotnet build DartsCompanion.sln` succeeds on `main` (output in `/logs/builds/{story-id}-build.log`)
- [ ] `dotnet test` passes on `main` (output in `/logs/builds/{story-id}-test.log`)
- [ ] `ng build` passes on `main` for frontend stories (output in `/logs/builds/{story-id}-build.log`)

### If verification passes:

- [ ] Log `✅ Done` to `/logs/agents/AGENT-LOG.md` and `/logs/agents/{story-id}.log`
- [ ] Mark story as `✅ Done` in the dev plan README
- [ ] Agent loop ends

### If verification fails — fix cycle (do NOT stop):

- [ ] Log `❌ Verification failed` and `🔧 Fix cycle` to agent logs
- [ ] Create a fix worktree: `git worktree add ../worktree-fix-{story-id} -b fix/{story-id}-{timestamp}`
- [ ] Investigate failure using `/logs/builds/{story-id}-build.log` and `/logs/builds/{story-id}-test.log`
- [ ] Apply fix, commit, push, create PR, squash merge
- [ ] Remove fix worktree and branch
- [ ] **Loop back to verification** — run build + test on `main` again
- [ ] Repeat until verification passes (max 3 attempts)
- [ ] After 3 failed attempts → set story to `🚫 Blocked` and escalate for human review
