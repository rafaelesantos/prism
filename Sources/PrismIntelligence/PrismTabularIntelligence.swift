//
//  PrismTabularIntelligence.swift
//  Prism
//
//  Created by Rafael Escaleira on 14/09/25.
//

import Foundation

/// A convenience class for training tabular regressors and classifiers from feature rows.
public final class PrismTabularIntelligence {
    private let data: [PrismIntelligenceFeatureRow]
    private let invalidRowCount: Int
    private let trainer: PrismIntelligenceLocalTrainer

    /// Creates a tabular intelligence instance from untyped dictionaries.
    ///
    /// Rows whose values cannot be converted to ``PrismIntelligenceFeatureValue``
    /// are counted as invalid and will cause training to return a failure result.
    ///
    /// - Parameters:
    ///   - data: An array of untyped feature dictionaries.
    ///   - trainer: The local trainer. Defaults to a new instance.
    public init(
        data: [[String: Any]],
        trainer: PrismIntelligenceLocalTrainer = .init()
    ) {
        let converted = data.map {
            $0.compactMapValues(PrismIntelligenceFeatureValue.init)
        }
        self.data = converted
        self.invalidRowCount =
            zip(data, converted)
            .filter { original, sanitized in
                original.count != sanitized.count || sanitized.isEmpty
            }
            .count
        self.trainer = trainer
    }

    /// Creates a tabular intelligence instance from typed feature rows.
    ///
    /// - Parameters:
    ///   - rows: An array of typed feature rows.
    ///   - trainer: The local trainer. Defaults to a new instance.
    public init(
        rows: [PrismIntelligenceFeatureRow],
        trainer: PrismIntelligenceLocalTrainer = .init()
    ) {
        self.data = rows
        self.invalidRowCount = 0
        self.trainer = trainer
    }

    /// Trains a tabular regressor from the loaded data.
    ///
    /// - Parameters:
    ///   - id: A unique identifier for the resulting model.
    ///   - name: A display name for the resulting model.
    ///   - maxDepth: Maximum tree depth. Defaults to 20.
    ///   - maxIterations: Maximum boosting iterations. Defaults to 10,000.
    ///   - minLossReduction: Minimum loss reduction. Defaults to 0.
    ///   - minChildWeight: Minimum child weight. Defaults to 0.01.
    ///   - randomSeed: Random seed. Defaults to 42.
    ///   - stepSize: Learning rate. Defaults to 0.01.
    /// - Returns: A ``PrismIntelligenceResult`` indicating success or failure.
    public func trainingRegressor(
        id: String,
        name: String,
        maxDepth: Int = 20,
        maxIterations: Int = 10_000,
        minLossReduction: Double = .zero,
        minChildWeight: Double = 0.01,
        randomSeed: Int = 42,
        stepSize: Double = 0.01
    ) async -> PrismIntelligenceResult {
        await train(
            kind: .tabularRegressor,
            configuration: PrismTabularTrainingConfiguration(
                id: id,
                name: name,
                maxDepth: maxDepth,
                maxIterations: maxIterations,
                minLossReduction: minLossReduction,
                minChildWeight: minChildWeight,
                randomSeed: randomSeed,
                stepSize: stepSize
            )
        )
    }

    /// Trains a tabular classifier from the loaded data.
    ///
    /// - Parameters:
    ///   - id: A unique identifier for the resulting model.
    ///   - name: A display name for the resulting model.
    ///   - maxDepth: Maximum tree depth. Defaults to 20.
    ///   - maxIterations: Maximum boosting iterations. Defaults to 10,000.
    ///   - minLossReduction: Minimum loss reduction. Defaults to 0.
    ///   - minChildWeight: Minimum child weight. Defaults to 0.01.
    ///   - randomSeed: Random seed. Defaults to 42.
    ///   - stepSize: Learning rate. Defaults to 0.01.
    /// - Returns: A ``PrismIntelligenceResult`` indicating success or failure.
    public func trainingClassifier(
        id: String,
        name: String,
        maxDepth: Int = 20,
        maxIterations: Int = 10_000,
        minLossReduction: Double = .zero,
        minChildWeight: Double = 0.01,
        randomSeed: Int = 42,
        stepSize: Double = 0.01
    ) async -> PrismIntelligenceResult {
        await train(
            kind: .tabularClassifier,
            configuration: PrismTabularTrainingConfiguration(
                id: id,
                name: name,
                maxDepth: maxDepth,
                maxIterations: maxIterations,
                minLossReduction: minLossReduction,
                minChildWeight: minChildWeight,
                randomSeed: randomSeed,
                stepSize: stepSize
            )
        )
    }

    private func train(
        kind: PrismIntelligenceModelKind,
        configuration: PrismTabularTrainingConfiguration
    ) async -> PrismIntelligenceResult {
        if invalidRowCount > 0 {
            return .failure(
                .invalidTrainingData("Found \(invalidRowCount) invalid tabular training rows.")
            )
        }

        do {
            let model: PrismIntelligenceModel

            switch kind {
            case .tabularClassifier:
                model = try await trainer.trainTabularClassifier(
                    data: data,
                    configuration: configuration
                )
            case .tabularRegressor:
                model = try await trainer.trainTabularRegressor(
                    data: data,
                    configuration: configuration
                )
            case .custom, .textClassifier, .foundationModelAdapter:
                return .failure(
                    .unsupportedInput("Unsupported tabular training kind: \(kind.rawValue)")
                )
            }

            return .saved(model: model)
        } catch let error as PrismIntelligenceError {
            return .failure(error)
        } catch {
            return .failure(.underlying(error.localizedDescription))
        }
    }
}
