# DESK-06 — Data Export

**Feature:** Desktop & Export
**Phase:** MVP
**Status:** 🔲 Not started
**Agent:** —
**Output:** —
**Notes:** —

---

## Context
User can export their data in CSV, Excel, or JSON format with scope options (all data, game mode filter, date range, current view). Export is server-side, async, requires active internet. Disabled offline.
> Implements: FA FR-D-06, FR-D-06a, FR-D-06b, FR-D-06c, FR-D-06d, FR-D-06e, TA §6 (RequestExportCommand, GetExportStatusQuery, DownloadExportQuery), TA §14 ADR arch-008 (ExcelExportWriter)

---

## Acceptance Criteria

**UI/UX:**
- [ ] Export button in stats dashboard/settings (disabled when offline with tooltip)
- [ ] Export dialog/modal on click:
  - [ ] Scope options: All data / Game mode filter / Date range filter / Current view
  - [ ] Format options: CSV / Excel (.xlsx) / JSON
  - [ ] Submit button: "Export"
  - [ ] Cancel button
- [ ] Progress indicator during export (polling status)
- [ ] Download triggered when status=Complete
- [ ] Error message if export fails (with retry option)

**Format-specific:**
- [ ] CSV: flat, one row per turn/dart; UTF-8 with BOM; async for >10,000 rows
- [ ] Excel (.xlsx): one sheet per game mode; header row (bold, frozen); auto-sized columns; summary sheet; aggregate row per sheet
- [ ] JSON: structured, includes profile + all sessions + PBs; excludes password/email; pretty-printed
- [ ] File naming: darts-companion_{scope}_{YYYY-MM-DD}.{ext}
- [ ] Export ≤5s for ≤1000 sessions; larger exports async with progress indicator (NFR)

**Performance:**
- [ ] Large exports (>10,000 rows) processed asynchronously
- [ ] Status polling every 2s until complete
- [ ] File size reasonable (<100MB for typical user data)

---

## Technical Implementation Notes

**Backend:**

*Entities & Services:*
- ExportJob: { exportJobId, userId, scope: enum (AllData, ByMode, ByDateRange, CurrentView), format: enum (CSV, Excel, JSON), status: enum (Pending, Processing, Complete, Failed), createdAt, completedAt?, filePath?, errorMessage?, scopeJson: string (serialised scope params) }
- ExportJobService (BackgroundService): processes queued ExportJobs; writes files to temp directory
- ExcelExportWriter: utility class for .xlsx generation (using EPPlus or ClosedXML)
- CsvExportWriter: utility class for CSV generation (using CsvHelper)
- JsonExportWriter: utility class for JSON serialization

*Commands:*
- RequestExportCommand: { scope, format } → POST /api/export
  - Handler: validates scope and format, creates ExportJob record, queues job, returns { jobId, estimatedTime }
  - Returns 202 Accepted + jobId
  - Validation: Format in [CSV, Excel, JSON], Scope in [AllData, ByMode, ByDateRange, CurrentView], DateFrom < DateTo (if ByDateRange)
  - Queue: add job to background service; service processes asynchronously

*Queries:*
- GetExportStatusQuery: { jobId } → GET /api/export/{jobId}
  - Returns { status: enum, progress?: int (0-100), errorMessage?: string }
  - Status values: Pending, Processing (+ progress %), Complete, Failed
- DownloadExportQuery: { jobId } → GET /api/export/{jobId}/download
  - Returns file blob with Content-Disposition: attachment; filename=...
  - Validates job status=Complete before download
  - Deletes file after download (or 24h expiry)

*Export Logic (ExportJobService):*
- Process ExportJob:
  1. Read ExportJob.ScopeJson to determine which sessions to include
  2. Deserialize scope params: ByMode → { mode: "501" }, ByDateRange → { from: "2025-01-01", to: "2025-03-07" }
  3. Query sessions filtered by scope
  4. Generate file based on format:
     - CSV: flatten turns/darts into rows; one row per turn (501/301) or per dart (NF); include game mode, date, metrics
     - Excel: multiple sheets (one per mode); header row frozen; auto-sized columns; summary sheet with aggregate stats
     - JSON: structured object { user: { displayName, ... }, sessions: [ { id, mode, score, turns: [...] } ], personalBests: [...] }
  5. Write file to temp path
  6. Update ExportJob.FilePath, Status=Complete, CompletedAt=Now
- Error handling: if exception, set Status=Failed, ErrorMessage=exception message

*Data Included:*
- CSV/Excel: Session data (date, mode, score, duration, turns/darts details)
- JSON: User profile (displayName, email?, stats), all sessions with full detail, personal bests, optional: badges (if LEAD-05 implemented)
- Excluded: passwords, authentication tokens, any PII beyond display name

*Performance:*
- Small exports (<1000 sessions): synchronous, return immediately
- Large exports: asynchronous, queued in background service, client polls status
- Progress estimation: for Excel, show "Generating sheets..." messages
- File size target: <100MB for typical user (5+ years of data)

**Angular:**

*Service & State:*
- ExportService: RequestExportCommand, GetExportStatusQuery, DownloadExportQuery
- ExportState: { jobId?, scope, format, status, progress, errorMessage, isExporting }
- Store: BehaviorSubject or NgRx for state management

*Component:*
- Standalone component: features/export/export-dialog/
- Route: /export or modal triggered from stats dashboard
- Dialog opened via button in STATS-01 or settings
- Offline detection: networkService.isOnline$ observable; disable export button if offline
- Form:
  - Scope radios: All Data / By Mode / By Date Range / Current View
  - Dynamic fields: mode dropdown (if By Mode), date pickers (if By Date Range)
  - Format radios: CSV / Excel / JSON
  - Submit: POST RequestExportCommand
- On submit:
  - Disable form, show "Exporting..." state
  - POST RequestExportCommand → get jobId
  - Start polling: GET /api/export/{jobId} every 2s
  - Update progress indicator (if available)
  - On status=Complete: call DownloadExportQuery; browser downloads file
  - On status=Failed: show error message + retry button
- Progress indicator: Material progress bar or simple spinner with "Processing..." text
- Download trigger: create anchor tag with href=blob URL, click programmatically
- Error handling: show error toast or modal with message + retry action

*Offline Handling:*
- Detect offline: networkService.isOnline$ = false
- Disable export button with tooltip: "Export requires internet connection"
- Show message if export attempted offline

*UI Integration:*
- Export button location: stats dashboard toolbar (DESK-02) or sidebar settings
- Button icon: download / share icon
- Keyboard support: dialog accessible via tab, form controls keyboard-navigable

---

## Dependencies
- Depends on PROF-01 (user context)
- Depends on GAME-04 (sessions exist to export)
- Depends on STATS-01 (stats dashboard context for export button)
- Requires ExcelExportWriter (ADR arch-008), ExportJob entity, ExportJobService

---

## Shared References
- [Domain Model](../../shared/domain-model.md) — ExportJob entity, Session/Turn/DartEntry/PersonalBest data structures
- [Architecture](../../shared/architecture.md) — Command/Query handler pattern (CQRS), background service pattern, ADR arch-008 (ExcelExportWriter)
- [API Contracts](../../shared/api-contracts.md) — POST /api/export, GET /api/export/{jobId}, GET /api/export/{jobId}/download, RequestExportDto, GetExportStatusDto schemas
- [NFRs](../../shared/non-functional-requirements.md) — §12.1 (responsive dialog), §13.1 (offline handling), export ≤5s for ≤1000 sessions, file <100MB, download progress in <2s
