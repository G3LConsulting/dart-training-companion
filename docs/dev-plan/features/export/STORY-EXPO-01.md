# STORY: EXPO-01 — Export Infrastructure & CSV Export

**Feature:** Data Export
**Phase:** MVP
**Status:** Pending
**Agent:** Full Stack Team
**Output:** Export API endpoints, background job processing, CSV export writer, frontend UI
**Notes:** Foundation for all export formats. Implements async export job processing and CSV output.

---

## Context

### Implements
- **FA §FR-D-06, FR-D-06a, FR-D-06b, FR-D-06e** — Export functionality and CSV format
- **TA §6** — RequestExportCommand, ExportJobService background processing

### Acceptance Criteria

- [ ] Export triggered from Profile & Settings page or stats views
- [ ] User selects export scope: All Data, Game Mode Filter, Date Range, Current View
- [ ] CSV format: flat file, one row per turn/dart, human-readable headers, UTF-8 with BOM
- [ ] File naming convention: `darts-companion_{scope}_{YYYY-MM-DD}.csv`
- [ ] Large exports (>10,000 rows) generated asynchronously; user sees download prompt when ready
- [ ] Export requires internet connection; buttons disabled offline with tooltip
- [ ] Export completes within 5 seconds for up to 1,000 sessions
- [ ] User can trigger export and receive download link via email (optional, phase 2)

---

## Tasks

| Task ID | Title | File Changes | Assigned | Status |
|---------|-------|-------------|----------|--------|
| [EXPO-01-T01](./expo-01-export-infrastructure-csv/TASK-EXPO-01-T01.md) | API: RequestExportCommand + ExportJobService BackgroundService | `Application/Export/Commands/`, `Infrastructure/BackgroundServices/`, `Api/Controllers/ExportController.cs` | Backend | Pending |
| [EXPO-01-T02](./expo-01-export-infrastructure-csv/TASK-EXPO-01-T02.md) | API: GetExportStatusQuery + DownloadExportQuery | `Application/Export/Queries/` | Backend | Pending |
| [EXPO-01-T03](./expo-01-export-infrastructure-csv/TASK-EXPO-01-T03.md) | API: CSV export writer | `Infrastructure/Export/CsvExportWriter.cs` | Backend | Pending |
| [EXPO-01-T04](./expo-01-export-infrastructure-csv/TASK-EXPO-01-T04.md) | Frontend: Export page with scope selector, format picker, download poller | `features/export/export.component.ts` | Frontend | Pending |
| [EXPO-01-T05](./expo-01-export-infrastructure-csv/TASK-EXPO-01-T05.md) | Tests: Export command and CSV writer tests | `UnitTests/Export/` | QA/Backend | Pending |

---

## Dependencies

- **AUTH-02** — User authentication and authorization in place
- **GAME-04** — Session data model and repository available
- **Shared References:** Domain Model (ExportJob, ExportStatus), API Contracts, Architecture (BackgroundService), NFRs (5-second export, offline restriction)

---

## Shared References

See [`../../shared/domain-model.md`](../../shared/domain-model.md) for ExportJob and ExportStatus entities.
See [`../../shared/api-contracts.md`](../../shared/api-contracts.md) for POST /api/export, GET /api/export/{jobId}, and download endpoints.
See [`../../shared/architecture.md`](../../shared/architecture.md) for BackgroundService and CQRS pattern.
See [`../../shared/nfrs.md`](../../shared/nfrs.md) for performance targets and offline constraints.
