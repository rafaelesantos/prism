//
//  PrismIntelligenceTypes.swift
//  Prism
//
//  Created by Rafael Escaleira on 11/04/26.
//

import Foundation

public enum PrismIntelligenceBackendKind: String, Codable, Sendable, CaseIterable {
    case local
    case apple
    case remote
}

public enum PrismIntelligenceCapability: String, Codable, Sendable, CaseIterable {
    case textClassification
    case tabularClassification
    case tabularRegression
    case languageGeneration
}

public struct PrismIntelligenceStatus: Codable, Equatable, Hashable, Sendable {
    public var backend: PrismIntelligenceBackendKind
    public var isAvailable: Bool
    public var reason: String?
    public var capabilities: [PrismIntelligenceCapability]
    public var modelID: String?
    public var modelName: String?
    public var provider: PrismLanguageIntelligenceProviderKind?
    public var supportsStreaming: Bool
    public var supportsCustomInstructions: Bool
    public var supportsModelAdapters: Bool

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

public enum PrismIntelligenceRequest: Sendable, Equatable {
    case classifyText(String)
    case classifyFeatures(PrismIntelligenceFeatureRow)
    case regressFeatures(PrismIntelligenceFeatureRow)
    case generate(PrismLanguageIntelligenceRequest)
}

public enum PrismIntelligenceResponse: Sendable, Equatable {
    case textClassification(String)
    case tabularClassification([String: Double])
    case tabularRegression(Double)
    case language(PrismLanguageIntelligenceResponse)

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

extension Dictionary where Key == String, Value == Any {
    package var intelligenceFeatures: PrismIntelligenceFeatureRow? {
        let features = compactMapValues {
            PrismIntelligenceFeatureValue($0)
        }

        return features.isEmpty ? nil : features
    }
}
