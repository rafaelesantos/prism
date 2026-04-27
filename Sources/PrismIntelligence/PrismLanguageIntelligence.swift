//
//  PrismLanguageIntelligence.swift
//  Prism
//
//  Created by Rafael Escaleira on 11/04/26.
//

import Foundation
import PrismFoundation

/// The kind of language intelligence provider.
public enum PrismLanguageIntelligenceProviderKind: String, Codable, Sendable, CaseIterable {
    /// Apple Intelligence via the FoundationModels framework.
    case apple
    /// A remote language model accessed over the network.
    case remote
}

/// Options for language generation.
public struct PrismLanguageGenerationOptions: Codable, Equatable, Hashable, Sendable {
    /// The sampling temperature. Higher values produce more varied output.
    public var temperature: Double?
    /// The maximum number of tokens in the generated response.
    public var maximumResponseTokens: Int?

    /// Creates generation options.
    ///
    /// - Parameters:
    ///   - temperature: The sampling temperature, or `nil` for the provider default.
    ///   - maximumResponseTokens: The maximum response token count, or `nil` for no limit.
    public init(
        temperature: Double? = nil,
        maximumResponseTokens: Int? = nil
    ) {
        self.temperature = temperature
        self.maximumResponseTokens = maximumResponseTokens
    }
}

/// A language generation request.
public struct PrismLanguageIntelligenceRequest: Codable, Equatable, Hashable, Sendable {
    /// The user-facing prompt text.
    public var prompt: String
    /// An optional system-level instruction applied before the prompt.
    public var systemPrompt: String?
    /// Additional context strings prepended to the prompt.
    public var context: [String]
    /// Generation options such as temperature and token limits.
    public var options: PrismLanguageGenerationOptions
    /// Arbitrary key-value metadata forwarded to the provider.
    public var metadata: [String: String]

    /// Creates a language generation request.
    ///
    /// - Parameters:
    ///   - prompt: The user prompt.
    ///   - systemPrompt: An optional system-level instruction.
    ///   - context: Additional context strings.
    ///   - options: Generation options.
    ///   - metadata: Arbitrary key-value metadata.
    public init(
        prompt: String,
        systemPrompt: String? = nil,
        context: [String] = [],
        options: PrismLanguageGenerationOptions = .init(),
        metadata: [String: String] = [:]
    ) {
        self.prompt = prompt
        self.systemPrompt = systemPrompt
        self.context = context
        self.options = options
        self.metadata = metadata
    }
}

/// Token usage statistics for a language generation response.
public struct PrismLanguageTokenUsage: Codable, Equatable, Hashable, Sendable {
    /// The number of tokens in the prompt.
    public var promptTokens: Int?
    /// The number of tokens in the generated completion.
    public var completionTokens: Int?
    /// The total number of tokens consumed (prompt + completion).
    public var totalTokens: Int?

    /// Creates token usage statistics.
    ///
    /// - Parameters:
    ///   - promptTokens: The prompt token count.
    ///   - completionTokens: The completion token count.
    ///   - totalTokens: The total token count.
    public init(
        promptTokens: Int? = nil,
        completionTokens: Int? = nil,
        totalTokens: Int? = nil
    ) {
        self.promptTokens = promptTokens
        self.completionTokens = completionTokens
        self.totalTokens = totalTokens
    }
}

/// A language generation response.
public struct PrismLanguageIntelligenceResponse: PrismEntity, Sendable {
    /// A unique identifier for the response.
    public var id: String
    /// The provider that produced this response.
    public var provider: PrismLanguageIntelligenceProviderKind
    /// The model identifier used for generation, if known.
    public var model: String?
    /// The generated text content.
    public var content: String
    /// The reason the generation stopped (e.g., "completed", "length").
    public var finishReason: String?
    /// Token usage statistics for the request/response cycle.
    public var usage: PrismLanguageTokenUsage?
    /// The creation timestamp as a UNIX epoch interval.
    public var createDate: TimeInterval
    /// Arbitrary key-value metadata returned by the provider.
    public var metadata: [String: String]

    /// Creates a language generation response.
    ///
    /// - Parameters:
    ///   - id: A unique identifier. Defaults to a new UUID string.
    ///   - provider: The provider kind that produced this response.
    ///   - model: An optional model identifier.
    ///   - content: The generated text.
    ///   - finishReason: An optional stop reason.
    ///   - usage: Optional token usage statistics.
    ///   - createDate: The creation timestamp. Defaults to now.
    ///   - metadata: Arbitrary key-value metadata.
    public init(
        id: String = UUID().uuidString,
        provider: PrismLanguageIntelligenceProviderKind,
        model: String? = nil,
        content: String,
        finishReason: String? = nil,
        usage: PrismLanguageTokenUsage? = nil,
        createDate: TimeInterval = Date.now.timeIntervalSince1970,
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.provider = provider
        self.model = model
        self.content = content
        self.finishReason = finishReason
        self.usage = usage
        self.createDate = createDate
        self.metadata = metadata
    }
}

/// The availability status of a provider.
public struct PrismLanguageIntelligenceStatus: Codable, Equatable, Hashable, Sendable {
    /// The provider this status describes.
    public var provider: PrismLanguageIntelligenceProviderKind
    /// Whether the provider is ready to accept generation requests.
    public var isAvailable: Bool
    /// A human-readable explanation when the provider is unavailable.
    public var reason: String?
    /// Whether the provider supports streaming responses.
    public var supportsStreaming: Bool
    /// Whether the provider supports custom system instructions.
    public var supportsCustomInstructions: Bool
    /// Whether the provider supports model adapters.
    public var supportsModelAdapters: Bool

    /// Creates a provider status.
    ///
    /// - Parameters:
    ///   - provider: The provider kind.
    ///   - isAvailable: Whether the provider is ready.
    ///   - reason: An optional explanation when unavailable.
    ///   - supportsStreaming: Whether streaming is supported.
    ///   - supportsCustomInstructions: Whether custom instructions are supported.
    ///   - supportsModelAdapters: Whether model adapters are supported.
    public init(
        provider: PrismLanguageIntelligenceProviderKind,
        isAvailable: Bool,
        reason: String? = nil,
        supportsStreaming: Bool = false,
        supportsCustomInstructions: Bool = true,
        supportsModelAdapters: Bool = false
    ) {
        self.provider = provider
        self.isAvailable = isAvailable
        self.reason = reason
        self.supportsStreaming = supportsStreaming
        self.supportsCustomInstructions = supportsCustomInstructions
        self.supportsModelAdapters = supportsModelAdapters
    }
}

/// A protocol for language intelligence providers.
///
/// Conform to this protocol to integrate a custom language model backend
/// with ``PrismIntelligenceClient``.
public protocol PrismLanguageIntelligenceProvider: Sendable {
    /// The kind of provider (Apple or remote).
    var kind: PrismLanguageIntelligenceProviderKind { get }

    /// Returns the current availability status of the provider.
    ///
    /// - Returns: A ``PrismLanguageIntelligenceStatus`` describing availability and feature support.
    func status() async -> PrismLanguageIntelligenceStatus

    /// Generates a response for the given request.
    ///
    /// - Parameter request: The language generation request.
    /// - Returns: A ``PrismLanguageIntelligenceResponse`` containing the generated text.
    /// - Throws: ``PrismIntelligenceError`` on failure.
    func generate(
        _ request: PrismLanguageIntelligenceRequest
    ) async throws -> PrismLanguageIntelligenceResponse
}

/// A facade for generative language models.
public actor PrismLanguageIntelligence {
    private let provider: any PrismLanguageIntelligenceProvider

    /// Creates a language intelligence facade backed by the given provider.
    ///
    /// - Parameter provider: A conforming language-intelligence provider.
    public init(
        provider: any PrismLanguageIntelligenceProvider
    ) {
        self.provider = provider
    }

    /// Returns the current availability status of the underlying provider.
    ///
    /// - Returns: A ``PrismLanguageIntelligenceStatus``.
    public func status() async -> PrismLanguageIntelligenceStatus {
        await provider.status()
    }

    /// Generates a response, first checking that the provider is available.
    ///
    /// - Parameter request: The language generation request.
    /// - Returns: A ``PrismLanguageIntelligenceResponse`` containing the generated text.
    /// - Throws: ``PrismIntelligenceError/providerUnavailable(_:)`` if the provider is not ready.
    public func generate(
        _ request: PrismLanguageIntelligenceRequest
    ) async throws -> PrismLanguageIntelligenceResponse {
        let status = await provider.status()
        guard status.isAvailable else {
            throw PrismIntelligenceError.providerUnavailable(
                status.reason ?? "The provider is currently unavailable."
            )
        }

        return try await provider.generate(request)
    }
}
