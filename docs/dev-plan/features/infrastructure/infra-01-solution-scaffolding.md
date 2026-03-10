# INFRA-01 — Solution Scaffolding & Domain Model

| Metadata | Value |
|----------|-------|
| Feature | Infrastructure |
| Phase | MVP |
| Status | 🔲 Not started |
| Agent | Backend Lead |
| Output | DartsCompanion.sln with 5 projects, domain entities, EF Core migration, Angular PWA scaffold |
| Notes | Foundation story for all subsequent infrastructure stories |

## Context

Create the .NET solution structure with all projects, the Angular PWA scaffold, and the initial domain entities with EF Core migrations. This is the foundation for all subsequent stories.

**Implements:** TA §4 (Solution Structure), TA §5 (Domain Model)

## Acceptance Criteria

- [ ] DartsCompanion.sln compiles with all 5 projects (Api, Application, Domain, Infrastructure, Web)
- [ ] Layer dependencies are correctly configured (Api→Application, Application→Domain, Infrastructure→Application+Domain, Domain has no deps)
- [ ] All domain entities (ApplicationUser, RefreshToken, GameSession, Turn, CricketTurn, DartEntry, UserStats, PersonalBest, ExportJob) and enums (GameMode, Hand, DartOutcome, ExportFormat, ExportStatus) compile
- [ ] EF Core initial migration applies without error to a PostgreSQL database
- [ ] Angular 21 PWA scaffold serves at localhost:4200

## Tasks

| Task ID | Title | Status | Layer |
|---------|-------|--------|-------|
| [INFRA-01-T01](infra-01-solution-scaffolding/infra-01-t01-solution-projects.md) | Create .NET solution & project structure | 🔲 | Infra |
| [INFRA-01-T02](infra-01-solution-scaffolding/infra-01-t02-domain-entities.md) | Domain entities & enums | 🔲 | DB |
| [INFRA-01-T03](infra-01-solution-scaffolding/infra-01-t03-ef-core-dbcontext.md) | EF Core DbContext & initial migration | 🔲 | DB |
| [INFRA-01-T04](infra-01-solution-scaffolding/infra-01-t04-angular-pwa-scaffold.md) | Angular 21 PWA scaffold | 🔲 | Frontend |

## Dependencies

None — foundation story.

## Shared References

- [Domain Model](../../shared/domain-model.md)
- [Architecture](../../shared/architecture.md)
