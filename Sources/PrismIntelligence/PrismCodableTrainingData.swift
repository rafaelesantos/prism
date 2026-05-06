//
//  PrismCodableTrainingData.swift
//  Prism
//
//  Created by Rafael Escaleira on 27/04/26.
//

import Foundation
import PrismFoundation

public struct PrismCodableTrainingData<T: Codable> {
    private let items: [T]
    private let testRatio: Double
    private let seed: UInt64
    private let trainer: PrismIntelligenceLocalTrainer

    public init(
        data: [T],
        testRatio: Double = 0.2,
        seed: UInt64 = 42,
        trainer: PrismIntelligenceLocalTrainer = .init()
    ) {
        self.items = data
        self.testRatio = max(0, min(1, testRatio))
        self.seed = seed
        self.trainer = trainer
    }

    public func trainClassifier<V>(
        id: String,
        name: String,
        target: KeyPath<T, V>,
        features: [PartialKeyPath<T>]? = nil,
        configuration: PrismTabularTrainingConfiguration? = nil
    ) async -> PrismIntelligenceResult {
        let targetName = propertyName(for: target)
        guard let targetName else {
            return .failure(.invalidTrainingData("Could not resolve target property name."))
        }

        let rows = extractFeatureRows(targetName: targetName, featureKeyPaths: features)
        guard !rows.isEmpty else {
            return .failure(.invalidTrainingData("No valid feature rows could be extracted from the data."))
        }

        let (trainRows, _) = split(rows)

        let config =
            configuration
            ?? PrismTabularTrainingConfiguration(
                id: id,
                name: name,
                targetColumn: targetName
            )
        let finalConfig = PrismTabularTrainingConfiguration(
            id: id,
            name: name,
            targetColumn: targetName,
            maxDepth: config.maxDepth,
            maxIterations: config.maxIterations,
            minLossReduction: config.minLossReduction,
            minChildWeight: config.minChildWeight,
            randomSeed: config.randomSeed,
            stepSize: config.stepSize
        )

        let intelligence = PrismTabularIntelligence(rows: trainRows, trainer: trainer)
        return await intelligence.trainingClassifier(
            id: finalConfig.id,
            name: finalConfig.name,
            maxDepth: finalConfig.maxDepth,
            maxIterations: finalConfig.maxIterations,
            minLossReduction: finalConfig.minLossReduction,
            minChildWeight: finalConfig.minChildWeight,
            randomSeed: finalConfig.randomSeed,
            stepSize: finalConfig.stepSize
        )
    }

    public func trainRegressor<V>(
        id: String,
        name: String,
        target: KeyPath<T, V>,
        features: [PartialKeyPath<T>]? = nil,
        configuration: PrismTabularTrainingConfiguration? = nil
    ) async -> PrismIntelligenceResult {
        let targetName = propertyName(for: target)
        guard let targetName else {
            return .failure(.invalidTrainingData("Could not resolve target property name."))
        }

        let rows = extractFeatureRows(targetName: targetName, featureKeyPaths: features)
        guard !rows.isEmpty else {
            return .failure(.invalidTrainingData("No valid feature rows could be extracted from the data."))
        }

        let (trainRows, _) = split(rows)

        let config =
            configuration
            ?? PrismTabularTrainingConfiguration(
                id: id,
                name: name,
                targetColumn: targetName
            )
        let finalConfig = PrismTabularTrainingConfiguration(
            id: id,
            name: name,
            targetColumn: targetName,
            maxDepth: config.maxDepth,
            maxIterations: config.maxIterations,
            minLossReduction: config.minLossReduction,
            minChildWeight: config.minChildWeight,
            randomSeed: config.randomSeed,
            stepSize: config.stepSize
        )

        let intelligence = PrismTabularIntelligence(rows: trainRows, trainer: trainer)
        return await intelligence.trainingRegressor(
            id: finalConfig.id,
            name: finalConfig.name,
            maxDepth: finalConfig.maxDepth,
            maxIterations: finalConfig.maxIterations,
            minLossReduction: finalConfig.minLossReduction,
            minChildWeight: finalConfig.minChildWeight,
            randomSeed: finalConfig.randomSeed,
            stepSize: finalConfig.stepSize
        )
    }

    public func trainTextClassifier(
        id: String,
        name: String,
        text: KeyPath<T, String>,
        label: KeyPath<T, String>,
        locale: PrismLocale? = nil,
        maxIterations: Int? = nil
    ) async -> PrismIntelligenceResult {
        let samples = items.map {
            PrismTextTrainingSample(
                text: $0[keyPath: text],
                label: $0[keyPath: label]
            )
        }

        guard !samples.isEmpty else {
            return .failure(.invalidTrainingData("No training samples provided."))
        }

        let (trainSamples, _) = splitArray(samples)

        let intelligence = PrismTextIntelligence(samples: trainSamples, trainer: trainer)
        return await intelligence.trainingTextClassifier(
            id: id,
            name: name,
            locale: locale,
            maxIterations: maxIterations
        )
    }

    public func featureRows() -> [PrismIntelligenceFeatureRow] {
        items.compactMap { featureRow(from: $0) }
    }

    public func trainTestSplit() -> (train: [T], test: [T]) {
        splitArray(items)
    }

    // MARK: - Internal

    func extractFeatureRows(
        targetName: String,
        featureKeyPaths: [PartialKeyPath<T>]?
    ) -> [PrismIntelligenceFeatureRow] {
        let allowedNames: Set<String>?
        if let featureKeyPaths {
            let names = featureKeyPaths.compactMap { propertyName(for: $0) }
            allowedNames = Set(names + [targetName])
        } else {
            allowedNames = nil
        }

        return items.compactMap { item -> PrismIntelligenceFeatureRow? in
            guard var row = featureRow(from: item) else { return nil }
            if let allowed = allowedNames {
                row = row.filter { allowed.contains($0.key) }
            }
            return row.isEmpty ? nil : row
        }
    }

    func featureRow(from item: T) -> PrismIntelligenceFeatureRow? {
        let mirror = Mirror(reflecting: item)
        var row: PrismIntelligenceFeatureRow = [:]

        for child in mirror.children {
            guard let label = child.label else { continue }
            let cleanLabel = label.hasPrefix("_") ? String(label.dropFirst()) : label
            if let value = PrismIntelligenceFeatureValue(child.value) {
                row[cleanLabel] = value
            }
        }

        return row.isEmpty ? nil : row
    }

    func propertyName(for keyPath: PartialKeyPath<T>) -> String? {
        guard !items.isEmpty else { return nil }
        let sample = items[0]
        let baseMirror = Mirror(reflecting: sample)

        for child in baseMirror.children {
            guard let label = child.label else { continue }
            let cleanLabel = label.hasPrefix("_") ? String(label.dropFirst()) : label

            if let typedKP = keyPath as? KeyPath<T, String> {
                let sampleValue = sample[keyPath: typedKP]
                if let childStr = child.value as? String, childStr == sampleValue {
                    return cleanLabel
                }
            } else if let typedKP = keyPath as? KeyPath<T, Int> {
                let sampleValue = sample[keyPath: typedKP]
                if let childInt = child.value as? Int, childInt == sampleValue {
                    return cleanLabel
                }
            } else if let typedKP = keyPath as? KeyPath<T, Double> {
                let sampleValue = sample[keyPath: typedKP]
                if let childDouble = child.value as? Double, childDouble == sampleValue {
                    return cleanLabel
                }
            } else if let typedKP = keyPath as? KeyPath<T, Bool> {
                let sampleValue = sample[keyPath: typedKP]
                if let childBool = child.value as? Bool, childBool == sampleValue {
                    return cleanLabel
                }
            } else if let typedKP = keyPath as? KeyPath<T, Float> {
                let sampleValue = sample[keyPath: typedKP]
                if let childFloat = child.value as? Float, childFloat == sampleValue {
                    return cleanLabel
                }
            }
        }

        return nil
    }

    private func split(
        _ rows: [PrismIntelligenceFeatureRow]
    ) -> (train: [PrismIntelligenceFeatureRow], test: [PrismIntelligenceFeatureRow]) {
        splitArray(rows)
    }

    private func splitArray<U>(_ array: [U]) -> (train: [U], test: [U]) {
        guard !array.isEmpty else { return ([], []) }

        var rng = SeededRandomNumberGenerator(seed: seed)
        let shuffled = array.shuffled(using: &rng)
        let testCount = max(0, Int((Double(shuffled.count) * testRatio).rounded()))
        let testSlice = Array(shuffled.prefix(testCount))
        let trainSlice = Array(shuffled.dropFirst(testCount))
        return (trainSlice, testSlice)
    }
}

struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        self.state = seed
    }

    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}
