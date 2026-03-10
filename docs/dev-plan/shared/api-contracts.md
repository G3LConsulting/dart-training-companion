> **Shared reference document** — API contracts and CQRS specifications. All backend features must implement these endpoints and commands/queries.

# API Contracts

## REST Endpoints

| Method | Route | Command/Query | Auth | Notes |
|--------|-------|---------------|------|-------|
| GET | /api/health | — | Anonymous | Liveness check, returns 200 OK |
| POST | /api/auth/register | RegisterUserCommand | Anonymous | Returns 201 Created with user ID |
| POST | /api/auth/verify-email | VerifyEmailCommand | Anonymous | Token in request body, returns 204 No Content |
| POST | /api/auth/resend-verification | ResendVerificationEmailCommand | Anonymous | Rate-limited, returns 204 No Content |
| POST | /api/auth/login | LoginQuery | Anonymous | Returns 200 OK with JWT + refresh token in JSON response |
| POST | /api/auth/refresh | RefreshTokenCommand | Anonymous | Rotates refresh token, returns new JWT + new refresh token |
| POST | /api/auth/logout | RevokeRefreshTokenCommand | Player | Revokes current refresh token, returns 204 No Content |
| POST | /api/auth/forgot-password | RequestPasswordResetCommand | Anonymous | Always returns 200 OK (no email enumeration) |
| POST | /api/auth/reset-password | ResetPasswordCommand | Anonymous | Token + new password in body, returns 204 No Content |
| GET | /api/profile | GetProfileQuery | Player | Returns 200 OK with user profile JSON |
| PUT | /api/profile | UpdateProfileCommand | Player | Returns 204 No Content |
| DELETE | /api/profile | DeleteAccountCommand | Player | Email confirmation in request body, returns 204 No Content, enqueues data export |
| GET | /api/sessions | GetSessionHistoryQuery | Player | ?page=1&pageSize=10&mode=Mode501, returns 200 OK with paginated sessions |
| GET | /api/sessions/{id} | GetSessionDetailQuery | Player | Returns 200 OK if found, 404 Not Found if missing or deleted |
| POST | /api/sessions | CreateSessionCommand | Player | Returns 201 Created with session ID |
| DELETE | /api/sessions/{id} | DeleteSessionCommand | Player | Returns 204 No Content, enqueues stats recalculation |
| POST | /api/sessions/sync | SyncSessionsCommand | Player | Bulk sync of offline-created sessions, returns 200 OK with conflicts array |
| GET | /api/sessions/conflicts | GetPendingConflictsQuery | Player | Returns 200 OK with unresolved conflicts array |
| POST | /api/sessions/conflicts/resolve | ResolveConflictCommand | Player | Returns 204 No Content |
| GET | /api/stats | GetStatsDashboardQuery | Player | ?range=7d&mode=Mode501, returns 200 OK with computed stats |
| GET | /api/stats/trends | GetTrendDataQuery | Player | ?metric=avg_3dart&mode=Mode501&range=30d, returns 200 OK with time-series data |
| GET | /api/stats/personal-bests | GetPersonalBestsQuery | Player | Returns 200 OK with array of top metrics |
| GET | /api/stats/number-focus/{number} | GetNumberFocusStatsQuery | Player | {number} = 1-20 or "bull", returns 200 OK with accuracy stats |
| GET | /api/stats/weekly | GetWeeklyStatsQuery | Player | Returns 200 OK with week-to-date statistics |
| GET | /api/stats/recalculation-status | GetRecalculationStatusQuery | Player | Polled after session deletion, returns status + progress percentage |
| POST | /api/export | RequestExportCommand | Player | Returns 202 Accepted with JobId in JSON response |
| GET | /api/export/{jobId} | GetExportStatusQuery | Player | Returns 200 OK with status (Pending, Processing, Complete, Failed) |
| GET | /api/export/{jobId}/download | DownloadExportQuery | Player | Streams file response with appropriate Content-Type (text/csv, application/json, etc.) |

---

## CQRS Commands & Queries

### Authentication Commands

| Command | Description | Trigger | Return Type | Validation |
|---------|-------------|---------|-------------|-----------|
| **RegisterUserCommand** | Create new user account | User submits registration form | RegisterUserCommandResponse (UserId, Email) | Email unique, password min 8 chars, display name max 100 |
| **VerifyEmailCommand** | Activate account via email token | User clicks verification link | VerifyEmailCommandResponse (Success: bool) | Token valid, not expired, not already verified |
| **ResendVerificationEmailCommand** | Send new verification email | User requests resend | ResendVerificationEmailCommandResponse (Success: bool) | User exists, not already verified, rate limit 3/hour |
| **LoginQuery** | Authenticate and issue tokens | User submits login form | LoginQueryResponse (AccessToken, RefreshToken, ExpiresIn) | User exists, email verified, password correct |
| **RefreshTokenCommand** | Rotate refresh token | Frontend calls on 401 or proactively | RefreshTokenCommandResponse (AccessToken, RefreshToken, ExpiresIn) | Refresh token valid, not revoked, not expired |
| **RevokeRefreshTokenCommand** | Logout, invalidate token | User clicks logout button | RevokeRefreshTokenCommandResponse (Success: bool) | Refresh token exists and belongs to user |
| **RequestPasswordResetCommand** | Send password reset email | User clicks "Forgot Password" | RequestPasswordResetCommandResponse (Success: bool, Message: string) | Always succeeds; no email enumeration |
| **ResetPasswordCommand** | Complete password reset | User submits token + new password | ResetPasswordCommandResponse (Success: bool) | Token valid, not expired, password meets requirements |

### Profile Commands

| Command | Description | Trigger | Return Type | Validation |
|---------|-------------|---------|-------------|-----------|
| **UpdateProfileCommand** | Modify user settings | User edits profile | UpdateProfileCommandResponse (Success: bool) | DisplayName max 100, DominantHand in enum, GameMode in enum |
| **DeleteAccountCommand** | Soft-delete account, enqueue data export | User confirms account deletion | DeleteAccountCommandResponse (Success: bool) | Email confirmation required in request body |

### Session Commands

| Command | Description | Trigger | Return Type | Validation |
|---------|-------------|---------|-------------|-----------|
| **CreateSessionCommand** | Start new game, persist to DB | User taps "New Game" | CreateSessionCommandResponse (SessionId, ConfigurationJson) | GameMode required, configuration valid per mode |
| **DeleteSessionCommand** | Soft-delete session, enqueue stats recalc | User deletes from history | DeleteSessionCommandResponse (Success: bool) | Session exists, belongs to user, not already deleted |
| **SyncSessionsCommand** | Bulk insert offline-created sessions | PWA reconnects, IndexedDB has queued items | SyncSessionsCommandResponse (SyncedCount: int, Conflicts: Conflict[]) | Validate each session before insert, detect timestamp conflicts |
| **ResolveConflictCommand** | Merge or discard conflicted session | User picks conflict resolution | ResolveConflictCommandResponse (Success: bool) | Conflict exists, resolution strategy valid |

### Stats Commands

| Command | Description | Trigger | Return Type | Validation |
|---------|-------------|---------|-------------|-----------|
| **RecalculateStatsCommand** | Recompute all statistics for user + mode | Enqueued by DeleteSessionCommand | RecalculateStatsCommandResponse (Success: bool, Stats: StatsJson) | GameMode valid, user has completed sessions |

### Export Commands

| Command | Description | Trigger | Return Type | Validation |
|---------|-------------|---------|-------------|-----------|
| **RequestExportCommand** | Create export job (CSV/Excel/JSON) | User selects export settings | RequestExportCommandResponse (JobId, Status) | Format valid, scope filters valid (date range, modes) |

### Authentication Queries

| Query | Description | Trigger | Return Type | Validation |
|-------|-------------|---------|-------------|-----------|
| **LoginQuery** | Authenticate user, return tokens | User submits login form | LoginQueryResponse (AccessToken, RefreshToken) | Credentials valid |

### Profile Queries

| Query | Description | Trigger | Return Type | Validation |
|-------|-----------|---------|-------------|-----------|
| **GetProfileQuery** | Retrieve user profile details | Page load or profile click | GetProfileQueryResponse (User: ApplicationUser) | User exists, not deleted |

### Session Queries

| Query | Description | Trigger | Return Type | Validation |
|-------|-----------|---------|-------------|-----------|
| **GetSessionHistoryQuery** | List user's sessions, paginated, filtered | User views history page | GetSessionHistoryQueryResponse (Sessions: [], PageCount: int, TotalCount: int) | Pagination valid, mode filter optional |
| **GetSessionDetailQuery** | Retrieve full session data (turns, config) | User clicks session | GetSessionDetailQueryResponse (Session: GameSession, Turns: Turn[]) | Session exists, not deleted, belongs to user |
| **GetPendingConflictsQuery** | List unresolved sync conflicts | After SyncSessionsCommand | GetPendingConflictsQueryResponse (Conflicts: Conflict[]) | User has pending conflicts |

### Stats Queries

| Query | Description | Trigger | Return Type | Validation |
|-------|-----------|---------|-------------|-----------|
| **GetStatsDashboardQuery** | Computed stats (avg, checkouts, etc.) | Stats dashboard page load | GetStatsDashboardQueryResponse (Stats: StatsJson, LastCalculatedAt: DateTimeOffset) | User has completed sessions, mode valid |
| **GetTrendDataQuery** | Time-series data for charts | Trends page load | GetTrendDataQueryResponse (DataPoints: TrendPoint[]) | Metric valid, mode valid, date range valid |
| **GetPersonalBestsQuery** | Top achievements per metric | PB screen load | GetPersonalBestsQueryResponse (Bests: PersonalBest[]) | User has completed sessions |
| **GetNumberFocusStatsQuery** | Accuracy per number (1-20, bull) | Number focus detail page | GetNumberFocusStatsQueryResponse (Stats: { [number]: { Hits: int, Misses: int, Percentage: decimal } }) | Number in range 1-20 or "bull" |
| **GetWeeklyStatsQuery** | Stats for current week | Weekly summary widget | GetWeeklyStatsQueryResponse (Stats: StatsJson, WeekStart: DateTimeOffset) | Week start configurable per user |
| **GetRecalculationStatusQuery** | Progress of background stats job | Polled after session delete | GetRecalculationStatusQueryResponse (IsRecalculating: bool, ProgressPercent: int) | Called during recalculation |

### Export Queries

| Query | Description | Trigger | Return Type | Validation |
|-------|-----------|---------|-------------|-----------|
| **GetExportStatusQuery** | Poll export job status | Export monitor page | GetExportStatusQueryResponse (Status: ExportStatus, CompletedAt?: DateTimeOffset) | Job exists, belongs to user |
| **DownloadExportQuery** | Stream generated file | User clicks download button | FileStreamResult (CSV/Excel/JSON) | Job complete, file exists, return appropriate Content-Type |

---

## FluentValidation Rules

| Command | Validator Class | Key Rules |
|---------|-----------------|-----------|
| RegisterUserCommand | RegisterUserCommandValidator | Email not null, valid format; Password min 8 chars, uppercase, digit; DisplayName max 100; Email not already in use |
| VerifyEmailCommand | VerifyEmailCommandValidator | Token not null, valid format |
| ResendVerificationEmailCommand | ResendVerificationEmailCommandValidator | Email not null; User exists; Not already verified; Rate limit: ≤3 per hour per email |
| LoginQuery | LoginQueryValidator | Email not null, valid format; Password not null; User must be verified |
| RefreshTokenCommand | RefreshTokenCommandValidator | RefreshToken not null; Valid format (JWT-like); Not blacklisted |
| RevokeRefreshTokenCommand | RevokeRefreshTokenCommandValidator | RefreshToken not null |
| RequestPasswordResetCommand | RequestPasswordResetCommandValidator | Email not null, valid format |
| ResetPasswordCommand | ResetPasswordCommandValidator | Token not null; NewPassword min 8 chars, uppercase, digit; Passwords match |
| UpdateProfileCommand | UpdateProfileCommandValidator | DisplayName max 100; DominantHand in [Left, Right] or null; PreferredGameMode in enum or null; TargetAverage positive or null |
| DeleteAccountCommand | DeleteAccountCommandValidator | EmailConfirmation matches user email (exact match) |
| CreateSessionCommand | CreateSessionCommandValidator | GameMode required, in enum; ConfigurationJson valid per mode (e.g., Mode501 requires StartingScore); Player2Name max 100 if pass-and-play |
| DeleteSessionCommand | DeleteSessionCommandValidator | SessionId valid GUID; Session exists |
| SyncSessionsCommand | SyncSessionsCommandValidator | Sessions array not empty; Each session has valid GameMode, ConfigurationJson, Turns/Entries |
| ResolveConflictCommand | ResolveConflictCommandValidator | ConflictId valid; ResolutionStrategy in [KeepLocal, KeepServer, Merge] |
| RecalculateStatsCommand | RecalculateStatsCommandValidator | UserId valid GUID; GameMode in enum |
| RequestExportCommand | RequestExportCommandValidator | Format in [Csv, Excel, Json]; DateStart ≤ DateEnd; GameModes not empty |

---

## Authentication Flow

### Registration & Verification
```
1. POST /api/auth/register { email, password, displayName }
   → 201 Created { userId }
   → Email sent with verification token

2. User clicks email link with token
   → POST /api/auth/verify-email { token }
   → 204 No Content
   → Account activated

3. If email lost: POST /api/auth/resend-verification { email }
   → 204 No Content
   → New verification email sent
```

### Login & Token Management
```
1. POST /api/auth/login { email, password }
   → 200 OK { accessToken, refreshToken, expiresIn }
   → JWT accessToken: 15-minute lifetime
   → Refresh token: 7-day lifetime, secure, httpOnly cookie preferred

2. Frontend attaches accessToken to every API call via Bearer header:
   Authorization: Bearer <accessToken>

3. On 401 or expiration: POST /api/auth/refresh { refreshToken }
   → 200 OK { newAccessToken, newRefreshToken, expiresIn }
   → Old refresh token invalidated (rotation)

4. Logout: POST /api/auth/logout
   → 204 No Content
   → Refresh token marked as revoked
```

### Password Reset
```
1. POST /api/auth/forgot-password { email }
   → 200 OK (always, no enumeration)
   → Email sent with reset token (if user exists)

2. User clicks email link with token
   → POST /api/auth/reset-password { token, newPassword }
   → 204 No Content
   → Password updated
```

---

## Error Responses

All error responses follow standardized format:

```json
{
  "type": "https://api.dartcompanion.app/errors/validation-error",
  "title": "Validation Failed",
  "status": 400,
  "detail": "One or more validation errors occurred.",
  "errors": {
    "Email": ["Email is required"],
    "Password": ["Password must be at least 8 characters"]
  }
}
```

Common HTTP status codes:
- **200 OK:** Successful query or command
- **201 Created:** Resource created (POST)
- **202 Accepted:** Async job queued (RequestExportCommand)
- **204 No Content:** Successful command with no response body
- **400 Bad Request:** Validation failure
- **401 Unauthorized:** Missing or invalid JWT
- **403 Forbidden:** User lacks permission
- **404 Not Found:** Resource does not exist
- **409 Conflict:** Sync conflict or duplicate key
- **429 Too Many Requests:** Rate limit exceeded
- **500 Internal Server Error:** Unhandled exception

---

## Request/Response DTOs

### RegisterUserCommand Request
```json
{
  "email": "player@example.com",
  "password": "SecurePass123",
  "displayName": "John Doe"
}
```

### LoginQuery Response
```json
{
  "accessToken": "eyJhbGc...",
  "refreshToken": "eyJhbGc...",
  "expiresIn": 900,
  "user": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "player@example.com",
    "displayName": "John Doe",
    "dominantHand": "Right"
  }
}
```

### CreateSessionCommand Request
```json
{
  "gameMode": "Mode501",
  "configurationJson": {
    "startingScore": 501,
    "doubleOut": true
  },
  "player2Name": null
}
```

### GetSessionHistoryQuery Response
```json
{
  "sessions": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "gameMode": "Mode501",
      "startedAt": "2026-03-09T10:00:00Z",
      "completedAt": "2026-03-09T10:15:00Z",
      "player2Name": null
    }
  ],
  "pageNumber": 1,
  "pageSize": 10,
  "totalCount": 42,
  "pageCount": 5
}
```

### RequestExportCommand Response
```json
{
  "jobId": "550e8400-e29b-41d4-a716-446655440000",
  "status": "Pending",
  "requestedAt": "2026-03-09T10:00:00Z"
}
```

