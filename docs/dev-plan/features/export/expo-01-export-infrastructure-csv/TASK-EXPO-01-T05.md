# TASK: EXPO-01-T05 — Tests: Export Command and CSV Writer Tests

**Story:** [EXPO-01](../STORY-EXPO-01.md)
**Layer:** Backend
**Status:** Pending
**Agent:** QA/Backend Team

---

## What to Build

Comprehensive unit and integration tests for export functionality:

**RequestExportCommand Tests:**
- Test valid command creates ExportJob with correct status (Pending)
- Test unauthorized access throws UnauthorizedAccessException
- Test missing required fields fail validation
- Test invalid scope throws validation error

**CsvExportWriter Tests:**
- Test CSV header row is correct
- Test UTF-8 BOM is present
- Test file naming follows convention: `darts-companion_{scope}_{YYYY-MM-DD}.csv`
- Test CSV escaping (quotes, commas, newlines)
- Test scope filtering (All, GameMode, DateRange, CurrentView)
- Test large dataset (1000+ rows) generates correctly
- Test empty dataset returns header only
- Test date/time formatting (ISO 8601)
- Test numeric columns (score, multiplier) are unquoted

**Integration Tests:**
- Test end-to-end: request export → background job processes → file generated → download available

---

## Files

| File Path | Type | Purpose |
|-----------|------|---------|
| `src/UnitTests/Export/RequestExportCommandTests.cs` | Unit Tests | Command handler tests |
| `src/UnitTests/Export/RequestExportCommandValidatorTests.cs` | Unit Tests | Validator tests |
| `src/UnitTests/Export/CsvExportWriterTests.cs` | Unit Tests | CSV writer tests |
| `src/IntegrationTests/Export/ExportEndToEndTests.cs` | Integration Tests | End-to-end workflow tests |

---

## Definition of Done

- [ ] RequestExportCommand tests compile and pass
- [ ] Test: valid command creates ExportJob with Status = Pending
- [ ] Test: UserId is set correctly from ICurrentUserService
- [ ] Test: unauthorized access throws UnauthorizedAccessException
- [ ] Test: missing required fields fail validation
- [ ] Validator tests compile and pass
- [ ] Test: valid scope values pass
- [ ] Test: invalid scope rejected
- [ ] CsvExportWriter tests compile and pass
- [ ] Test: CSV header row matches specification
- [ ] Test: first byte is UTF-8 BOM (0xEF 0xBB 0xBF)
- [ ] Test: file name follows convention
- [ ] Test: commas in fields are escaped with quotes
- [ ] Test: quotes are escaped as double quotes
- [ ] Test: newlines in fields are preserved within quoted fields
- [ ] Test: scope filtering works (All returns all, GameMode filters correctly)
- [ ] Test: DateRange filtering works (start/end dates applied)
- [ ] Test: large dataset (1000 rows) generates without errors
- [ ] Test: empty dataset returns header only
- [ ] Test: dates formatted as yyyy-MM-dd HH:mm:ss
- [ ] Test: numeric columns (score, multiplier) are unquoted
- [ ] Integration tests compile and pass
- [ ] Test: POST /api/export creates job, GET status returns Pending, then Processing, then Completed
- [ ] Test: GET /api/export/{jobId}/download returns CSV file after completion
- [ ] Test coverage ≥80% for export-related code

---

## Implementation Notes

**RequestExportCommandTests:**
```csharp
[TestFixture]
public class RequestExportCommandTests
{
    private RequestExportCommandHandler _handler;
    private Mock<IApplicationDbContext> _mockDbContext;
    private Mock<ICurrentUserService> _mockCurrentUserService;

    [SetUp]
    public void SetUp()
    {
        _mockDbContext = new Mock<IApplicationDbContext>();
        _mockCurrentUserService = new Mock<ICurrentUserService>();
        _handler = new RequestExportCommandHandler(_mockDbContext.Object, _mockCurrentUserService.Object);
    }

    [Test]
    public async Task Handle_ValidCommand_CreatesExportJob()
    {
        // Arrange
        var userId = "test-user-123";
        _mockCurrentUserService.Setup(x => x.UserId).Returns(userId);

        var command = new RequestExportCommand
        {
            Format = ExportFormat.Csv,
            Scope = ExportScope.All
        };

        // Act
        var result = await _handler.Handle(command, CancellationToken.None);

        // Assert
        Assert.IsNotNull(result);
        Assert.IsNotEmpty(result.JobId.ToString());
        Assert.AreEqual("Pending", result.Status);
    }

    [Test]
    public void Handle_UnauthorizedUser_ThrowsException()
    {
        // Arrange
        _mockCurrentUserService.Setup(x => x.UserId).Returns(string.Empty);

        var command = new RequestExportCommand
        {
            Format = ExportFormat.Csv,
            Scope = ExportScope.All
        };

        // Assert
        Assert.ThrowsAsync<UnauthorizedAccessException>(
            async () => await _handler.Handle(command, CancellationToken.None)
        );
    }
}
```

**CsvExportWriterTests:**
```csharp
[TestFixture]
public class CsvExportWriterTests
{
    private CsvExportWriter _writer;
    private Mock<IApplicationDbContext> _mockDbContext;
    private Mock<IBlobStorageService> _mockBlobStorage;
    private Mock<IExportDataProvider> _mockDataProvider;

    [SetUp]
    public void SetUp()
    {
        _mockDbContext = new Mock<IApplicationDbContext>();
        _mockBlobStorage = new Mock<IBlobStorageService>();
        _mockDataProvider = new Mock<IExportDataProvider>();
        _writer = new CsvExportWriter(_mockDbContext.Object, _mockBlobStorage.Object, _mockDataProvider.Object);
    }

    [Test]
    public async Task WriteAsync_ValidData_GeneratesCorrectCsv()
    {
        // Arrange
        var exportJob = new ExportJob
        {
            Id = Guid.NewGuid(),
            UserId = "test-user",
            Format = ExportFormat.Csv,
            Scope = ExportScope.All
        };

        var exportData = new ExportData
        {
            Darts = new List<DartExportRow>
            {
                new DartExportRow
                {
                    SessionId = Guid.NewGuid(),
                    Date = new DateTime(2026, 3, 9, 10, 30, 0),
                    GameMode = "X01",
                    Target = 20,
                    Multiplier = 1,
                    Score = 20,
                    Round = 1,
                    Leg = 1,
                    IsCheckout = false,
                    Notes = "Test dart"
                }
            }
        };

        _mockDataProvider.Setup(x => x.GetExportDataAsync(exportJob, It.IsAny<CancellationToken>()))
            .ReturnsAsync(exportData);

        // Act
        var result = await _writer.WriteAsync(exportJob, CancellationToken.None);

        // Assert
        Assert.IsNotEmpty(result);
        Assert.That(result, Does.EndWith(".csv"));
    }

    [Test]
    public async Task WriteAsync_CsvContent_IncludesUtf8Bom()
    {
        // Arrange
        var exportJob = new ExportJob { /* ... */ };
        var exportData = new ExportData { Darts = new List<DartExportRow>() };

        _mockDataProvider.Setup(x => x.GetExportDataAsync(exportJob, It.IsAny<CancellationToken>()))
            .ReturnsAsync(exportData);

        // Capture uploaded content
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
        var bytes = uploadedContent.ToArray();
        Assert.That(bytes[0], Is.EqualTo(0xEF)); // UTF-8 BOM
        Assert.That(bytes[1], Is.EqualTo(0xBB));
        Assert.That(bytes[2], Is.EqualTo(0xBF));
    }

    [Test]
    public async Task WriteAsync_CsvHeader_IsCorrect()
    {
        // Arrange
        var exportJob = new ExportJob { /* ... */ };
        var exportData = new ExportData { Darts = new List<DartExportRow>() };

        _mockDataProvider.Setup(x => x.GetExportDataAsync(exportJob, It.IsAny<CancellationToken>()))
            .ReturnsAsync(exportData);

        string csvContent = null;
        _mockBlobStorage.Setup(x => x.UploadFileAsync(It.IsAny<string>(), It.IsAny<Stream>(), It.IsAny<string>(), It.IsAny<CancellationToken>()))
            .Callback<string, Stream, string, CancellationToken>((name, stream, type, ct) =>
            {
                stream.Position = 3; // Skip BOM
                using (var reader = new StreamReader(stream))
                {
                    csvContent = reader.ReadToEnd();
                }
            })
            .ReturnsAsync("blob-path");

        // Act
        await _writer.WriteAsync(exportJob, CancellationToken.None);

        // Assert
        var lines = csvContent.Split(Environment.NewLine);
        Assert.That(lines[0], Does.Contain("Session ID"));
        Assert.That(lines[0], Does.Contain("Date"));
        Assert.That(lines[0], Does.Contain("Game Mode"));
    }

    [Test]
    public void CsvEscape_WithComma_QuotesField()
    {
        // Arrange
        var fields = new[] { "field1", "field, with comma", "field3" };

        // Act
        var result = _writer.CsvEscape(fields); // Make method public or use reflection

        // Assert
        Assert.That(result, Does.Contain("\"field, with comma\""));
    }

    [Test]
    public void CsvEscape_WithQuote_DoublesQuote()
    {
        // Arrange
        var fields = new[] { "field\"with quote" };

        // Act
        var result = _writer.CsvEscape(fields);

        // Assert
        Assert.That(result, Does.Contain("\"field\"\"with quote\""));
    }

    [Test]
    public async Task WriteAsync_FileNaming_FollowsConvention()
    {
        // Arrange
        var exportJob = new ExportJob
        {
            Scope = ExportScope.All
        };
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
        Assert.That(uploadedFileName, Does.Match(@"darts-companion_.*_\d{4}-\d{2}-\d{2}\.csv"));
    }
}
```

**Integration Tests:**
```csharp
[TestFixture]
public class ExportEndToEndTests
{
    private readonly DbContextOptions<ApplicationDbContext> _dbContextOptions;

    [SetUp]
    public void SetUp()
    {
        _dbContextOptions = new DbContextOptionsBuilder<ApplicationDbContext>()
            .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
            .Options;
    }

    [Test]
    public async Task ExportWorkflow_RequestThenDownload_Succeeds()
    {
        // Arrange
        using (var context = new ApplicationDbContext(_dbContextOptions))
        {
            // Create test sessions and darts
            var session = new Session { UserId = "test-user", GameMode = "X01", StartTime = DateTime.UtcNow };
            context.Sessions.Add(session);
            context.SaveChanges();

            // Act
            var request = new RequestExportCommand { Format = ExportFormat.Csv, Scope = ExportScope.All };
            var handler = new RequestExportCommandHandler(context, new MockCurrentUserService("test-user"));
            var jobResult = await handler.Handle(request, CancellationToken.None);

            // Assert
            var createdJob = context.ExportJobs.First(j => j.Id == Guid.Parse(jobResult.JobId));
            Assert.AreEqual(ExportStatus.Pending, createdJob.Status);
        }
    }
}
```

---

## References

- [`../../shared/architecture.md`](../../shared/architecture.md) — Testing patterns, mocking strategies
- NUnit: https://nunit.org/
- Moq: https://github.com/moq/moq4
- Entity Framework Core Testing: https://docs.microsoft.com/en-us/ef/core/testing/
