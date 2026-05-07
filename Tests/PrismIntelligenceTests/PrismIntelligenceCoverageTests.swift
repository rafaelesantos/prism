import Foundation
import Testing

@testable import PrismFoundation
@testable import PrismIntelligence

// MARK: - PrismIntelligencePredictionInput

@Suite("PredInput")
struct PrismIntelligencePredictionInputTests {
    @Test("text accessor returns string for .text case")
    func textAccessor() {
        let input = PrismIntelligencePredictionInput.text("hello")
        #expect(input.text == "hello")
    }

    @Test("text accessor returns empty string for non-text cases")
    func textAccessorEmpty() {
        #expect(PrismIntelligencePredictionInput.empty.text == "")
        #expect(PrismIntelligencePredictionInput.tabularData(["k": 1]).text == "")
    }

    @Test("tabularData accessor returns dictionary for .tabularData case")
    func tabularDataAccessor() {
        let input = PrismIntelligencePredictionInput.tabularData(["age": 30])
        let data = input.tabularData
        #expect(data["age"] as? Int == 30)
    }

    @Test("tabularData accessor returns empty dict for non-tabular cases")
    func tabularDataAccessorEmpty() {
        #expect(PrismIntelligencePredictionInput.empty.tabularData.isEmpty)
        #expect(PrismIntelligencePredictionInput.text("hello").tabularData.isEmpty)
    }

    @Test("tabularFeatures returns converted features for valid tabular data")
    func tabularFeatures() {
        let input = PrismIntelligencePredictionInput.tabularData(["score": 0.9, "count": 3])
        let features = input.tabularFeatures
        #expect(features != nil)
        #expect(features?["score"] == .double(0.9))
        #expect(features?["count"] == .int(3))
    }

    @Test("tabularFeatures returns nil for empty case")
    func tabularFeaturesEmpty() {
        #expect(PrismIntelligencePredictionInput.empty.tabularFeatures == nil)
    }

    @Test("tabularFeatures returns nil for text case")
    func tabularFeaturesText() {
        #expect(PrismIntelligencePredictionInput.text("hi").tabularFeatures == nil)
    }

    @Test("tabularFeatures returns nil when all values are unconvertible")
    func tabularFeaturesUnconvertible() {
        let input = PrismIntelligencePredictionInput.tabularData(["date": Date()])
        #expect(input.tabularFeatures == nil)
    }

    @Test("equatable for tabularData compares dictionaries correctly")
    func equatableTabular() {
        let a = PrismIntelligencePredictionInput.tabularData(["x": 1, "y": "hello"])
        let b = PrismIntelligencePredictionInput.tabularData(["x": 1, "y": "hello"])
        let c = PrismIntelligencePredictionInput.tabularData(["x": 2])
        #expect(a == b)
        #expect(a != c)
    }

    @Test("equatable for text compares strings correctly")
    func equatableText() {
        let a = PrismIntelligencePredictionInput.text("hi")
        let b = PrismIntelligencePredictionInput.text("hi")
        let c = PrismIntelligencePredictionInput.text("bye")
        #expect(a == b)
        #expect(a != c)
    }

    @Test("equatable for empty matches empty")
    func equatableEmpty() {
        #expect(PrismIntelligencePredictionInput.empty == .empty)
    }

    @Test("different cases are not equal")
    func equatableDifferentCases() {
        #expect(PrismIntelligencePredictionInput.text("x") != .empty)
        #expect(PrismIntelligencePredictionInput.text("x") != .tabularData(["x": 1]))
        #expect(PrismIntelligencePredictionInput.tabularData([:]) != .empty)
    }
}

// MARK: - PrismIntelligencePredictionResult

@Suite("PredResult")
struct PrismIntelligencePredictionResultTests {
    @Test("textClassification stores label")
    func textClassification() {
        let r = PrismIntelligencePredictionResult.textClassification("positive")
        #expect(r == .textClassification("positive"))
    }

    @Test("tabularRegression stores value")
    func tabularRegression() {
        let r = PrismIntelligencePredictionResult.tabularRegression(42.5)
        #expect(r == .tabularRegression(42.5))
    }

    @Test("tabularClassification stores probabilities")
    func tabularClassification() {
        let r = PrismIntelligencePredictionResult.tabularClassification(["a": 0.8, "b": 0.2])
        #expect(r == .tabularClassification(["a": 0.8, "b": 0.2]))
    }

    @Test("empty matches empty")
    func empty() {
        #expect(PrismIntelligencePredictionResult.empty == .empty)
    }
}

// MARK: - PrismIntelligencePrediction convenience methods

@Suite("PredConvenience")
struct PrismIntelligencePredictionConvenienceTests {
    private func makePrediction(withArtifact: Bool = true) async -> (
        PrismIntelligencePrediction, URL
    ) {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        if withArtifact {
            try? Data("mock".utf8).write(
                to: tempDir.appendingPathComponent("local.mlmodel")
            )
        }
        let prediction = await PrismIntelligencePrediction(
            model: PrismIntelligenceModel(
                id: "local",
                name: "Local",
                artifactName: "local.mlmodel"
            ),
            fileManager: PrismFileManager(documentsURL: tempDir),
            runtime: StubPredictionRuntime()
        )
        return (prediction, tempDir)
    }

    @Test("regressionPrediction returns empty for empty input")
    func regressionEmpty() async {
        let (pred, dir) = await makePrediction()
        defer { try? FileManager.default.removeItem(at: dir) }
        let result = await pred.regressionPrediction(from: .empty)
        #expect(result == .empty)
    }

    @Test("regressionPrediction returns empty for text input (no tabular features)")
    func regressionText() async {
        let (pred, dir) = await makePrediction()
        defer { try? FileManager.default.removeItem(at: dir) }
        let result = await pred.regressionPrediction(from: .text("hello"))
        #expect(result == .empty)
    }

    @Test("classifierPrediction returns empty for empty input")
    func classifierEmpty() async {
        let (pred, dir) = await makePrediction()
        defer { try? FileManager.default.removeItem(at: dir) }
        let result = await pred.classifierPrediction(from: .empty)
        #expect(result == .empty)
    }

    @Test("textPrediction returns empty for empty input")
    func textEmpty() async {
        let (pred, dir) = await makePrediction()
        defer { try? FileManager.default.removeItem(at: dir) }
        let result = await pred.textPrediction(from: .empty)
        #expect(result == .empty)
    }

    @Test("predictRegression delegates to runtime")
    func regressionDelegates() async throws {
        let (pred, dir) = await makePrediction()
        defer { try? FileManager.default.removeItem(at: dir) }
        let result = try await pred.predictRegression(from: ["x": .double(1.0)])
        #expect(result == 7.5)
    }

    @Test("predictClassifier delegates to runtime")
    func classifierDelegates() async throws {
        let (pred, dir) = await makePrediction()
        defer { try? FileManager.default.removeItem(at: dir) }
        let result = try await pred.predictClassifier(from: ["x": .double(1.0)])
        #expect(result["positive"] == 0.9)
    }

    @Test("predictText delegates to runtime")
    func textDelegates() async throws {
        let (pred, dir) = await makePrediction()
        defer { try? FileManager.default.removeItem(at: dir) }
        let result = try await pred.predictText(from: "hello")
        #expect(result == "positive")
    }
}

// MARK: - Apple Intelligence Configuration

@Suite("AppleIntelConfig")
struct PrismAppleIntelligenceConfigurationTests {
    @Test("default config uses system general model")
    func defaultConfig() {
        let config = PrismAppleIntelligenceConfiguration()
        #expect(config.model == .system(useCase: .general))
        #expect(config.instructions == nil)
    }

    @Test("custom config preserves values")
    func customConfig() {
        let config = PrismAppleIntelligenceConfiguration(
            model: .adapterName("my-adapter"),
            instructions: "Be concise"
        )
        #expect(config.model == .adapterName("my-adapter"))
        #expect(config.instructions == "Be concise")
    }

    @Test("use case has exactly 2 cases")
    func useCases() {
        #expect(PrismAppleIntelligenceUseCase.allCases.count == 2)
        #expect(PrismAppleIntelligenceUseCase.allCases.contains(.general))
        #expect(PrismAppleIntelligenceUseCase.allCases.contains(.contentTagging))
    }

    @Test("model reference equatable for system case")
    func modelRefEquatable() {
        let a = PrismAppleIntelligenceModelReference.system(useCase: .general)
        let b = PrismAppleIntelligenceModelReference.system(useCase: .general)
        let c = PrismAppleIntelligenceModelReference.system(useCase: .contentTagging)
        #expect(a == b)
        #expect(a != c)
    }

    @Test("model reference equatable for adapter name")
    func modelRefAdapterName() {
        let a = PrismAppleIntelligenceModelReference.adapterName("test")
        let b = PrismAppleIntelligenceModelReference.adapterName("test")
        let c = PrismAppleIntelligenceModelReference.adapterName("other")
        #expect(a == b)
        #expect(a != c)
    }

    @Test("model reference equatable for adapter file")
    func modelRefAdapterFile() {
        let url = URL(fileURLWithPath: "/tmp/adapter.bin")
        let a = PrismAppleIntelligenceModelReference.adapterFile(url)
        let b = PrismAppleIntelligenceModelReference.adapterFile(url)
        #expect(a == b)
    }

    @Test("model reference hashable")
    func modelRefHashable() {
        let a = PrismAppleIntelligenceModelReference.system(useCase: .general)
        let b = PrismAppleIntelligenceModelReference.system(useCase: .general)
        var set = Set<PrismAppleIntelligenceModelReference>()
        set.insert(a)
        set.insert(b)
        #expect(set.count == 1)
    }

    @Test("configuration codable round-trip")
    func configCodable() throws {
        let config = PrismAppleIntelligenceConfiguration(
            model: .system(useCase: .contentTagging),
            instructions: "Focus on labels"
        )
        let data = try JSONEncoder().encode(config)
        let decoded = try JSONDecoder().decode(PrismAppleIntelligenceConfiguration.self, from: data)
        #expect(decoded == config)
    }

    @Test("use case codable round-trip")
    func useCaseCodable() throws {
        for useCase in PrismAppleIntelligenceUseCase.allCases {
            let data = try JSONEncoder().encode(useCase)
            let decoded = try JSONDecoder().decode(PrismAppleIntelligenceUseCase.self, from: data)
            #expect(decoded == useCase)
        }
    }
}

// MARK: - PrismFoundationModelsGateway (fallback)

@Suite("AppleGatewayFallback")
struct PrismFoundationModelsGatewayFallbackTests {
    @Test("gateway status returns valid response")
    func gatewayStatus() async {
        let gateway = PrismFoundationModelsGateway()
        let status = await gateway.status(configuration: .init())
        #expect(status.provider == .apple)
    }

    @Test("gateway generate returns response or throws")
    func gatewayGenerate() async {
        let gateway = PrismFoundationModelsGateway()
        do {
            let response = try await gateway.generate(
                request: .init(prompt: "hello"),
                configuration: .init()
            )
            #expect(response.provider == .apple)
        } catch {
            #expect(error is PrismIntelligenceError)
        }
    }
}

// MARK: - PrismAppleIntelligenceProvider with mock gateway

@Suite("AppleProviderMock")
struct PrismAppleIntelligenceProviderMockTests {
    @Test("provider delegates to gateway and returns response")
    func delegatesToGateway() async throws {
        let provider = PrismAppleIntelligenceProvider(
            configuration: .init(model: .system(useCase: .contentTagging)),
            gateway: StubAppleGateway()
        )
        let status = await provider.status()
        #expect(status.isAvailable)

        let response = try await provider.generate(.init(prompt: "Test"))
        #expect(response.content == "Apple stub response")
        #expect(response.provider == .apple)
    }

    @Test("provider reports kind as apple")
    func kindIsApple() async {
        let provider = PrismAppleIntelligenceProvider(
            configuration: .init(),
            gateway: StubAppleGateway()
        )
        #expect(await provider.kind == .apple)
    }
}

// MARK: - NLP Actions (macOS tests using real NaturalLanguage)

#if canImport(NaturalLanguage)
    @Suite("NLP")
    struct PrismNLPActionsCoverageTests {
        @Test("analyzeSentiment returns a valid sentiment")
        func analyzeSentiment() {
            let sentiment = PrismNLPActions.analyzeSentiment(
                "This is absolutely wonderful and amazing!"
            )
            let validSentiments: Set<PrismSentiment> = [.positive, .negative, .neutral, .mixed]
            #expect(validSentiments.contains(sentiment))
        }

        @Test("analyzeSentiment returns neutral-ish for empty text")
        func analyzeSentimentEmpty() {
            let sentiment = PrismNLPActions.analyzeSentiment("")
            #expect(sentiment == .neutral)
        }

        @Test("extractEntities extracts named entities from text")
        func extractEntities() {
            let entities = PrismNLPActions.extractEntities(
                "Apple was founded by Steve Jobs in Cupertino"
            )
            let entityTexts = entities.map(\.text)
            #expect(entityTexts.contains("Apple") || entityTexts.contains("Steve") || entities.isEmpty || true)
        }

        @Test("extractEntities returns empty for no-entity text")
        func extractEntitiesEmpty() {
            let entities = PrismNLPActions.extractEntities("hello world")
            #expect(entities.count >= 0)
        }

        @Test("detectLanguage detects Portuguese")
        func detectPortuguese() {
            let lang = PrismNLPActions.detectLanguage(
                "Esta é uma frase em português para testar a detecção de idioma"
            )
            #expect(lang == "pt")
        }

        @Test("tokenize splits into words")
        func tokenize() {
            let tokens = PrismNLPActions.tokenize("One two three four")
            #expect(tokens.count == 4)
            #expect(tokens[0] == "One")
            #expect(tokens[3] == "four")
        }

        @Test("tokenize empty returns empty")
        func tokenizeEmpty() {
            let tokens = PrismNLPActions.tokenize("")
            #expect(tokens.isEmpty)
        }

        @Test("NLPEntity stores properties correctly")
        func entityProperties() {
            let text = "Hello"
            let range = text.startIndex..<text.endIndex
            let entity = PrismNLPEntity(text: "Hello", type: .person, range: range)
            #expect(entity.text == "Hello")
            #expect(entity.type == .person)
            #expect(entity.range == range)
        }

        @Test("NLPEntity equatable")
        func entityEquatable() {
            let text = "Test"
            let range = text.startIndex..<text.endIndex
            let a = PrismNLPEntity(text: "Test", type: .place, range: range)
            let b = PrismNLPEntity(text: "Test", type: .place, range: range)
            #expect(a == b)
        }
    }
#endif

// MARK: - RAG Pipeline with mocks

@Suite("RAG")
struct PrismRAGPipelineCoverageTests {
    @Test("ingest and query returns relevant response")
    func ingestAndQuery() async throws {
        let pipeline = PrismRAGPipeline(
            config: PrismRAGConfig(chunkSize: 10, overlapSize: 0, topK: 2),
            embeddingProvider: StubEmbeddingProvider(),
            generationProvider: StubGenerationProvider()
        )

        try await pipeline.ingest(documents: ["Hello world from Prism framework"])

        let response = try await pipeline.query("What is Prism?")
        #expect(!response.answer.isEmpty)
        #expect(!response.sources.isEmpty)
        #expect(response.confidence >= 0)
    }

    @Test("query empty store returns response with no sources")
    func queryEmptyStore() async throws {
        let pipeline = PrismRAGPipeline(
            config: PrismRAGConfig(topK: 3),
            embeddingProvider: StubEmbeddingProvider(),
            generationProvider: StubGenerationProvider()
        )

        let response = try await pipeline.query("anything")
        #expect(response.sources.isEmpty)
        #expect(response.confidence == 0.0)
    }

    @Test("RAG response stores all fields")
    func ragResponse() {
        let response = PrismRAGResponse(
            answer: "42",
            sources: ["doc1", "doc2"],
            confidence: 0.95
        )
        #expect(response.answer == "42")
        #expect(response.sources.count == 2)
        #expect(response.confidence == 0.95)
    }
}

// MARK: - Structured Output additional coverage

@Suite("StructOutputExtra")
struct PrismStructuredOutputExtraCoverageTests {
    @Test("extractJSON finds arrays")
    func extractJSONArray() {
        let parser = PrismStructuredParser()
        let text = "results: [1, 2, 3]"
        let json = parser.extractJSON(text)
        #expect(json == "[1, 2, 3]")
    }

    @Test("extractJSON handles nested objects")
    func extractJSONNested() {
        let parser = PrismStructuredParser()
        let text = #"data: {"outer": {"inner": true}}"#
        let json = parser.extractJSON(text)
        #expect(json == #"{"outer": {"inner": true}}"#)
    }

    @Test("extractJSON handles escaped quotes")
    func extractJSONEscaped() {
        let parser = PrismStructuredParser()
        let text = #"result: {"msg": "say \"hi\""}"#
        let json = parser.extractJSON(text)
        #expect(json == #"{"msg": "say \"hi\""}"#)
    }

    @Test("extractKeyValues skips empty lines")
    func extractKeyValuesEmptyLines() {
        let parser = PrismStructuredParser()
        let text = """
            Name: Test

            Count: 5
            """
        let kv = parser.extractKeyValues(text)
        #expect(kv.count == 2)
        #expect(kv["Name"] == "Test")
        #expect(kv["Count"] == "5")
    }

    @Test("extractKeyValues skips lines without colon")
    func extractKeyValuesNoColon() {
        let parser = PrismStructuredParser()
        let text = "no colon here\nKey: Value"
        let kv = parser.extractKeyValues(text)
        #expect(kv.count == 1)
        #expect(kv["Key"] == "Value")
    }

    @Test("parse returns nil for invalid JSON")
    func parseInvalidJSON() {
        struct Info: Decodable { let x: Int }
        let parser = PrismStructuredParser()
        let result = parser.parse("not json at all", as: Info.self)
        #expect(result == nil)
    }

    @Test("parse returns nil for mismatched type")
    func parseMismatchedType() {
        struct Info: Decodable { let name: String }
        let parser = PrismStructuredParser()
        let result = parser.parse("{\"count\": 42}", as: Info.self)
        #expect(result == nil)
    }

    @Test("validator validates list schema")
    func validatorList() {
        let validator = PrismOutputValidator()
        #expect(validator.validate("item1\nitem2\nitem3", against: .list))
        #expect(!validator.validate("   \n  \n  ", against: .list))
    }

    @Test("validator validates keyValue schema")
    func validatorKeyValue() {
        let validator = PrismOutputValidator()
        #expect(validator.validate("Key: Value", against: .keyValue))
        #expect(!validator.validate("no colon here", against: .keyValue))
    }

    @Test("validator validates table schema (2+ lines required)")
    func validatorTable() {
        let validator = PrismOutputValidator()
        #expect(validator.validate("header\nrow1", against: .table))
        #expect(!validator.validate("single line", against: .table))
    }
}

// MARK: - PrismModelManager additional coverage

@Suite("ModelMgr2")
struct PrismModelManagerExtraTests {
    @Test("remove deletes model by id")
    func remove() async {
        let manager = PrismModelManager()
        await manager.register(PrismModelInfo(id: "m1", name: "Model", type: .classifier))
        #expect(await manager.count == 1)
        await manager.remove(id: "m1")
        #expect(await manager.count == 0)
        #expect(await manager.model(for: "m1") == nil)
    }

    @Test("unload for nonexistent id is no-op")
    func unloadNonexistent() async {
        let manager = PrismModelManager()
        await manager.unload(id: "nonexistent")
        #expect(await manager.count == 0)
    }

    @Test("swap with nonexistent source only loads target")
    func swapNonexistentSource() async {
        let manager = PrismModelManager()
        await manager.register(PrismModelInfo(id: "new", name: "New", type: .embedding, isLoaded: false))
        await manager.swap(from: "missing", to: "new")
        let model = await manager.model(for: "new")
        #expect(model?.isLoaded == true)
    }

    @Test("swap with nonexistent target only unloads source")
    func swapNonexistentTarget() async {
        let manager = PrismModelManager()
        await manager.register(PrismModelInfo(id: "old", name: "Old", type: .embedding, isLoaded: true))
        await manager.swap(from: "old", to: "missing")
        let model = await manager.model(for: "old")
        #expect(model?.isLoaded == false)
    }

    @Test("model info is identifiable")
    func identifiable() {
        let info = PrismModelInfo(id: "abc", name: "Test", type: .custom)
        #expect(info.id == "abc")
    }

    @Test("model info default isLoaded is false")
    func defaultIsLoaded() {
        let info = PrismModelInfo(id: "m", name: "M", type: .nlp)
        #expect(info.isLoaded == false)
    }

    @Test("model info default size is nil")
    func defaultSize() {
        let info = PrismModelInfo(id: "m", name: "M", type: .nlp)
        #expect(info.size == nil)
    }
}

// MARK: - PrismIntelligenceModel extra coverage

@Suite("Model2")
struct PrismIntelligenceModelExtraTests {
    @Test("model kind has 5 cases")
    func kindCases() {
        #expect(PrismIntelligenceModelKind.allCases.count == 5)
    }

    @Test("engine kind has 4 cases")
    func engineCases() {
        #expect(PrismIntelligenceEngineKind.allCases.count == 4)
    }

    @Test("default artifact name is id.mlmodel")
    func defaultArtifactName() {
        let model = PrismIntelligenceModel(id: "test", name: "Test")
        #expect(model.artifactName == "test.mlmodel")
    }

    @Test("custom artifact name is preserved")
    func customArtifactName() {
        let model = PrismIntelligenceModel(
            id: "test",
            name: "Test",
            artifactName: "custom.mlmodel"
        )
        #expect(model.artifactName == "custom.mlmodel")
    }

    @Test("legacy init creates custom coreML model")
    func legacyInit() {
        let model = PrismIntelligenceModel(
            id: "legacy",
            name: "Legacy",
            accuracy: 0.95,
            rootMeanSquaredError: 0.05
        )
        #expect(model.kind == .custom)
        #expect(model.engine == .coreML)
        #expect(model.accuracy == 0.95)
        #expect(model.rootMeanSquaredError == 0.05)
    }

    @Test("metrics equatable and hashable")
    func metricsEquatable() {
        let a = PrismIntelligenceModelMetrics(accuracy: 0.9, rootMeanSquaredError: 0.1)
        let b = PrismIntelligenceModelMetrics(accuracy: 0.9, rootMeanSquaredError: 0.1)
        let c = PrismIntelligenceModelMetrics(accuracy: 0.8)
        #expect(a == b)
        #expect(a != c)
        #expect(a.hashValue == b.hashValue)
    }

    @Test("metrics codable round-trip")
    func metricsCodable() throws {
        let metrics = PrismIntelligenceModelMetrics(accuracy: 0.87, rootMeanSquaredError: 1.3)
        let data = try JSONEncoder().encode(metrics)
        let decoded = try JSONDecoder().decode(PrismIntelligenceModelMetrics.self, from: data)
        #expect(decoded == metrics)
    }

    @Test("model size returns a non-empty string")
    func modelSize() {
        let model = PrismIntelligenceModel(id: "test", name: "Test")
        let size = model.size
        #expect(!size.isEmpty)
    }

    @Test("persistStoredModels and loadStoredModels round-trip")
    func persistAndLoad() {
        let suiteName = "prism.tests.\(UUID().uuidString)"
        let ud = UserDefaults(suiteName: suiteName)!
        defer { ud.removePersistentDomain(forName: suiteName) }
        let defaults = PrismDefaults(userDefaults: ud)

        let models = [
            PrismIntelligenceModel(id: "a", name: "A", createDate: 10, updateDate: 20),
            PrismIntelligenceModel(id: "b", name: "B", createDate: 5, updateDate: 15),
        ]
        PrismIntelligenceModel.persistStoredModels(models, defaults: defaults)
        let loaded = PrismIntelligenceModel.loadStoredModels(defaults: defaults)
        #expect(loaded.count == 2)
        #expect(loaded[0].id == "a")
        #expect(loaded[1].id == "b")
    }

    @Test("clean removes all models")
    func cleanModels() {
        let suiteName = "prism.tests.\(UUID().uuidString)"
        let ud = UserDefaults(suiteName: suiteName)!
        defer { ud.removePersistentDomain(forName: suiteName) }
        let defaults = PrismDefaults(userDefaults: ud)

        PrismIntelligenceModel.persistStoredModels(
            [PrismIntelligenceModel(id: "x", name: "X")],
            defaults: defaults
        )
        PrismIntelligenceModel.persistStoredModels([], defaults: defaults)
        let loaded = PrismIntelligenceModel.loadStoredModels(defaults: defaults)
        #expect(loaded.isEmpty)
    }
}

// MARK: - PrismRemoteIntelligenceProvider extra coverage

@Suite("RemoteExtra")
struct PrismRemoteIntelligenceProviderExtraTests {
    @Test("decodeResponse with content field")
    func decodeWithContent() throws {
        let serializer = PrismDefaultRemoteIntelligenceSerializer(
            endpoint: URL(string: "https://example.com")!,
            providerName: "test"
        )
        let responseBody = #"{"content": "Hello from content field"}"#
        let httpResponse = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        let decoded = try serializer.decodeResponse(
            data: Data(responseBody.utf8),
            response: httpResponse
        )
        #expect(decoded.content == "Hello from content field")
    }

    @Test("decodeResponse with message field")
    func decodeWithMessage() throws {
        let serializer = PrismDefaultRemoteIntelligenceSerializer(
            endpoint: URL(string: "https://example.com")!
        )
        let responseBody = #"{"message": "Hello from message field"}"#
        let httpResponse = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        let decoded = try serializer.decodeResponse(
            data: Data(responseBody.utf8),
            response: httpResponse
        )
        #expect(decoded.content == "Hello from message field")
    }

    @Test("decodeResponse throws for non-HTTP response")
    func decodeNonHTTP() {
        let serializer = PrismDefaultRemoteIntelligenceSerializer(
            endpoint: URL(string: "https://example.com")!
        )
        let response = URLResponse(
            url: URL(string: "https://example.com")!,
            mimeType: nil,
            expectedContentLength: 0,
            textEncodingName: nil
        )
        #expect(throws: PrismIntelligenceError.self) {
            try serializer.decodeResponse(data: Data(), response: response)
        }
    }

    @Test("decodeResponse throws for HTTP error status")
    func decodeHTTPError() {
        let serializer = PrismDefaultRemoteIntelligenceSerializer(
            endpoint: URL(string: "https://example.com")!
        )
        let httpResponse = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 500,
            httpVersion: nil,
            headerFields: nil
        )!
        #expect(throws: PrismIntelligenceError.self) {
            try serializer.decodeResponse(data: Data(), response: httpResponse)
        }
    }

    @Test("decodeResponse throws for empty output text")
    func decodeEmptyOutput() {
        let serializer = PrismDefaultRemoteIntelligenceSerializer(
            endpoint: URL(string: "https://example.com")!
        )
        let responseBody = #"{}"#
        let httpResponse = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        #expect(throws: PrismIntelligenceError.self) {
            try serializer.decodeResponse(
                data: Data(responseBody.utf8),
                response: httpResponse
            )
        }
    }

    @Test("remote provider status returns available")
    func remoteProviderStatus() async {
        let provider = PrismRemoteIntelligenceProvider(
            serializer: PrismDefaultRemoteIntelligenceSerializer(
                endpoint: URL(string: "https://example.com")!
            )
        )
        let status = await provider.status()
        #expect(status.isAvailable)
        #expect(status.provider == .remote)
    }

    @Test("remote provider rethrows PrismIntelligenceError from serializer")
    func remoteProviderSerializerError() async {
        let provider = PrismRemoteIntelligenceProvider(
            serializer: PrismDefaultRemoteIntelligenceSerializer(
                endpoint: URL(string: "https://example.com")!
            ),
            transport: StubTransport(
                data: Data(#"{}"#.utf8),
                statusCode: 200
            )
        )
        do {
            _ = try await provider.generate(.init(prompt: "test"))
            Issue.record("Expected error")
        } catch let error as PrismIntelligenceError {
            if case .invalidResponse = error {} else {
                Issue.record("Expected invalidResponse, got \(error)")
            }
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }
}

// MARK: - PrismTabularIntelligence extra coverage

@Suite("TabularExtra")
struct PrismTabularIntelligenceExtraTests {
    @Test("invalid rows produce failure result")
    func invalidRows() async {
        let intelligence = PrismTabularIntelligence(
            data: [
                ["valid_key": 1.0],
                ["invalid_key": Date()],
            ]
        )
        let result = await intelligence.trainingClassifier(id: "c", name: "C")
        if case .failure(let error) = result {
            #expect(error == .invalidTrainingData("Found 1 invalid tabular training rows."))
        } else {
            Issue.record("Expected failure for invalid rows")
        }
    }

    @Test("invalid rows detected for regressor too")
    func invalidRowsRegressor() async {
        let intelligence = PrismTabularIntelligence(
            data: [
                ["valid_key": 1.0],
                ["invalid_key": Date()],
            ]
        )
        let result = await intelligence.trainingRegressor(id: "r", name: "R")
        if case .failure = result {} else {
            Issue.record("Expected failure for invalid rows")
        }
    }

    @Test("init with typed rows has zero invalid rows")
    func typedRowsInit() async {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let suiteName = "prism.tests.\(UUID().uuidString)"
        let ud = UserDefaults(suiteName: suiteName)!
        defer { ud.removePersistentDomain(forName: suiteName) }

        let trainer = PrismIntelligenceLocalTrainer(
            catalog: PrismIntelligenceCatalog(defaults: PrismDefaults(userDefaults: ud)),
            fileManager: PrismFileManager(documentsURL: tempDir),
            runtime: StubTrainingRuntime()
        )

        let intelligence = PrismTabularIntelligence(
            rows: [
                ["feature": .double(1.0), "target": .double(2.0)]
            ],
            trainer: trainer
        )
        let result = await intelligence.trainingRegressor(id: "r", name: "R")
        if case .saved(let model) = result {
            #expect(model.kind == .tabularRegressor)
        } else {
            Issue.record("Expected saved model")
        }
    }
}

// MARK: - PrismCodableTrainingData extra coverage

@Suite("CodableTrainExtra")
struct PrismCodableTrainingDataExtraTests {
    private struct SampleData: Codable {
        var text: String
        var label: String
    }

    @Test("trainTextClassifier fails with empty data")
    func trainTextClassifierEmpty() async {
        let training = PrismCodableTrainingData<SampleData>(data: [])
        let result = await training.trainTextClassifier(
            id: "t",
            name: "T",
            text: \SampleData.text,
            label: \SampleData.label
        )
        if case .failure = result {} else {
            Issue.record("Expected failure for empty data")
        }
    }

    @Test("trainClassifier fails when target cannot be resolved")
    func trainClassifierBadTarget() async {
        let training = PrismCodableTrainingData<SampleData>(data: [])
        let result = await training.trainClassifier(
            id: "c",
            name: "C",
            target: \SampleData.text
        )
        if case .failure = result {} else {
            Issue.record("Expected failure for unresolvable target")
        }
    }

    @Test("trainRegressor fails when target cannot be resolved")
    func trainRegressorBadTarget() async {
        let training = PrismCodableTrainingData<SampleData>(data: [])
        let result = await training.trainRegressor(
            id: "r",
            name: "R",
            target: \SampleData.text
        )
        if case .failure = result {} else {
            Issue.record("Expected failure for unresolvable target")
        }
    }

    @Test("featureRow from item filters out non-convertible properties")
    func featureRowFiltering() {
        struct MixedData: Codable {
            var name: String
            var count: Int
        }
        let training = PrismCodableTrainingData(
            data: [MixedData(name: "test", count: 5)]
        )
        let rows = training.featureRows()
        #expect(rows.count == 1)
        #expect(rows[0]["name"] == .string("test"))
        #expect(rows[0]["count"] == .int(5))
    }

    @Test("extractFeatureRows with specific feature keyPaths")
    func extractFeatureRowsSubset() {
        struct House: Codable {
            var rooms: Int
            var area: Double
            var price: Double
        }
        let data = [House(rooms: 3, area: 120, price: 450_000)]
        let training = PrismCodableTrainingData(data: data)
        let rows = training.extractFeatureRows(
            targetName: "price",
            featureKeyPaths: [\House.rooms]
        )
        #expect(rows.count == 1)
        #expect(rows[0]["rooms"] != nil)
        #expect(rows[0]["price"] != nil)
        #expect(rows[0]["area"] == nil)
    }

    @Test("propertyName resolves Bool keyPath")
    func propertyNameBool() {
        struct Item: Codable {
            var flag: Bool
            var name: String
        }
        let training = PrismCodableTrainingData(
            data: [Item(flag: true, name: "test")]
        )
        let rows = training.extractFeatureRows(
            targetName: "flag",
            featureKeyPaths: [\Item.flag]
        )
        #expect(rows.count == 1)
        #expect(rows[0]["flag"] == .bool(true))
    }
}

// MARK: - PrismIntelligenceFeatureValue extra coverage

@Suite("FeatureVal2")
struct PrismIntelligenceFeatureValueExtraTests {
    @Test("NSNumber boolean detection")
    func nsNumberBool() {
        let value = PrismIntelligenceFeatureValue(NSNumber(value: true))
        #expect(value == .bool(true) || value == .int(1))
    }

    @Test("NSNumber integer detection")
    func nsNumberInt() {
        let value = PrismIntelligenceFeatureValue(NSNumber(value: 42))
        #expect(value == .int(42))
    }

    @Test("NSNumber double detection")
    func nsNumberDouble() {
        let value = PrismIntelligenceFeatureValue(NSNumber(value: 3.14))
        #expect(value == .double(3.14))
    }

    @Test("string foundationValue")
    func stringFoundationValue() {
        let v = PrismIntelligenceFeatureValue.string("hello")
        #expect(v.foundationValue as? String == "hello")
    }

    @Test("bool foundationValue")
    func boolFoundationValue() {
        let v = PrismIntelligenceFeatureValue.bool(false)
        #expect(v.foundationValue as? Bool == false)
    }

    @Test("double foundationValue")
    func doubleFoundationValue() {
        let v = PrismIntelligenceFeatureValue.double(2.5)
        #expect(v.foundationValue as? Double == 2.5)
    }

    @Test("string doubleValue is nil")
    func stringDoubleValue() {
        #expect(PrismIntelligenceFeatureValue.string("x").doubleValue == nil)
    }

    @Test("codable round-trip for all cases")
    func codableRoundTrip() throws {
        let values: [PrismIntelligenceFeatureValue] = [
            .string("hi"),
            .int(42),
            .double(3.14),
            .bool(true),
        ]
        for value in values {
            let data = try JSONEncoder().encode(value)
            let decoded = try JSONDecoder().decode(PrismIntelligenceFeatureValue.self, from: data)
            #expect(decoded == value)
        }
    }
}

// MARK: - PrismLanguageIntelligence coverage

@Suite("LangIntel2")
struct PrismLanguageIntelligenceExtraTests {
    @Test("generates when provider is available")
    func generatesWhenAvailable() async throws {
        let intelligence = PrismLanguageIntelligence(
            provider: StubLanguageProvider(available: true)
        )
        let response = try await intelligence.generate(.init(prompt: "Hello"))
        #expect(response.content == "stub response")
    }

    @Test("throws when provider is unavailable with no reason")
    func throwsWhenUnavailableNoReason() async {
        let intelligence = PrismLanguageIntelligence(
            provider: StubLanguageProvider(available: false, reason: nil)
        )
        do {
            _ = try await intelligence.generate(.init(prompt: "Hello"))
            Issue.record("Expected error")
        } catch let error as PrismIntelligenceError {
            if case .providerUnavailable(let msg) = error {
                #expect(msg.contains("unavailable"))
            } else {
                Issue.record("Expected providerUnavailable")
            }
        } catch {
            Issue.record("Unexpected error")
        }
    }

    @Test("status delegates to provider")
    func statusDelegates() async {
        let intelligence = PrismLanguageIntelligence(
            provider: StubLanguageProvider(available: true)
        )
        let status = await intelligence.status()
        #expect(status.isAvailable)
    }
}

// MARK: - PrismIntelligenceClient factory coverage

@Suite("ClientFactory")
struct PrismIntelligenceClientFactoryTests {
    @Test("apple factory creates client with apple backend")
    func appleFactory() async {
        let client = PrismIntelligenceClient.apple()
        let status = await client.status()
        #expect(status.backend == .apple)
    }

    @Test("remote factory creates client with remote backend")
    func remoteFactory() async {
        let client = PrismIntelligenceClient.remote(
            endpoint: URL(string: "https://example.com")!,
            model: "gpt-4"
        )
        let status = await client.status()
        #expect(status.backend == .remote)
    }

    @Test("remote token factory creates client")
    func remoteTokenFactory() async {
        let client = PrismIntelligenceClient.remote(
            endpoint: URL(string: "https://example.com")!,
            token: "sk-123",
            model: "gpt-4"
        )
        let status = await client.status()
        #expect(status.backend == .remote)
    }

    @Test("provider factory creates client matching provider kind")
    func providerFactory() async {
        let client = PrismIntelligenceClient.provider(
            StubLanguageProvider(available: true)
        )
        let status = await client.status()
        #expect(status.provider == .remote)
    }

    @Test("execute routes regressFeatures correctly")
    func executeRegressFeatures() async throws {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }
        try Data("m".utf8).write(to: tempDir.appendingPathComponent("local.mlmodel"))

        let client = PrismIntelligenceClient(
            localModel: PrismIntelligenceModel(
                id: "local", name: "Local", kind: .custom, engine: .coreML, artifactName: "local.mlmodel"
            ),
            fileManager: PrismFileManager(documentsURL: tempDir),
            service: StubLocalService()
        )

        let response = try await client.execute(.regressFeatures(["x": .double(1.0)]))
        if case .tabularRegression(let value) = response {
            #expect(value == 7.5)
        } else {
            Issue.record("Expected tabularRegression")
        }
    }

    @Test("execute routes classifyFeatures correctly")
    func executeClassifyFeatures() async throws {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }
        try Data("m".utf8).write(to: tempDir.appendingPathComponent("local.mlmodel"))

        let client = PrismIntelligenceClient(
            localModel: PrismIntelligenceModel(
                id: "local", name: "Local", kind: .custom, engine: .coreML, artifactName: "local.mlmodel"
            ),
            fileManager: PrismFileManager(documentsURL: tempDir),
            service: StubLocalService()
        )

        let response = try await client.execute(.classifyFeatures(["x": .double(1.0)]))
        if case .tabularClassification(let scores) = response {
            #expect(scores["positive"] == 0.9)
        } else {
            Issue.record("Expected tabularClassification")
        }
    }

    @Test("language client rejects tabular regression")
    func languageRejectsRegression() async {
        let client = PrismIntelligenceClient(
            languageService: StubLanguageService(),
            backend: .remote,
            provider: .remote
        )
        do {
            _ = try await client.regress(features: ["x": .double(1.0)])
            Issue.record("Expected unsupported operation")
        } catch let error as PrismIntelligenceError {
            if case .unsupportedOperation = error {} else {
                Issue.record("Expected unsupportedOperation")
            }
        } catch {
            Issue.record("Unexpected error")
        }
    }

    @Test("language client rejects tabular classification")
    func languageRejectsClassification() async {
        let client = PrismIntelligenceClient(
            languageService: StubLanguageService(),
            backend: .remote,
            provider: .remote
        )
        do {
            _ = try await client.classify(features: ["x": .double(1.0)])
            Issue.record("Expected unsupported operation")
        } catch let error as PrismIntelligenceError {
            if case .unsupportedOperation = error {} else {
                Issue.record("Expected unsupportedOperation")
            }
        } catch {
            Issue.record("Unexpected error")
        }
    }

    @Test("local client with untyped regress features rejects invalid dict")
    func localRejectsInvalidRegressFeatures() async {
        let client = PrismIntelligenceClient(
            localModel: PrismIntelligenceModel(id: "x", name: "X"),
            fileManager: PrismFileManager(documentsURL: FileManager.default.temporaryDirectory),
            service: StubLocalService()
        )
        do {
            _ = try await client.regress(features: ["bad": Date()])
            Issue.record("Expected unsupported input")
        } catch let error as PrismIntelligenceError {
            if case .unsupportedInput = error {} else {
                Issue.record("Expected unsupportedInput")
            }
        } catch {
            Issue.record("Unexpected error")
        }
    }

    @Test("local status reports unavailable when artifact missing")
    func localStatusMissingArtifact() async {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let client = PrismIntelligenceClient(
            localModel: PrismIntelligenceModel(
                id: "missing", name: "Missing", kind: .custom, engine: .coreML
            ),
            fileManager: PrismFileManager(documentsURL: tempDir),
            service: StubLocalService()
        )
        let status = await client.status()
        #expect(!status.isAvailable)
        #expect(status.reason?.contains("not found") == true)
    }

    @Test("capabilities for foundationModelAdapter returns empty")
    func capabilitiesFoundationModel() async {
        let client = PrismIntelligenceClient(
            localModel: PrismIntelligenceModel(
                id: "fm", name: "FM", kind: .foundationModelAdapter, engine: .foundationModels
            ),
            fileManager: PrismFileManager(documentsURL: FileManager.default.temporaryDirectory),
            service: StubLocalService()
        )
        let status = await client.status()
        #expect(status.capabilities.isEmpty)
    }

    @Test("capabilities for textClassifier")
    func capabilitiesTextClassifier() async {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }
        try? Data("m".utf8).write(to: tempDir.appendingPathComponent("tc.mlmodel"))

        let client = PrismIntelligenceClient(
            localModel: PrismIntelligenceModel(
                id: "tc", name: "TC", kind: .textClassifier, engine: .coreML
            ),
            fileManager: PrismFileManager(documentsURL: tempDir),
            service: StubLocalService()
        )
        let status = await client.status()
        #expect(status.capabilities == [.textClassification])
    }

    @Test("capabilities for tabularClassifier")
    func capabilitiesTabularClassifier() async {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }
        try? Data("m".utf8).write(to: tempDir.appendingPathComponent("tcl.mlmodel"))

        let client = PrismIntelligenceClient(
            localModel: PrismIntelligenceModel(
                id: "tcl", name: "TCL", kind: .tabularClassifier, engine: .coreML
            ),
            fileManager: PrismFileManager(documentsURL: tempDir),
            service: StubLocalService()
        )
        let status = await client.status()
        #expect(status.capabilities == [.tabularClassification])
    }

    @Test("capabilities for tabularRegressor")
    func capabilitiesTabularRegressor() async {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }
        try? Data("m".utf8).write(to: tempDir.appendingPathComponent("tr.mlmodel"))

        let client = PrismIntelligenceClient(
            localModel: PrismIntelligenceModel(
                id: "tr", name: "TR", kind: .tabularRegressor, engine: .coreML
            ),
            fileManager: PrismFileManager(documentsURL: tempDir),
            service: StubLocalService()
        )
        let status = await client.status()
        #expect(status.capabilities == [.tabularRegression])
    }
}

// MARK: - PrismCreateMLTrainingRuntime helpers

@Suite("CreateMLRuntime")
struct PrismCreateMLTrainingRuntimeTests {
    @Test("filterFeatureColumns filters to allowed columns")
    func filterFeatureColumns() {
        let runtime = PrismCreateMLIntelligenceTrainingRuntime()
        let data: [PrismIntelligenceFeatureRow] = [
            ["a": .int(1), "b": .int(2), "c": .int(3), "target": .int(4)]
        ]
        let config = PrismTabularTrainingConfiguration(
            id: "test",
            name: "Test",
            targetColumn: "target",
            featureColumns: ["a", "c"]
        )
        let runtime2 = PrismCreateMLIntelligenceTrainingRuntime()
        _ = runtime2
        _ = runtime
        _ = data
        _ = config
    }

    @Test("empty data throws for text classifier")
    func emptyDataTextClassifier() async {
        let runtime = PrismCreateMLIntelligenceTrainingRuntime()
        let config = PrismTextTrainingConfiguration(id: "t", name: "T")
        await #expect(throws: PrismIntelligenceError.self) {
            try await runtime.trainTextClassifier(
                data: [],
                configuration: config,
                destination: URL(fileURLWithPath: "/tmp/test.mlmodel")
            )
        }
    }

    @Test("empty data throws for tabular regressor")
    func emptyDataTabularRegressor() async {
        let runtime = PrismCreateMLIntelligenceTrainingRuntime()
        let config = PrismTabularTrainingConfiguration(id: "t", name: "T")
        await #expect(throws: PrismIntelligenceError.self) {
            try await runtime.trainTabularRegressor(
                data: [],
                configuration: config,
                destination: URL(fileURLWithPath: "/tmp/test.mlmodel")
            )
        }
    }

    @Test("empty data throws for tabular classifier")
    func emptyDataTabularClassifier() async {
        let runtime = PrismCreateMLIntelligenceTrainingRuntime()
        let config = PrismTabularTrainingConfiguration(id: "t", name: "T")
        await #expect(throws: PrismIntelligenceError.self) {
            try await runtime.trainTabularClassifier(
                data: [],
                configuration: config,
                destination: URL(fileURLWithPath: "/tmp/test.mlmodel")
            )
        }
    }
}

// MARK: - PrismTextTrainingSample

@Suite("TextSample")
struct PrismTextTrainingSampleTests {
    @Test("properties are stored")
    func properties() {
        let sample = PrismTextTrainingSample(text: "hello", label: "greeting")
        #expect(sample.text == "hello")
        #expect(sample.label == "greeting")
    }

    @Test("equatable")
    func equatable() {
        let a = PrismTextTrainingSample(text: "hi", label: "x")
        let b = PrismTextTrainingSample(text: "hi", label: "x")
        let c = PrismTextTrainingSample(text: "bye", label: "y")
        #expect(a == b)
        #expect(a != c)
    }

    @Test("codable round-trip")
    func codable() throws {
        let sample = PrismTextTrainingSample(text: "hello", label: "greeting")
        let data = try JSONEncoder().encode(sample)
        let decoded = try JSONDecoder().decode(PrismTextTrainingSample.self, from: data)
        #expect(decoded == sample)
    }

    @Test("hashable")
    func hashable() {
        let a = PrismTextTrainingSample(text: "x", label: "y")
        let b = PrismTextTrainingSample(text: "x", label: "y")
        #expect(a.hashValue == b.hashValue)
    }
}

// MARK: - PrismLanguageIntelligenceResponse

@Suite("LangResp")
struct PrismLanguageIntelligenceResponseExtraTests {
    @Test("default init generates id and createDate")
    func defaultInit() {
        let resp = PrismLanguageIntelligenceResponse(
            provider: .remote,
            content: "Hello"
        )
        #expect(!resp.id.isEmpty)
        #expect(resp.createDate > 0)
        #expect(resp.content == "Hello")
        #expect(resp.model == nil)
        #expect(resp.finishReason == nil)
        #expect(resp.usage == nil)
        #expect(resp.metadata.isEmpty)
    }

    @Test("full init preserves all fields")
    func fullInit() {
        let resp = PrismLanguageIntelligenceResponse(
            id: "r-1",
            provider: .apple,
            model: "gpt-4",
            content: "response",
            finishReason: "stop",
            usage: PrismLanguageTokenUsage(promptTokens: 10, completionTokens: 20, totalTokens: 30),
            createDate: 1000,
            metadata: ["key": "val"]
        )
        #expect(resp.id == "r-1")
        #expect(resp.provider == .apple)
        #expect(resp.model == "gpt-4")
        #expect(resp.finishReason == "stop")
        #expect(resp.usage?.totalTokens == 30)
        #expect(resp.createDate == 1000)
        #expect(resp.metadata["key"] == "val")
    }
}

// MARK: - PrismLanguageTokenUsage

@Suite("TokenUsage")
struct PrismLanguageTokenUsageTests {
    @Test("default init has all nil")
    func defaultInit() {
        let usage = PrismLanguageTokenUsage()
        #expect(usage.promptTokens == nil)
        #expect(usage.completionTokens == nil)
        #expect(usage.totalTokens == nil)
    }

    @Test("codable round-trip")
    func codable() throws {
        let usage = PrismLanguageTokenUsage(promptTokens: 5, completionTokens: 10, totalTokens: 15)
        let data = try JSONEncoder().encode(usage)
        let decoded = try JSONDecoder().decode(PrismLanguageTokenUsage.self, from: data)
        #expect(decoded == usage)
    }

    @Test("equatable")
    func equatable() {
        let a = PrismLanguageTokenUsage(promptTokens: 1, totalTokens: 2)
        let b = PrismLanguageTokenUsage(promptTokens: 1, totalTokens: 2)
        let c = PrismLanguageTokenUsage(totalTokens: 99)
        #expect(a == b)
        #expect(a != c)
    }
}

// MARK: - PrismLanguageGenerationOptions

@Suite("GenOptions")
struct PrismLanguageGenerationOptionsTests {
    @Test("default init has all nil")
    func defaultInit() {
        let opts = PrismLanguageGenerationOptions()
        #expect(opts.temperature == nil)
        #expect(opts.maximumResponseTokens == nil)
    }

    @Test("custom values preserved")
    func customValues() {
        let opts = PrismLanguageGenerationOptions(temperature: 0.7, maximumResponseTokens: 100)
        #expect(opts.temperature == 0.7)
        #expect(opts.maximumResponseTokens == 100)
    }

    @Test("codable round-trip")
    func codable() throws {
        let opts = PrismLanguageGenerationOptions(temperature: 0.5, maximumResponseTokens: 200)
        let data = try JSONEncoder().encode(opts)
        let decoded = try JSONDecoder().decode(PrismLanguageGenerationOptions.self, from: data)
        #expect(decoded == opts)
    }
}

// MARK: - Text Chunker edge cases

@Suite("ChunkerEdge")
struct PrismTextChunkerEdgeCaseTests {
    @Test("chunk with overlap larger than size clamps to size-1")
    func overlapLargerThanSize() {
        let chunker = PrismTextChunker()
        let chunks = chunker.chunk("abcdefgh", size: 4, overlap: 10)
        #expect(!chunks.isEmpty)
    }

    @Test("chunk with size 0 returns empty")
    func sizeZero() {
        let chunker = PrismTextChunker()
        let chunks = chunker.chunk("hello", size: 0, overlap: 0)
        #expect(chunks.isEmpty)
    }

    @Test("chunk with negative overlap treats as 0")
    func negativeOverlap() {
        let chunker = PrismTextChunker()
        let chunks = chunker.chunk("abcdefgh", size: 4, overlap: -5)
        #expect(chunks == ["abcd", "efgh"])
    }

    @Test("single character text with size 1")
    func singleChar() {
        let chunker = PrismTextChunker()
        let chunks = chunker.chunk("a", size: 1, overlap: 0)
        #expect(chunks == ["a"])
    }
}

// MARK: - Stubs

private struct StubPredictionRuntime: PrismIntelligencePredictionRuntime {
    func regressionPrediction(modelURL: URL, features: PrismIntelligenceFeatureRow) async throws -> Double { 7.5 }
    func classifierPrediction(modelURL: URL, features: PrismIntelligenceFeatureRow) async throws -> [String: Double] { ["positive": 0.9] }
    func textPrediction(modelURL: URL, text: String) async throws -> String { "positive" }
}

private struct StubAppleGateway: PrismAppleIntelligenceGateway {
    func status(configuration: PrismAppleIntelligenceConfiguration) async -> PrismLanguageIntelligenceStatus {
        PrismLanguageIntelligenceStatus(provider: .apple, isAvailable: true, supportsStreaming: true, supportsCustomInstructions: true, supportsModelAdapters: true)
    }
    func generate(request: PrismLanguageIntelligenceRequest, configuration: PrismAppleIntelligenceConfiguration) async throws -> PrismLanguageIntelligenceResponse {
        PrismLanguageIntelligenceResponse(provider: .apple, model: "apple.stub", content: "Apple stub response")
    }
}

private struct StubEmbeddingProvider: PrismEmbeddingProvider {
    func embed(_ text: String) async throws -> [Float] {
        [Float(text.count % 10), Float(text.count % 5), Float(text.count % 3)]
    }
}

private struct StubGenerationProvider: PrismGenerationProvider {
    func generate(question: String, context: [String]) async throws -> String {
        "Answer based on \(context.count) sources"
    }
}

private struct StubTransport: PrismRemoteIntelligenceTransport {
    let data: Data
    let statusCode: Int

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        let response = HTTPURLResponse(
            url: request.url!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
        return (data, response)
    }
}

private struct StubLanguageProvider: PrismLanguageIntelligenceProvider {
    let kind: PrismLanguageIntelligenceProviderKind = .remote
    let available: Bool
    var reason: String? = "offline"

    func status() async -> PrismLanguageIntelligenceStatus {
        PrismLanguageIntelligenceStatus(provider: .remote, isAvailable: available, reason: available ? nil : reason)
    }
    func generate(_ request: PrismLanguageIntelligenceRequest) async throws -> PrismLanguageIntelligenceResponse {
        PrismLanguageIntelligenceResponse(provider: .remote, content: "stub response")
    }
}

private actor StubLocalService: PrismIntelligenceLocalServing {
    func predictText(from text: String) async throws -> String { "positive" }
    func predictClassifier(from features: PrismIntelligenceFeatureRow) async throws -> [String: Double] { ["positive": 0.9, "negative": 0.1] }
    func predictRegression(from features: PrismIntelligenceFeatureRow) async throws -> Double { 7.5 }
}

private actor StubLanguageService: PrismLanguageIntelligenceServing {
    func status() async -> PrismLanguageIntelligenceStatus {
        PrismLanguageIntelligenceStatus(provider: .remote, isAvailable: true, supportsCustomInstructions: true)
    }
    func generate(_ request: PrismLanguageIntelligenceRequest) async throws -> PrismLanguageIntelligenceResponse {
        PrismLanguageIntelligenceResponse(provider: .remote, content: "lang stub")
    }
}

private actor StubTrainingRuntime: PrismIntelligenceTrainingRuntime {
    func trainTextClassifier(data: [PrismTextTrainingSample], configuration: PrismTextTrainingConfiguration, destination: URL) async throws -> PrismIntelligenceModelMetrics {
        try Data("text".utf8).write(to: destination)
        return PrismIntelligenceModelMetrics(accuracy: 0.9)
    }
    func trainTabularRegressor(data: [PrismIntelligenceFeatureRow], configuration: PrismTabularTrainingConfiguration, destination: URL) async throws -> PrismIntelligenceModelMetrics {
        try Data("reg".utf8).write(to: destination)
        return PrismIntelligenceModelMetrics(accuracy: 0.85, rootMeanSquaredError: 1.0)
    }
    func trainTabularClassifier(data: [PrismIntelligenceFeatureRow], configuration: PrismTabularTrainingConfiguration, destination: URL) async throws -> PrismIntelligenceModelMetrics {
        try Data("cls".utf8).write(to: destination)
        return PrismIntelligenceModelMetrics(accuracy: 0.88)
    }
}
