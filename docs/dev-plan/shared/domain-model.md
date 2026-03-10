> **Shared reference document** — Domain model extracted from Technical Architecture. All developers should reference this document for entity definitions, relationships, and database design.

# Domain Model

## Entities

### ApplicationUser (extends IdentityUser< Guid >)

| Field | Type | Notes |
|-------|------|-------|
| Id | Guid | Primary key, inherited from IdentityUser |
| Email | string | Unique, inherited from IdentityUser |
| DisplayName | string | Max 100 characters |
| DominantHand | Hand? | Optional enum: Left, Right |
| PreferredGameMode | GameMode? | Optional enum: Mode501, Mode301, Cricket, NumberFocus |
| TargetAverage | decimal? | Optional user-defined goal |
| WeekStartDay | DayOfWeek | Default: Monday |
| HomeScreenPbMetricKey | string? | Key to metric displayed on home screen |
| LeaderboardOptIn | bool | Default: false |
| IsDeleted | bool | Soft delete flag |
| DeletedAt | DateTimeOffset? | Soft delete timestamp |
| CreatedAt | DateTimeOffset | Record creation timestamp |
| UpdatedAt | DateTimeOffset | Last modification timestamp |

**Notes:** Password hash, email confirmation token, and security stamp are managed by ASP.NET Core Identity base class.

**Relationships:**
- One-to-many with RefreshToken
- One-to-many with GameSession
- One-to-many with UserStats
- One-to-many with PersonalBest
- One-to-many with ExportJob

---

### RefreshToken

| Field | Type | Notes |
|-------|------|-------|
| Id | Guid | Primary key |
| UserId | Guid | Foreign key → ApplicationUser |
| TokenHash | string | SHA-256 hash of token |
| ExpiresAt | DateTimeOffset | 7-day lifetime from creation |
| IsRevoked | bool | Logout sets this to true |
| CreatedAt | DateTimeOffset | Token creation timestamp |

**Notes:** Tokens are hashed for security; never store plaintext tokens in database.

---

### GameSession

| Field | Type | Notes |
|-------|------|-------|
| Id | Guid | Primary key |
| UserId | Guid | Foreign key → ApplicationUser |
| GameMode | GameMode | Enum: Mode501, Mode301, Cricket, NumberFocus |
| StartedAt | DateTimeOffset | Game start timestamp |
| CompletedAt | DateTimeOffset? | Null if in-progress |
| Player2Name | string? | Optional, pass-and-play mode only, max 100 |
| ConfigurationJson | string | JSONB, game configuration (e.g., starting score, options) |
| IsDeleted | bool | Soft delete flag |
| CreatedAt | DateTimeOffset | Record creation timestamp |

**Notes:** ConfigurationJson uses PostgreSQL jsonb type via EF Core value conversion. Composite index on (UserId, IsDeleted, CompletedAt DESC) for efficient history queries.

**Relationships:**
- Belongs to ApplicationUser
- One-to-many with Turn (501/301 modes)
- One-to-many with CricketTurn (Cricket mode)
- One-to-many with DartEntry (Number Focus mode)
- One-to-many with PersonalBest (via SessionId reference)

---

### Turn (501/301 Modes)

| Field | Type | Notes |
|-------|------|-------|
| Id | Guid | Primary key |
| SessionId | Guid | Foreign key → GameSession |
| TurnNumber | int | 1-based turn sequence |
| PlayerIndex | int | 0 = Player 1, 1 = Player 2 |
| Score | int | Points scored this turn |
| RemainingScore | int | Score remaining before bust check |
| IsBust | bool | True if turn exceeded remaining score |

**Notes:** One turn per player per round. Used for Mode501 and Mode301 games.

---

### CricketTurn

| Field | Type | Notes |
|-------|------|-------|
| Id | Guid | Primary key |
| SessionId | Guid | Foreign key → GameSession |
| TurnNumber | int | 1-based turn sequence |
| PlayerIndex | int | 0 = Player 1, 1 = Player 2 |
| MarksN15 | int | Mark count on 15 (0–3) |
| MarksN16 | int | Mark count on 16 (0–3) |
| MarksN17 | int | Mark count on 17 (0–3) |
| MarksN18 | int | Mark count on 18 (0–3) |
| MarksN19 | int | Mark count on 19 (0–3) |
| MarksN20 | int | Mark count on 20 (0–3) |
| MarksBull | int | Mark count on bull (0–3) |
| PointsScored | int | Points awarded this turn (after closing numbers) |

**Notes:** Used exclusively for Cricket game mode.

---

### DartEntry (Number Focus Mode)

| Field | Type | Notes |
|-------|------|-------|
| Id | Guid | Primary key |
| SessionId | Guid | Foreign key → GameSession |
| DartNumber | int | 1-based dart sequence |
| Outcome | DartOutcome | Enum: Triple, Double, Single, Miss |

**Notes:** One entry per dart thrown in Number Focus mode. Used for accuracy tracking.

---

### UserStats

| Field | Type | Notes |
|-------|------|-------|
| Id | Guid | Primary key |
| UserId | Guid | Foreign key → ApplicationUser |
| GameMode | GameMode | Enum: Mode501, Mode301, Cricket, NumberFocus |
| StatsJson | string | JSONB, computed statistics (3-dart average, checkouts, etc.) |
| IsRecalculating | bool | True while background job is recalculating |
| LastCalculatedAt | DateTimeOffset? | Timestamp of last stats computation |

**Notes:** StatsJson uses PostgreSQL jsonb type. Composite unique index on (UserId, GameMode) ensures one stats record per user per mode.

---

### PersonalBest

| Field | Type | Notes |
|-------|------|-------|
| Id | Guid | Primary key |
| UserId | Guid | Foreign key → ApplicationUser |
| MetricKey | string | e.g., "avg_3dart_501", "checkout_501" |
| Value | decimal | The best recorded value |
| AchievedAt | DateTimeOffset | When this PB was achieved |
| SessionId | Guid? | Optional foreign key → GameSession |

**Notes:** SessionId is nullable; may be null for imported data or legacy records.

---

### ExportJob

| Field | Type | Notes |
|-------|------|-------|
| Id | Guid | Primary key |
| UserId | Guid | Foreign key → ApplicationUser |
| Status | ExportStatus | Enum: Pending, Processing, Complete, Failed |
| Format | ExportFormat | Enum: Csv, Excel, Json |
| ScopeJson | string | JSONB, export filters (date range, game modes) |
| FilePath | string? | Path to generated file, null until Complete |
| RequestedAt | DateTimeOffset | User request timestamp |
| CompletedAt | DateTimeOffset? | Completion timestamp, null until Complete/Failed |

**Notes:** Temporary files deleted after download or retention period. No soft delete for this entity.

---

## Enums

### GameMode
```
Mode501
Mode301
Cricket
NumberFocus
```

### Hand
```
Left
Right
```

### DartOutcome
```
Triple
Double
Single
Miss
```

### ExportFormat
```
Csv
Excel
Json
```

### ExportStatus
```
Pending
Processing
Complete
Failed
```

---

## Database Design Notes

- **Soft Deletes:** All entities except ExportJob use IsDeleted flag and DeletedAt timestamp. No hard deletes. Queries must filter `WHERE IsDeleted = false` as applicable.
- **JSON Columns:** ConfigurationJson and StatsJson leverage PostgreSQL jsonb type via EF Core value conversion for flexible, queryable structured data.
- **Indexes:**
  - Composite unique index on GameSession: (UserId, GameMode)
  - Composite index on GameSession: (UserId, IsDeleted, CompletedAt DESC) for efficient history queries
  - Composite unique index on UserStats: (UserId, GameMode)
- **Identity Integration:** ApplicationUser extends IdentityUser<Guid>; password and token management delegated to Identity framework.
- **Audit Trail:** CreatedAt and UpdatedAt maintained on all entities for traceability.
