# API Contracts — Darts Training Companion

> **Shared reference document.** Do not duplicate this content in story files — link to it instead.

---

## Overview

All endpoints follow REST conventions. Responses use HTTP status codes and optional ProblemDetails (RFC 7807) for errors. Authentication via JWT bearer token (except Health and Auth endpoints). Pagination via `?page=1&pageSize=20` query parameters where applicable.

**Base URL (POC):** `https://api.darts-training-companion.local`

---

## 1. Health

### GET /api/health

Connectivity check for PWA offline detection. Returns 200 if API is running.

| Property | Value |
|----------|-------|
| **HTTP Method** | GET |
| **Route** | `/api/health` |
| **Auth Required** | No (Anonymous) |
| **Response Status** | 200 OK |
| **Response Body** | Plain text: "Healthy" or JSON: `{ "status": "Healthy" }` |

**Notes:**
- Used by SyncService (connectivity.service.ts) to detect online/offline
- Pinged every 10 seconds when app is active
- No business logic; returns immediately
- Should be cached-bust-proof (no caching headers)

---

## 2. Auth

### POST /api/auth/register

Create a new user account. Email must be unique. Password hashed via PBKDF2/HMAC-SHA512. Verification email sent.

| Property | Value |
|----------|-------|
| **HTTP Method** | POST |
| **Route** | `/api/auth/register` |
| **Auth Required** | No (Anonymous) |
| **Request Body** | JSON |
| **Response Status** | 201 Created, 400 Bad Request, 409 Conflict (email exists) |
| **Command** | RegisterUserCommand |

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "SecurePassword123!",
  "displayName": "John Doe"
}
```

**Response (201):**
```json
{
  "userId": "550e8400-e29b-41d4-a716-446655440000",
  "email": "user@example.com",
  "displayName": "John Doe",
  "message": "Registration successful. Please verify your email."
}
```

**Response (409 Conflict):**
```json
{
  "type": "https://api.darts-training-companion.local/errors/email-already-exists",
  "title": "Email Already In Use",
  "status": 409,
  "detail": "An account with this email already exists."
}
```

**Validators:**
- Email: valid format, not null
- Password: min 8 chars, contains upper, lower, digit, special char
- DisplayName: 1–100 chars, not null

---

### POST /api/auth/verify-email

Verify email address using token sent to user's inbox.

| Property | Value |
|----------|-------|
| **HTTP Method** | POST |
| **Route** | `/api/auth/verify-email` |
| **Auth Required** | No (Anonymous) |
| **Request Body** | JSON |
| **Response Status** | 200 OK, 400 Bad Request, 404 Not Found |
| **Command** | VerifyEmailCommand |

**Request Body:**
```json
{
  "email": "user@example.com",
  "token": "CfDJ8..."
}
```

**Response (200):**
```json
{
  "message": "Email verified successfully. You can now log in."
}
```

**Response (400):**
```json
{
  "type": "https://api.darts-training-companion.local/errors/invalid-token",
  "title": "Invalid or Expired Token",
  "status": 400,
  "detail": "The verification token is invalid or has expired."
}
```

---

### POST /api/auth/resend-verification

Resend verification email to user's registered email address.

| Property | Value |
|----------|-------|
| **HTTP Method** | POST |
| **Route** | `/api/auth/resend-verification` |
| **Auth Required** | No (Anonymous) |
| **Request Body** | JSON |
| **Response Status** | 200 OK, 404 Not Found |
| **Command** | ResendVerificationEmailCommand |

**Request Body:**
```json
{
  "email": "user@example.com"
}
```

**Response (200):**
```json
{
  "message": "Verification email sent. Please check your inbox."
}
```

---

### POST /api/auth/login

Authenticate user with email and password. Returns JWT and refresh token.

| Property | Value |
|----------|-------|
| **HTTP Method** | POST |
| **Route** | `/api/auth/login` |
| **Auth Required** | No (Anonymous) |
| **Request Body** | JSON |
| **Response Status** | 200 OK, 400 Bad Request, 401 Unauthorized |
| **Command** | LoginCommand |

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "SecurePassword123!"
}
```

**Response (200):**
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
  "expiresIn": 900,
  "tokenType": "Bearer",
  "userId": "550e8400-e29b-41d4-a716-446655440000"
}
```

**Response (401):**
```json
{
  "type": "https://api.darts-training-companion.local/errors/invalid-credentials",
  "title": "Invalid Email or Password",
  "status": 401,
  "detail": "Email or password is incorrect."
}
```

**Notes:**
- AccessToken valid for 15 minutes
- RefreshToken valid for 7 days; hash stored in database
- Client must store both tokens (accessToken in memory, refreshToken in secure storage)
- Include `Authorization: Bearer <accessToken>` in subsequent requests

---

### POST /api/auth/refresh

Issue a new access token using a valid refresh token.

| Property | Value |
|----------|-------|
| **HTTP Method** | POST |
| **Route** | `/api/auth/refresh` |
| **Auth Required** | No (Anonymous) |
| **Request Body** | JSON |
| **Response Status** | 200 OK, 401 Unauthorized |
| **Command** | RefreshTokenCommand |

**Request Body:**
```json
{
  "refreshToken": "f47ac10b-58cc-4372-a567-0e02b2c3d479"
}
```

**Response (200):**
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "550e8400-e29b-41d4-a716-446655440001",
  "expiresIn": 900,
  "tokenType": "Bearer"
}
```

**Response (401):**
```json
{
  "type": "https://api.darts-training-companion.local/errors/invalid-refresh-token",
  "title": "Invalid or Expired Refresh Token",
  "status": 401,
  "detail": "Refresh token is invalid, expired, or revoked."
}
```

**Notes:**
- Refresh token is rotated on each use; old token invalidated
- If refresh token is expired or revoked, user must re-login

---

### POST /api/auth/logout

Revoke the provided refresh token. User is logged out.

| Property | Value |
|----------|-------|
| **HTTP Method** | POST |
| **Route** | `/api/auth/logout` |
| **Auth Required** | Yes (Bearer) |
| **Request Body** | JSON |
| **Response Status** | 200 OK, 401 Unauthorized |
| **Command** | LogoutCommand |

**Request Body:**
```json
{
  "refreshToken": "f47ac10b-58cc-4372-a567-0e02b2c3d479"
}
```

**Response (200):**
```json
{
  "message": "Logged out successfully."
}
```

---

### POST /api/auth/forgot-password

Request a password reset token. Token sent to user's email.

| Property | Value |
|----------|-------|
| **HTTP Method** | POST |
| **Route** | `/api/auth/forgot-password` |
| **Auth Required** | No (Anonymous) |
| **Request Body** | JSON |
| **Response Status** | 200 OK (always, for security), 404 Not Found |
| **Command** | ForgotPasswordCommand |

**Request Body:**
```json
{
  "email": "user@example.com"
}
```

**Response (200):**
```json
{
  "message": "Password reset email sent. Please check your inbox."
}
```

**Notes:**
- Always returns 200, even if email not found (prevents email enumeration attacks)

---

### POST /api/auth/reset-password

Reset password using a valid reset token.

| Property | Value |
|----------|-------|
| **HTTP Method** | POST |
| **Route** | `/api/auth/reset-password` |
| **Auth Required** | No (Anonymous) |
| **Request Body** | JSON |
| **Response Status** | 200 OK, 400 Bad Request |
| **Command** | ResetPasswordCommand |

**Request Body:**
```json
{
  "email": "user@example.com",
  "token": "CfDJ8...",
  "newPassword": "NewPassword123!"
}
```

**Response (200):**
```json
{
  "message": "Password reset successfully. You can now log in."
}
```

**Response (400):**
```json
{
  "type": "https://api.darts-training-companion.local/errors/invalid-reset-token",
  "title": "Invalid or Expired Reset Token",
  "status": 400,
  "detail": "The reset token is invalid or has expired."
}
```

---

## 3. Profile

### GET /api/profile

Retrieve current user's profile. Requires authentication.

| Property | Value |
|----------|-------|
| **HTTP Method** | GET |
| **Route** | `/api/profile` |
| **Auth Required** | Yes (Bearer) |
| **Response Status** | 200 OK, 401 Unauthorized |
| **Query** | GetProfileQuery |

**Response (200):**
```json
{
  "userId": "550e8400-e29b-41d4-a716-446655440000",
  "email": "user@example.com",
  "displayName": "John Doe",
  "dominantHand": "Right",
  "preferredGameMode": "Mode501",
  "targetAverage": 45.50,
  "weekStartDay": "Monday",
  "homeScreenPbMetricKey": "avg_3dart_501",
  "leaderboardOptIn": false,
  "createdAt": "2025-01-15T10:30:00Z",
  "updatedAt": "2025-03-07T14:22:00Z"
}
```

---

### PUT /api/profile

Update current user's profile settings.

| Property | Value |
|----------|-------|
| **HTTP Method** | PUT |
| **Route** | `/api/profile` |
| **Auth Required** | Yes (Bearer) |
| **Request Body** | JSON |
| **Response Status** | 200 OK, 400 Bad Request, 401 Unauthorized |
| **Command** | UpdateProfileCommand |

**Request Body:**
```json
{
  "displayName": "John Smith",
  "dominantHand": "Right",
  "preferredGameMode": "Cricket",
  "targetAverage": 50.00,
  "weekStartDay": "Sunday",
  "homeScreenPbMetricKey": "avg_3dart_cricket",
  "leaderboardOptIn": true
}
```

**Response (200):**
```json
{
  "message": "Profile updated successfully.",
  "profile": {
    "userId": "550e8400-e29b-41d4-a716-446655440000",
    "email": "user@example.com",
    "displayName": "John Smith",
    "dominantHand": "Right",
    "preferredGameMode": "Cricket",
    "targetAverage": 50.00,
    "weekStartDay": "Sunday",
    "homeScreenPbMetricKey": "avg_3dart_cricket",
    "leaderboardOptIn": true,
    "updatedAt": "2025-03-07T14:22:00Z"
  }
}
```

---

### DELETE /api/profile

Delete user account (soft delete). All user data flagged as deleted. Data export available before deletion.

| Property | Value |
|----------|-------|
| **HTTP Method** | DELETE |
| **Route** | `/api/profile` |
| **Auth Required** | Yes (Bearer) |
| **Request Body** | JSON (optional confirmation) |
| **Response Status** | 204 No Content, 401 Unauthorized |
| **Command** | DeleteAccountCommand |

**Request Body (optional):**
```json
{
  "confirm": true,
  "reason": "User requested deletion"
}
```

**Response (204):**
```
(No body; user account and all related data flagged IsDeleted = true)
```

**Notes:**
- Soft delete only; data remains in database indefinitely
- User can re-register with same email after deletion
- (Post-MVP: purge policy for GDPR compliance)

---

## 4. Sessions

### GET /api/sessions

List user's game sessions with optional pagination and filtering.

| Property | Value |
|----------|-------|
| **HTTP Method** | GET |
| **Route** | `/api/sessions` |
| **Auth Required** | Yes (Bearer) |
| **Query Parameters** | `page=1`, `pageSize=20`, `mode=501`, `status=completed` |
| **Response Status** | 200 OK, 401 Unauthorized |
| **Query** | GetSessionsQuery |

**Query Parameters:**
- `page`: Integer, default 1
- `pageSize`: Integer, default 20 (max 100)
- `mode`: Optional filter (Mode501, Mode301, Cricket, NumberFocus)
- `status`: Optional filter (in_progress, completed, abandoned)
- `sortBy`: Optional (startedAt, completedAt, score)
- `sortOrder`: Optional (asc, desc)

**Response (200):**
```json
{
  "items": [
    {
      "id": "b2e9d3a0-8c2b-4e1f-a9d5-3e7c2f1b4a5d",
      "gameMode": "Mode501",
      "startedAt": "2025-03-07T10:00:00Z",
      "completedAt": "2025-03-07T10:15:30Z",
      "player2Name": null,
      "turns": [
        {
          "id": "a1b2c3d4-5678-90ab-cdef-1234567890ab",
          "turnNumber": 1,
          "playerIndex": 0,
          "score": 45,
          "remainingScore": 456,
          "isBust": false
        }
      ],
      "configurationJson": { "handicap": false },
      "isDeleted": false,
      "createdAt": "2025-03-07T10:00:00Z",
      "updatedAt": "2025-03-07T10:15:30Z"
    }
  ],
  "totalCount": 45,
  "pageNumber": 1,
  "pageSize": 20,
  "totalPages": 3
}
```

---

### GET /api/sessions/{id}

Retrieve a single game session by ID.

| Property | Value |
|----------|-------|
| **HTTP Method** | GET |
| **Route** | `/api/sessions/{id}` |
| **Auth Required** | Yes (Bearer) |
| **Response Status** | 200 OK, 401 Unauthorized, 404 Not Found |
| **Query** | GetSessionByIdQuery |

**Response (200):**
```json
{
  "id": "b2e9d3a0-8c2b-4e1f-a9d5-3e7c2f1b4a5d",
  "gameMode": "Mode501",
  "startedAt": "2025-03-07T10:00:00Z",
  "completedAt": "2025-03-07T10:15:30Z",
  "player2Name": "Jane Doe",
  "turns": [ { ... }, { ... } ],
  "cricketTurns": [],
  "dartEntries": [],
  "configurationJson": { "handicap": false },
  "isDeleted": false,
  "createdAt": "2025-03-07T10:00:00Z",
  "updatedAt": "2025-03-07T10:15:30Z"
}
```

---

### POST /api/sessions

Create a new game session (start a new game).

| Property | Value |
|----------|-------|
| **HTTP Method** | POST |
| **Route** | `/api/sessions` |
| **Auth Required** | Yes (Bearer) |
| **Request Body** | JSON |
| **Response Status** | 201 Created, 400 Bad Request, 401 Unauthorized |
| **Command** | CreateSessionCommand |

**Request Body:**
```json
{
  "gameMode": "Mode501",
  "startedAt": "2025-03-07T10:00:00Z",
  "completedAt": null,
  "player2Name": "Jane Doe",
  "configurationJson": {
    "handicap": false,
    "autoAdvance": true
  },
  "turns": [
    {
      "turnNumber": 1,
      "playerIndex": 0,
      "score": 45,
      "remainingScore": 456,
      "isBust": false
    }
  ],
  "cricketTurns": [],
  "dartEntries": []
}
```

**Response (201):**
```json
{
  "id": "b2e9d3a0-8c2b-4e1f-a9d5-3e7c2f1b4a5d",
  "gameMode": "Mode501",
  "startedAt": "2025-03-07T10:00:00Z",
  "completedAt": null,
  "player2Name": "Jane Doe",
  "configurationJson": { "handicap": false, "autoAdvance": true },
  "turns": [ { "turnNumber": 1, ... } ],
  "isDeleted": false,
  "createdAt": "2025-03-07T10:00:00Z",
  "updatedAt": "2025-03-07T10:00:00Z"
}
```

---

### DELETE /api/sessions/{id}

Soft-delete a session (mark as deleted; data retained).

| Property | Value |
|----------|-------|
| **HTTP Method** | DELETE |
| **Route** | `/api/sessions/{id}` |
| **Auth Required** | Yes (Bearer) |
| **Response Status** | 204 No Content, 401 Unauthorized, 404 Not Found |
| **Command** | DeleteSessionCommand |

**Response (204):**
```
(No body; session flagged IsDeleted = true)
```

---

### POST /api/sessions/sync

Sync offline sessions to server. All-or-nothing batch upload with conflict detection.

| Property | Value |
|----------|-------|
| **HTTP Method** | POST |
| **Route** | `/api/sessions/sync` |
| **Auth Required** | Yes (Bearer) |
| **Request Body** | JSON array |
| **Response Status** | 200 OK, 400 Bad Request, 401 Unauthorized, 409 Conflict |
| **Command** | SyncSessionsCommand |

**Request Body:**
```json
{
  "sessions": [
    {
      "id": "b2e9d3a0-8c2b-4e1f-a9d5-3e7c2f1b4a5d",
      "gameMode": "Mode501",
      "startedAt": "2025-03-07T10:00:00Z",
      "completedAt": "2025-03-07T10:15:30Z",
      "player2Name": null,
      "configurationJson": { "handicap": false },
      "turns": [ { ... } ],
      "isDeleted": false
    }
  ]
}
```

**Constraints:**
- Max 100 sessions per batch
- Sessions must belong to authenticated user
- All sessions must have valid gameMode and turns/cricketTurns/dartEntries per mode

**Response (200):**
```json
{
  "syncedCount": 5,
  "conflicts": []
}
```

**Response (409 with conflicts):**
```json
{
  "syncedCount": 0,
  "conflicts": [
    {
      "conflictId": "c1d2e3f4-5678-90ab-cdef-1234567890ab",
      "localSession": {
        "id": "b2e9d3a0-8c2b-4e1f-a9d5-3e7c2f1b4a5d",
        "completedAt": "2025-03-07T10:15:30Z",
        "turns": 2
      },
      "serverSession": {
        "id": "b2e9d3a0-8c2b-4e1f-a9d5-3e7c2f1b4a5d",
        "completedAt": "2025-03-07T10:20:00Z",
        "turns": 3
      }
    }
  ]
}
```

**Notes:**
- Conflict occurs if session exists on server with different completedAt or turn count
- Client must resolve conflicts before retry (see /api/sessions/conflicts/resolve)

---

### GET /api/sessions/conflicts

List unresolved conflicts from last sync.

| Property | Value |
|----------|-------|
| **HTTP Method** | GET |
| **Route** | `/api/sessions/conflicts` |
| **Auth Required** | Yes (Bearer) |
| **Response Status** | 200 OK, 401 Unauthorized |
| **Query** | GetConflictsQuery |

**Response (200):**
```json
{
  "conflicts": [
    {
      "conflictId": "c1d2e3f4-5678-90ab-cdef-1234567890ab",
      "localSession": { ... },
      "serverSession": { ... }
    }
  ]
}
```

---

### POST /api/sessions/conflicts/resolve

Resolve a single conflict by choosing a resolution strategy.

| Property | Value |
|----------|-------|
| **HTTP Method** | POST |
| **Route** | `/api/sessions/conflicts/resolve` |
| **Auth Required** | Yes (Bearer) |
| **Request Body** | JSON |
| **Response Status** | 200 OK, 400 Bad Request, 401 Unauthorized, 404 Not Found |
| **Command** | ResolveConflictCommand |

**Request Body:**
```json
{
  "conflictId": "c1d2e3f4-5678-90ab-cdef-1234567890ab",
  "resolution": "KeepLocal"
}
```

**Resolution Strategies:**
- `KeepBoth`: Save both local and server versions as separate sessions
- `KeepLocal`: Override server session with local version
- `KeepRemote`: Discard local version, use server version
- `KeepNeither`: Delete both versions

**Response (200):**
```json
{
  "message": "Conflict resolved successfully.",
  "resolution": "KeepLocal"
}
```

---

## 5. Stats

### GET /api/stats

Retrieve user's aggregated statistics for all game modes.

| Property | Value |
|----------|-------|
| **HTTP Method** | GET |
| **Route** | `/api/stats` |
| **Auth Required** | Yes (Bearer) |
| **Query Parameters** | `range=30d`, `mode=501` |
| **Response Status** | 200 OK, 401 Unauthorized |
| **Query** | GetStatsQuery |

**Query Parameters:**
- `range`: Optional (7d, 30d, 90d, 365d, all); default all
- `mode`: Optional filter (Mode501, Mode301, Cricket, NumberFocus)

**Response (200):**
```json
{
  "stats": [
    {
      "userId": "550e8400-e29b-41d4-a716-446655440000",
      "gameMode": "Mode501",
      "gamesPlayed": 25,
      "gamesWon": 15,
      "avg3Dart": 42.50,
      "avgDarts": 21.30,
      "highestScore": 120,
      "lowestScore": 5,
      "winRate": 0.60,
      "isRecalculating": false,
      "lastCalculatedAt": "2025-03-07T14:22:00Z",
      "createdAt": "2025-01-15T10:30:00Z",
      "updatedAt": "2025-03-07T14:22:00Z"
    }
  ]
}
```

---

### GET /api/stats/trends

Retrieve stat trends over time (for trend charts).

| Property | Value |
|----------|-------|
| **HTTP Method** | GET |
| **Route** | `/api/stats/trends` |
| **Auth Required** | Yes (Bearer) |
| **Query Parameters** | `metric=avg_3dart_501`, `mode=501`, `range=90d` |
| **Response Status** | 200 OK, 401 Unauthorized, 400 Bad Request |
| **Query** | GetTrendsQuery |

**Query Parameters:**
- `metric`: Required (e.g., avg_3dart_501, avg_darts_301, cricket_points_per_game)
- `mode`: Optional filter; inferred from metric if omitted
- `range`: Optional (7d, 30d, 90d, 365d, all); default 90d

**Response (200):**
```json
{
  "metric": "avg_3dart_501",
  "dataPoints": [
    {
      "date": "2025-02-05",
      "value": 40.20
    },
    {
      "date": "2025-02-06",
      "value": 41.50
    }
  ],
  "range": "90d"
}
```

---

### GET /api/stats/personal-bests

Retrieve user's personal best achievements.

| Property | Value |
|----------|-------|
| **HTTP Method** | GET |
| **Route** | `/api/stats/personal-bests` |
| **Auth Required** | Yes (Bearer) |
| **Query Parameters** | `mode=501` |
| **Response Status** | 200 OK, 401 Unauthorized |
| **Query** | GetPersonalBestsQuery |

**Query Parameters:**
- `mode`: Optional filter (Mode501, Mode301, Cricket, NumberFocus)

**Response (200):**
```json
{
  "personalBests": [
    {
      "id": "d4e5f6g7-8901-2345-6789-abcdef012345",
      "userId": "550e8400-e29b-41d4-a716-446655440000",
      "metricKey": "avg_3dart_501",
      "value": 50.75,
      "achievedAt": "2025-03-01T15:30:00Z",
      "sessionId": "b2e9d3a0-8c2b-4e1f-a9d5-3e7c2f1b4a5d"
    },
    {
      "id": "e5f6g7h8-9012-3456-7890-bcdef0123456",
      "metricKey": "avg_darts_501",
      "value": 21.10,
      "achievedAt": "2025-02-28T12:00:00Z",
      "sessionId": "b2e9d3a0-8c2b-4e1f-a9d5-3e7c2f1b4a5d"
    }
  ]
}
```

---

### GET /api/stats/number-focus/{number}

Retrieve NumberFocus accuracy and performance data for a specific target number.

| Property | Value |
|----------|-------|
| **HTTP Method** | GET |
| **Route** | `/api/stats/number-focus/{number}` |
| **Auth Required** | Yes (Bearer) |
| **Path Parameters** | `number`: 1–20 or "bull" |
| **Query Parameters** | `range=30d` |
| **Response Status** | 200 OK, 400 Bad Request, 401 Unauthorized, 404 Not Found |
| **Query** | GetNumberFocusQuery |

**Response (200):**
```json
{
  "number": "20",
  "dartsThrownTotal": 240,
  "triples": 80,
  "doubles": 45,
  "singles": 60,
  "misses": 55,
  "weightedAccuracy": 68.75,
  "lastUpdated": "2025-03-07T14:22:00Z"
}
```

**Weighted Accuracy Formula:**
```
(Triples × 3 + Doubles × 2 + Singles × 1) / (Total Darts × 3) × 100
```

---

### GET /api/stats/weekly

Retrieve weekly aggregated statistics (games per day, darts per day, PBs achieved).

| Property | Value |
|----------|-------|
| **HTTP Method** | GET |
| **Route** | `/api/stats/weekly` |
| **Auth Required** | Yes (Bearer) |
| **Query Parameters** | `range=4w`, `mode=501` |
| **Response Status** | 200 OK, 401 Unauthorized |
| **Query** | GetWeeklyStatsQuery |

**Query Parameters:**
- `range`: Optional (1w, 2w, 4w, 13w); default 4w
- `mode`: Optional filter

**Response (200):**
```json
{
  "weekStartDay": "Monday",
  "weeks": [
    {
      "startDate": "2025-02-17",
      "endDate": "2025-02-23",
      "gamesPlayed": 12,
      "dartsThrownTotal": 360,
      "personalBestsAchieved": 2,
      "avgPer3Darts": 41.20
    },
    {
      "startDate": "2025-02-24",
      "endDate": "2025-03-02",
      "gamesPlayed": 15,
      "dartsThrownTotal": 450,
      "personalBestsAchieved": 1,
      "avgPer3Darts": 42.50
    }
  ]
}
```

---

### GET /api/stats/recalculation-status

Check if stats recalculation is in progress.

| Property | Value |
|----------|-------|
| **HTTP Method** | GET |
| **Route** | `/api/stats/recalculation-status` |
| **Auth Required** | Yes (Bearer) |
| **Response Status** | 200 OK, 401 Unauthorized |
| **Query** | GetStatsRecalculationStatusQuery |

**Response (200):**
```json
{
  "isRecalculating": false,
  "lastCalculatedAt": "2025-03-07T14:22:00Z"
}
```

**Notes:**
- Client polls this endpoint every 2 seconds until isRecalculating = false
- Used by StatsProgressComponent to show spinner during recalculation

---

## 6. Export

### POST /api/export

Request a data export job (CSV, Excel, or JSON).

| Property | Value |
|----------|-------|
| **HTTP Method** | POST |
| **Route** | `/api/export` |
| **Auth Required** | Yes (Bearer) |
| **Request Body** | JSON |
| **Response Status** | 202 Accepted, 400 Bad Request, 401 Unauthorized |
| **Command** | CreateExportCommand |

**Request Body:**
```json
{
  "format": "Excel",
  "scope": {
    "startDate": "2025-01-01",
    "endDate": "2025-03-07",
    "gameModes": ["Mode501", "Mode301", "Cricket", "NumberFocus"],
    "includePersonalBests": true,
    "includeStats": true
  }
}
```

**Response (202):**
```json
{
  "jobId": "e6f7g8h9-0123-4567-89ab-cdef01234567",
  "status": "Pending",
  "format": "Excel",
  "requestedAt": "2025-03-07T14:22:00Z",
  "estimatedCompletionTime": "2025-03-07T14:23:00Z"
}
```

**Notes:**
- Export runs asynchronously
- Status polling via GET /api/export/{jobId}
- Offline mode: export disabled with tooltip message

---

### GET /api/export/{jobId}

Check export job status and retrieve result metadata.

| Property | Value |
|----------|-------|
| **HTTP Method** | GET |
| **Route** | `/api/export/{jobId}` |
| **Auth Required** | Yes (Bearer) |
| **Response Status** | 200 OK, 401 Unauthorized, 404 Not Found |
| **Query** | GetExportJobQuery |

**Response (200 — Processing):**
```json
{
  "jobId": "e6f7g8h9-0123-4567-89ab-cdef01234567",
  "status": "Processing",
  "format": "Excel",
  "requestedAt": "2025-03-07T14:22:00Z",
  "completedAt": null,
  "filePath": null,
  "progress": {
    "estimatedPercentage": 45
  }
}
```

**Response (200 — Complete):**
```json
{
  "jobId": "e6f7g8h9-0123-4567-89ab-cdef01234567",
  "status": "Complete",
  "format": "Excel",
  "requestedAt": "2025-03-07T14:22:00Z",
  "completedAt": "2025-03-07T14:23:30Z",
  "filePath": "/exports/550e8400-e29b-41d4-a716-446655440000/export_20250307.xlsx",
  "downloadUrl": "/api/export/e6f7g8h9-0123-4567-89ab-cdef01234567/download"
}
```

**Response (200 — Failed):**
```json
{
  "jobId": "e6f7g8h9-0123-4567-89ab-cdef01234567",
  "status": "Failed",
  "format": "Excel",
  "requestedAt": "2025-03-07T14:22:00Z",
  "completedAt": "2025-03-07T14:23:45Z",
  "error": "Insufficient disk space. Please try again later."
}
```

---

### GET /api/export/{jobId}/download

Download the completed export file.

| Property | Value |
|----------|-------|
| **HTTP Method** | GET |
| **Route** | `/api/export/{jobId}/download` |
| **Auth Required** | Yes (Bearer) |
| **Response Status** | 200 OK (file stream), 400 Bad Request, 401 Unauthorized, 404 Not Found |

**Response Headers:**
```
Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
Content-Disposition: attachment; filename="DartsTraining_Export_20250307.xlsx"
Content-Length: 524288
```

**Response Body:** Binary file data (xlsx, csv, or json depending on format)

**Notes:**
- Only available after Status = Complete
- 400 Bad Request if status != Complete
- Downloads are one-time; file remains on server for 7 days (cleanup TBD)

---

## Error Responses (All Endpoints)

All error responses use RFC 7807 ProblemDetails format:

```json
{
  "type": "https://api.darts-training-companion.local/errors/validation-failed",
  "title": "One or More Validation Errors Occurred",
  "status": 400,
  "detail": "Please check the errors property for details.",
  "errors": [
    {
      "field": "email",
      "messages": ["Email is required", "Email must be a valid email address"]
    },
    {
      "field": "password",
      "messages": ["Password must be at least 8 characters long"]
    }
  ],
  "traceId": "0HN8J7K6L5M4N3O2P1Q0R9S8T7U6V5W4"
}
```

**Common Status Codes:**
- **200 OK** — Request succeeded
- **201 Created** — Resource created
- **202 Accepted** — Async request queued (export, stats recalculation)
- **204 No Content** — Resource deleted
- **400 Bad Request** — Validation error or malformed request
- **401 Unauthorized** — Missing or invalid JWT
- **404 Not Found** — Resource not found
- **409 Conflict** — Sync conflict or email already exists
- **500 Internal Server Error** — Server error; check traceId in logs

---

## Rate Limiting (Post-MVP)

Rate limiting headers (planned for production):
```
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1641024000
```

---

## Pagination Convention

All list endpoints support pagination via query parameters:
```
GET /api/sessions?page=1&pageSize=20
GET /api/stats/personal-bests?page=1&pageSize=50
```

Response includes metadata:
```json
{
  "items": [ ... ],
  "totalCount": 150,
  "pageNumber": 1,
  "pageSize": 20,
  "totalPages": 8
}
```
