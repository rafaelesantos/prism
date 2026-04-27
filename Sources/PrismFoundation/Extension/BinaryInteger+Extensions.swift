//
//  BinaryInteger+Extensions.swift
//  Prism
//
//  Created by Rafael Escaleira on 02/06/25.
//

import Foundation

extension BinaryInteger {
    /// Whether this integer is even.
    public var isEven: Bool {
        self % 2 == 0
    }

    /// Whether this integer is odd.
    public var isOdd: Bool {
        !isEven
    }

    /// This value converted to `Double`.
    public var double: Double {
        Double(self)
    }

    /// The string representation of this integer.
    public var string: String {
        String(self)
    }

    /// A `Date` created by treating this integer as a Unix timestamp in seconds.
    public var timestamp: Date {
        Date(timeIntervalSince1970: TimeInterval(self))
    }

    /// A `Date` created by treating this integer as a Unix timestamp in milliseconds.
    public var milliseconds: Date {
        Date(timeIntervalSince1970: TimeInterval(self) / 1000)
    }

    /// Formats this integer as a decimal string using the current locale.
    ///
    /// - Parameter withSeparator: Whether to include grouping separators. Defaults to `true`.
    /// - Returns: The formatted string, or `nil` if formatting fails.
    public func formatted(withSeparator: Bool = true) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        formatter.usesGroupingSeparator = withSeparator
        let number = NSNumber(value: Int64(self))
        return formatter.string(from: number)
    }

    /// Formats this integer as a currency string using the given locale.
    ///
    /// - Parameter locale: The locale for currency formatting. Defaults to `.current`.
    /// - Returns: The formatted currency string, or `nil` if formatting fails.
    public func currency(locale: Locale = .current) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = locale
        let number = NSNumber(value: Int64(self))
        return formatter.string(from: number)
    }
}
