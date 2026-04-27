//
//  Data+Extensions.swift
//  Prism
//
//  Created by Rafael Escaleira on 24/03/25.
//

import Foundation

extension Data {
    /// The UTF-8 decoded string representation of the data.
    public var string: String {
        String(decoding: self, as: UTF8.self)
    }

    /// Decodes the data into a `Decodable` entity using JSON decoding.
    ///
    /// - Parameters:
    ///   - type: The type to decode.
    ///   - formatter: An optional date formatter for date decoding strategy. If `nil`, the default strategy is used.
    /// - Returns: A decoded instance of `T`.
    /// - Throws: A `DecodingError` if the data cannot be decoded into the given type.
    public func entity<T: Decodable>(
        for type: T.Type,
        with formatter: DateFormatter? = nil
    ) throws -> T {
        let jsonDecoder = JSONDecoder()
        guard let formatter else { return try jsonDecoder.decode(T.self, from: self) }
        jsonDecoder.dateDecodingStrategy = .formatted(formatter)
        return try jsonDecoder.decode(T.self, from: self)
    }

    /// Splits the data into ranges delimited by the given ASCII scalar.
    ///
    /// - Parameter code: The ASCII scalar to use as a delimiter.
    /// - Returns: An array of ranges representing each field between delimiters.
    public func fieldRanges(for code: Unicode.Scalar) -> [Range<Data.Index>] {
        guard code.isASCII else { return [startIndex..<endIndex] }

        var ranges: [Range<Data.Index>] = []
        var start = startIndex
        var index = start

        while index < endIndex {
            if self[index] == UInt8(ascii: code) {
                ranges.append(start..<index)
                formIndex(after: &index)
                start = index
                continue
            }
            formIndex(after: &index)
        }

        ranges.append(start..<endIndex)
        return ranges
    }

    /// Parses an integer from the raw ASCII bytes within the given range.
    ///
    /// - Parameter range: The byte range to parse.
    /// - Returns: The parsed `Int`, or `nil` if the bytes do not represent a valid integer.
    public func int(in range: Range<Index>) -> Int? {
        guard !range.isEmpty else { return nil }

        var index = range.lowerBound
        var isNegative = false
        var value = 0

        if self[index] == UInt8(ascii: "-") {
            isNegative = true
            formIndex(after: &index)
        }

        guard index < range.upperBound else { return nil }

        while index < range.upperBound {
            let byte = self[index]
            guard byte >= UInt8(ascii: "0"), byte <= UInt8(ascii: "9") else { return nil }
            value = value * 10 + Int(byte - UInt8(ascii: "0"))
            formIndex(after: &index)
        }

        return isNegative ? -value : value
    }

    /// Parses a double from the raw ASCII bytes within the given range.
    ///
    /// Supports both `.` and `,` as decimal separators.
    ///
    /// - Parameter range: The byte range to parse.
    /// - Returns: The parsed `Double`, or `nil` if the bytes do not represent a valid number.
    public func double(in range: Range<Index>) -> Double? {
        guard !range.isEmpty else { return nil }

        var index = range.lowerBound
        var isNegative = false
        var integerPart = 0.0
        var fractionalPart = 0.0
        var divisor = 1.0
        var hasDecimalSeparator = false

        if self[index] == UInt8(ascii: "-") {
            isNegative = true
            formIndex(after: &index)
        }

        guard index < range.upperBound else { return nil }

        while index < range.upperBound {
            let byte = self[index]

            if byte == UInt8(ascii: ".") || byte == UInt8(ascii: ",") {
                guard !hasDecimalSeparator else { return nil }
                hasDecimalSeparator = true
                formIndex(after: &index)
                continue
            }

            guard byte >= UInt8(ascii: "0"), byte <= UInt8(ascii: "9") else { return nil }

            let digit = Double(byte - UInt8(ascii: "0"))

            if hasDecimalSeparator {
                divisor *= 10
                fractionalPart = fractionalPart * 10 + digit
            } else {
                integerPart = integerPart * 10 + digit
            }

            formIndex(after: &index)
        }

        let value = integerPart + fractionalPart / divisor
        return isNegative ? -value : value
    }

    /// Returns the single byte within the given range, or `nil` if the range does not contain exactly one byte.
    ///
    /// - Parameter range: The byte range to read.
    /// - Returns: The byte value, or `nil` if the range is empty or spans more than one byte.
    public func byte(in range: Range<Index>) -> UInt8? {
        guard !range.isEmpty else { return nil }
        let next = index(after: range.lowerBound)
        guard next == range.upperBound else { return nil }
        return self[range.lowerBound]
    }

    /// Checks whether the bytes in the given range are equal to the provided ASCII string.
    ///
    /// - Parameters:
    ///   - ascii: The ASCII string to compare against.
    ///   - range: The byte range within the data to compare.
    /// - Returns: `true` if the bytes match exactly.
    public func equalsASCII(_ ascii: StaticString, in range: Range<Index>) -> Bool {
        let bytes = ascii.withUTF8Buffer { buffer in
            Array(buffer)
        }

        guard distance(from: range.lowerBound, to: range.upperBound) == bytes.count else {
            return false
        }

        var index = range.lowerBound
        var offset = 0

        while index < range.upperBound {
            if self[index] != bytes[offset] {
                return false
            }
            formIndex(after: &index)
            offset += 1
        }

        return true
    }

    /// Checks whether the data begins with the given ASCII string.
    ///
    /// - Parameter ascii: The ASCII prefix to check for.
    /// - Returns: `true` if the data starts with the given bytes.
    public func hasPrefixASCII(_ ascii: StaticString) -> Bool {
        guard !isEmpty else { return ascii.utf8CodeUnitCount == 0 }

        let bytes = ascii.withUTF8Buffer { buffer in
            Array(buffer)
        }

        guard count >= bytes.count else { return false }

        var index = startIndex
        var offset = 0

        while offset < bytes.count {
            if self[index] != bytes[offset] {
                return false
            }
            formIndex(after: &index)
            offset += 1
        }

        return true
    }

    /// Decodes the bytes in the given range as a UTF-8 string.
    ///
    /// - Parameter range: The byte range to decode.
    /// - Returns: The decoded string, or `nil` if the bytes are not valid UTF-8.
    public func string(in range: Range<Index>) -> String? {
        String(data: self[range], encoding: .utf8)
    }
}
