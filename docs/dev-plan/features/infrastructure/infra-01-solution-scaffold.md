# INFRA-01 — Solution Scaffold & Project Setup

**Feature:** Infrastructure
**Phase:** MVP
**Status:** 🔲 Not started
**Agent:** —
**Output:** —
**Notes:** —

---

## Context

Creates the .NET solution, all projects, Angular PWA scaffold, and Docker Compose stack (base + local dev override). This is the foundation all other stories build on.

> Implements: TA §4, §11, §13

---

## Acceptance Criteria

- [ ] Solution DartsCompanion.sln created with all required projects: Api, Application, Domain, Infrastructure, UnitTests, IntegrationTests
- [ ] Angular 21 PWA scaffolded with @angular/pwa, standalone components, lazy routing
- [ ] `docker/docker-compose.yml` defines all 8 services (api, web, nginx-proxy, postgres, seq, prometheus, grafana, mailhog)
- [ ] `docker/docker-compose.override.yml` provides local dev overrides (exposed ports, bind mounts, dev server for Angular, dotnet watch for API)
- [ ] `docker compose up` starts the full local stack; API reachable at http://localhost:8080, Angular at http://localhost:4200
- [ ] Layer dependency rules enforced (Api→Application only, Application→Domain only, etc.)
- [ ] .env file created (never committed); secrets injected via GitHub Actions
- [ ] GitHub Actions workflow file created: builds solution, runs tests, builds Docker images, deploys

---

## Technical Implementation Notes

**Backend Solution Structure:**
- DartsCompanion.sln root with projects per TA §4 solution structure
- Project dependencies: Api → Application → Domain; Infrastructure sibling to Application
- OTel base setup configured directly in Api/Program.cs (no separate ServiceDefaults project)

**Frontend Angular Setup:**
- `ng new DartsCompanion.Web --standalone --routing --style=scss` then `ng add @angular/pwa`
- Standalone components and lazy routing for code splitting
- PWA manifest and service worker for offline-first capability

**Docker — Base Stack:**
- `docker/docker-compose.yml` with 8 services: api, web, nginx-proxy, postgres, seq, prometheus, grafana, mailhog
- All services defined per TA §11 specifications (production-shaped, no exposed ports except nginx-proxy)

**Docker — Local Dev Override:**
- `docker/docker-compose.override.yml` merged automatically by `docker compose up`
- API runs with `dotnet watch` and source bind mount for hot-reload
- Angular runs `ng serve` on port 4200 with poll-based file watching
- postgres, seq, grafana, mailhog ports exposed locally for tooling (DBeaver, Seq UI, etc.)
- `.env` and `.env.example` files at repo root; `.env` never committed

**CI/CD Pipeline:**
- `.github/workflows/build-deploy.yml` per TA §12
- Steps: dotnet build, dotnet test, docker build api + web, docker push, docker compose up -d
- Secrets injected via GitHub Actions secrets (never in .env)

---

## Dependencies

None

---

## Shared References

- [Architecture](../../shared/architecture.md) — §4 (solution structure), §11 (docker composition), §13 (local dev setup), §12 (ci/cd)
