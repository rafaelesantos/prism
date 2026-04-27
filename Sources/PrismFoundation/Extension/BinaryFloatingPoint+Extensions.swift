//
//  BinaryFloatingPoint+Extensions.swift
//  Prism
//
//  Created by Rafael Escaleira on 02/06/25.
//

import Foundation

extension BinaryFloatingPoint {
    /// The absolute value of this number.
    public var abs: Self {
        Swift.abs(self)
    }

    /// This value converted to `Double`.
    public var double: Double {
        Double(self)
    }

    /// This value truncated to an `Int`.
    public var int: Int {
        Int(self)
    }

    /// The string representation of this value as a `Double`.
    public var string: String {
        String(double)
    }

    /// This value truncated to an `Int64`.
    public var int64: Int64 {
        Int64(self)
    }

    /// Formats this value as a decimal string with grouping separators.
    ///
    /// - Parameters:
    ///   - decimals: The number of decimal places. Defaults to `2`.
    ///   - locale: The locale for formatting. Defaults to `.current`.
    /// - Returns: The formatted string, or `nil` if formatting fails.
    public func formatted(decimals: Int = 2, locale: Locale = .current) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = decimals
        formatter.maximumFractionDigits = decimals
        formatter.locale = locale
        formatter.usesGroupingSeparator = true
        return formatter.string(from: NSNumber(value: double))
    }

    /// Formats this value as a currency string using the given locale.
    ///
    /// - Parameter locale: The locale for currency formatting. Defaults to `.current`.
    /// - Returns: The formatted currency string, or `nil` if formatting fails.
    public func currency(locale: Locale = .current) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = locale
        return formatter.string(from: NSNumber(value: double))
    }

    /// This value scaled by 10^8 and rounded to the nearest integer, useful for fixed-point arithmetic.
    public var largeNormalized: Int64 {
        let scale: Double = 100_000_000
        let normalized = Int64((double * scale).rounded())
        return normalized
    }
}
