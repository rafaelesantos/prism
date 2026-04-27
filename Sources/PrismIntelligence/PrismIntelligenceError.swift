//
//  PrismIntelligenceError.swift
//  Prism
//
//  Created by Rafael Escaleira on 11/04/26.
//

import Foundation

/// Errors produced by the intelligence module.
public enum PrismIntelligenceError: Error, Sendable, Equatable {
    /// The training data is empty or malformed.
    case invalidTrainingData(String)
    /// The current platform does not support the requested operation.
    case unsupportedPlatform(String)
    /// The requested operation is not supported by the active backend.
    case unsupportedOperation(String)
    /// No model with the given identifier exists in the catalog.
    case modelNotFound(String)
    /// The compiled model artifact could not be found on disk.
    case artifactNotFound(String)
    /// The input data could not be converted to the expected format.
    case unsupportedInput(String)
    /// The prediction step failed.
    case predictionFailed(String)
    /// The training step failed.
    case trainingFailed(String)
    /// The language-intelligence provider is not currently available.
    case providerUnavailable(String)
    /// The response from the provider is missing or malformed.
    case invalidResponse(String)
    /// A network-level failure occurred during a remote request.
    case networkFailure(String)
    /// A model adapter could not be loaded or applied.
    case adapterFailure(String)
    /// A wrapped error from an underlying framework.
    case underlying(String)
}

extension PrismIntelligenceError: LocalizedError {
    /// A localized description of the error.
    public var errorDescription: String? {
        switch self {
        case .invalidTrainingData(let message):
            "Invalid training data: \(message)"
        case .unsupportedPlatform(let message):
            "Unsupported platform: \(message)"
        case .unsupportedOperation(let message):
            "Unsupported operation: \(message)"
        case .modelNotFound(let identifier):
            "Model not found: \(identifier)"
        case .artifactNotFound(let artifact):
            "Model artifact not found: \(artifact)"
        case .unsupportedInput(let message):
            "Unsupported input: \(message)"
        case .predictionFailed(let message):
            "Prediction failed: \(message)"
        case .trainingFailed(let message):
            "Training failed: \(message)"
        case .providerUnavailable(let message):
            "Provider unavailable: \(message)"
        case .invalidResponse(let message):
            "Invalid response: \(message)"
        case .networkFailure(let message):
            "Network failure: \(message)"
        case .adapterFailure(let message):
            "Adapter failure: \(message)"
        case .underlying(let message):
            message
        }
    }
}
