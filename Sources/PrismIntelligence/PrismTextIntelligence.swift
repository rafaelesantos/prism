//
//  PrismTextIntelligence.swift
//  Prism
//
//  Created by Rafael Escaleira on 13/09/25.
//

import Foundation
import PrismFoundation

/// A convenience class for training text classifiers from labeled samples.
public final class PrismTextIntelligence {
    let data: [PrismTextTrainingSample]
    private let invalidRowCount: Int
    private let trainer: PrismIntelligenceLocalTrainer

    /// Creates a text intelligence instance from dictionary rows.
    ///
    /// Each dictionary must contain `"text"` and `"label"` keys. Rows missing
    /// either key are counted as invalid and will cause training to return a failure result.
    ///
    /// - Parameters:
    ///   - data: An array of dictionaries with `"text"` and `"label"` entries.
    ///   - trainer: The local trainer. Defaults to a new instance.
    public init(
        data: [[String: String]],
        trainer: PrismIntelligenceLocalTrainer = .init()
    ) {
        self.data = data.compactMap { row in
            guard let text = row["text"],
                let label = row["label"]
            else {
                return nil
            }

            return PrismTextTrainingSample(
                text: text,
                label: label
            )
        }
        self.invalidRowCount = data.count - self.data.count
        self.trainer = trainer
    }

    /// Creates a text intelligence instance from typed training samples.
    ///
    /// - Parameters:
    ///   - samples: An array of ``PrismTextTrainingSample`` values.
    ///   - trainer: The local trainer. Defaults to a new instance.
    public init(
        samples: [PrismTextTrainingSample],
        trainer: PrismIntelligenceLocalTrainer = .init()
    ) {
        self.data = samples
        self.invalidRowCount = 0
        self.trainer = trainer
    }

    /// Trains a text classifier from the loaded samples.
    ///
    /// - Parameters:
    ///   - id: A unique identifier for the resulting model.
    ///   - name: A display name for the resulting model.
    ///   - locale: An optional locale for training language. Defaults to ``PrismLocale/current``.
    ///   - maxIterations: An optional maximum number of training iterations.
    /// - Returns: A ``PrismIntelligenceResult`` indicating success or failure.
    public func trainingTextClassifier(
        id: String,
        name: String,
        locale: PrismLocale? = nil,
        maxIterations: Int? = nil
    ) async -> PrismIntelligenceResult {
        if invalidRowCount > 0 {
            return .failure(
                .invalidTrainingData("Found \(invalidRowCount) invalid text training rows.")
            )
        }

        let resolvedLocale = locale ?? .current
        do {
            let model = try await trainer.trainTextClassifier(
                data: data,
                configuration: PrismTextTrainingConfiguration(
                    id: id,
                    name: name,
                    localeIdentifier: resolvedLocale.identifier,
                    maxIterations: maxIterations
                )
            )
            return .saved(model: model)
        } catch let error as PrismIntelligenceError {
            return .failure(error)
        } catch {
            return .failure(.underlying(error.localizedDescription))
        }
    }
}
