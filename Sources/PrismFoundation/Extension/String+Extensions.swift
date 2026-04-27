//
//  String+Extensions.swift
//  Prism
//
//  Created by Rafael Escaleira on 15/05/25.
//

import Foundation

extension String {
    /// Returns the string with a newline character appended.
    public var breakLine: String {
        self + "\n"
    }

    /// A newline character (`\n`).
    public static var breakLine: String {
        "\n"
    }

    /// Returns the string with a trailing space appended.
    public var space: String {
        self + " "
    }

    /// A single space character.
    public static var space: String {
        " "
    }

    /// The `Double` value parsed from this string, or `nil` if parsing fails.
    public var double: Double? {
        Double(self)
    }

    /// The `Int` value parsed from this string, or `nil` if parsing fails.
    public var int: Int? {
        Int(self)
    }

    /// A case- and diacritic-insensitive version of the string using the current locale.
    public var normalized: String {
        self.folding(
            options: [
                .diacriticInsensitive,
                .caseInsensitive,
            ],
            locale: .current
        )
    }

    /// Parses this string into a `Date` using the given formatter.
    ///
    /// - Parameter formatter: The date formatter to use for parsing.
    /// - Returns: The parsed `Date`, or `nil` if the string does not match the formatter's format.
    public func date(with formatter: PrismDateFormatter) -> Date? {
        formatter.date(from: self)
    }

    /// A deterministic 64-bit hash computed using the FNV-1a algorithm over the string's UTF-8 bytes.
    public var stableHash: Int64 {
        var hash: Int64 = 1_469_598_103_934_665_603
        let fnvPrime: Int64 = 1_099_511_628_211

        for byte in utf8 {
            hash = (hash ^ Int64(byte)) &* fnvPrime
        }

        return hash
    }
}

extension Substring {
    /// A deterministic 64-bit hash computed using the FNV-1a algorithm over the substring's UTF-8 bytes.
    public var stableHash: Int64 {
        var hash: Int64 = 1_469_598_103_934_665_603
        let fnvPrime: Int64 = 1_099_511_628_211

        for byte in utf8 {
            hash = (hash ^ Int64(byte)) &* fnvPrime
        }

        return hash
    }
}
