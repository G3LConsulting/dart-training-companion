# INFRA-02-T01 — Docker Compose Base & Override Files

| Metadata | Value |
|----------|-------|
| Story | [INFRA-02](../infra-02-docker-compose-local-dev.md) — Docker Compose & Local Dev Environment |
| Layer | Infra |
| Status | 🔲 Not started |
| Agent | DevOps Lead |

## What to Build

Create docker-compose.yml with all 8 services (API, PWA, PostgreSQL, Seq, Prometheus, Grafana, Mailhog, nginx), docker-compose.override.yml for local dev hot-reload, .env.example with documentation, Dockerfiles for API and Web, nginx reverse proxy config, and Prometheus scrape configuration.

## Files to Create or Modify

| File Path | Purpose | Type |
|-----------|---------|------|
| docker-compose.yml | Main compose file with all services | Create |
| docker-compose.override.yml | Local dev overrides (ports, volumes, watch) | Create |
| .env.example | Environment variable template with documentation | Create |
| src/DartsCompanion.Api/Dockerfile | Multi-stage .NET API container | Create |
| src/DartsCompanion.Web/Dockerfile | Node.js / Angular PWA container | Create |
| docker/nginx.conf | Nginx reverse proxy configuration | Create |
| docker/prometheus.yml | Prometheus scrape targets | Create |
| docker/grafana/provisioning/dashboards.yml | Grafana dashboard provisioning | Create |
| docker/grafana/provisioning/datasources.yml | Grafana datasource configuration | Create |

## Definition of Done

- [ ] docker compose up starts all 8 services without error
- [ ] All service containers reach "running" state
- [ ] API accessible at localhost:8080 (via nginx)
- [ ] Angular PWA accessible at localhost:4200 (ng serve in dev)
- [ ] Seq (logging) accessible at localhost:5341
- [ ] Mailhog (email) accessible at localhost:8025
- [ ] Prometheus accessible at localhost:9090
- [ ] Grafana accessible at localhost:3000
- [ ] PostgreSQL accessible at localhost:5432 (from host)
- [ ] .env.example documents all required variables
- [ ] docker-compose.override.yml enables hot-reload (dotnet watch, ng serve)
- [ ] All service-to-service communication works (API connects to DB, logs to Seq, etc.)
- [ ] Network isolation: services communicate via service name, not localhost
- [ ] Volume mounts allow live code reloading without container restart

## Implementation Notes

1. **Docker Compose Services**:
   ```
   - postgres: PostgreSQL 16 Alpine with persistent volume
   - seq: Structured logging (accessible at :5341)
   - prometheus: Metrics collection (accessible at :9090)
   - grafana: Dashboard UI (accessible at :3000)
   - mailhog: SMTP debugging (accessible at :8025)
   - nginx: Reverse proxy for API and PWA
   - api: .NET API service (built from Dockerfile)
   - web: Angular PWA service (built from Dockerfile)
   ```

2. **Dockerfile for API**:
   - Multi-stage build: restore dependencies in build stage, publish to runtime stage
   - Use mcr.microsoft.com/dotnet/runtime:10.0 as base
   - Expose port 8080
   - Set ASPNETCORE_URLS=http://+:8080
   - ENTRYPOINT: dotnet DartsCompanion.Api.dll

3. **Dockerfile for Web**:
   - Build stage: Node 21 Alpine, npm install, ng build --configuration production
   - Runtime stage: nginx:alpine, copy dist to /usr/share/nginx/html
   - Expose port 4200 (dev) / 80 (prod)
   - In dev (override.yml), mount src volume and run ng serve

4. **docker-compose.yml Base Config**:
   - Version: '3.9'
   - Define networks: backend (internal), frontend (API + Web)
   - PostgreSQL:
     - Image: postgres:16-alpine
     - Environment: POSTGRES_PASSWORD, POSTGRES_DB
     - Volume: postgres_data:/var/lib/postgresql/data
   - Seq, Prometheus, Grafana, Mailhog with standard images
   - API and Web services built from Dockerfiles
   - Nginx reverse proxy routes /api/* to API container, / to PWA

5. **docker-compose.override.yml Local Dev**:
   - Override ports: expose all services locally
   - API service: add volumes for src/, set dotnet watch via command
   - Web service: add volumes for src/, override command to ng serve
   - Remove production build optimizations
   - Set environment to Development for detailed logs

6. **.env.example Documentation**:
   ```
   # Database
   POSTGRES_PASSWORD=dev_password_change_in_prod
   POSTGRES_DB=dartscompanion

   # API
   ASPNETCORE_ENVIRONMENT=Development
   JWT_SECRET=your_jwt_secret_here
   SMTP_HOST=mailhog
   SMTP_PORT=1025

   # Seq logging
   SEQ_OTLP_ENDPOINT=http://seq:5341

   # Prometheus
   PROMETHEUS_SCRAPE_INTERVAL=15s
   ```

7. **Nginx Reverse Proxy**:
   - Listen on port 8080
   - Route /api/* → http://api:8080
   - Route /* → http://web:4200 (dev) or web container (prod)
   - Set appropriate headers (X-Forwarded-For, Host, etc.)
   - CORS headers if needed

8. **Prometheus Configuration**:
   - Scrape targets: API /metrics endpoint, Prometheus itself
   - Set scrape_interval: 15s
   - Persistent volume for TSDB data

9. **Volume Strategy**:
   - postgres_data: PostgreSQL persistence
   - Dev overrides: bind-mount src/ directories for live reload
   - Production: remove bind mounts, rely on built images

10. **Workflow**:
    - `docker compose build` to build images
    - `docker compose up -d` to start services
    - `docker compose logs -f [service]` to view logs
    - `docker compose down` to stop all services
    - `docker compose down -v` to remove volumes (database reset)

## References

- [Architecture](../../../shared/architecture.md)
- [Technical Approach §11](../../../shared/technical-approach.md#section-11-infrastructure--deployment)
- [Technical Approach §13](../../../shared/technical-approach.md#section-13-local-development)
