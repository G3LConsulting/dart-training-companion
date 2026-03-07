# Architecture — Darts Training Companion

> **Shared reference document.** Do not duplicate this content in story files — link to it instead.

---

## Platform & Technology Choices

| Category | Choice | Notes |
|----------|--------|-------|
| **Backend Runtime** | .NET 10 | Latest LTS; used in Web API |
| **Backend Framework** | ASP.NET Core Web API | RESTful endpoints, middleware, Identity integration |
| **Frontend Framework** | Angular 21 PWA | TypeScript, RxJS, @angular/pwa for offline & installability |
| **Authentication** | ASP.NET Core Identity + JWT Bearer | PBKDF2/HMAC-SHA512 password hashing, email tokens, rotating refresh tokens. OAuth2 (Google) post-MVP |
| **Database** | PostgreSQL 16 | Relational; jsonb for ConfigurationJson, StatsJson, ScopeJson; Docker container |
| **ORM** | EF Core 10 | Code-first migrations, value converters for jsonb, soft-delete queries |
| **Local Orchestration** | Docker Compose with `docker-compose.override.yml` | Same toolchain as server deployment; override adds hot-reload, exposed ports, dev servers |
| **Hosting — POC** | Docker Compose on private server | 8 services: api, web, nginx-proxy, postgres, seq, prometheus, grafana, mailhog |
| **Hosting — Production** | Azure Container Apps | Managed containers, scaling, integration with Key Vault |
| **CI/CD** | GitHub Actions + self-hosted runner | On private server; pushes images to local Docker registry or ACR |
| **Observability — Metrics** | Prometheus + Grafana | Scrapes /metrics endpoint; dashboards for CPU, memory, request latency |
| **Observability — Logs & Traces** | Seq (OTLP HTTP port 4318) | Structured logging via Serilog, OpenTelemetry traces; searchable UI on port 5341 |
| **Email (Dev/POC)** | Mailhog | SMTP on port 1025, UI on 8025. Configurable SMTP provider for production |
| **Email (Production)** | Configurable SMTP provider | Settings via environment or Azure Key Vault |
| **Secrets — POC** | Docker .env file | Checked into repo (POC only); no production secrets stored here |
| **Secrets — Production** | Azure Key Vault + DefaultAzureCredential | Managed identity injection; no plaintext secrets in images or code |
| **Environments** | Single (prod on private server) | For POC, all services run in one environment. Production readiness via env variables and Key Vault |
| **HTTPS** | Enforced at nginx reverse proxy | All traffic to backend and frontend via HTTPS (self-signed cert for POC) |

---

## Key Architectural Patterns

### CQRS via MediatR

Business logic is separated into **Commands** (writes) and **Queries** (reads). All requests dispatch through `IMediator.Send()`.

**Handler Organization:**
- Commands → `Application/[Domain]/Commands/`
- Queries → `Application/[Domain]/Queries/`
- Each handler lives in a subfolder or single file (e.g., `RegisterUserCommand.cs`, `RegisterUserCommandHandler.cs`)

**Constraints:**
- Controllers are thin; they extract HTTP context (userId, query params) and delegate to handlers
- No business logic in controllers, domain entities, or infrastructure
- Handlers are stateless; all state flows through constructor-injected services (repositories, IEmailSender, etc.)
- Validators auto-register via `FluentValidation` and are invoked by `ValidationBehaviour` pipeline middleware

**ValidationBehaviour:**
- MediatR pipeline behaviour auto-discovers validators from Application assembly
- On validation failure: returns HTTP 400 ProblemDetails with error list
- On validation success: handler invoked
- Reduces boilerplate; validators live alongside commands/queries

---

### ASP.NET Core Identity

Provides account management, password hashing, email verification tokens, and password reset workflows.

**Core Flows:**
1. **Register:** User submits email + password → hashed via PBKDF2/HMAC-SHA512 → email verification token sent
2. **Verify Email:** User clicks link or enters token → IsEmailConfirmed set to true
3. **Login:** Email + password → Identity validates hash → JWT (15-min) + Refresh Token (7-day) issued
4. **Refresh:** Client sends expired JWT + Refresh Token → validate token hash in DB → new JWT issued
5. **Logout:** Refresh token marked as Revoked (IsRevoked = true)
6. **Forgot Password:** User submits email → password reset token generated → email sent → user clicks link + submits new password

**Token Storage:**
- JWT: Stateless; includes userId, expiry, scopes. Expires 15 minutes
- Refresh Token: Hash (SHA-256) stored in RefreshToken table; plaintext never stored. Expires 7 days

**Password Hashing:**
- Default Identity hasher: PBKDF2 + HMAC-SHA512, 1000+ iterations
- Not configurable for MVP; production may migrate to Argon2 if needed

---

### Offline-First PWA

Angular app uses **localStorage** for in-progress sessions and **IndexedDB** for completed offline queue. On reconnection, all-or-nothing sync via POST /api/sessions/sync.

**Offline Workflow:**
1. User starts a game (online) → session created on server, stored in localStorage
2. User enters offline → SyncService detects (GET /api/health fails) → UI shows "Offline Mode" banner
3. User continues entering turns → updates persisted to localStorage (in-memory also)
4. User reconnects → SyncService detects (GET /api/health succeeds) → triggers POST /api/sessions/sync
5. Sync payload includes up to 100 sessions per batch; server returns syncedCount + conflicts array
6. On conflict: UI prompts user to choose "Keep Both", "Keep Local", "Keep Remote", "Keep Neither" → POST /api/sessions/conflicts/resolve
7. On success: localStorage cleared, sessions now server-backed

**Triggers:**
- Auto-sync on reconnect (network listener)
- Manual sync button (SyncBannerComponent)
- Periodic sync attempt (interval configurable, default 30s when offline)

**Connectivity Detection:**
- GET /api/health pinged every 10 seconds when app is active
- 200 = online, any other response = offline
- No reliance on navigator.onLine (unreliable on mobile)

**IndexedDB Usage:**
- Optional; allows larger queue for users with many offline sessions
- Not required for MVP; localStorage sufficient for typical session counts

---

### Stats Recalculation (BackgroundService + Channel)

Async stats recomputation without blocking request/response cycle.

**Flow:**
1. User triggers recalculation → Command → enqueues userId into Channel<Guid>
2. API returns HTTP 202 Accepted immediately; response includes recalculation status URL
3. BackgroundService polls Channel → dequeues userId
4. Recalculates all UserStats rows for that user (one per GameMode)
5. Computes averages, trends, personal bests from completed GameSessions
6. Updates StatsJson, LastCalculatedAt, sets IsRecalculating = false
7. Client polls GET /api/stats/recalculation-status?userId=X until IsRecalculating = false

**Performance:**
- Single in-process service; no external queue needed for MVP
- Channel bounded (default 100) to prevent memory buildup
- Heavy calculations (e.g., 500+ sessions) may take seconds; acceptable for background task

---

### Data Export (ExportJobService + BackgroundService)

Asynchronous export generation with file storage and progress tracking.

**Flow:**
1. User submits export request (filters: date range, modes, metrics) → Command
2. ExportJob created with Status=Pending, ScopeJson captured
3. API returns HTTP 202 + jobId; client redirects to progress page
4. ExportJobService polls DB for Pending jobs → sets Status=Processing
5. Enqueues task (ExcelExportWriter or CsvExportWriter) to generate file
6. On completion: Status=Complete, FilePath set, CompletedAt set
7. Client polls GET /api/export/{jobId} → when Complete, shows download button
8. GET /api/export/{jobId}/download streams file (Content-Disposition: attachment)

**Writers:**
- **ExcelExportWriter:** Uses DocumentFormat.OpenXml (OpenXml SDK) to generate .xlsx with multiple sheets (sessions, stats, PBs)
- **CsvExportWriter:** Streams CSV via TextWriter
- **JsonExportWriter:** Serializes data structure as JSON

**Storage:**
- File saved to local filesystem (POC) or Azure Blob (production)
- No archival or retention policy for MVP; production TBD

---

### Chart Wrappers (ng2-charts / Chart.js)

Dedicated Angular components encapsulate Chart.js interactions; each accepts @Input() data contracts.

**Components:**
- **TrendChartComponent** — Line chart for stat trends over time (X: dates, Y: metric value)
- **SessionBarChartComponent** — Horizontal bar chart comparing sessions by average or score
- **NumberFocusHeatGridComponent** — Grid heatmap showing accuracy per target number (1–20, bull)
- **WeeklyBarChartComponent** — Grouped bar chart for weekly stats (darts thrown, games played, PBs achieved)

**Contract Example (TrendChartComponent):**
```typescript
@Input() data: TrendDataPoint[] = [];  // { date: Date, value: number }
@Input() title: string = '';
@Input() yAxisLabel: string = '';
@Input() colors?: { backgroundColor: string; borderColor: string };
```

**Benefits:**
- Swappable implementations (can replace Chart.js with Plotly, D3, etc. without view changes)
- Consistent styling and behavior across app
- Unit-testable data transformations separate from charting library

---

## Solution Folder Structure

### Backend (.NET 10 / ASP.NET Core)

```
DartsTrainingCompanion.sln
├── DartsTrainingCompanion.Api/
│   ├── Program.cs                          // Startup, service registration, middleware
│   ├── appsettings.json                   // Config: DB, JWT, email, Seq endpoints
│   ├── appsettings.Production.json
│   ├── Controllers/
│   │   ├── HealthController.cs
│   │   ├── AuthController.cs
│   │   ├── ProfileController.cs
│   │   ├── SessionsController.cs
│   │   ├── StatsController.cs
│   │   └── ExportController.cs
│   ├── Middleware/
│   │   ├── ExceptionHandlingMiddleware.cs
│   │   └── CorrelationIdMiddleware.cs
│   └── DartsTrainingCompanion.Api.csproj
│
├── DartsTrainingCompanion.Application/
│   ├── Behaviours/
│   │   └── ValidationBehaviour.cs
│   ├── Auth/
│   │   ├── Commands/
│   │   │   ├── RegisterUserCommand.cs
│   │   │   ├── RegisterUserCommandHandler.cs
│   │   │   ├── VerifyEmailCommand.cs
│   │   │   ├── LoginCommand.cs
│   │   │   ├── RefreshTokenCommand.cs
│   │   │   ├── LogoutCommand.cs
│   │   │   ├── ForgotPasswordCommand.cs
│   │   │   └── ResetPasswordCommand.cs
│   │   ├── Queries/
│   │   │   └── GetCurrentUserQuery.cs
│   │   └── Validators/
│   │       ├── RegisterUserCommandValidator.cs
│   │       └── LoginCommandValidator.cs
│   ├── Profile/
│   │   ├── Commands/
│   │   │   ├── UpdateProfileCommand.cs
│   │   │   └── DeleteAccountCommand.cs
│   │   ├── Queries/
│   │   │   └── GetProfileQuery.cs
│   │   └── Validators/
│   │       └── UpdateProfileCommandValidator.cs
│   ├── Sessions/
│   │   ├── Commands/
│   │   │   ├── CreateSessionCommand.cs
│   │   │   ├── DeleteSessionCommand.cs
│   │   │   └── SyncSessionsCommand.cs
│   │   ├── Queries/
│   │   │   ├── GetSessionsQuery.cs
│   │   │   ├── GetSessionByIdQuery.cs
│   │   │   └── GetConflictsQuery.cs
│   │   ├── DTOs/
│   │   │   ├── SessionDto.cs
│   │   │   ├── TurnDto.cs
│   │   │   ├── ConflictDto.cs
│   │   │   └── SyncPayloadDto.cs
│   │   └── Validators/
│   │       └── CreateSessionCommandValidator.cs
│   ├── Stats/
│   │   ├── Commands/
│   │   │   └── RecalculateStatsCommand.cs
│   │   ├── Queries/
│   │   │   ├── GetStatsQuery.cs
│   │   │   ├── GetStatsRecalculationStatusQuery.cs
│   │   │   ├── GetTrendsQuery.cs
│   │   │   ├── GetPersonalBestsQuery.cs
│   │   │   ├── GetNumberFocusQuery.cs
│   │   │   └── GetWeeklyStatsQuery.cs
│   │   ├── DTOs/
│   │   │   ├── StatsDto.cs
│   │   │   ├── TrendPointDto.cs
│   │   │   └── PersonalBestDto.cs
│   │   └── Services/
│   │       └── StatsCalculationService.cs
│   ├── Export/
│   │   ├── Commands/
│   │   │   ├── CreateExportCommand.cs
│   │   │   └── ResolveConflictCommand.cs
│   │   ├── Queries/
│   │   │   └── GetExportJobQuery.cs
│   │   ├── DTOs/
│   │   │   └── ExportJobDto.cs
│   │   └── Services/
│   │       ├── ExcelExportWriter.cs
│   │       ├── CsvExportWriter.cs
│   │       └── JsonExportWriter.cs
│   ├── Common/
│   │   ├── Interfaces/
│   │   │   ├── IEmailSender.cs
│   │   │   ├── IExcelExportWriter.cs
│   │   │   └── ICurrentUserService.cs
│   │   ├── Exceptions/
│   │   │   ├── ValidationException.cs
│   │   │   ├── NotFoundException.cs
│   │   │   └── ConflictException.cs
│   │   └── DTOs/
│   │       ├── ProblemDetailsDto.cs
│   │       └── PagedResultDto.cs
│   ├── ServiceRegistration.cs
│   └── DartsTrainingCompanion.Application.csproj
│
├── DartsTrainingCompanion.Domain/
│   ├── Entities/
│   │   ├── ApplicationUser.cs
│   │   ├── RefreshToken.cs
│   │   ├── GameSession.cs
│   │   ├── Turn.cs
│   │   ├── CricketTurn.cs
│   │   ├── DartEntry.cs
│   │   ├── UserStats.cs
│   │   ├── PersonalBest.cs
│   │   └── ExportJob.cs
│   ├── Enums/
│   │   ├── GameMode.cs
│   │   ├── DartOutcome.cs
│   │   ├── ExportFormat.cs
│   │   ├── ExportStatus.cs
│   │   └── Hand.cs
│   ├── ValueObjects/
│   │   └── (e.g., PersonalBestValue if needed)
│   └── DartsTrainingCompanion.Domain.csproj
│
├── DartsTrainingCompanion.Infrastructure/
│   ├── Persistence/
│   │   ├── ApplicationDbContext.cs
│   │   ├── Repositories/
│   │   │   ├── GenericRepository.cs
│   │   │   ├── SessionRepository.cs
│   │   │   ├── StatsRepository.cs
│   │   │   └── ExportJobRepository.cs
│   │   └── Migrations/
│   │       ├── 20240101000000_Initial.cs
│   │       └── (subsequent migrations)
│   ├── Email/
│   │   └── SmtpEmailSender.cs
│   ├── Identity/
│   │   └── IdentityService.cs
│   ├── Export/
│   │   ├── ExcelExportWriter.cs
│   │   ├── CsvExportWriter.cs
│   │   └── ExportJobService.cs                  // BackgroundService polling DB
│   ├── Stats/
│   │   └── StatsRecalculationService.cs         // BackgroundService with Channel<Guid>
│   ├── Observability/
│   │   ├── ActivityEnrichment.cs
│   │   └── MetricsRegistration.cs
│   ├── ServiceRegistration.cs
│   └── DartsTrainingCompanion.Infrastructure.csproj
│
└── docker/
    ├── docker-compose.yml                      // Full stack: api, web, nginx-proxy, postgres, seq, prometheus, grafana, mailhog
    ├── docker-compose.override.yml             // Local dev: hot-reload, exposed ports, dev servers
    ├── prometheus.yml                          // Prometheus scrape config
    └── nginx.conf                              // Reverse proxy + SSL termination
```

### Frontend (Angular 21 PWA)

```
darts-training-companion/ (root)
├── angular.json
├── tsconfig.json
├── package.json
├── src/
│   ├── index.html
│   ├── main.ts
│   ├── styles.scss                              // Global styles, dark mode variables
│   ├── manifest.webmanifest
│   ├── ngsw-config.json
│   ├── favicon.ico
│   ├── app/
│   │   ├── app.config.ts
│   │   ├── app.component.ts
│   │   ├── layout/
│   │   │   ├── navbar/
│   │   │   │   └── navbar.component.ts
│   │   │   └── sidebar/
│   │   │       └── sidebar.component.ts
│   │   ├── pages/
│   │   │   ├── home/
│   │   │   │   ├── home.component.ts
│   │   │   │   └── home.component.scss
│   │   │   ├── auth/
│   │   │   │   ├── register/
│   │   │   │   ├── login/
│   │   │   │   ├── verify-email/
│   │   │   │   ├── forgot-password/
│   │   │   │   └── reset-password/
│   │   │   ├── sessions/
│   │   │   │   ├── session-list/
│   │   │   │   ├── session-detail/
│   │   │   │   ├── session-form/
│   │   │   │   └── session-input/ (score entry, number-focus drills)
│   │   │   ├── stats/
│   │   │   │   ├── stats-dashboard/
│   │   │   │   ├── trends/
│   │   │   │   ├── personal-bests/
│   │   │   │   ├── number-focus-heatmap/
│   │   │   │   └── weekly-breakdown/
│   │   │   ├── export/
│   │   │   │   ├── export-config/
│   │   │   │   └── export-progress/
│   │   │   └── profile/
│   │   │       ├── profile-view/
│   │   │       └── profile-edit/
│   │   ├── components/
│   │   │   ├── sync-banner/
│   │   │   │   └── sync-banner.component.ts
│   │   │   ├── offline-indicator/
│   │   │   │   └── offline-indicator.component.ts
│   │   │   ├── charts/
│   │   │   │   ├── trend-chart/
│   │   │   │   ├── session-bar-chart/
│   │   │   │   ├── number-focus-heat-grid/
│   │   │   │   └── weekly-bar-chart/
│   │   │   ├── conflict-resolver/
│   │   │   │   └── conflict-resolver.component.ts
│   │   │   └── (other reusable components)
│   │   ├── services/
│   │   │   ├── api/
│   │   │   │   ├── auth.service.ts
│   │   │   │   ├── sessions.service.ts
│   │   │   │   ├── stats.service.ts
│   │   │   │   ├── export.service.ts
│   │   │   │   ├── profile.service.ts
│   │   │   │   └── http.client.ts (interceptors)
│   │   │   ├── offline/
│   │   │   │   ├── sync.service.ts
│   │   │   │   ├── storage.service.ts
│   │   │   │   └── connectivity.service.ts
│   │   │   ├── auth/
│   │   │   │   ├── auth-state.service.ts
│   │   │   │   ├── jwt.service.ts
│   │   │   │   └── guard/
│   │   │   │       ├── auth.guard.ts
│   │   │   │       └── admin.guard.ts (if needed post-MVP)
│   │   │   ├── theme/
│   │   │   │   └── theme.service.ts
│   │   │   └── (other services)
│   │   ├── models/
│   │   │   ├── auth.model.ts
│   │   │   ├── session.model.ts
│   │   │   ├── stats.model.ts
│   │   │   ├── export.model.ts
│   │   │   └── (DTOs matching API contracts)
│   │   ├── pipes/
│   │   │   └── (e.g., number formatting)
│   │   └── directives/
│   │       └── (e.g., touch-target validation)
│   └── environments/
│       ├── environment.ts
│       └── environment.prod.ts
├── Dockerfile
├── .dockerignore
└── angular-build.env.example
```

---

## Layer Architecture & Rules

### Dependency Flow

```
Api (Controllers, Middleware)
    ↓ (depends on, dispatches to)
Application (CQRS handlers, validators, services)
    ↓ (depends on, implements via injected interfaces)
Infrastructure (EF Core, repositories, email, export writers, background services)
    ↓
Domain (entities, enums, value objects — no dependencies)
```

### Rules

| Layer | Allowed Dependencies | Forbidden |
|-------|---------------------|-----------|
| **Api** | Application, Domain | Infrastructure (EF Core, concrete services) |
| **Application** | Domain, Infrastructure via interfaces (IEmailSender, IExcelExportWriter, ICurrentUserService) | Direct EF Core queries, concrete implementations |
| **Infrastructure** | Application (via ICurrentUserService contract), Domain | Api (circular dependency) |
| **Domain** | None | Any external dependencies |

### Enforcement

- Controllers inject only `IMediator` (MediatR) and `ICurrentUserService`
- Application handlers inject repositories and services via interfaces (Dependency Injection)
- Infrastructure implements interfaces and registers in ServiceCollection
- Unit tests can mock Infrastructure; no EF Core in Application tests

---

## Architectural Decision Records (ADRs)

### Architecture Decisions

| ID | Title | Decision |
|----|----|----------|
| **arch-001** | CQRS via MediatR | Commands and queries separate; business logic in handlers, validated by FluentValidation pipeline behaviour |
| **arch-002** | ASP.NET Core Identity + JWT | Email/password auth with PBKDF2 hashing; JWT 15-min + rotating refresh token 7-day |
| **arch-003** | PostgreSQL jsonb for flexible config | GameSession.ConfigurationJson, UserStats.StatsJson, ExportJob.ScopeJson stored as jsonb; EF value-converted to POCOs |
| **arch-004** | Offline-first PWA with all-or-nothing sync | localStorage + IndexedDB; POST /api/sessions/sync; conflicts resolved via ConflictResolver component |
| **arch-005** | Stats recalculation via in-process BackgroundService + Channel | No external queue; Channel<Guid> with bounded capacity; UI polls for completion |
| **arch-006** | Async data export via ExportJobService | Status-tracked job (Pending → Processing → Complete/Failed); ExcelExportWriter encapsulates OpenXml generation |
| **arch-007** | Chart wrapper components (TrendChart, SessionBarChart, etc.) | Dedicated Angular components with @Input() contracts; swappable implementations |
| **arch-008** | Docker Compose override for local dev | `docker-compose.override.yml` merged with base; API uses `dotnet watch`, Angular uses `ng serve`; same toolchain as production |

### Security Decisions

| ID | Title | Decision |
|----|----|----|
| **sec-001** | HTTPS enforced at nginx reverse proxy | All traffic (frontend, backend, services) via HTTPS; self-signed cert for POC |

### Infrastructure Decisions

| ID | Title | Decision |
|----|----|----|
| **infra-001** | Docker Compose for POC, Azure Container Apps for production | Local: 8 services; Production: managed containers with Key Vault secrets |
| **infra-002** | Seq (OTLP) + Prometheus/Grafana for observability | Structured logs via Serilog; metrics via .NET diagnostics; no vendor lock-in |
| **infra-003** | CI/CD via GitHub Actions + self-hosted runner | On private server; pushes to local registry or Azure Container Registry |

---

## Docker Compose Services (POC Environment)

```yaml
version: '3.9'
services:
  # Darts Training API (.NET 10)
  api:
    build: ./DartsTrainingCompanion.Api/
    ports: [ "5000:8080" ]
    environment:
      ConnectionStrings__DefaultConnection: "Host=postgres;Port=5432;Database=darts_training;Username=darts_user;Password=..."
      JWT__SecretKey: "..."
      JWT__Issuer: "https://darts-training-companion.local"
      JWT__Audience: "darts-training-app"
      Seq__Url: "http://seq:5341"
      Prometheus__Port: "9090"
    depends_on: [ postgres, seq ]
    healthcheck:
      test: [ "CMD", "curl", "-f", "http://localhost:8080/api/health" ]
      interval: 10s
      timeout: 5s
      retries: 3

  # Angular 21 PWA
  web:
    build: ./darts-training-companion/
    ports: [ "4200:80" ]
    environment:
      API_URL: "https://api.darts-training-companion.local"
    depends_on: [ api ]

  # nginx Reverse Proxy (HTTPS, routing)
  nginx-proxy:
    image: nginx:latest
    ports: [ "80:80", "443:443" ]
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./certs/:/etc/nginx/certs/:ro
    depends_on: [ api, web ]

  # PostgreSQL 16
  postgres:
    image: postgres:16-alpine
    ports: [ "5432:5432" ]
    environment:
      POSTGRES_DB: darts_training
      POSTGRES_USER: darts_user
      POSTGRES_PASSWORD: (secure)
    volumes:
      - postgres_data:/var/lib/postgresql/data

  # Seq (logs & traces)
  seq:
    image: datalust/seq:latest
    ports: [ "5341:80", "4318:4318" ]
    environment:
      ACCEPT_EULA: "Y"
    volumes:
      - seq_data:/data

  # Prometheus (metrics)
  prometheus:
    image: prom/prometheus:latest
    ports: [ "9090:9090" ]
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - prometheus_data:/prometheus

  # Grafana (dashboards)
  grafana:
    image: grafana/grafana:latest
    ports: [ "3000:3000" ]
    environment:
      GF_SECURITY_ADMIN_PASSWORD: admin
    volumes:
      - grafana_data:/var/lib/grafana
    depends_on: [ prometheus ]

  # Mailhog (email testing)
  mailhog:
    image: mailhog/mailhog:latest
    ports: [ "1025:1025", "8025:8025" ]

volumes:
  postgres_data:
  seq_data:
  prometheus_data:
  grafana_data:
```

---

## Configuration & Secrets Management

### POC Environment (.env in Docker Compose)

```
# Database
POSTGRES_DB=darts_training
POSTGRES_USER=darts_user
POSTGRES_PASSWORD=dev_password_change_in_prod

# JWT
JWT_SECRET_KEY=dev_secret_key_change_in_prod
JWT_ISSUER=https://darts-training-companion.local
JWT_AUDIENCE=darts-training-app

# Email (Mailhog)
SMTP_HOST=mailhog
SMTP_PORT=1025
SMTP_USERNAME=
SMTP_PASSWORD=

# Observability
SEQ_URL=http://seq:5341
PROMETHEUS_PORT=9090
```

### Production Environment (Azure Key Vault)

- All secrets (JWT, SMTP, DB password) stored in Key Vault
- DefaultAzureCredential (managed identity) used for injection
- No plaintext secrets in images or code repositories

---

## Design Principles

1. **Layered Architecture:** Clear separation of concerns; each layer has a single responsibility
2. **CQRS:** Command/Query separation; handlers are single-purpose, testable
3. **DI Container:** All dependencies injected; no singletons or static dependencies
4. **Soft Deletes:** All user-owned data soft-deleted; no hard deletes for MVP
5. **Observability:** Structured logging, distributed tracing (OTLP), metrics collection
6. **Offline-First:** PWA with sync on reconnect; user data persisted locally first
7. **Security-First:** HTTPS enforced, secrets managed, identity tokens with short expiry
8. **Scalability:** Async background services (stats, export); stateless API for horizontal scaling
