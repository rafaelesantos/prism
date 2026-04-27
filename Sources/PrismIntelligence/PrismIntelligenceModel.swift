//
//  PrismIntelligenceModel.swift
//  Prism
//
//  Created by Rafael Escaleira on 13/09/25.
//

import Foundation
import PrismFoundation

/// The kind of intelligence model.
public enum PrismIntelligenceModelKind: String, Codable, Sendable, CaseIterable {
    /// A user-supplied Core ML model with unspecified task type.
    case custom
    /// A model trained to classify free-form text.
    case textClassifier
    /// A model trained to classify tabular feature rows.
    case tabularClassifier
    /// A model trained to predict continuous values from tabular features.
    case tabularRegressor
    /// An adapter for a foundation language model.
    case foundationModelAdapter
}

/// The training engine used.
public enum PrismIntelligenceEngineKind: String, Codable, Sendable, CaseIterable {
    /// An externally compiled Core ML model artifact.
    case coreML
    /// A model trained on-device with CreateML.
    case createML
    /// Apple FoundationModels framework.
    case foundationModels
    /// A remotely hosted model.
    case remote
}

/// Performance metrics for a model.
public struct PrismIntelligenceModelMetrics: Codable, Equatable, Hashable, Sendable {
    /// The classification accuracy as a value between 0 and 1, if applicable.
    public var accuracy: Double?
    /// The root mean squared error for regression models, if applicable.
    public var rootMeanSquaredError: Double?

    /// Creates model metrics.
    ///
    /// - Parameters:
    ///   - accuracy: The classification accuracy, or `nil` for non-classification models.
    ///   - rootMeanSquaredError: The RMSE, or `nil` for non-regression models.
    public init(
        accuracy: Double? = nil,
        rootMeanSquaredError: Double? = nil
    ) {
        self.accuracy = accuracy
        self.rootMeanSquaredError = rootMeanSquaredError
    }
}

private enum PrismIntelligenceStorageKey {
    static let current = "prism.intelligence.models"
    static let legacy = "prism.models"
}

private struct PrismLegacyIntelligenceModel: Codable, Equatable, Hashable, Sendable {
    let id: String
    let name: String
    let isTraining: Bool
    let createDate: TimeInterval?
    let updateDate: TimeInterval?
    let accuracy: Double?
    let rootMeanSquaredError: Double?
}

/// An intelligence model with metadata and metrics.
public struct PrismIntelligenceModel: PrismEntity, Sendable {
    /// A unique identifier for the model.
    public var id: String
    /// A human-readable display name.
    public var name: String
    /// The task kind this model performs.
    public var kind: PrismIntelligenceModelKind
    /// The engine that produced or runs this model.
    public var engine: PrismIntelligenceEngineKind
    /// The filename of the compiled model artifact on disk.
    public var artifactName: String
    /// Whether the model is currently being trained.
    public var isTraining: Bool
    /// The creation timestamp as a UNIX epoch interval.
    public var createDate: TimeInterval?
    /// The last-updated timestamp as a UNIX epoch interval.
    public var updateDate: TimeInterval?
    /// The BCP-47 locale identifier used during training, if applicable.
    public var localeIdentifier: String?
    /// Evaluation metrics collected after training.
    public var metrics: PrismIntelligenceModelMetrics
    /// Arbitrary key-value metadata associated with the model.
    public var metadata: [String: String]

    /// Creates a fully specified intelligence model.
    ///
    /// - Parameters:
    ///   - id: A unique identifier.
    ///   - name: A display name.
    ///   - kind: The task kind. Defaults to ``PrismIntelligenceModelKind/custom``.
    ///   - engine: The engine kind. Defaults to ``PrismIntelligenceEngineKind/coreML``.
    ///   - artifactName: The artifact filename. Defaults to `"\(id).mlmodel"`.
    ///   - isTraining: Whether the model is currently training.
    ///   - createDate: An optional creation timestamp.
    ///   - updateDate: An optional last-updated timestamp.
    ///   - localeIdentifier: An optional locale identifier.
    ///   - metrics: Evaluation metrics.
    ///   - metadata: Arbitrary key-value metadata.
    public init(
        id: String,
        name: String,
        kind: PrismIntelligenceModelKind = .custom,
        engine: PrismIntelligenceEngineKind = .coreML,
        artifactName: String? = nil,
        isTraining: Bool = false,
        createDate: TimeInterval? = nil,
        updateDate: TimeInterval? = nil,
        localeIdentifier: String? = nil,
        metrics: PrismIntelligenceModelMetrics = .init(),
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.name = name
        self.kind = kind
        self.engine = engine
        self.artifactName = artifactName ?? "\(id).mlmodel"
        self.isTraining = isTraining
        self.createDate = createDate
        self.updateDate = updateDate
        self.localeIdentifier = localeIdentifier
        self.metrics = metrics
        self.metadata = metadata
    }

    /// Creates a legacy-compatible intelligence model with inline metric values.
    ///
    /// - Parameters:
    ///   - id: A unique identifier.
    ///   - name: A display name.
    ///   - isTraining: Whether the model is currently training.
    ///   - createDate: An optional creation timestamp.
    ///   - updateDate: An optional last-updated timestamp.
    ///   - accuracy: An optional classification accuracy.
    ///   - rootMeanSquaredError: An optional RMSE value.
    public init(
        id: String,
        name: String,
        isTraining: Bool = false,
        createDate: TimeInterval? = nil,
        updateDate: TimeInterval? = nil,
        accuracy: Double? = nil,
        rootMeanSquaredError: Double? = nil
    ) {
        self.init(
            id: id,
            name: name,
            kind: .custom,
            engine: .coreML,
            artifactName: "\(id).mlmodel",
            isTraining: isTraining,
            createDate: createDate,
            updateDate: updateDate,
            metrics: .init(
                accuracy: accuracy,
                rootMeanSquaredError: rootMeanSquaredError
            )
        )
    }

    /// The classification accuracy from ``metrics``, if available.
    public var accuracy: Double? {
        metrics.accuracy
    }

    /// The root mean squared error from ``metrics``, if available.
    public var rootMeanSquaredError: Double? {
        metrics.rootMeanSquaredError
    }

    /// A human-readable string describing the on-disk size of the model artifact.
    public var size: String {
        let fileManager = PrismFileManager()
        return fileManager.size(at: artifactURL(fileManager: fileManager))
    }

    /// Returns the file URL of the model artifact on disk.
    ///
    /// - Parameter fileManager: The file manager used to resolve paths.
    /// - Returns: The artifact URL, or `nil` if the path cannot be resolved.
    public func artifactURL(
        fileManager: PrismFileManager = .init()
    ) -> URL? {
        fileManager.path(with: artifactName, privacy: .public)
    }

    /// All persisted models, loaded from user defaults and sorted by most recently updated.
    public static var models: [PrismIntelligenceModel] {
        loadStoredModels()
    }

    /// Removes all persisted models from user defaults.
    public static func clean() {
        persistStoredModels([])
    }

    static func loadStoredModels(
        defaults: PrismDefaults = .init()
    ) -> [PrismIntelligenceModel] {
        if let models: [PrismIntelligenceModel] = defaults.get(for: PrismIntelligenceStorageKey.current) {
            return sort(models)
        }

        if let models: [PrismIntelligenceModel] = defaults.get(for: PrismIntelligenceStorageKey.legacy) {
            return sort(models)
        }

        if let legacy: [PrismLegacyIntelligenceModel] = defaults.get(for: PrismIntelligenceStorageKey.legacy) {
            return sort(
                legacy.map {
                    PrismIntelligenceModel(
                        id: $0.id,
                        name: $0.name,
                        isTraining: $0.isTraining,
                        createDate: $0.createDate,
                        updateDate: $0.updateDate,
                        accuracy: $0.accuracy,
                        rootMeanSquaredError: $0.rootMeanSquaredError
                    )
                }
            )
        }

        return []
    }

    static func persistStoredModels(
        _ models: [PrismIntelligenceModel],
        defaults: PrismDefaults = .init()
    ) {
        let sortedModels = sort(models)
        defaults.set(sortedModels, for: PrismIntelligenceStorageKey.current)
        defaults.set(sortedModels, for: PrismIntelligenceStorageKey.legacy)
    }

    private static func sort(
        _ models: [PrismIntelligenceModel]
    ) -> [PrismIntelligenceModel] {
        models.sorted {
            ($0.updateDate ?? $0.createDate ?? .zero) > ($1.updateDate ?? $1.createDate ?? .zero)
        }
    }
}
