//
//  PrismIntelligenceTrainingTypes.swift
//  Prism
//
//  Created by Rafael Escaleira on 11/04/26.
//

import Foundation
import PrismFoundation

public struct PrismTextTrainingConfiguration: Sendable, Equatable {
    public var id: String
    public var name: String
    public var localeIdentifier: String?
    public var maxIterations: Int?

    public init(
        id: String,
        name: String,
        localeIdentifier: String? = nil,
        maxIterations: Int? = nil
    ) {
        self.id = id
        self.name = name
        self.localeIdentifier = localeIdentifier
        self.maxIterations = maxIterations
    }
}

public struct PrismTabularTrainingConfiguration: Sendable, Equatable {
    public var id: String
    public var name: String
    public var targetColumn: String
    public var maxDepth: Int
    public var maxIterations: Int
    public var minLossReduction: Double
    public var minChildWeight: Double
    public var randomSeed: Int
    public var stepSize: Double
    public var featureColumns: [String]?
    public var earlyStoppingRounds: Int?
    public var rowSubsample: Double
    public var columnSubsample: Double

    public init(
        id: String,
        name: String,
        targetColumn: String = "target",
        maxDepth: Int = 20,
        maxIterations: Int = 10_000,
        minLossReduction: Double = .zero,
        minChildWeight: Double = 0.01,
        randomSeed: Int = 42,
        stepSize: Double = 0.01,
        featureColumns: [String]? = nil,
        earlyStoppingRounds: Int? = nil,
        rowSubsample: Double = 1.0,
        columnSubsample: Double = 1.0
    ) {
        self.id = id
        self.name = name
        self.targetColumn = targetColumn
        self.maxDepth = maxDepth
        self.maxIterations = maxIterations
        self.minLossReduction = minLossReduction
        self.minChildWeight = minChildWeight
        self.randomSeed = randomSeed
        self.stepSize = stepSize
        self.featureColumns = featureColumns
        self.earlyStoppingRounds = earlyStoppingRounds
        self.rowSubsample = rowSubsample
        self.columnSubsample = columnSubsample
    }
}

internal protocol PrismIntelligenceTrainingRuntime: Sendable {
    func trainTextClassifier(
        data: [PrismTextTrainingSample],
        configuration: PrismTextTrainingConfiguration,
        destination: URL
    ) async throws -> PrismIntelligenceModelMetrics

    func trainTabularRegressor(
        data: [PrismIntelligenceFeatureRow],
        configuration: PrismTabularTrainingConfiguration,
        destination: URL
    ) async throws -> PrismIntelligenceModelMetrics

    func trainTabularClassifier(
        data: [PrismIntelligenceFeatureRow],
        configuration: PrismTabularTrainingConfiguration,
        destination: URL
    ) async throws -> PrismIntelligenceModelMetrics
}
