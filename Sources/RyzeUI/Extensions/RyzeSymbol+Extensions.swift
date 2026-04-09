//
//  RyzeSymbol+Extensions.swift
//  Ryze
//
//  Created by Rafael Escaleira on 02/09/25.
//

import Foundation

extension RyzeSymbol {
    public static var allSymbols: [String] {
        guard let symbols = try? RyzeUIFile.symbols.data.entity(for: [String].self) else { return [] }
        return symbols
    }
}
