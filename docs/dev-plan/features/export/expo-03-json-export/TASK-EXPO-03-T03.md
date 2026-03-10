# TASK: EXPO-03-T03 — Tests: JSON Export Tests

**Story:** [EXPO-03](../STORY-EXPO-03.md)
**Layer:** Backend
**Status:** Pending
**Agent:** QA/Backend Team

---

## What to Build

Comprehensive unit tests for JsonExportWriter to verify JSON structure, schema compliance, and data sensitivity.

---

## Files

| File Path | Type | Purpose |
|-----------|------|---------|
| `src/UnitTests/Export/JsonExportWriterTests.cs` | Unit Tests | JSON writer tests |

---

## Definition of Done

- [ ] Tests compile and pass
- [ ] Test: generated .json is valid JSON (parses without error)
- [ ] Test: JSON includes exportMetadata with exportedAt, scope, userAgent
- [ ] Test: JSON includes profile section with displayName, joinedAt, timezone
- [ ] Test: JSON includes gameSessions array with sessions and nested darts
- [ ] Test: JSON includes numberFocusSets array
- [ ] Test: JSON includes personalBestRecords array
- [ ] Test: JSON excludes sensitive fields (password, passwordHash, email, tokens)
- [ ] Test: JSON is pretty-printed (contains indentation and newlines)
- [ ] Test: file naming follows convention: `darts-companion_{scope}_{YYYY-MM-DD}.json`
- [ ] Test: scope filtering applied (All, GameMode, DateRange, CurrentView)
- [ ] Test: empty dataset generates valid .json with empty arrays
- [ ] Test: JSON structure can be deserialized back to objects
- [ ] Test: dates are ISO 8601 formatted
- [ ] Integration test: end-to-end generation and schema validation

---

## Implementation Notes

**JsonExportWriterTests:**
```csharp
[TestFixture]
public class JsonExportWriterTests
{
    private JsonExportWriter _writer;
    private Mock<IApplicationDbContext> _mockDbContext;
    private Mock<IBlobStorageService> _mockBlobStorage;
    private Mock<IExportDataProvider> _mockDataProvider;

    [SetUp]
    public void SetUp()
    {
        _mockDbContext = new Mock<IApplicationDbContext>();
        _mockBlobStorage = new Mock<IBlobStorageService>();
        _mockDataProvider = new Mock<IExportDataProvider>();
        _writer = new JsonExportWriter(_mockDbContext.Object, _mockBlobStorage.Object, _mockDataProvider.Object);
    }

    [Test]
    public async Task WriteAsync_ValidData_GeneratesValidJson()
    {
        // Arrange
        var exportJob = new ExportJob
        {
            Id = Guid.NewGuid(),
            UserId = "test-user",
            Format = ExportFormat.Json,
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
                    Multiplier = 3,
                    Score = 60,
                    Round = 1,
                    Leg = 1
                }
            }
        };

        _mockDataProvider.Setup(x => x.GetExportDataAsync(exportJob, It.IsAny<CancellationToken>()))
            .ReturnsAsync(exportData);

        string jsonContent = null;
        _mockBlobStorage.Setup(x => x.UploadFileAsync(It.IsAny<string>(), It.IsAny<Stream>(), It.IsAny<string>(), It.IsAny<CancellationToken>()))
            .Callback<string, Stream, string, CancellationToken>((name, stream, type, ct) =>
            {
                using (var reader = new StreamReader(stream))
                {
                    jsonContent = reader.ReadToEnd();
                }
            })
            .ReturnsAsync("blob-path");

        // Act
        await _writer.WriteAsync(exportJob, CancellationToken.None);

        // Assert
        Assert.IsNotNull(jsonContent);
        var json = JObject.Parse(jsonContent); // Verify valid JSON
        Assert.IsNotNull(json);
    }

    [Test]
    public async Task WriteAsync_JsonStructure_IncludesRequiredFields()
    {
        // Arrange
        var exportJob = new ExportJob { Format = ExportFormat.Json, Scope = ExportScope.All };
        var exportData = new ExportData { Darts = new List<DartExportRow>() };

        _mockDataProvider.Setup(x => x.GetExportDataAsync(exportJob, It.IsAny<CancellationToken>()))
            .ReturnsAsync(exportData);

        string jsonContent = null;
        _mockBlobStorage.Setup(x => x.UploadFileAsync(It.IsAny<string>(), It.IsAny<Stream>(), It.IsAny<string>(), It.IsAny<CancellationToken>()))
            .Callback<string, Stream, string, CancellationToken>((name, stream, type, ct) =>
            {
                using (var reader = new StreamReader(stream))
                {
                    jsonContent = reader.ReadToEnd();
                }
            })
            .ReturnsAsync("blob-path");

        // Act
        await _writer.WriteAsync(exportJob, CancellationToken.None);

        // Assert
        var json = JObject.Parse(jsonContent);
        Assert.IsNotNull(json["exportMetadata"]);
        Assert.IsNotNull(json["profile"]);
        Assert.IsNotNull(json["gameSessions"]);
        Assert.IsNotNull(json["numberFocusSets"]);
        Assert.IsNotNull(json["personalBestRecords"]);
    }

    [Test]
    public async Task WriteAsync_ExportMetadata_ContainsRequiredFields()
    {
        // Arrange
        var exportJob = new ExportJob { Format = ExportFormat.Json, Scope = ExportScope.All };
        var exportData = new ExportData { Darts = new List<DartExportRow>() };

        _mockDataProvider.Setup(x => x.GetExportDataAsync(exportJob, It.IsAny<CancellationToken>()))
            .ReturnsAsync(exportData);

        string jsonContent = null;
        _mockBlobStorage.Setup(x => x.UploadFileAsync(It.IsAny<string>(), It.IsAny<Stream>(), It.IsAny<string>(), It.IsAny<CancellationToken>()))
            .Callback<string, Stream, string, CancellationToken>((name, stream, type, ct) =>
            {
                using (var reader = new StreamReader(stream))
                {
                    jsonContent = reader.ReadToEnd();
                }
            })
            .ReturnsAsync("blob-path");

        // Act
        await _writer.WriteAsync(exportJob, CancellationToken.None);

        // Assert
        var json = JObject.Parse(jsonContent);
        var metadata = json["exportMetadata"];
        Assert.IsNotNull(metadata["exportedAt"]);
        Assert.IsNotNull(metadata["scope"]);
        Assert.IsNotNull(metadata["userAgent"]);
    }

    [Test]
    public async Task WriteAsync_Excludes_SensitiveFields()
    {
        // Arrange
        var exportJob = new ExportJob { Format = ExportFormat.Json, Scope = ExportScope.All };
        var exportData = new ExportData { Darts = new List<DartExportRow>() };

        _mockDataProvider.Setup(x => x.GetExportDataAsync(exportJob, It.IsAny<CancellationToken>()))
            .ReturnsAsync(exportData);

        string jsonContent = null;
        _mockBlobStorage.Setup(x => x.UploadFileAsync(It.IsAny<string>(), It.IsAny<Stream>(), It.IsAny<string>(), It.IsAny<CancellationToken>()))
            .Callback<string, Stream, string, CancellationToken>((name, stream, type, ct) =>
            {
                using (var reader = new StreamReader(stream))
                {
                    jsonContent = reader.ReadToEnd();
                }
            })
            .ReturnsAsync("blob-path");

        // Act
        await _writer.WriteAsync(exportJob, CancellationToken.None);

        // Assert
        // Ensure no passwords, tokens, or sensitive data in JSON
        Assert.That(jsonContent, Does.Not.Contain("password"));
        Assert.That(jsonContent, Does.Not.Contain("token"));
        Assert.That(jsonContent, Does.Not.Contain("secret"));
    }

    [Test]
    public async Task WriteAsync_JsonFormatting_IsPrettyPrinted()
    {
        // Arrange
        var exportJob = new ExportJob { Format = ExportFormat.Json, Scope = ExportScope.All };
        var exportData = new ExportData { Darts = new List<DartExportRow>() };

        _mockDataProvider.Setup(x => x.GetExportDataAsync(exportJob, It.IsAny<CancellationToken>()))
            .ReturnsAsync(exportData);

        string jsonContent = null;
        _mockBlobStorage.Setup(x => x.UploadFileAsync(It.IsAny<string>(), It.IsAny<Stream>(), It.IsAny<string>(), It.IsAny<CancellationToken>()))
            .Callback<string, Stream, string, CancellationToken>((name, stream, type, ct) =>
            {
                using (var reader = new StreamReader(stream))
                {
                    jsonContent = reader.ReadToEnd();
                }
            })
            .ReturnsAsync("blob-path");

        // Act
        await _writer.WriteAsync(exportJob, CancellationToken.None);

        // Assert: pretty-printed JSON should have newlines and indentation
        Assert.That(jsonContent, Does.Contain("\n"));
        Assert.That(jsonContent, Does.Contain("  ")); // Indentation
    }

    [Test]
    public async Task WriteAsync_FileNaming_FollowsConvention()
    {
        // Arrange
        var exportJob = new ExportJob { Format = ExportFormat.Json, Scope = ExportScope.All };
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
        Assert.That(uploadedFileName, Does.Match(@"darts-companion_.*_\d{4}-\d{2}-\d{2}\.json"));
        Assert.That(uploadedFileName, Does.EndWith(".json"));
    }

    [Test]
    public async Task WriteAsync_Dates_AreIso8601Formatted()
    {
        // Arrange
        var exportJob = new ExportJob { Format = ExportFormat.Json, Scope = ExportScope.All };
        var exportData = new ExportData { Darts = new List<DartExportRow>() };

        _mockDataProvider.Setup(x => x.GetExportDataAsync(exportJob, It.IsAny<CancellationToken>()))
            .ReturnsAsync(exportData);

        string jsonContent = null;
        _mockBlobStorage.Setup(x => x.UploadFileAsync(It.IsAny<string>(), It.IsAny<Stream>(), It.IsAny<string>(), It.IsAny<CancellationToken>()))
            .Callback<string, Stream, string, CancellationToken>((name, stream, type, ct) =>
            {
                using (var reader = new StreamReader(stream))
                {
                    jsonContent = reader.ReadToEnd();
                }
            })
            .ReturnsAsync("blob-path");

        // Act
        await _writer.WriteAsync(exportJob, CancellationToken.None);

        // Assert: exportedAt should be ISO 8601
        var json = JObject.Parse(jsonContent);
        var exportedAt = json["exportMetadata"]["exportedAt"].Value<string>();
        Assert.DoesNotThrow(() => DateTime.Parse(exportedAt, null, System.Globalization.DateTimeStyles.RoundtripKind));
    }
}
```

---

## References

- Newtonsoft.Json: https://www.newtonsoft.com/json
- NUnit: https://nunit.org/
- ISO 8601: https://en.wikipedia.org/wiki/ISO_8601
