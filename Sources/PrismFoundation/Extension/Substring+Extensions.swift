//
//  Substring+Extensions.swift
//  Prism
//
//  Created by Rafael Escaleira on 27/08/25.
//

import Foundation

extension Substring {
    /// This substring converted to a `String`.
    public var string: String {
        String(self)
    }

    /// The `Int` value parsed from this substring, or `nil` if parsing fails.
    public var int: Int? {
        Int(self)
    }

    /// The `Double` value parsed from this substring, or `nil` if parsing fails.
    public var double: Double? {
        Double(self)
    }
}
