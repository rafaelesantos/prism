//
//  Encodable+Extensions.swift
//  Prism
//
//  Created by Rafael Escaleira on 24/03/25.
//

import Foundation

extension Encodable {
    /// The pretty-printed JSON string representation of this value.
    ///
    /// - Throws: An `EncodingError` if the value cannot be encoded.
    public var json: String {
        get throws {
            return try data().string
        }
    }

    /// Encodes this value to JSON `Data` using the given date formatter.
    ///
    /// - Parameter formatter: The date formatter to use for date encoding.
    /// - Returns: The encoded JSON data with pretty-printing and sorted keys.
    /// - Throws: An `EncodingError` if the value cannot be encoded.
    public func data(with formatter: DateFormatter) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .formatted(formatter)
        return try encoder.encode(self)
    }

    /// Encodes this value to JSON `Data` using a date formatter configured with the given style.
    ///
    /// - Parameter dateStyle: The date style to use. Defaults to `.long`.
    /// - Returns: The encoded JSON data.
    /// - Throws: An `EncodingError` if the value cannot be encoded.
    public func data(with dateStyle: DateFormatter.Style = .long) throws -> Data {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        dateFormatter.dateStyle = dateStyle
        return try data(with: dateFormatter)
    }
}
