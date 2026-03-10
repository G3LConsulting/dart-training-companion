# INFRA-04 — Observability Setup

| Metadata | Value |
|----------|-------|
| Feature | Infrastructure |
| Phase | MVP |
| Status | 🔲 Not started |
| Agent | Backend Lead |
| Output | OpenTelemetry configuration in API, Grafana dashboard, Prometheus scraping |
| Notes | Enables traces, metrics, and structured logging for production monitoring |

## Context

Configure OpenTelemetry in the API for traces, metrics, and logs. Wire up Seq (OTLP) and Prometheus exporter. This creates complete visibility into system behavior and performance.

**Implements:** TA §9 (Observability)

## Acceptance Criteria

- [ ] API emits traces to Seq via OTLP without errors
- [ ] API exposes /metrics endpoint for Prometheus scraping
- [ ] Structured logs appear in Seq with request context (correlation IDs)
- [ ] Custom ActivitySources registered for DartsCompanion.Application and DartsCompanion.Infrastructure
- [ ] Metrics include: request rate, request duration, error rate, database query duration
- [ ] Traces include: HTTP requests, database queries, application custom activities
- [ ] No PII in trace attributes or log fields
- [ ] Grafana dashboard displays API metrics after docker compose up

## Tasks

| Task ID | Title | Status | Layer |
|---------|-------|--------|-------|
| [INFRA-04-T01](infra-04-observability-setup/infra-04-t01-opentelemetry-config.md) | OpenTelemetry configuration in Program.cs | 🔲 | API |
| [INFRA-04-T02](infra-04-observability-setup/infra-04-t02-grafana-dashboard.md) | Grafana dashboard provisioning | 🔲 | Infra |

## Dependencies

- [INFRA-01](infra-01-solution-scaffolding.md) — API project must exist
- [INFRA-02](infra-02-docker-compose-local-dev.md) — Docker stack with Seq and Prometheus must be running

## Shared References

- [Architecture](../../shared/architecture.md)
- [Technical Approach §9](../../shared/technical-approach.md#section-9-observability)
- [Non-Functional Requirements](../../shared/non-functional-requirements.md)
