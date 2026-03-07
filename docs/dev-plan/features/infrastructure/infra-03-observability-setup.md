# INFRA-03 — Observability Setup

**Feature:** Infrastructure
**Phase:** MVP
**Status:** 🔲 Not started
**Agent:** —
**Output:** —
**Notes:** —

---

## Context

Configures OpenTelemetry for all three signals (traces, metrics, logs), wires Seq (OTLP HTTP) and Prometheus exporter. No PII in telemetry; metrics and traces flow to observability services for monitoring and debugging.

> Implements: TA §9

---

## Acceptance Criteria

- [ ] All inbound HTTP requests traced via OpenTelemetry.Instrumentation.AspNetCore
- [ ] All EF Core queries traced with query text (redacted of sensitive data)
- [ ] Logs and traces exported to Seq via OTLP HTTP (port 4318)
- [ ] Prometheus /metrics endpoint active and scraped by prometheus container
- [ ] No PII (email, display names) in trace attributes or log messages
- [ ] Custom ActivitySource("DartsCompanion.Application") used in ValidationBehaviour for per-command spans
- [ ] Seq UI accessible at http://seq:80 in local stack; Grafana at configured port
- [ ] All OTel exporters healthy and no dropped signals under normal load

---

## Technical Implementation Notes

**OpenTelemetry Instrumentation:**
- NuGet packages: OpenTelemetry.Extensions.Hosting, OpenTelemetry.Instrumentation.AspNetCore, OpenTelemetry.Instrumentation.Http, OpenTelemetry.Instrumentation.EntityFrameworkCore, OpenTelemetry.Exporter.OpenTelemetryProtocol, OpenTelemetry.Exporter.Prometheus.AspNetCore
- OTel configuration is centralised in `Program.cs` (Api project) per TA §9 code block; no separate ServiceDefaults project
- All three signals (traces, metrics, logs) configured in one place

**Trace Instrumentation:**
- AspNetCore instrumentation: inbound HTTP requests tagged with method, path, status code
- EF Core instrumentation: query text (redacted), parameters, duration
- Custom ActivitySource in Application layer: `new ActivitySource("DartsCompanion.Application")`
- ValidationBehaviour creates child spans for each command validation step

**Metric Instrumentation:**
- Standard .NET metrics: HTTP request duration, exception count, GC stats
- Custom counters in application code for domain events (e.g., session completed, stats updated)
- Prometheus exporter at /metrics endpoint on port 9090 or 5000 (per Docker port mapping)

**Log Exporting:**
- ILogger integration via OpenTelemetry logging exporter
- Seq receives logs via OTLP HTTP at http://seq:4318 (from container network)
- Log level: Information by default; Debug only in development profile

**Configuration:**
- SEQ_OTLP_ENDPOINT env var: http://seq:4318 (container DNS name)
- OTEL_EXPORTER_OTLP_PROTOCOL: http/protobuf
- PROMETHEUS_ENDPOINT: http://localhost:9090 (local scrape config)

**Security & Privacy:**
- No email addresses, phone numbers, or display names in attribute values
- Query parameters redacted in EF Core spans
- Sampling rate configured to reduce volume in production (e.g., 10% of traces)

---

## Dependencies

- INFRA-01 — Solution Scaffold & Project Setup — OpenTelemetry packages must be added to projects during scaffolding

---

## Shared References

- [Architecture](../../shared/architecture.md) — §9 (observability design, code blocks for setup)
- [Non-Functional Requirements](../../shared/non-functional-requirements.md) — observability and monitoring requirements
