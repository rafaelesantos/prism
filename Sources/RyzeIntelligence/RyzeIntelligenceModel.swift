//
//  RyzeIntelligenceModel.swift
//  Ryze
//
//  Created by Rafael Escaleira on 13/09/25.
//

import Foundation
import RyzeFoundation

public struct RyzeIntelligenceModel: RyzeEntity, Sendable {
    public var id: String
    public var name: String
    public var isTraining: Bool
    public var createDate: TimeInterval?
    public var updateDate: TimeInterval?
    public var accuracy: Double?
    public var rootMeanSquaredError: Double?

    public init(
        id: String,
        name: String,
        isTraining: Bool = false,
        createDate: TimeInterval? = nil,
        updateDate: TimeInterval? = nil,
        accuracy: Double? = nil,
        rootMeanSquaredError: Double? = nil
    ) {
        self.id = id
        self.name = name
        self.isTraining = isTraining
        self.createDate = createDate
        self.updateDate = updateDate
        self.accuracy = accuracy
        self.rootMeanSquaredError = rootMeanSquaredError
    }

    public var size: String {
        let id = "\(id).mlmodel"
        let fileManager = RyzeFileManager()
        let path = fileManager.path(with: id, privacy: .public)
        return fileManager.size(at: path)
    }

    public static var models: [RyzeIntelligenceModel] {
        let defaults = RyzeDefaults()
        let models: [RyzeIntelligenceModel] = defaults.get(for: "ryze.models") ?? []
        return models
    }

    public static func clean() {
        let defaults = RyzeDefaults()
        let models: [RyzeIntelligenceModel] = []
        defaults.set(models, for: "ryze.models")
    }
}
