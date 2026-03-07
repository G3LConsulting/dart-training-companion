# Domain Model — Darts Training Companion

> **Shared reference document.** Do not duplicate this content in story files — link to it instead.

---

## Entities

### 1. ApplicationUser (extends IdentityUser< Guid >)

Core user account and profile entity. Extends ASP.NET Core Identity's IdentityUser to enable built-in account management, password hashing (PBKDF2/HMAC-SHA512), and email token workflows.

| Field | Type | Constraints | Notes |
|-------|------|-------------|-------|
| Id | Guid | PK | Auto-generated primary key |
| Email | string | Not null | Unique username; used for login |
| DisplayName | string | Max 100 chars | User's public name; shown on leaderboards |
| DominantHand | Hand? | Enum (Left, Right) | Optional; used for hand-of-hand analysis (post-MVP) |
| PreferredGameMode | GameMode? | Enum (Mode501, Mode301, Cricket, NumberFocus) | Optional; home screen defaults to this mode |
| TargetAverage | decimal? | Optional; 2 decimal places | User-defined target average for Mode501/301 |
| WeekStartDay | DayOfWeek | Enum; default Monday | Controls weekly stats rollup (e.g. Sunday vs Monday) |
| HomeScreenPbMetricKey | string? | Max 255 chars | Metric key (e.g. "avg_3dart_501") shown in Home PB widget |
| LeaderboardOptIn | bool | Default false | Controls visibility on global leaderboards (post-MVP) |
| IsDeleted | bool | Default false | Soft-delete flag; must be checked in queries |
| DeletedAt | DateTimeOffset? | Optional | Timestamp of soft delete; null if not deleted |
| CreatedAt | DateTimeOffset | Not null | Account creation timestamp (set by EF) |
| UpdatedAt | DateTimeOffset | Not null | Last modified timestamp (set by EF) |

**Relationships:**
- RefreshToken: one-to-many (one user, many tokens)
- GameSession: one-to-many
- UserStats: one-to-many (one per GameMode)
- PersonalBest: one-to-many
- ExportJob: one-to-many

---

### 2. RefreshToken

Rotating JWT refresh token with server-side revocation support. Used to issue new access tokens (15-min expiry) without requiring password re-entry.

| Field | Type | Constraints | Notes |
|-------|------|-------------|-------|
| Id | Guid | PK | Auto-generated |
| UserId | Guid | FK → ApplicationUser | Non-null foreign key |
| TokenHash | string | Not null, 64 chars | SHA-256 hash of token (never store plaintext) |
| ExpiresAt | DateTimeOffset | Not null | Refresh token valid for 7 days |
| IsRevoked | bool | Default false | Set true on logout/password change |
| CreatedAt | DateTimeOffset | Not null | Token issue timestamp |

**Validation:**
- Expired tokens (ExpiresAt < now) are rejected automatically
- Revoked tokens must be deleted or flagged before expiry
- No purging for MVP; soft-deleted records remain indefinitely

---

### 3. GameSession

Top-level container for a single game, tracking mode, players, timestamps, and turn data. Relationships to Turn, CricketTurn, DartEntry depend on GameMode.

| Field | Type | Constraints | Notes |
|-------|------|-------------|-------|
| Id | Guid | PK | Auto-generated |
| UserId | Guid | FK → ApplicationUser | Non-null; must be soft-deleted user-aware |
| GameMode | GameMode | Enum | Mode501, Mode301, Cricket, or NumberFocus; never null |
| StartedAt | DateTimeOffset | Not null | When game began |
| CompletedAt | DateTimeOffset? | Optional | Null if in-progress/abandoned |
| Player2Name | string? | Max 100 chars | Opponent name for multiplayer modes (optional) |
| ConfigurationJson | JSONB | Not null | PostgreSQL jsonb column; stores mode-specific config (handicaps, custom scoring rules, etc.) as EF value-converted object |
| IsDeleted | bool | Default false | Soft-delete flag |
| CreatedAt | DateTimeOffset | Not null | Record creation (set by EF) |
| UpdatedAt | DateTimeOffset | Not null | Last modified (set by EF) |

**Relationships:**
- ApplicationUser: many-to-one (non-null FK)
- Turn: one-to-many (501/301 games only)
- CricketTurn: one-to-many (Cricket games only)
- DartEntry: one-to-many (NumberFocus games only)

**Indexes:**
- Composite: (UserId, IsDeleted, CompletedAt DESC) for efficient completed-session queries
- UserId + GameMode for session filtering

---

### 4. Turn (501/301)

Single turn in a Mode501 or Mode301 game. One turn per player per round. Tracks score, remaining points, and bust status.

| Field | Type | Constraints | Notes |
|-------|------|-------------|-------|
| Id | Guid | PK | Auto-generated |
| SessionId | Guid | FK → GameSession | Non-null; turn cannot exist without session |
| TurnNumber | int | ≥ 1 (1-based) | Sequential turn count (1, 2, 3, …) |
| PlayerIndex | int | 0 or 1 | 0 = player 1, 1 = player 2 |
| Score | int | ≥ 0 | Points scored in this turn (sum of darts) |
| RemainingScore | int | ≥ 0 | Points still needed to reach 0 (before this turn) |
| IsBust | bool | Default false | True if turn busts out (score exceeds remaining) |

**Rules:**
- Turn sequence is immutable once created
- RemainingScore must be calculated from session state + prior turns
- Bust status can be inferred from logic or stored for denormalization

---

### 5. CricketTurn

Single turn in a Cricket game. Tracks marks on numbers 15–20 and bull, plus points scored.

| Field | Type | Constraints | Notes |
|-------|------|-------------|-------|
| Id | Guid | PK | Auto-generated |
| SessionId | Guid | FK → GameSession | Non-null; cannot exist without Cricket session |
| TurnNumber | int | ≥ 1 (1-based) | Sequential turn count |
| PlayerIndex | int | 0 or 1 | 0 = player 1, 1 = player 2 |
| MarksN15 | int | 0–3 | Marks on 15 |
| MarksN16 | int | 0–3 | Marks on 16 |
| MarksN17 | int | 0–3 | Marks on 17 |
| MarksN18 | int | 0–3 | Marks on 18 |
| MarksN19 | int | 0–3 | Marks on 19 |
| MarksN20 | int | 0–3 | Marks on 20 |
| MarksBull | int | 0–3 | Marks on bull (25) |
| PointsScored | int | ≥ 0 | Points earned this turn (if numbers already closed by opponent, 0) |

**Rules:**
- A number is "closed" when a player has ≥ 3 marks on it
- Points scored are only awarded if the number is closed and opponent hasn't closed it
- Bull counts as a single number for closing (≥3 marks)
- Composite turn-level scores are derived from mark transitions and opponent state

---

### 6. DartEntry (NumberFocus)

Single dart throw in a NumberFocus game. Records outcome (triple, double, single, miss) for accuracy metrics.

| Field | Type | Constraints | Notes |
|-------|------|-------------|-------|
| Id | Guid | PK | Auto-generated |
| SessionId | Guid | FK → GameSession | Non-null; dart belongs to a NumberFocus session |
| DartNumber | int | ≥ 1 (1-based) | Dart sequence within session (1, 2, 3, …, up to 60+) |
| Outcome | DartOutcome | Enum | Triple, Double, Single, or Miss |

**Weighted Accuracy Formula:**
```
(Triples × 3 + Doubles × 2 + Singles × 1) / (total darts × 3) × 100%
```
- Triples weighted 3, Doubles 2, Singles 1, Misses 0
- Denominator normalizes to 100% if all darts are triples

---

### 7. UserStats

Aggregated statistics per user per game mode. Calculated asynchronously and cached in JSONB; supports real-time recalculation via BackgroundService.

| Field | Type | Constraints | Notes |
|-------|------|-------------|-------|
| Id | Guid | PK | Auto-generated |
| UserId | Guid | FK → ApplicationUser | Non-null; cannot exist without user |
| GameMode | GameMode | Enum | Mode501, Mode301, Cricket, or NumberFocus |
| StatsJson | JSONB | Not null | PostgreSQL jsonb; EF value-converted object containing computed averages, win rates, trends, etc. |
| IsRecalculating | bool | Default false | True while BackgroundService recalculates; prevents stale reads |
| LastCalculatedAt | DateTimeOffset? | Optional | Timestamp of most recent stat recalculation |
| CreatedAt | DateTimeOffset | Not null | Record creation |
| UpdatedAt | DateTimeOffset | Not null | Last modification |

**Indexes:**
- Composite unique: (UserId, GameMode) — one stats row per user per mode

**Recalculation:**
- On-demand via Command → enqueues userId into BackgroundService Channel< Guid >
- In-process service dequeues, recalculates StatsJson, sets LastCalculatedAt
- Frontend polls GET /api/stats/recalculation-status to await completion

---

### 8. PersonalBest

Single record of a user's best achievement for a specific metric. Examples: fastest 501 average, highest single-game accuracy in NumberFocus, best cricket score.

| Field | Type | Constraints | Notes |
|-------|------|-------------|-------|
| Id | Guid | PK | Auto-generated |
| UserId | Guid | FK → ApplicationUser | Non-null |
| MetricKey | string | Max 255 chars, not null | e.g., "avg_3dart_501", "avg_darts_301", "nf_accuracy_20", "nf_weighted_accuracy_bull", "cricket_points_per_game", etc. |
| Value | decimal | Not null; 2–4 decimal places | Numeric value (average, percentage, count, etc.) |
| AchievedAt | DateTimeOffset | Not null | When the PB was set |
| SessionId | Guid? | Optional FK → GameSession | Links to session where PB was achieved; nullable for manual entries |
| CreatedAt | DateTimeOffset | Not null | Record creation |
| UpdatedAt | DateTimeOffset | Not null | Last modification |

**Indexes:**
- Composite: (UserId, MetricKey) for fast PB lookup

**Metric Keys (non-exhaustive):**
- Mode501: avg_3dart_501, avg_darts_501
- Mode301: avg_3dart_301, avg_darts_301
- Cricket: cricket_points_per_game, cricket_fastest_game_darts
- NumberFocus: nf_accuracy_20, nf_weighted_accuracy_bull, nf_accuracy_all_numbers, nf_3_in_a_row_triples

---

### 9. ExportJob

Asynchronous data export request. Tracks CSV/Excel/JSON generation and file storage. No archival; files are temporary.

| Field | Type | Constraints | Notes |
|-------|------|-------------|-------|
| Id | Guid | PK | Auto-generated |
| UserId | Guid | FK → ApplicationUser | Non-null; export belongs to a user |
| Status | ExportStatus | Enum | Pending, Processing, Complete, Failed |
| Format | ExportFormat | Enum | Csv, Excel, Json |
| ScopeJson | JSONB | Not null | Filters: date range, game modes, metrics; EF value-converted |
| FilePath | string? | Max 512 chars | Filesystem or blob path; null until Complete |
| RequestedAt | DateTimeOffset | Not null | When export was initiated |
| CompletedAt | DateTimeOffset? | Optional | When export finished (Complete or Failed) |
| CreatedAt | DateTimeOffset | Not null | Record creation |
| UpdatedAt | DateTimeOffset | Not null | Last modification |

**Lifecycle:**
1. User triggers export → POST /api/export → ExportJob created with Status=Pending
2. ExportJobService polls for Pending jobs, sets Status=Processing
3. Enqueues channel message to ExcelExportWriter (or CsvExportWriter) to generate file
4. On completion: Status=Complete, FilePath set, CompletedAt set
5. On error: Status=Failed, CompletedAt set, FilePath null
6. Client polls GET /api/export/{jobId} to monitor progress and download when ready

**Cleanup:** Temporary files are not purged for MVP; logs should note cleanup strategy for production.

---

## Enums

### GameMode
```csharp
enum GameMode
{
    Mode501,      // Standard 501 game
    Mode301,      // Standard 301 game
    Cricket,      // Cricket (darts variant)
    NumberFocus   // Single-number training drills
}
```

### DartOutcome
```csharp
enum DartOutcome
{
    Triple,    // Triple ring
    Double,    // Double ring (including outer bull)
    Single,    // Single area
    Miss       // Missed the board or gutter
}
```

### ExportFormat
```csharp
enum ExportFormat
{
    Csv,       // CSV text file
    Excel,     // .xlsx (OpenXml)
    Json       // JSON object array
}
```

### ExportStatus
```csharp
enum ExportStatus
{
    Pending,    // Awaiting processing
    Processing, // Currently generating file
    Complete,   // File ready for download
    Failed      // Error occurred during generation
}
```

### Hand
```csharp
enum Hand
{
    Left,       // Left-handed thrower
    Right       // Right-handed thrower
}
```

---

## Database & Storage Notes

### Soft Deletes
- All user-owned entities (GameSession, UserStats, PersonalBest, ExportJob) have IsDeleted bool and DeletedAt DateTimeOffset?
- Queries must filter `WHERE IsDeleted = false` unless explicitly retrieving deleted records
- No hard deletes for MVP; soft-deleted records remain indefinitely in database
- Exception: ExportJob temporary files are not archived; cleanup strategy deferred to production

### JSONB Columns
- ConfigurationJson (GameSession), StatsJson (UserStats), ScopeJson (ExportJob): PostgreSQL jsonb type
- EF Core 10 handles mapping via value conversion (e.g., `modelBuilder.Entity<GameSession>().Property(e => e.ConfigurationJson).HasConversion(new JsonValueConverter())`)
- Allows indexing and querying JSON fields at database level
- Deserialized to C# POCOs (ConfigDto, StatsDto, ExportScopeDto) in Application layer

### Composite Indexes
- (UserId, GameMode) UNIQUE on UserStats — ensures one stats row per mode per user
- (UserId, IsDeleted, CompletedAt DESC) on GameSession — optimizes "show my recent completed games" queries
- (UserId, MetricKey) on PersonalBest — fast PB lookup by metric

### Migrations
- EF Core 10 code-first; all schema changes via migration files in Infrastructure/Migrations/
- Database initialized via `dotnet ef database update` in Docker startup scripts

---

## Weighted Accuracy Calculation (NumberFocus)

Used for all NumberFocus metrics and displayed in NumberFocusAccuracyComponent.

```
Weighted Accuracy (%) = [(T × 3) + (D × 2) + (S × 1)] / (Total Darts × 3) × 100

where:
  T = number of triples
  D = number of doubles
  S = number of singles
  Total Darts = T + D + S + M (misses)
```

**Example:**
- 60 darts: 20 triples, 15 doubles, 10 singles, 15 misses
- Score: (20×3) + (15×2) + (10×1) = 60 + 30 + 10 = 100 points
- Accuracy: 100 / (60×3) × 100 = 100 / 180 × 100 = **55.6%**

**Display:** Rounded to 1 decimal place; color-coded by performance bands (green ≥50%, yellow 40–49%, red <40%).
