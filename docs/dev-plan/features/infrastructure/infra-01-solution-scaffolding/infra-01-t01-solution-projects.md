# INFRA-01-T01 — Create .NET Solution & Project Structure

| Metadata | Value |
|----------|-------|
| Story | [INFRA-01](../infra-01-solution-scaffolding.md) — Solution Scaffolding & Domain Model |
| Layer | Infra |
| Status | 🔲 Not started |
| Agent | Backend Lead |

## What to Build

Create DartsCompanion.sln with src/DartsCompanion.Api, .Application, .Domain, .Infrastructure and tests/DartsCompanion.UnitTests, .IntegrationTests. Set project references per layer rules.

## Files to Create or Modify

| File Path | Purpose | Type |
|-----------|---------|------|
| DartsCompanion.sln | Solution file | Create |
| src/DartsCompanion.Api/DartsCompanion.Api.csproj | API layer project | Create |
| src/DartsCompanion.Application/DartsCompanion.Application.csproj | Application layer project | Create |
| src/DartsCompanion.Domain/DartsCompanion.Domain.csproj | Domain layer project | Create |
| src/DartsCompanion.Infrastructure/DartsCompanion.Infrastructure.csproj | Infrastructure layer project | Create |
| tests/DartsCompanion.UnitTests/DartsCompanion.UnitTests.csproj | Unit tests project | Create |
| tests/DartsCompanion.IntegrationTests/DartsCompanion.IntegrationTests.csproj | Integration tests project | Create |

## Definition of Done

- [ ] Solution compiles without errors
- [ ] Layer references are correct (Api→Application only, Application→Domain only, Infrastructure→Application+Domain, Domain has no dependencies)
- [ ] Project structure matches directory layout
- [ ] All projects target .NET 9.0
- [ ] No circular dependencies between layers

## Implementation Notes

1. Use `dotnet new sln` to create the solution
2. Use `dotnet new classlib` for library projects (Application, Domain, Infrastructure)
3. Use `dotnet new web` for API project
4. Use `dotnet new xunit` for test projects
5. Add project references using `dotnet add` with proper direction:
   - DartsCompanion.Api → DartsCompanion.Application
   - DartsCompanion.Application → DartsCompanion.Domain
   - DartsCompanion.Infrastructure → DartsCompanion.Application
   - DartsCompanion.Infrastructure → DartsCompanion.Domain
   - Test projects → respective layers being tested

## References

- [Architecture](../../../shared/architecture.md)
- [Technical Approach §4](../../../shared/technical-approach.md#section-4-solution-structure)
