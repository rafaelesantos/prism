//
//  PrismLocaleManager.swift
//  Prism
//
//  Created by Rafael Escaleira on 27/04/26.
//

import Foundation
import Observation

@Observable
@MainActor
public final class PrismLocaleManager {
    private static let defaultsKey = "com.prism.selectedLocale"

    public var current: PrismLocale {
        didSet {
            if persistsSelection {
                persistLocale(current)
            }
        }
    }

    public let available: [PrismLocale]

    public let persistsSelection: Bool

    public init(
        initial: PrismLocale? = nil,
        available: [PrismLocale] = PrismLocale.allCases.map { $0 },
        persistsSelection: Bool = true
    ) {
        self.available = available
        self.persistsSelection = persistsSelection
        self.current = initial ?? Self.restoredLocale() ?? .current
    }

    // MARK: - Persistence

    private static func restoredLocale() -> PrismLocale? {
        guard let identifier = UserDefaults.standard.string(forKey: defaultsKey) else {
            return nil
        }
        return PrismLocale.allCases.first { $0.identifier == identifier }
    }

    private func persistLocale(_ locale: PrismLocale) {
        UserDefaults.standard.set(locale.identifier, forKey: Self.defaultsKey)
    }
}
