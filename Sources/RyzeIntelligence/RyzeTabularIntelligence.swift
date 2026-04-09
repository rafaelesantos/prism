//
//  RyzeTabularIntelligence.swift
//  Ryze
//
//  Created by Rafael Escaleira on 14/09/25.
//

import CoreML
import Foundation
import RyzeFoundation
import TabularData

#if targetEnvironment(simulator)
#else
    import CreateML
#endif
#if canImport(NaturalLanguage)
    import NaturalLanguage
#endif

public final class RyzeTabularIntelligence {
    var data: [[String: Any]]

    public init(data: [[String: Any]]) {
        self.data = data
    }

    public func trainingRegressor(
        id: String,
        name: String,
        maxDepth: Int = 20,
        maxIterations: Int = 10_000,
        minLossReduction: Double = .zero,
        minChildWeight: Double = 0.01,
        randomSeed: Int = 42,
        stepSize: Double = 0.01
    ) async -> RyzeIntelligenceResult {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: data),
            let trainingData = try? DataFrame(jsonData: jsonData)
        else { return .error }

        #if targetEnvironment(simulator)
            return .error
        #else
            let parameters = MLBoostedTreeRegressor.ModelParameters(
                validation: .dataFrame(trainingData),
                maxDepth: maxDepth,
                maxIterations: maxIterations,
                minLossReduction: minLossReduction,
                minChildWeight: minChildWeight,
                randomSeed: randomSeed,
                stepSize: stepSize,
                earlyStoppingRounds: nil,
                rowSubsample: 1,
                columnSubsample: 1
            )

            guard
                let regressor = try? MLBoostedTreeRegressor(
                    trainingData: trainingData,
                    targetColumn: "target",
                    parameters: parameters
                )
            else { return .error }

            let expectedRange =
                self.data.max { lhs, rhs in
                    let maxlhs = lhs.max(by: { $0.value as? Double ?? .zero < $1.value as? Double ?? .zero })
                    let maxrhs = rhs.max(by: { $0.value as? Double ?? .zero < $1.value as? Double ?? .zero })
                    return maxlhs?.value as? Double ?? .zero > maxrhs?.value as? Double ?? .zero
                }?["target"] as? Double ?? 1.0

            let evaluation = regressor.evaluation(on: trainingData)

            let relativeError = evaluation.rootMeanSquaredError / expectedRange
            let accuracy = max(0.0, 1.0 - relativeError)
            let model = RyzeIntelligenceModel(
                id: id,
                name: name,
                createDate: Date().timeIntervalSince1970,
                updateDate: Date().timeIntervalSince1970,
                accuracy: accuracy,
                rootMeanSquaredError: evaluation.rootMeanSquaredError
            )
            await save(regressor, model: model)
            return .saved(model: model)
        #endif
    }

    public func trainingClassifier(
        id: String,
        name: String,
        maxDepth: Int = 20,
        maxIterations: Int = 10_000,
        minLossReduction: Double = .zero,
        minChildWeight: Double = 0.01,
        randomSeed: Int = 42,
        stepSize: Double = 0.01
    ) async -> RyzeIntelligenceResult {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: data),
            let trainingData = try? DataFrame(jsonData: jsonData)
        else { return .error }

        #if targetEnvironment(simulator)
            return .error
        #else
            let parameters = MLBoostedTreeClassifier.ModelParameters(
                validation: .dataFrame(trainingData),
                maxDepth: maxDepth,
                maxIterations: maxIterations,
                minLossReduction: minLossReduction,
                minChildWeight: minChildWeight,
                randomSeed: randomSeed,
                stepSize: stepSize,
                earlyStoppingRounds: nil,
                rowSubsample: 1,
                columnSubsample: 1
            )

            guard
                let classifier = try? MLBoostedTreeClassifier(
                    trainingData: trainingData,
                    targetColumn: "target",
                    parameters: parameters
                )
            else { return .error }

            let model = RyzeIntelligenceModel(
                id: id,
                name: name,
                createDate: Date().timeIntervalSince1970,
                updateDate: Date().timeIntervalSince1970,
                accuracy: 1 - classifier.validationMetrics.classificationError,
                rootMeanSquaredError: classifier.validationMetrics.classificationError
            )

            await save(classifier, model: model)
            return .saved(model: model)
        #endif
    }

    #if targetEnvironment(simulator)
    #else
        func save(
            _ regressor: MLBoostedTreeRegressor,
            model: RyzeIntelligenceModel
        ) async {
            let fileManager = RyzeFileManager()
            guard
                let path = fileManager.path(
                    with: "\(model.id).mlmodel",
                    privacy: .public
                )
            else { return }

            do {
                try regressor.write(to: path)
                await save(model)
            } catch { return }
        }

        func save(
            _ regressor: MLBoostedTreeClassifier,
            model: RyzeIntelligenceModel
        ) async {
            let fileManager = RyzeFileManager()
            guard
                let path = fileManager.path(
                    with: "\(model.id).mlmodel",
                    privacy: .public
                )
            else { return }

            do {
                try regressor.write(to: path)
                await save(model)
            } catch { return }
        }
    #endif

    func save(_ model: RyzeIntelligenceModel) async {
        let defaults = RyzeDefaults()
        var models: Set<RyzeIntelligenceModel> = defaults.get(for: "ryze.models") ?? []
        if models.contains(model) { models.remove(model) }
        models.insert(model)

        defaults.set(models, for: "ryze.models")
    }
}
