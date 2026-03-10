# INFRA-02 — Docker Compose & Local Dev Environment

| Metadata | Value |
|----------|-------|
| Feature | Infrastructure |
| Phase | MVP |
| Status | 🔲 Not started |
| Agent | DevOps Lead |
| Output | docker-compose.yml, docker-compose.override.yml, Dockerfiles, environment configs |
| Notes | Enables full stack local development with hot-reload and observability stack |

## Context

Set up Docker Compose for the full stack (API, PWA, PostgreSQL, Seq, Prometheus, Grafana, Mailhog, nginx) with a local dev override for hot-reload and exposed ports. This creates a complete, reproducible local development environment.

**Implements:** TA §11 (Infrastructure & Deployment), TA §13 (Local Development)

## Acceptance Criteria

- [ ] docker compose up starts all 8 services without error
- [ ] API accessible at localhost:8080, Angular at localhost:4200, Seq at localhost:5341, Mailhog at localhost:8025
- [ ] .env.example file present with all required variables documented
- [ ] docker-compose.override.yml enables hot-reload for API (dotnet watch) and Angular (ng serve)
- [ ] All services communicate internally via container networking (PostgreSQL hostname resolution, API-to-DB, etc.)
- [ ] Volume mounts for code allow live code reloading in development

## Tasks

| Task ID | Title | Status | Layer |
|---------|-------|--------|-------|
| [INFRA-02-T01](infra-02-docker-compose-local-dev/infra-02-t01-docker-compose-setup.md) | Docker Compose base + override files | 🔲 | Infra |

## Dependencies

- [INFRA-01](infra-01-solution-scaffolding.md) — Solution structure must exist for Dockerfiles

## Shared References

- [Architecture](../../shared/architecture.md)
- [Technical Approach §11](../../shared/technical-approach.md#section-11-infrastructure--deployment)
