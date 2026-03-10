# INFRA-04-T01 — OpenTelemetry Configuration in Program.cs

| Metadata | Value |
|----------|-------|
| Story | [INFRA-04](../infra-04-observability-setup.md) — Observability Setup |
| Layer | API |
| Status | 🔲 Not started |
| Agent | Backend Lead |

## What to Build

Add OpenTelemetry NuGet packages and configure tracing (AspNetCore, Http, EFCore, custom sources), metrics (AspNetCore, custom meter, Prometheus), and logging (OTLP to Seq) in Program.cs. This creates comprehensive observability for API requests, database queries, and application events.

## Files to Create or Modify

| File Path | Purpose | Type |
|-----------|---------|------|
| src/DartsCompanion.Api/DartsCompanion.Api.csproj | Add OTel NuGet packages | Modify |
| src/DartsCompanion.Api/Program.cs | Configure OTel providers in dependency injection | Modify |
| src/DartsCompanion.Infrastructure/ServiceCollectionExtensions.cs | Extract observability setup to extension method (optional) | Create |

## Definition of Done

- [ ] All required NuGet packages added to csproj (OpenTelemetry, AspNetCore, Http, EntityFrameworkCore, Prometheus, Seq exporters)
- [ ] API starts without errors with OTel configuration
- [ ] Traces appear in Seq UI with request details (method, path, status, duration)
- [ ] /metrics endpoint returns valid Prometheus-format metrics
- [ ] Custom ActivitySource created for DartsCompanion.Application
- [ ] Custom ActivitySource created for DartsCompanion.Infrastructure
- [ ] Database query spans appear in traces
- [ ] HTTP client request spans appear in traces
- [ ] Structured logs include correlation IDs for request tracing
- [ ] No exceptions or warnings in application startup
- [ ] Prometheus successfully scrapes /metrics endpoint
- [ ] PII validation: no user IDs, emails, or sensitive data in trace attributes

## Implementation Notes

1. **NuGet Packages to Add**:
   ```
   OpenTelemetry
   OpenTelemetry.Exporter.Prometheus
   OpenTelemetry.Exporter.OpenTelemetryProtocol
   OpenTelemetry.Instrumentation.AspNetCore
   OpenTelemetry.Instrumentation.Http
   OpenTelemetry.Instrumentation.EntityFrameworkCore
   OpenTelemetry.Extensions.Hosting
   ```

2. **Program.cs Setup** (order matters):
   - Define resource with service name, version
   - Configure TracerProviderBuilder with AspNetCore, Http, EFCore, custom sources
   - Configure MeterProviderBuilder with AspNetCore, custom meters, Prometheus exporter
   - Configure LoggerProvider with OTLP exporter to Seq
   - Register ActivitySource for application use

3. **Tracing Configuration**:
   ```csharp
   var builder = WebApplication.CreateBuilder(args);

   // Define resource (service identity)
   var resource = ResourceBuilder.CreateDefault()
       .AddService("dartscompanion-api", version: "1.0.0");

   // Configure tracer provider
   builder.Services.AddOpenTelemetry()
       .ConfigureResource(r => r.AddAttributes(new Dictionary<string, object>
       {
           { "service.name", "DartsCompanion.Api" },
           { "service.version", "1.0.0" }
       }))
       .WithTracing(tracingBuilder => tracingBuilder
           .AddResource(resource)
           .AddAspNetCoreInstrumentation()
           .AddHttpClientInstrumentation()
           .AddEntityFrameworkCoreInstrumentation()
           .AddSource("DartsCompanion.Application")
           .AddSource("DartsCompanion.Infrastructure")
           .AddOtlpExporter(options =>
           {
               options.Endpoint = new Uri(builder.Configuration["OTLP:Endpoint"] ?? "http://seq:5341");
           }));
   ```

4. **Metrics Configuration**:
   ```csharp
   .WithMetrics(metricsBuilder => metricsBuilder
       .AddResource(resource)
       .AddAspNetCoreInstrumentation()
       .AddMeter("DartsCompanion.Application")
       .AddMeter("DartsCompanion.Infrastructure")
       .AddPrometheusExporter(options =>
       {
           options.Port = 9090;
           options.Path = "/metrics";
       }));
   ```

5. **Logging Configuration**:
   ```csharp
   builder.Logging.ClearProviders();
   builder.Logging.AddOpenTelemetry(options =>
   {
       options.SetResourceBuilder(resource);
       options.AddOtlpExporter(exporterOptions =>
       {
           exporterOptions.Endpoint = new Uri(builder.Configuration["OTLP:Endpoint"] ?? "http://seq:5341");
       });
   });
   ```

6. **Custom ActivitySource Creation**:
   - In Application and Infrastructure layers, create static ActivitySource:
     ```csharp
     public static class ObservabilityConstants
     {
         public static readonly ActivitySource ApplicationActivitySource =
             new ActivitySource("DartsCompanion.Application");
         public static readonly ActivitySource InfrastructureActivitySource =
             new ActivitySource("DartsCompanion.Infrastructure");
     }
     ```

7. **Custom Meter for Metrics**:
   ```csharp
   public static class MetricsConstants
   {
       public static readonly Meter ApplicationMeter =
           new Meter("DartsCompanion.Application", "1.0.0");
   }

   // In services:
   var counter = MetricsConstants.ApplicationMeter.CreateCounter<long>("games.completed");
   counter.Add(1);
   ```

8. **Environment Variables / Configuration**:
   - OTLP:Endpoint: http://seq:5341 (default, Seq endpoint)
   - PROMETHEUS_PORT: 9090 (default, Prometheus scrape port)
   - OTEL_SDK_DISABLED: false (enable OpenTelemetry)
   - Set in docker-compose or appsettings.json

9. **Prometheus Endpoint**:
   - Automatically exposed at /metrics by .AddPrometheusExporter()
   - Port: 9090 (or configured port)
   - Prometheus scrapes at: http://api:9090/metrics (or localhost:9090/metrics in dev)

10. **Seq Integration**:
    - OTLP exporter sends traces and logs to Seq
    - Seq UI at localhost:5341 (in docker compose)
    - View traces, logs, and request correlation in Seq dashboard

11. **PII Prevention**:
    - Avoid logging/tracing user IDs, emails, phone numbers
    - Use correlation IDs instead (UUID, not user ID)
    - Redact sensitive fields in middleware or instrumentation
    - Example: CustomActivitySource can filter attributes before export

12. **Health Check**:
    - Add healthcheck endpoint: GET /health
    - Returns 200 OK when services are ready
    - Can be used in docker-compose for startup detection

## References

- [Architecture](../../../shared/architecture.md)
- [Technical Approach §9](../../../shared/technical-approach.md#section-9-observability)
- [Non-Functional Requirements](../../../shared/non-functional-requirements.md)
