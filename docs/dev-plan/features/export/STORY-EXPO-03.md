# STORY: EXPO-03 — JSON Export

**Feature:** Data Export
**Phase:** MVP
**Status:** Pending
**Agent:** Backend Team
**Output:** JSON export writer, structured data export, future re-import compatibility
**Notes:** Enables GDPR data export and data portability. Mirrors internal data model.

---

## Context

### Implements
- **FA §FR-D-06d** — JSON export format

### Acceptance Criteria

- [ ] Structured .json file with full data graph
- [ ] Includes: profile metadata (excluding password/email), all sessions with turns/darts, all Number Focus sets, Personal Best records
- [ ] JSON structure mirrors internal data model for future re-import capability
- [ ] Pretty-printed for human readability
- [ ] File naming: `darts-companion_{scope}_{YYYY-MM-DD}.json`
- [ ] Scope filtering applied: All, GameMode, DateRange, CurrentView
- [ ] No sensitive fields (passwords, auth tokens, email) included

---

## Tasks

| Task ID | Title | File Changes | Assigned | Status |
|---------|-------|-------------|----------|--------|
| [EXPO-03-T01](./expo-03-json-export/TASK-EXPO-03-T01.md) | API: JSON export writer | `Infrastructure/Export/JsonExportWriter.cs` | Backend | Pending |
| [EXPO-03-T02](./expo-03-json-export/TASK-EXPO-03-T02.md) | Integrate JSON writer into ExportJobService | `Infrastructure/BackgroundServices/ExportJobService.cs` | Backend | Pending |
| [EXPO-03-T03](./expo-03-json-export/TASK-EXPO-03-T03.md) | Tests: JSON export tests | `UnitTests/Export/JsonExportWriterTests.cs` | QA/Backend | Pending |

---

## Dependencies

- **EXPO-01** — Export infrastructure, job processing, data provider
- **Shared References:** Domain Model (all entities), NFRs (GDPR data export)

---

## Shared References

See [`../../shared/domain-model.md`](../../shared/domain-model.md) for entity structure.
See [`../../shared/nfrs.md`](../../shared/nfrs.md) for GDPR data export requirements.
