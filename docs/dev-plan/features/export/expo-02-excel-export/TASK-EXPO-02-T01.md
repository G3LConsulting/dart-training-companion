# TASK: EXPO-02-T01 — API: ExcelExportWriter (DocumentFormat.OpenXml)

**Story:** [EXPO-02](../STORY-EXPO-02.md)
**Layer:** Backend
**Status:** Pending
**Agent:** Backend Team

---

## What to Build

Implement ExcelExportWriter to generate .xlsx workbooks with multi-sheet layout:

**Structure:**
- Summary sheet (first sheet): overview of all data with KPIs per game mode
  - Rows: Game Mode, Total Sessions, Avg Score, Checkout %, Best Leg, Last Session Date
- Detail sheets: one sheet per game mode found in data
  - Each sheet: header row (bold, frozen), data rows, summary row
  - Columns: Session ID, Date, Target, Multiplier, Score, Round, Leg, Checkout, Notes
  - Column widths auto-fitted to content

**Features:**
- Uses DocumentFormat.OpenXml library for .xlsx generation
- Frozen panes: header row frozen for scrolling
- Styling: bold header, number formatting for columns
- Summary row: aggregates (SUM, AVERAGE, COUNT) using Excel formulas
- File naming: `darts-companion_{scope}_{YYYY-MM-DD}.xlsx`

---

## Files

| File Path | Type | Purpose |
|-----------|------|---------|
| `src/Application/Common/Interfaces/IExcelExportWriter.cs` | Interface | Abstract Excel export |
| `src/Infrastructure/Export/ExcelExportWriter.cs` | Implementation | Excel generation logic |

---

## Definition of Done

- [ ] ExcelExportWriter implements IExportWriter
- [ ] WriteAsync method accepts ExportJob, queries data, generates .xlsx
- [ ] Summary sheet created with KPI rows per game mode
- [ ] Detail sheets created: one per game mode
- [ ] Header row: bold font, frozen pane (frozen first row)
- [ ] Data rows: correct columns, number formatting for score/multiplier
- [ ] Summary row: formulas for SUM (total score), AVERAGE (avg score), COUNT (total darts)
- [ ] Column widths auto-fitted to content (not hardcoded)
- [ ] File saved to blob storage with correct naming convention
- [ ] Generated .xlsx opens in Excel, Google Sheets, LibreOffice without errors
- [ ] Scope filtering applied: All, GameMode, DateRange, CurrentView
- [ ] Large datasets handled efficiently (streaming writer if available)
- [ ] Unit tests verify sheet structure, formulas, styling
- [ ] Integration tests verify end-to-end .xlsx generation

---

## Implementation Notes

**ExcelExportWriter:**
```csharp
using DocumentFormat.OpenXml;
using DocumentFormat.OpenXml.Packaging;
using DocumentFormat.OpenXml.Spreadsheet;

public class ExcelExportWriter : IExportWriter
{
    private readonly IApplicationDbContext _dbContext;
    private readonly IBlobStorageService _blobStorage;
    private readonly IExportDataProvider _dataProvider;

    public async Task<string> WriteAsync(ExportJob job, CancellationToken cancellationToken)
    {
        var data = await _dataProvider.GetExportDataAsync(job, cancellationToken);
        var fileName = GenerateFileName(job);
        var filePath = await WriteToStorageAsync(fileName, data, cancellationToken);
        return filePath;
    }

    private async Task<string> WriteToStorageAsync(string fileName, ExportData data, CancellationToken cancellationToken)
    {
        using (var memoryStream = new MemoryStream())
        {
            using (var spreadsheet = SpreadsheetDocument.Create(memoryStream, SpreadsheetDocumentType.Workbook))
            {
                var workbookPart = spreadsheet.AddWorkbookPart();
                var workbook = new Workbook();

                // Create summary sheet
                var summarySheetPart = workbookPart.AddNewPart<WorksheetPart>();
                var summarySheet = new Worksheet();
                summarySheetPart.Worksheet = summarySheet;

                // Create detail sheets per game mode
                var gameModes = data.Darts.GroupBy(d => d.GameMode).ToList();
                var sheetData = new SheetData();

                // Add summary rows
                var summaryRows = CreateSummaryRows(data, gameModes);
                foreach (var row in summaryRows)
                    sheetData.Append(row);

                summarySheet.Append(sheetData);

                // Create worksheets for each game mode
                var sheets = new Sheets();
                sheets.Append(new Sheet { Name = "Summary", SheetId = 1, Id = workbookPart.GetIdOfPart(summarySheetPart) });

                uint sheetId = 2;
                foreach (var mode in gameModes)
                {
                    var detailSheetPart = workbookPart.AddNewPart<WorksheetPart>();
                    var detailSheet = new Worksheet();
                    var detailSheetData = new SheetData();

                    // Add headers
                    var headerRow = CreateHeaderRow();
                    detailSheetData.Append(headerRow);

                    // Add data rows
                    uint rowIndex = 2;
                    foreach (var dart in mode.OrderBy(d => d.Date))
                    {
                        var row = CreateDataRow(dart, rowIndex);
                        detailSheetData.Append(row);
                        rowIndex++;
                    }

                    // Add summary row
                    var summaryRow = CreateAggregateRow(mode, rowIndex);
                    detailSheetData.Append(summaryRow);

                    detailSheet.Append(detailSheetData);

                    // Freeze panes (freeze header row)
                    var sheetViews = new SheetViews();
                    var sheetView = new SheetView { TabSelected = true, WorkbookViewId = 0u };
                    var pane = new Pane { VerticalSplit = 1u, TopLeftCell = "A2", ActivePane = PaneValues.BottomLeft };
                    sheetView.Append(pane);
                    sheetViews.Append(sheetView);
                    detailSheet.Insert(0, sheetViews);

                    detailSheetPart.Worksheet = detailSheet;
                    sheets.Append(new Sheet { Name = mode.Key, SheetId = sheetId, Id = workbookPart.GetIdOfPart(detailSheetPart) });
                    sheetId++;
                }

                workbook.Append(sheets);
                workbookPart.Workbook = workbook;
                spreadsheet.Close();
            }

            memoryStream.Position = 0;
            return await _blobStorage.UploadFileAsync(fileName, memoryStream, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", cancellationToken);
        }
    }

    private Row CreateHeaderRow()
    {
        var row = new Row { RowIndex = 1 };
        var headers = new[] { "Session ID", "Date", "Target", "Multiplier", "Score", "Round", "Leg", "Checkout", "Notes" };

        uint cellIndex = 1;
        foreach (var header in headers)
        {
            var cell = new Cell
            {
                CellReference = GetCellReference(cellIndex, 1),
                CellValue = new CellValue(header),
                DataType = CellValues.String,
                StyleIndex = 1u // Bold style
            };
            row.Append(cell);
            cellIndex++;
        }

        return row;
    }

    private Row CreateDataRow(DartExportRow dart, uint rowIndex)
    {
        var row = new Row { RowIndex = rowIndex };
        var values = new object[]
        {
            dart.SessionId.ToString(),
            dart.Date.ToString("yyyy-MM-dd HH:mm:ss"),
            dart.Target.ToString(),
            dart.Multiplier.ToString(),
            dart.Score.ToString(),
            dart.Round.ToString(),
            dart.Leg.ToString(),
            dart.IsCheckout ? "Yes" : "No",
            dart.Notes ?? ""
        };

        uint cellIndex = 1;
        foreach (var value in values)
        {
            var cellValue = value?.ToString() ?? "";
            var cell = new Cell
            {
                CellReference = GetCellReference(cellIndex, rowIndex),
                CellValue = new CellValue(cellValue),
                DataType = CellValues.String
            };
            row.Append(cell);
            cellIndex++;
        }

        return row;
    }

    private Row CreateAggregateRow(IGrouping<string, DartExportRow> groupData, uint rowIndex)
    {
        var row = new Row { RowIndex = rowIndex };

        // Add label
        var labelCell = new Cell
        {
            CellReference = GetCellReference(1, rowIndex),
            CellValue = new CellValue("TOTAL"),
            DataType = CellValues.String,
            StyleIndex = 1u // Bold
        };
        row.Append(labelCell);

        // Empty cells for columns 2-4
        for (uint i = 2; i <= 4; i++)
            row.Append(new Cell { CellReference = GetCellReference(i, rowIndex) });

        // Sum formula for Score (column 5)
        var sumCell = new Cell
        {
            CellReference = GetCellReference(5, rowIndex),
            CellValue = new CellValue($"=SUM(E2:E{rowIndex - 1})")
        };
        row.Append(sumCell);

        return row;
    }

    private List<Row> CreateSummaryRows(ExportData data, List<IGrouping<string, DartExportRow>> gameModes)
    {
        var rows = new List<Row>();
        rows.Add(new Row { RowIndex = 1 });

        uint rowIndex = 2;
        foreach (var mode in gameModes)
        {
            var row = new Row { RowIndex = rowIndex };
            row.Append(new Cell { CellReference = $"A{rowIndex}", CellValue = new CellValue(mode.Key), DataType = CellValues.String });
            row.Append(new Cell { CellReference = $"B{rowIndex}", CellValue = new CellValue(mode.Count().ToString()), DataType = CellValues.Number });
            row.Append(new Cell { CellReference = $"C{rowIndex}", CellValue = new CellValue(mode.Average(d => d.Score).ToString("F2")), DataType = CellValues.Number });
            rows.Add(row);
            rowIndex++;
        }

        return rows;
    }

    private string GenerateFileName(ExportJob job)
    {
        var dateStr = DateTime.UtcNow.ToString("yyyy-MM-dd");
        var scopeStr = job.Scope switch
        {
            ExportScope.All => "all-data",
            ExportScope.GameMode => $"mode-{job.GameModeFilter}",
            ExportScope.DateRange => $"range-{job.StartDate:yyyy-MM-dd}-{job.EndDate:yyyy-MM-dd}",
            ExportScope.CurrentView => "current-view",
            _ => "export"
        };
        return $"darts-companion_{scopeStr}_{dateStr}.xlsx";
    }

    private string GetCellReference(uint column, uint row)
    {
        var columnLetter = GetColumnLetter(column);
        return $"{columnLetter}{row}";
    }

    private string GetColumnLetter(uint column)
    {
        var result = "";
        while (column > 0)
        {
            result = (char)('A' + (column - 1) % 26) + result;
            column = (column - 1) / 26;
        }
        return result;
    }
}
```

**Package.json (NuGet):**
- Add: `DocumentFormat.OpenXml` (latest stable version)

---

## References

- [`../../shared/architecture.md`](../../shared/architecture.md) — ADR arch-008, export pattern
- DocumentFormat.OpenXml: https://github.com/OfficeDev/Open-XML-SDK
- ECMA-376 (Office Open XML): https://www.ecma-international.org/publications/standards/Ecma-376.html
