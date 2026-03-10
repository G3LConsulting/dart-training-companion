# STORY: EXPO-02 — Excel Export

**Feature:** Data Export
**Phase:** MVP
**Status:** Pending
**Agent:** Backend Team
**Output:** Excel export writer, multi-sheet workbooks, summary sheet, auto-fitted columns
**Notes:** Extends export functionality to Excel format using DocumentFormat.OpenXml.

---

## Context

### Implements
- **FA §FR-D-06c** — Excel export format
- **TA ADR arch-008** — DocumentFormat.OpenXml library architecture decision

### Acceptance Criteria

- [ ] .xlsx workbook with one sheet per game mode in selected data
- [ ] Each sheet has bold frozen header row, data rows, auto-sized summary row with aggregates
- [ ] Summary sheet appears as first sheet showing top-level KPIs per mode (total sessions, avg score, etc.)
- [ ] Column widths auto-fitted to content
- [ ] File naming: `darts-companion_{scope}_{YYYY-MM-DD}.xlsx`
- [ ] Files are valid and open in Excel, Google Sheets, LibreOffice

---

## Tasks

| Task ID | Title | File Changes | Assigned | Status |
|---------|-------|-------------|----------|--------|
| [EXPO-02-T01](./expo-02-excel-export/TASK-EXPO-02-T01.md) | API: ExcelExportWriter (DocumentFormat.OpenXml) | `Infrastructure/Export/ExcelExportWriter.cs`, `IExcelExportWriter.cs` | Backend | Pending |
| [EXPO-02-T02](./expo-02-excel-export/TASK-EXPO-02-T02.md) | Integrate Excel writer into ExportJobService | `Infrastructure/BackgroundServices/ExportJobService.cs` | Backend | Pending |
| [EXPO-02-T03](./expo-02-excel-export/TASK-EXPO-02-T03.md) | Tests: Excel export tests | `UnitTests/Export/ExcelExportWriterTests.cs` | QA/Backend | Pending |

---

## Dependencies

- **EXPO-01** — Export infrastructure, job processing, data provider
- **Shared References:** Architecture (ADR arch-008), Domain Model (ExportFormat)

---

## Shared References

See [`../../shared/architecture.md`](../../shared/architecture.md) for ADR arch-008 (DocumentFormat.OpenXml library choice).
See [`../../shared/domain-model.md`](../../shared/domain-model.md) for ExportFormat enum and related entities.
