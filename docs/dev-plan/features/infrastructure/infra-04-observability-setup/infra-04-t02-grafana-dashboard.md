# INFRA-04-T02 — Grafana Dashboard Provisioning

| Metadata | Value |
|----------|-------|
| Story | [INFRA-04](../infra-04-observability-setup.md) — Observability Setup |
| Layer | Infra |
| Status | 🔲 Not started |
| Agent | DevOps Lead |

## What to Build

Create a basic Grafana dashboard JSON for API request metrics including rate, duration, error rate, and database performance. Provision the dashboard and Prometheus datasource via Grafana provisioning files.

## Files to Create or Modify

| File Path | Purpose | Type |
|-----------|---------|------|
| docker/grafana/dashboards/api-metrics.json | Grafana dashboard definition | Create |
| docker/grafana/provisioning/dashboards.yml | Dashboard provisioning config | Create |
| docker/grafana/provisioning/datasources.yml | Datasource provisioning config | Create |

## Definition of Done

- [ ] api-metrics.json is valid JSON
- [ ] dashboards.yml and datasources.yml are valid YAML
- [ ] After docker compose up, Grafana is accessible at localhost:3000
- [ ] Default datasource (Prometheus) is automatically configured
- [ ] API Metrics dashboard is visible in Grafana UI
- [ ] Dashboard displays: request rate, request duration, error rate
- [ ] Dashboard displays: database query duration, connection pool status
- [ ] Charts auto-refresh every 10 seconds
- [ ] Time range selector functional (last hour, last day, etc.)
- [ ] All panel queries use proper PromQL syntax
- [ ] No errors in Grafana logs

## Implementation Notes

1. **Grafana Provisioning Files Location**:
   - Place in docker/grafana/provisioning/
   - Mount in docker-compose.yml at /etc/grafana/provisioning
   - Grafana automatically loads configurations on startup

2. **datasources.yml Structure**:
   ```yaml
   apiVersion: 1
   providers:
     - name: 'Prometheus'
       orgId: 1
       folder: ''
       type: file
       disableDeletion: false
       options:
         path: /etc/grafana/provisioning/datasources

   datasources:
     - name: Prometheus
       type: prometheus
       access: proxy
       orgId: 1
       url: http://prometheus:9090
       isDefault: true
       editable: true
   ```

3. **dashboards.yml Structure**:
   ```yaml
   apiVersion: 1
   providers:
     - name: 'DartsCompanion'
       orgId: 1
       folder: ''
       type: file
       disableDeletion: false
       editable: true
       options:
         path: /etc/grafana/provisioning/dashboards
   ```

4. **api-metrics.json Dashboard Structure**:
   - Dashboard metadata: title, description, refresh interval
   - Datasource references to Prometheus
   - Panel definitions with PromQL queries
   - Layout and sizing

5. **Core Panels to Include**:

   a) **Request Rate** (HTTP requests per second):
   - PromQL: `rate(http_server_request_duration_seconds_count{service_name="dartscompanion-api"}[1m])`
   - Graph type: Time series
   - Y-axis: Requests/sec

   b) **Request Duration** (P50, P95, P99):
   - PromQL: `histogram_quantile(0.50, rate(http_server_request_duration_seconds_bucket[5m]))`
   - Multiple series for different quantiles
   - Graph type: Time series
   - Y-axis: Duration (milliseconds)

   c) **Request Count by Status Code**:
   - PromQL: `sum by (http_status_code) (rate(http_server_request_duration_seconds_count[5m]))`
   - Graph type: Bar chart or stacked area

   d) **Error Rate**:
   - PromQL: `sum(rate(http_server_request_duration_seconds_count{http_status_code=~"5.."}[5m])) / sum(rate(http_server_request_duration_seconds_count[5m]))`
   - Display as percentage
   - Color alert if > 1%

   e) **Database Query Duration**:
   - PromQL: `histogram_quantile(0.95, rate(db_client_operation_duration_seconds_bucket[5m]))`
   - Show P95 database query time

   f) **Active Database Connections**:
   - PromQL: `db_client_connections_usage`
   - Current value / maximum connections
   - Gauge type

   g) **Memory Usage**:
   - PromQL: `process_resident_memory_bytes`
   - Time series display

   h) **CPU Usage**:
   - PromQL: `rate(process_cpu_seconds_total[5m])`
   - Percentage of CPU cores

6. **Panel Configuration Template**:
   ```json
   {
     "title": "Request Rate",
     "type": "timeseries",
     "targets": [
       {
         "expr": "rate(http_server_request_duration_seconds_count[1m])",
         "refId": "A",
         "legendFormat": "Requests/sec"
       }
     ],
     "fieldConfig": {
       "defaults": {
         "custom": {
           "hideFrom": {
             "tooltip": false,
             "viz": false,
             "legend": false
           }
         },
         "unit": "reqps"
       }
     },
     "options": {
       "legend": {
         "calcs": [],
         "displayMode": "list",
         "placement": "bottom"
       }
     }
   }
   ```

7. **Dashboard Layout**:
   - Row 1: Request metrics (rate, duration, errors)
   - Row 2: Database metrics (query duration, connections)
   - Row 3: System metrics (memory, CPU)
   - Each panel: 6-12 grid width, 8-10 grid height

8. **Refresh Settings**:
   - Auto-refresh: 10s
   - Time range: Last 1 hour (user-adjustable)
   - Timezone: Browser local time

9. **Legend and Tooltips**:
   - Show legends on all time series panels
   - Tooltip mode: Multi-series
   - Display values in legend

10. **Alert Thresholds** (optional):
    - Error rate > 1%: Yellow threshold at 0.5%, Red at 1%
    - P95 latency > 1000ms: Warning threshold
    - Database connection pool > 80% utilized: Warning

11. **Docker Compose Integration**:
    - Grafana container mounts provisioning directory:
      ```yaml
      grafana:
        volumes:
          - ./docker/grafana/provisioning:/etc/grafana/provisioning
          - grafana_storage:/var/lib/grafana
      ```

12. **Verification Steps**:
    - `docker compose up -d grafana prometheus`
    - Navigate to http://localhost:3000
    - Login (default: admin / admin)
    - Check "Dashboards" → "DartsCompanion" → "API Metrics"
    - Verify data is being scraped from Prometheus

## References

- [Architecture](../../../shared/architecture.md)
- [Technical Approach §9](../../../shared/technical-approach.md#section-9-observability)
