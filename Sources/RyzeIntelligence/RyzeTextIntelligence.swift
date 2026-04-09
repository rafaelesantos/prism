//
//  RyzeTextIntelligence.swift
//  Ryze
//
//  Created by Rafael Escaleira on 13/09/25.
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

public final class RyzeTextIntelligence {
    let data: [[String: String]]

    public init(data: [[String: String]]) {
        self.data = data
    }

    public func trainingTextClassifier(
        id: String,
        name: String,
        maxIterations: Int? = nil
    ) async -> RyzeIntelligenceResult {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: data),
            let trainingData = try? DataFrame(jsonData: jsonData)
        else { return .error }

        #if targetEnvironment(simulator)
            return .error
        #elseif os(macOS) || os(iOS)
            var parameters = MLTextClassifier.ModelParameters(
                validation: .dataFrame(
                    trainingData,
                    textColumn: "text",
                    labelColumn: "label"
                ),
                algorithm: .transferLearning(.bertEmbedding, revision: nil),
                language: RyzeLocale.current.naturalLanguage
            )
            parameters.maxIterations = maxIterations

            guard
                let classifier = try? MLTextClassifier(
                    trainingData: trainingData,
                    textColumn: "text",
                    labelColumn: "label",
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
        #else
            return .error
        #endif
    }

    #if targetEnvironment(simulator)
    #elseif os(macOS) || os(iOS)
        func save(
            _ classifier: MLTextClassifier,
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
                try classifier.write(to: path)
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
