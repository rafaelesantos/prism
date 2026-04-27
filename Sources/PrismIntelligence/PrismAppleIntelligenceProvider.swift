//
//  PrismAppleIntelligenceProvider.swift
//  Prism
//
//  Created by Rafael Escaleira on 11/04/26.
//

import Foundation

/// Apple Intelligence use cases.
public enum PrismAppleIntelligenceUseCase: String, Codable, Sendable, CaseIterable {
    /// General-purpose language generation.
    case general
    /// Content tagging and categorization.
    case contentTagging
}

/// A reference to an Apple Intelligence model (system or adapter).
public enum PrismAppleIntelligenceModelReference: Codable, Equatable, Hashable, Sendable {
    /// The built-in system language model for the specified use case.
    case system(useCase: PrismAppleIntelligenceUseCase)
    /// A named adapter registered with the system.
    case adapterName(String)
    /// An adapter loaded from a file URL.
    case adapterFile(URL)
}

/// Configuration for the Apple Intelligence provider.
public struct PrismAppleIntelligenceConfiguration: Codable, Equatable, Hashable, Sendable {
    /// The model reference (system model or adapter) to use.
    public var model: PrismAppleIntelligenceModelReference
    /// Optional system-level instructions applied to every generation session.
    public var instructions: String?

    /// Creates an Apple Intelligence configuration.
    ///
    /// - Parameters:
    ///   - model: The model reference. Defaults to the general system model.
    ///   - instructions: Optional system-level instructions.
    public init(
        model: PrismAppleIntelligenceModelReference = .system(useCase: .general),
        instructions: String? = nil
    ) {
        self.model = model
        self.instructions = instructions
    }
}

internal protocol PrismAppleIntelligenceGateway: Sendable {
    func status(
        configuration: PrismAppleIntelligenceConfiguration
    ) async -> PrismLanguageIntelligenceStatus

    func generate(
        request: PrismLanguageIntelligenceRequest,
        configuration: PrismAppleIntelligenceConfiguration
    ) async throws -> PrismLanguageIntelligenceResponse
}

/// An Apple Intelligence provider backed by the FoundationModels framework.
public actor PrismAppleIntelligenceProvider: PrismLanguageIntelligenceProvider {
    /// The provider kind, always ``PrismLanguageIntelligenceProviderKind/apple``.
    public let kind: PrismLanguageIntelligenceProviderKind = .apple

    private let configuration: PrismAppleIntelligenceConfiguration
    private let gateway: any PrismAppleIntelligenceGateway

    /// Creates an Apple Intelligence provider with the given configuration.
    ///
    /// - Parameter configuration: The model and instruction configuration.
    public init(
        configuration: PrismAppleIntelligenceConfiguration = .init()
    ) {
        self.configuration = configuration
        self.gateway = PrismFoundationModelsGateway()
    }

    init(
        configuration: PrismAppleIntelligenceConfiguration = .init(),
        gateway: any PrismAppleIntelligenceGateway
    ) {
        self.configuration = configuration
        self.gateway = gateway
    }

    /// Returns the current availability status of Apple Intelligence on this device.
    public func status() async -> PrismLanguageIntelligenceStatus {
        await gateway.status(configuration: configuration)
    }

    /// Generates a response using the configured Apple Intelligence model.
    ///
    /// - Parameter request: The language generation request.
    /// - Returns: A ``PrismLanguageIntelligenceResponse`` with the generated content.
    /// - Throws: ``PrismIntelligenceError/providerUnavailable(_:)`` if the model is not available.
    public func generate(
        _ request: PrismLanguageIntelligenceRequest
    ) async throws -> PrismLanguageIntelligenceResponse {
        try await gateway.generate(
            request: request,
            configuration: configuration
        )
    }
}

#if canImport(FoundationModels)
    import FoundationModels

    @available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
    private struct PrismFoundationModelsGatewayImpl {
        func status(
            configuration: PrismAppleIntelligenceConfiguration
        ) -> PrismLanguageIntelligenceStatus {
            do {
                let model = try resolvedModel(from: configuration.model)

                if model.isAvailable {
                    return PrismLanguageIntelligenceStatus(
                        provider: .apple,
                        isAvailable: true,
                        supportsStreaming: false,
                        supportsCustomInstructions: true,
                        supportsModelAdapters: true
                    )
                }

                return PrismLanguageIntelligenceStatus(
                    provider: .apple,
                    isAvailable: false,
                    reason: availabilityReason(from: model.availability),
                    supportsStreaming: false,
                    supportsCustomInstructions: true,
                    supportsModelAdapters: true
                )
            } catch {
                return PrismLanguageIntelligenceStatus(
                    provider: .apple,
                    isAvailable: false,
                    reason: error.localizedDescription,
                    supportsStreaming: false,
                    supportsCustomInstructions: true,
                    supportsModelAdapters: true
                )
            }
        }

        func generate(
            request: PrismLanguageIntelligenceRequest,
            configuration: PrismAppleIntelligenceConfiguration
        ) async throws -> PrismLanguageIntelligenceResponse {
            let model = try resolvedModel(from: configuration.model)

            guard model.isAvailable else {
                throw PrismIntelligenceError.providerUnavailable(
                    availabilityReason(from: model.availability)
                )
            }

            let instructions = mergedInstructions(
                configuration: configuration,
                request: request
            )
            let prompt = mergedPrompt(for: request)
            let session = LanguageModelSession(
                model: model,
                instructions: instructions
            )
            let response = try await session.respond(
                to: prompt,
                options: generationOptions(from: request.options)
            )

            return PrismLanguageIntelligenceResponse(
                provider: .apple,
                model: modelIdentifier(from: configuration.model),
                content: response.content,
                finishReason: "completed",
                usage: nil,
                metadata: [
                    "transcriptEntries": "\(response.transcriptEntries.count)"
                ]
            )
        }

        private func generationOptions(
            from options: PrismLanguageGenerationOptions
        ) -> GenerationOptions {
            GenerationOptions(
                sampling: nil,
                temperature: options.temperature,
                maximumResponseTokens: options.maximumResponseTokens
            )
        }

        private func mergedInstructions(
            configuration: PrismAppleIntelligenceConfiguration,
            request: PrismLanguageIntelligenceRequest
        ) -> String? {
            [configuration.instructions, request.systemPrompt]
                .compactMap { value in
                    guard let value,
                        !value.isEmpty
                    else {
                        return nil
                    }

                    return value
                }
                .joined(separator: "\n\n")
                .nilIfEmpty
        }

        private func mergedPrompt(
            for request: PrismLanguageIntelligenceRequest
        ) -> String {
            if request.context.isEmpty {
                return request.prompt
            }

            let context = request.context.joined(separator: "\n- ")
            return """
                Context:
                - \(context)

                Request:
                \(request.prompt)
                """
        }

        private func resolvedModel(
            from reference: PrismAppleIntelligenceModelReference
        ) throws -> SystemLanguageModel {
            switch reference {
            case .system(let useCase):
                return SystemLanguageModel(
                    useCase: resolvedUseCase(from: useCase)
                )
            case .adapterName(let name):
                let adapter = try SystemLanguageModel.Adapter(name: name)
                return SystemLanguageModel(adapter: adapter)
            case .adapterFile(let url):
                let adapter = try SystemLanguageModel.Adapter(fileURL: url)
                return SystemLanguageModel(adapter: adapter)
            }
        }

        private func resolvedUseCase(
            from useCase: PrismAppleIntelligenceUseCase
        ) -> SystemLanguageModel.UseCase {
            switch useCase {
            case .general:
                .general
            case .contentTagging:
                .contentTagging
            }
        }

        private func availabilityReason(
            from availability: SystemLanguageModel.Availability
        ) -> String {
            switch availability {
            case .available:
                "Available"
            case .unavailable(let reason):
                switch reason {
                case .deviceNotEligible:
                    "This device is not eligible for Apple Intelligence."
                case .appleIntelligenceNotEnabled:
                    "Apple Intelligence is not enabled."
                case .modelNotReady:
                    "The Apple Intelligence model is not ready yet."
                @unknown default:
                    "Apple Intelligence is unavailable."
                }
            }
        }

        private func modelIdentifier(
            from reference: PrismAppleIntelligenceModelReference
        ) -> String {
            switch reference {
            case .system(let useCase):
                "apple.\(useCase.rawValue)"
            case .adapterName(let name):
                "apple.adapter.\(name)"
            case .adapterFile(let url):
                "apple.adapter.\(url.lastPathComponent)"
            }
        }
    }
#endif

internal struct PrismFoundationModelsGateway: PrismAppleIntelligenceGateway {
    func status(
        configuration: PrismAppleIntelligenceConfiguration
    ) async -> PrismLanguageIntelligenceStatus {
        #if canImport(FoundationModels)
            if #available(iOS 26.0, macOS 26.0, visionOS 26.0, *) {
                return PrismFoundationModelsGatewayImpl().status(
                    configuration: configuration
                )
            }
        #endif

        return PrismLanguageIntelligenceStatus(
            provider: .apple,
            isAvailable: false,
            reason: "Foundation Models is unavailable on this platform or SDK.",
            supportsStreaming: false,
            supportsCustomInstructions: false,
            supportsModelAdapters: false
        )
    }

    func generate(
        request: PrismLanguageIntelligenceRequest,
        configuration: PrismAppleIntelligenceConfiguration
    ) async throws -> PrismLanguageIntelligenceResponse {
        #if canImport(FoundationModels)
            if #available(iOS 26.0, macOS 26.0, visionOS 26.0, *) {
                return try await PrismFoundationModelsGatewayImpl().generate(
                    request: request,
                    configuration: configuration
                )
            }
        #endif

        throw PrismIntelligenceError.providerUnavailable(
            "Foundation Models is unavailable on this platform or SDK."
        )
    }
}

extension String {
    fileprivate var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
