# TASK: EXPO-02-T03 — Tests: Excel Export Tests

**Story:** [EXPO-02](../STORY-EXPO-02.md)
**Layer:** Backend
**Status:** Pending
**Agent:** QA/Backend Team

---

## What to Build

Comprehensive unit tests for ExcelExportWriter to verify sheet structure, styling, and formulas.

---

## Files

| File Path | Type | Purpose |
|-----------|------|---------|
| `src/UnitTests/Export/ExcelExportWriterTests.cs` | Unit Tests | Excel writer tests |

---

## Definition of Done

- [ ] Tests compile and pass
- [ ] Test: generated .xlsx is valid and readable
- [ ] Test: summary sheet exists as first sheet
- [ ] Test: detail sheet created per game mode
- [ ] Test: header row has bold formatting
- [ ] Test: header row frozen pane set
- [ ] Test: data rows populated correctly
- [ ] Test: summary row (aggregate) has SUM formula
- [ ] Test: file naming follows convention: `darts-companion_{scope}_{YYYY-MM-DD}.xlsx`
- [ ] Test: file opens in OpenXmlValidator without errors
- [ ] Test: scope filtering applied (All, GameMode, DateRange, CurrentView)
- [ ] Test: empty dataset generates valid .xlsx (header + summary only)
- [ ] Test: large dataset (1000+ rows) generates without errors
- [ ] Integration test: post-generation validation with actual Excel file library

---

## Implementation Notes

**ExcelExportWriterTests:**
```csharp
[TestFixture]
public class ExcelExportWriterTests
{
    private ExcelExportWriter _writer;
    private Mock<IApplicationDbContext> _mockDbContext;
    private Mock<IBlobStorageService> _mockBlobStorage;
    private Mock<IExportDataProvider> _mockDataProvider;

    [SetUp]
    public void SetUp()
    {
        _mockDbContext = new Mock<IApplicationDbContext>();
        _mockBlobStorage = new Mock<IBlobStorageService>();
        _mockDataProvider = new Mock<IExportDataProvider>();
        _writer = new ExcelExportWriter(_mockDbContext.Object, _mockBlobStorage.Object, _mockDataProvider.Object);
    }

    [Test]
    public async Task WriteAsync_ValidData_GeneratesValidXlsx()
    {
        // Arrange
        var exportJob = new ExportJob
        {
            Id = Guid.NewGuid(),
            UserId = "test-user",
            Format = ExportFormat.Excel,
            Scope = ExportScope.All
        };

        var exportData = new ExportData
        {
            Darts = new List<DartExportRow>
            {
                new DartExportRow
                {
                    SessionId = Guid.NewGuid(),
                    Date = new DateTime(2026, 3, 9),
                    GameMode = "X01",
                    Target = 20,
                    Multiplier = 1,
                    Score = 20,
                    Round = 1,
                    Leg = 1,
                    IsCheckout = false,
                    Notes = "Test"
                }
            }
        };

        _mockDataProvider.Setup(x => x.GetExportDataAsync(exportJob, It.IsAny<CancellationToken>()))
            .ReturnsAsync(exportData);

        MemoryStream uploadedContent = null;
        _mockBlobStorage.Setup(x => x.UploadFileAsync(It.IsAny<string>(), It.IsAny<Stream>(), It.IsAny<string>(), It.IsAny<CancellationToken>()))
            .Callback<string, Stream, string, CancellationToken>((name, stream, type, ct) =>
            {
                uploadedContent = new MemoryStream();
                stream.Position = 0;
                stream.CopyTo(uploadedContent);
            })
            .ReturnsAsync("blob-path");

        // Act
        var result = await _writer.WriteAsync(exportJob, CancellationToken.None);

        // Assert
        Assert.IsNotEmpty(result);
        uploadedContent.Position = 0;
        using (var doc = SpreadsheetDocument.Open(uploadedContent, false))
        {
            Assert.IsNotNull(doc.WorkbookPart);
            Assert.Greater(doc.WorkbookPart.Workbook.Sheets.Count(), 0);
        }
    }

    [Test]
    public async Task WriteAsync_MultipleGameModes_CreatesDetailSheets()
    {
        // Arrange
        var exportJob = new ExportJob { Format = ExportFormat.Excel, Scope = ExportScope.All };
        var exportData = new ExportData
        {
            Darts = new List<DartExportRow>
            {
                new DartExportRow { GameMode = "X01", Target = 20, Score = 20 },
                new DartExportRow { GameMode = "Cricket", Target = 20, Score = 20 },
                new DartExportRow { GameMode = "X01", Target = 19, Score = 19 }
            }
        };

        _mockDataProvider.Setup(x => x.GetExportDataAsync(exportJob, It.IsAny<CancellationToken>()))
            .ReturnsAsync(exportData);

        MemoryStream uploadedContent = null;
        _mockBlobStorage.Setup(x => x.UploadFileAsync(It.IsAny<string>(), It.IsAny<Stream>(), It.IsAny<string>(), It.IsAny<CancellationToken>()))
            .Callback<string, Stream, string, CancellationToken>((name, stream, type, ct) =>
            {
                uploadedContent = new MemoryStream();
                stream.Position = 0;
                stream.CopyTo(uploadedContent);
            })
            .ReturnsAsync("blob-path");

        // Act
        await _writer.WriteAsync(exportJob, CancellationToken.None);

        // Assert
        uploadedContent.Position = 0;
        using (var doc = SpreadsheetDocument.Open(uploadedContent, false))
        {
            var sheets = doc.WorkbookPart.Workbook.Sheets.Cast<Sheet>().ToList();
            // Should have: Summary, X01, Cricket
            Assert.AreEqual(3, sheets.Count);
            Assert.AreEqual("Summary", sheets[0].Name);
            Assert.Contains("X01", sheets.Select(s => s.Name).ToArray());
            Assert.Contains("Cricket", sheets.Select(s => s.Name).ToArray());
        }
    }

    [Test]
    public async Task WriteAsync_FileNaming_FollowsConvention()
    {
        // Arrange
        var exportJob = new ExportJob { Format = ExportFormat.Excel, Scope = ExportScope.All };
        var exportData = new ExportData { Darts = new List<DartExportRow>() };

        _mockDataProvider.Setup(x => x.GetExportDataAsync(exportJob, It.IsAny<CancellationToken>()))
            .ReturnsAsync(exportData);

        string uploadedFileName = null;
        _mockBlobStorage.Setup(x => x.UploadFileAsync(It.IsAny<string>(), It.IsAny<Stream>(), It.IsAny<string>(), It.IsAny<CancellationToken>()))
            .Callback<string, Stream, string, CancellationToken>((name, stream, type, ct) => uploadedFileName = name)
            .ReturnsAsync("blob-path");

        // Act
        await _writer.WriteAsync(exportJob, CancellationToken.None);

        // Assert
        Assert.That(uploadedFileName, Does.Match(@"darts-companion_.*_\d{4}-\d{2}-\d{2}\.xlsx"));
        Assert.That(uploadedFileName, Does.EndWith(".xlsx"));
    }

    [Test]
    public async Task WriteAsync_EmptyData_GeneratesValidFile()
    {
        // Arrange
        var exportJob = new ExportJob { Format = ExportFormat.Excel, Scope = ExportScope.All };
        var exportData = new ExportData { Darts = new List<DartExportRow>() };

        _mockDataProvider.Setup(x => x.GetExportDataAsync(exportJob, It.IsAny<CancellationToken>()))
            .ReturnsAsync(exportData);

        MemoryStream uploadedContent = null;
        _mockBlobStorage.Setup(x => x.UploadFileAsync(It.IsAny<string>(), It.IsAny<Stream>(), It.IsAny<string>(), It.IsAny<CancellationToken>()))
            .Callback<string, Stream, string, CancellationToken>((name, stream, type, ct) =>
            {
                uploadedContent = new MemoryStream();
                stream.Position = 0;
                stream.CopyTo(uploadedContent);
            })
            .ReturnsAsync("blob-path");

        // Act
        await _writer.WriteAsync(exportJob, CancellationToken.None);

        // Assert
        uploadedContent.Position = 0;
        using (var doc = SpreadsheetDocument.Open(uploadedContent, false))
        {
            Assert.IsNotNull(doc.WorkbookPart);
            var sheets = doc.WorkbookPart.Workbook.Sheets.Cast<Sheet>().ToList();
            Assert.Greater(sheets.Count, 0); // At least summary sheet
        }
    }

    [Test]
    public async Task WriteAsync_LargeDataset_GeneratesWithoutError()
    {
        // Arrange
        var exportJob = new ExportJob { Format = ExportFormat.Excel, Scope = ExportScope.All };
        var darts = new List<DartExportRow>();
        for (int i = 0; i < 1000; i++)
        {
            darts.Add(new DartExportRow
            {
                SessionId = Guid.NewGuid(),
                Date = DateTime.UtcNow.AddDays(-i),
                GameMode = i % 2 == 0 ? "X01" : "Cricket",
                Target = (i % 20) + 1,
                Score = 20
            });
        }
        var exportData = new ExportData { Darts = darts };

        _mockDataProvider.Setup(x => x.GetExportDataAsync(exportJob, It.IsAny<CancellationToken>()))
            .ReturnsAsync(exportData);

        _mockBlobStorage.Setup(x => x.UploadFileAsync(It.IsAny<string>(), It.IsAny<Stream>(), It.IsAny<string>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync("blob-path");

        // Act & Assert: should not throw
        var result = await _writer.WriteAsync(exportJob, CancellationToken.None);
        Assert.IsNotEmpty(result);
    }
}
```

---

## References

- Open XML SDK: https://github.com/OfficeDev/Open-XML-SDK
- NUnit: https://nunit.org/
- Moq: https://github.com/moq/moq4
