//
//  PrismIntelligenceCatalog.swift
//  Prism
//
//  Created by Rafael Escaleira on 11/04/26.
//

import Foundation
import PrismFoundation

/// A catalog of persisted intelligence models.
///
/// `PrismIntelligenceCatalog` manages the storage and retrieval of
/// ``PrismIntelligenceModel`` records in user defaults.
public actor PrismIntelligenceCatalog {
    private let defaults: PrismDefaults

    /// Creates a catalog backed by the given defaults store.
    ///
    /// - Parameter defaults: The defaults store used for persistence.
    public init(
        defaults: PrismDefaults = .init()
    ) {
        self.defaults = defaults
    }

    /// Returns all persisted models sorted by most recently updated.
    ///
    /// - Returns: An array of ``PrismIntelligenceModel``.
    public func allModels() -> [PrismIntelligenceModel] {
        PrismIntelligenceModel.loadStoredModels(defaults: defaults)
    }

    /// Returns the model with the given identifier, if it exists.
    ///
    /// - Parameter id: The model identifier to search for.
    /// - Returns: The matching model, or `nil` if not found.
    public func model(
        id: String
    ) -> PrismIntelligenceModel? {
        allModels().first { $0.id == id }
    }

    /// Persists a model, inserting or replacing an existing record with the same identifier.
    ///
    /// - Parameter model: The model to save.
    public func save(
        _ model: PrismIntelligenceModel
    ) {
        var models = allModels()

        if let index = models.firstIndex(where: { $0.id == model.id }) {
            models[index] = model
        } else {
            models.append(model)
        }

        PrismIntelligenceModel.persistStoredModels(
            models,
            defaults: defaults
        )
    }

    /// Removes the model with the given identifier from the catalog.
    ///
    /// - Parameter id: The identifier of the model to remove.
    /// - Returns: The removed model, or `nil` if no model matched.
    @discardableResult
    public func remove(
        id: String
    ) -> PrismIntelligenceModel? {
        var models = allModels()
        guard let index = models.firstIndex(where: { $0.id == id }) else {
            return nil
        }

        let removed = models.remove(at: index)
        PrismIntelligenceModel.persistStoredModels(
            models,
            defaults: defaults
        )
        return removed
    }

    /// Removes all models from the catalog.
    public func clean() {
        PrismIntelligenceModel.persistStoredModels(
            [],
            defaults: defaults
        )
    }
}
