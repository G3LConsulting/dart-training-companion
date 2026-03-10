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
| src/DartsCompanion.Api/Program.cs | Startup config using DI extension methods (see pattern below) | Create |
| src/DartsCompanion.Api/DependencyInjection.cs | API-layer DI registrations (controllers, Swagger, CORS) | Create |
| src/DartsCompanion.Application/DartsCompanion.Application.csproj | Application layer project | Create |
| src/DartsCompanion.Application/DependencyInjection.cs | Application-layer DI (MediatR, FluentValidation, pipeline behaviours) | Create |
| src/DartsCompanion.Domain/DartsCompanion.Domain.csproj | Domain layer project | Create |
| src/DartsCompanion.Infrastructure/DartsCompanion.Infrastructure.csproj | Infrastructure layer project | Create |
| src/DartsCompanion.Infrastructure/DependencyInjection.cs | Infrastructure-layer DI (DbContext, Identity, repositories) | Create |
| tests/DartsCompanion.UnitTests/DartsCompanion.UnitTests.csproj | Unit tests project | Create |
| tests/DartsCompanion.IntegrationTests/DartsCompanion.IntegrationTests.csproj | Integration tests project | Create |

## Definition of Done

- [ ] Solution compiles without errors
- [ ] Layer references are correct (Api→Application only, Application→Domain only, Infrastructure→Application+Domain, Domain has no dependencies)
- [ ] Project structure matches directory layout
- [ ] All projects target .NET 10.0
- [ ] No circular dependencies between layers
- [ ] `Program.cs` uses DI extension methods pattern (see below) — feature agents will never modify this file
- [ ] Each layer has a `DependencyInjection.cs` with its `Add{Layer}Services()` extension method

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

6. **Critical — DI Extension Methods Pattern for Parallel Development:**

   `Program.cs` must be structured so that **no feature agent ever needs to modify it**. All DI registrations happen via extension methods in each layer's `DependencyInjection.cs`.

   ```csharp
   // Program.cs — created once, never modified by feature agents
   var builder = WebApplication.CreateBuilder(args);

   builder.Services
       .AddApiServices()
       .AddApplicationServices()
       .AddInfrastructureServices(builder.Configuration);

   var app = builder.Build();

   // Middleware pipeline
   app.UseHttpsRedirection();
   app.UseAuthentication();
   app.UseAuthorization();
   app.MapControllers();

   app.Run();
   ```

   ```csharp
   // DartsCompanion.Application/DependencyInjection.cs
   public static class DependencyInjection
   {
       public static IServiceCollection AddApplicationServices(this IServiceCollection services)
       {
           services.AddMediatR(cfg =>
               cfg.RegisterServicesFromAssembly(typeof(DependencyInjection).Assembly));
           services.AddValidatorsFromAssembly(typeof(DependencyInjection).Assembly);
           services.AddTransient(typeof(IPipelineBehavior<,>), typeof(ValidationBehaviour<,>));
           return services;
       }
   }
   ```

   MediatR and FluentValidation both use assembly scanning, so feature agents just create their handler/validator classes in the correct namespace and they are discovered automatically.

## References

- [Architecture](../../../shared/architecture.md)
- [Parallel Development Guide](../../../shared/parallel-development-guide.md)
