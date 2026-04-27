//
//  PrismIntelligenceClient.swift
//  Prism
//
//  Created by Rafael Escaleira on 11/04/26.
//

import Foundation
import PrismFoundation

/// The kind of intelligence backend.
public enum PrismIntelligenceBackendKind: String, Codable, Sendable, CaseIterable {
    /// On-device inference using a Core ML or CreateML model artifact.
    case local
    /// Apple Intelligence via the FoundationModels framework.
    case apple
    /// A remote language model accessed over the network.
    case remote
}

/// Capabilities of an intelligence backend.
public enum PrismIntelligenceCapability: String, Codable, Sendable, CaseIterable {
    /// Classifying free-form text into discrete labels.
    case textClassification
    /// Classifying tabular feature rows into discrete labels.
    case tabularClassification
    /// Predicting a continuous numeric value from tabular features.
    case tabularRegression
    /// Generating natural-language text from a prompt.
    case languageGeneration
}

/// Availability status and capabilities of a backend.
public struct PrismIntelligenceStatus: Codable, Equatable, Hashable, Sendable {
    /// The kind of backend this status describes.
    public var backend: PrismIntelligenceBackendKind
    /// Whether the backend is ready to accept requests.
    public var isAvailable: Bool
    /// A human-readable explanation when the backend is unavailable.
    public var reason: String?
    /// The set of capabilities the backend supports.
    public var capabilities: [PrismIntelligenceCapability]
    /// The identifier of the model served by this backend, if applicable.
    public var modelID: String?
    /// The display name of the model, if applicable.
    public var modelName: String?
    /// The language-intelligence provider kind, for Apple or remote backends.
    public var provider: PrismLanguageIntelligenceProviderKind?
    /// Whether the backend supports streaming responses.
    public var supportsStreaming: Bool
    /// Whether the backend supports custom system instructions.
    public var supportsCustomInstructions: Bool
    /// Whether the backend supports model adapters.
    public var supportsModelAdapters: Bool

    /// Creates a new backend status.
    ///
    /// - Parameters:
    ///   - backend: The kind of backend.
    ///   - isAvailable: Whether the backend is ready.
    ///   - reason: An optional explanation when unavailable.
    ///   - capabilities: The supported capabilities.
    ///   - modelID: An optional model identifier.
    ///   - modelName: An optional model display name.
    ///   - provider: An optional language-intelligence provider kind.
    ///   - supportsStreaming: Whether streaming is supported.
    ///   - supportsCustomInstructions: Whether custom instructions are supported.
    ///   - supportsModelAdapters: Whether model adapters are supported.
    public init(
        backend: PrismIntelligenceBackendKind,
        isAvailable: Bool,
        reason: String? = nil,
        capabilities: [PrismIntelligenceCapability],
        modelID: String? = nil,
        modelName: String? = nil,
        provider: PrismLanguageIntelligenceProviderKind? = nil,
        supportsStreaming: Bool = false,
        supportsCustomInstructions: Bool = false,
        supportsModelAdapters: Bool = false
    ) {
        self.backend = backend
        self.isAvailable = isAvailable
        self.reason = reason
        self.capabilities = capabilities
        self.modelID = modelID
        self.modelName = modelName
        self.provider = provider
        self.supportsStreaming = supportsStreaming
        self.supportsCustomInstructions = supportsCustomInstructions
        self.supportsModelAdapters = supportsModelAdapters
    }
}

/// An intelligence request (classification, regression, or generation).
public enum PrismIntelligenceRequest: Sendable, Equatable {
    /// Classify free-form text into a label.
    case classifyText(String)
    /// Classify a tabular feature row into label probabilities.
    case classifyFeatures(PrismIntelligenceFeatureRow)
    /// Predict a continuous value from a tabular feature row.
    case regressFeatures(PrismIntelligenceFeatureRow)
    /// Generate natural-language text from a language request.
    case generate(PrismLanguageIntelligenceRequest)
}

/// An intelligence response.
public enum PrismIntelligenceResponse: Sendable, Equatable {
    /// A predicted text label from a text classifier.
    case textClassification(String)
    /// Label probabilities from a tabular classifier.
    case tabularClassification([String: Double])
    /// A predicted continuous value from a tabular regressor.
    case tabularRegression(Double)
    /// A generated language response.
    case language(PrismLanguageIntelligenceResponse)

    /// The textual content of the response, if applicable.
    ///
    /// Returns the classification label for ``textClassification`` or the generated
    /// content for ``language``. Returns `nil` for tabular results.
    public var text: String? {
        switch self {
        case .textClassification(let value):
            value
        case .language(let response):
            response.content
        case .tabularClassification, .tabularRegression:
            nil
        }
    }
}

internal protocol PrismIntelligenceLocalServing: Sendable {
    func predictText(from text: String) async throws -> String
    func predictClassifier(
        from features: PrismIntelligenceFeatureRow
    ) async throws -> [String: Double]
    func predictRegression(
        from features: PrismIntelligenceFeatureRow
    ) async throws -> Double
}

internal protocol PrismLanguageIntelligenceServing: Sendable {
    func status() async -> PrismLanguageIntelligenceStatus
    func generate(
        _ request: PrismLanguageIntelligenceRequest
    ) async throws -> PrismLanguageIntelligenceResponse
}

extension PrismIntelligencePrediction: PrismIntelligenceLocalServing {}
extension PrismLanguageIntelligence: PrismLanguageIntelligenceServing {}

/// A unified facade for intelligence: local, Apple, and remote.
///
/// `PrismIntelligenceClient` is the primary entry point for running predictions and
/// generating text. Create a client with one of the factory methods, then call
/// ``status()``, ``classify(text:)``, ``regress(features:)-5v8wn``, or ``generate(_:)-4kb7s``.
///
/// ```swift
/// // Local text classification
/// let client = try await PrismIntelligenceClient.local(modelID: "sentiment")
/// let label = try await client.classify(text: "I love this product!")
///
/// // Apple Intelligence generation
/// let apple = PrismIntelligenceClient.apple()
/// let answer = try await apple.generate("Summarize quantum computing.")
///
/// // Remote provider generation
/// let remote = PrismIntelligenceClient.remote(endpoint: url)
/// let response = try await remote.generate("Hello, world!")
/// ```
public actor PrismIntelligenceClient {
    private enum Backend {
        case local(
            model: PrismIntelligenceModel,
            fileManager: PrismFileManager,
            service: any PrismIntelligenceLocalServing
        )
        case language(
            backend: PrismIntelligenceBackendKind,
            provider: PrismLanguageIntelligenceProviderKind,
            service: any PrismLanguageIntelligenceServing
        )
    }

    private let backend: Backend

    /// Creates a client backed by an on-device Core ML model.
    ///
    /// - Parameters:
    ///   - model: The intelligence model descriptor.
    ///   - fileManager: The file manager used to resolve model artifacts.
    /// - Returns: A configured ``PrismIntelligenceClient`` for local inference.
    public static func local(
        model: PrismIntelligenceModel,
        fileManager: PrismFileManager = .init()
    ) async -> PrismIntelligenceClient {
        let service = await PrismIntelligencePrediction(
            model: model,
            fileManager: fileManager
        )
        return PrismIntelligenceClient(
            localModel: model,
            fileManager: fileManager,
            service: service
        )
    }

    /// Creates a client backed by an on-device model resolved from the catalog by identifier.
    ///
    /// - Parameters:
    ///   - modelID: The unique identifier of the model in the catalog.
    ///   - catalog: The catalog to search.
    ///   - fileManager: The file manager used to resolve model artifacts.
    /// - Returns: A configured ``PrismIntelligenceClient`` for local inference.
    /// - Throws: ``PrismIntelligenceError/modelNotFound(_:)`` if the identifier is not in the catalog.
    public static func local(
        modelID: String,
        catalog: PrismIntelligenceCatalog = .init(),
        fileManager: PrismFileManager = .init()
    ) async throws -> PrismIntelligenceClient {
        guard let model = await catalog.model(id: modelID) else {
            throw PrismIntelligenceError.modelNotFound(modelID)
        }

        return await local(
            model: model,
            fileManager: fileManager
        )
    }

    /// Creates a client backed by Apple Intelligence via the FoundationModels framework.
    ///
    /// - Parameter configuration: The Apple Intelligence configuration (model reference and instructions).
    /// - Returns: A configured ``PrismIntelligenceClient`` for Apple Intelligence generation.
    public static func apple(
        configuration: PrismAppleIntelligenceConfiguration = .init()
    ) -> PrismIntelligenceClient {
        let provider = PrismAppleIntelligenceProvider(
            configuration: configuration
        )
        let service = PrismLanguageIntelligence(provider: provider)

        return PrismIntelligenceClient(
            languageService: service,
            backend: .apple,
            provider: .apple
        )
    }

    /// Creates a client backed by a remote language model endpoint.
    ///
    /// Uses the default serializer (``PrismDefaultRemoteIntelligenceSerializer``) to encode
    /// requests and decode responses.
    ///
    /// - Parameters:
    ///   - endpoint: The URL of the remote inference endpoint.
    ///   - model: An optional model identifier sent to the remote API.
    ///   - providerName: A label for the remote provider, used in response metadata.
    ///   - headers: Additional HTTP headers included with every request.
    ///   - timeout: The request timeout interval in seconds.
    ///   - transport: The networking transport used to perform HTTP requests.
    /// - Returns: A configured ``PrismIntelligenceClient`` for remote generation.
    public static func remote(
        endpoint: URL,
        model: String? = nil,
        providerName: String = "remote",
        headers: [String: String] = [:],
        timeout: TimeInterval = 60,
        transport: any PrismRemoteIntelligenceTransport = PrismURLSessionRemoteIntelligenceTransport()
    ) -> PrismIntelligenceClient {
        let serializer = PrismDefaultRemoteIntelligenceSerializer(
            endpoint: endpoint,
            model: model,
            providerName: providerName,
            headers: headers,
            timeout: timeout
        )

        return remote(
            serializer: serializer,
            transport: transport
        )
    }

    /// Creates a client backed by a remote language model with Bearer token authentication.
    ///
    /// This is a convenience factory that automatically sets the `Authorization: Bearer <token>` header.
    ///
    /// - Parameters:
    ///   - endpoint: The URL of the remote inference endpoint.
    ///   - token: The authentication token sent as a Bearer token.
    ///   - model: An optional model identifier sent to the remote API.
    ///   - providerName: A label for the remote provider. Defaults to `"remote"`.
    ///   - timeout: The request timeout interval in seconds. Defaults to 60.
    ///   - transport: The networking transport used to perform HTTP requests.
    /// - Returns: A configured ``PrismIntelligenceClient`` for remote generation.
    public static func remote(
        endpoint: URL,
        token: String,
        model: String? = nil,
        providerName: String = "remote",
        timeout: TimeInterval = 60,
        transport: any PrismRemoteIntelligenceTransport = PrismURLSessionRemoteIntelligenceTransport()
    ) -> PrismIntelligenceClient {
        remote(
            endpoint: endpoint,
            model: model,
            providerName: providerName,
            headers: ["Authorization": "Bearer \(token)"],
            timeout: timeout,
            transport: transport
        )
    }

    /// Creates a client backed by a remote language model using a custom serializer.
    ///
    /// - Parameters:
    ///   - serializer: A serializer that converts requests and responses for the remote API.
    ///   - transport: The networking transport used to perform HTTP requests.
    /// - Returns: A configured ``PrismIntelligenceClient`` for remote generation.
    public static func remote(
        serializer: any PrismRemoteIntelligenceSerializer,
        transport: any PrismRemoteIntelligenceTransport = PrismURLSessionRemoteIntelligenceTransport()
    ) -> PrismIntelligenceClient {
        let provider = PrismRemoteIntelligenceProvider(
            serializer: serializer,
            transport: transport
        )
        let service = PrismLanguageIntelligence(provider: provider)

        return PrismIntelligenceClient(
            languageService: service,
            backend: .remote,
            provider: .remote
        )
    }

    /// Creates a client backed by a custom language-intelligence provider.
    ///
    /// The backend kind is inferred from ``PrismLanguageIntelligenceProvider/kind``.
    ///
    /// - Parameter provider: A conforming language-intelligence provider.
    /// - Returns: A configured ``PrismIntelligenceClient``.
    public static func provider(
        _ provider: any PrismLanguageIntelligenceProvider
    ) -> PrismIntelligenceClient {
        let service = PrismLanguageIntelligence(provider: provider)
        let backend: PrismIntelligenceBackendKind =
            switch provider.kind {
            case .apple:
                .apple
            case .remote:
                .remote
            }

        return PrismIntelligenceClient(
            languageService: service,
            backend: backend,
            provider: provider.kind
        )
    }

    init(
        localModel: PrismIntelligenceModel,
        fileManager: PrismFileManager,
        service: any PrismIntelligenceLocalServing
    ) {
        self.backend = .local(
            model: localModel,
            fileManager: fileManager,
            service: service
        )
    }

    init(
        languageService: any PrismLanguageIntelligenceServing,
        backend: PrismIntelligenceBackendKind,
        provider: PrismLanguageIntelligenceProviderKind
    ) {
        self.backend = .language(
            backend: backend,
            provider: provider,
            service: languageService
        )
    }

    /// Returns the current availability status and capabilities of the backend.
    ///
    /// - Returns: A ``PrismIntelligenceStatus`` describing availability and supported capabilities.
    public func status() async -> PrismIntelligenceStatus {
        switch backend {
        case .local(let model, let fileManager, _):
            let isSupportedEngine = model.engine == .coreML || model.engine == .createML
            let artifactURL = model.artifactURL(fileManager: fileManager)
            let artifactExists =
                artifactURL.map {
                    FileManager.default.fileExists(atPath: $0.path)
                } ?? false

            return PrismIntelligenceStatus(
                backend: .local,
                isAvailable: isSupportedEngine && artifactExists,
                reason: localAvailabilityReason(
                    for: model,
                    isSupportedEngine: isSupportedEngine,
                    artifactExists: artifactExists
                ),
                capabilities: capabilities(for: model),
                modelID: model.id,
                modelName: model.name
            )

        case .language(let backend, let provider, let service):
            let status = await service.status()
            return PrismIntelligenceStatus(
                backend: backend,
                isAvailable: status.isAvailable,
                reason: status.reason,
                capabilities: [.languageGeneration],
                provider: provider,
                supportsStreaming: status.supportsStreaming,
                supportsCustomInstructions: status.supportsCustomInstructions,
                supportsModelAdapters: status.supportsModelAdapters
            )
        }
    }

    /// Executes an intelligence request and returns the corresponding response.
    ///
    /// This method dispatches to the appropriate prediction or generation method
    /// based on the request case.
    ///
    /// - Parameter request: The intelligence request to execute.
    /// - Returns: A ``PrismIntelligenceResponse`` matching the request type.
    /// - Throws: ``PrismIntelligenceError`` if the operation is unsupported or fails.
    public func execute(
        _ request: PrismIntelligenceRequest
    ) async throws -> PrismIntelligenceResponse {
        switch request {
        case .classifyText(let text):
            return .textClassification(
                try await classify(text: text)
            )
        case .classifyFeatures(let features):
            return .tabularClassification(
                try await classify(features: features)
            )
        case .regressFeatures(let features):
            return .tabularRegression(
                try await regress(features: features)
            )
        case .generate(let request):
            return .language(
                try await generate(request)
            )
        }
    }

    /// Classifies free-form text into a label using the local model.
    ///
    /// - Parameter text: The text to classify.
    /// - Returns: The predicted label.
    /// - Throws: ``PrismIntelligenceError/unsupportedOperation(_:)`` if the backend is not local.
    public func classify(
        text: String
    ) async throws -> String {
        switch backend {
        case .local(_, _, let service):
            return try await service.predictText(from: text)
        case .language(let backend, _, _):
            throw PrismIntelligenceError.unsupportedOperation(
                "Text classification is not supported by the \(backend.rawValue) backend."
            )
        }
    }

    /// Classifies a tabular feature row into label probabilities using the local model.
    ///
    /// - Parameter features: A dictionary of feature names to values.
    /// - Returns: A dictionary mapping labels to their predicted probabilities.
    /// - Throws: ``PrismIntelligenceError/unsupportedOperation(_:)`` if the backend is not local.
    public func classify(
        features: PrismIntelligenceFeatureRow
    ) async throws -> [String: Double] {
        switch backend {
        case .local(_, _, let service):
            return try await service.predictClassifier(from: features)
        case .language(let backend, _, _):
            throw PrismIntelligenceError.unsupportedOperation(
                "Tabular classification is not supported by the \(backend.rawValue) backend."
            )
        }
    }

    /// Classifies an untyped feature dictionary into label probabilities.
    ///
    /// The dictionary values are converted to ``PrismIntelligenceFeatureValue`` automatically.
    ///
    /// - Parameter features: A dictionary of feature names to untyped values.
    /// - Returns: A dictionary mapping labels to their predicted probabilities.
    /// - Throws: ``PrismIntelligenceError/unsupportedInput(_:)`` if conversion fails.
    public func classify(
        features: [String: Any]
    ) async throws -> [String: Double] {
        guard let converted = features.intelligenceFeatures else {
            throw PrismIntelligenceError.unsupportedInput(
                "Could not convert feature dictionary into supported values."
            )
        }

        return try await classify(features: converted)
    }

    /// Predicts a continuous value from a tabular feature row using the local model.
    ///
    /// - Parameter features: A dictionary of feature names to values.
    /// - Returns: The predicted numeric value.
    /// - Throws: ``PrismIntelligenceError/unsupportedOperation(_:)`` if the backend is not local.
    public func regress(
        features: PrismIntelligenceFeatureRow
    ) async throws -> Double {
        switch backend {
        case .local(_, _, let service):
            return try await service.predictRegression(from: features)
        case .language(let backend, _, _):
            throw PrismIntelligenceError.unsupportedOperation(
                "Tabular regression is not supported by the \(backend.rawValue) backend."
            )
        }
    }

    /// Predicts a continuous value from an untyped feature dictionary.
    ///
    /// The dictionary values are converted to ``PrismIntelligenceFeatureValue`` automatically.
    ///
    /// - Parameter features: A dictionary of feature names to untyped values.
    /// - Returns: The predicted numeric value.
    /// - Throws: ``PrismIntelligenceError/unsupportedInput(_:)`` if conversion fails.
    public func regress(
        features: [String: Any]
    ) async throws -> Double {
        guard let converted = features.intelligenceFeatures else {
            throw PrismIntelligenceError.unsupportedInput(
                "Could not convert feature dictionary into supported values."
            )
        }

        return try await regress(features: converted)
    }

    /// Generates text from a prompt string using the language backend.
    ///
    /// This is a convenience wrapper that builds a ``PrismLanguageIntelligenceRequest``
    /// and returns just the response content.
    ///
    /// - Parameters:
    ///   - prompt: The user prompt.
    ///   - systemPrompt: An optional system-level instruction.
    ///   - context: Additional context strings prepended to the prompt.
    ///   - options: Generation options such as temperature and token limits.
    ///   - metadata: Arbitrary key-value metadata forwarded to the provider.
    /// - Returns: The generated text content.
    /// - Throws: ``PrismIntelligenceError/unsupportedOperation(_:)`` if the backend is local.
    public func generate(
        _ prompt: String,
        systemPrompt: String? = nil,
        context: [String] = [],
        options: PrismLanguageGenerationOptions = .init(),
        metadata: [String: String] = [:]
    ) async throws -> String {
        let response = try await generate(
            PrismLanguageIntelligenceRequest(
                prompt: prompt,
                systemPrompt: systemPrompt,
                context: context,
                options: options,
                metadata: metadata
            )
        )

        return response.content
    }

    /// Generates a full language response from a structured request.
    ///
    /// - Parameter request: The language-intelligence request.
    /// - Returns: A ``PrismLanguageIntelligenceResponse`` containing the generated content and metadata.
    /// - Throws: ``PrismIntelligenceError/unsupportedOperation(_:)`` if the backend is local.
    public func generate(
        _ request: PrismLanguageIntelligenceRequest
    ) async throws -> PrismLanguageIntelligenceResponse {
        switch backend {
        case .local(let model, _, _):
            throw PrismIntelligenceError.unsupportedOperation(
                "Language generation is not supported by the local model \(model.id)."
            )
        case .language(_, _, let service):
            return try await service.generate(request)
        }
    }

    private func localAvailabilityReason(
        for model: PrismIntelligenceModel,
        isSupportedEngine: Bool,
        artifactExists: Bool
    ) -> String? {
        if !isSupportedEngine {
            return "Local inference only supports Core ML compatible models."
        }

        if !artifactExists {
            return "Model artifact not found: \(model.artifactName)"
        }

        return nil
    }

    private func capabilities(
        for model: PrismIntelligenceModel
    ) -> [PrismIntelligenceCapability] {
        switch model.kind {
        case .textClassifier:
            [.textClassification]
        case .tabularClassifier:
            [.tabularClassification]
        case .tabularRegressor:
            [.tabularRegression]
        case .custom:
            [
                .textClassification,
                .tabularClassification,
                .tabularRegression,
            ]
        case .foundationModelAdapter:
            []
        }
    }
}

extension Dictionary where Key == String, Value == Any {
    fileprivate var intelligenceFeatures: PrismIntelligenceFeatureRow? {
        let features = compactMapValues {
            PrismIntelligenceFeatureValue($0)
        }

        return features.isEmpty ? nil : features
    }
}
