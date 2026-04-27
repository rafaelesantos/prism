//
//  PrismIntelligenceResult.swift
//  Prism
//
//  Created by Rafael Escaleira on 13/09/25.
//

/// The outcome of a training operation.
public enum PrismIntelligenceResult: Sendable, Equatable {
    /// An unspecified error occurred.
    case error
    /// Training succeeded and the model was persisted.
    case saved(model: PrismIntelligenceModel)
    /// Training failed with a specific error.
    case failure(PrismIntelligenceError)
}
