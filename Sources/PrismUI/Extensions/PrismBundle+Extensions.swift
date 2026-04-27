//
//  PrismBundle+Extensions.swift
//  Prism
//
//  Created by Rafael Escaleira on 06/06/25.
//

import Foundation
import PrismFoundation

extension PrismBundle {
    /// Retrieves all available SF Symbol names from the system `CoreGlyphs` bundle.
    ///
    /// Reads the `name_availability.plist` from `com.apple.CoreGlyphs` and returns
    /// the symbol keys sorted alphabetically.
    ///
    /// - Throws: ``PrismUIError/systemSymbolNotFound`` if the CoreGlyphs bundle or plist is unavailable.
    /// - Returns: A sorted array of SF Symbol name strings.
    public func getSymbols() async throws(PrismUIError) -> [String] {
        guard let bundle = Bundle(identifier: "com.apple.CoreGlyphs") else {
            throw .systemSymbolNotFound
        }

        guard let resourcePath = bundle.path(forResource: "name_availability", ofType: "plist"),
            let plist = NSDictionary(contentsOfFile: resourcePath),
            let plistSymbols = plist["symbols"] as? [String: String]
        else {
            throw .systemSymbolNotFound
        }

        return plistSymbols.map(\.key).sorted(by: <)
    }
}
