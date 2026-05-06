//
//  PrismModelManager.swift
//  Prism
//
//  Created by Rafael Escaleira on 28/04/26.
//

import Foundation

public enum PrismModelType: String, Sendable, CaseIterable {
    case classifier
    case regressor
    case nlp
    case embedding
    case custom
}

public struct PrismModelInfo: Sendable, Equatable, Identifiable {
    public let id: String
    public let name: String
    public let type: PrismModelType
    public let size: Int64?
    public var isLoaded: Bool

    public init(id: String, name: String, type: PrismModelType, size: Int64? = nil, isLoaded: Bool = false) {
        self.id = id
        self.name = name
        self.type = type
        self.size = size
        self.isLoaded = isLoaded
    }
}

public actor PrismModelManager {
    private var models: [String: PrismModelInfo] = [:]

    public init() {}

    public func register(_ model: PrismModelInfo) {
        models[model.id] = model
    }

    public func unload(id: String) {
        guard var model = models[id] else { return }
        model.isLoaded = false
        models[id] = model
    }

    public var loadedModels: [PrismModelInfo] {
        Array(models.values)
    }

    public func swap(from sourceID: String, to targetID: String) {
        if var source = models[sourceID] {
            source.isLoaded = false
            models[sourceID] = source
        }
        if var target = models[targetID] {
            target.isLoaded = true
            models[targetID] = target
        }
    }

    public func model(for id: String) -> PrismModelInfo? {
        models[id]
    }

    public func remove(id: String) {
        models.removeValue(forKey: id)
    }

    public var count: Int {
        models.count
    }
}
