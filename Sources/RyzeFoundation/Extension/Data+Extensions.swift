//
//  Data+Extensions.swift
//  Ryze
//
//  Created by Rafael Escaleira on 24/03/25.
//

@_exported import Foundation

public extension Data {
    var string: String {
        String(
            data: self,
            encoding: .utf8
        ).unsafelyUnwrapped
    }
    
    func entity<T: Decodable>(
        for type: T.Type,
        with formatter: DateFormatter? = nil
    ) throws -> T {
        let jsonDecoder = JSONDecoder()
        guard let formatter else { return try jsonDecoder.decode(T.self, from: self) }
        jsonDecoder.dateDecodingStrategy = .formatted(formatter)
        return try jsonDecoder.decode(T.self, from: self)
    }
    
    func fieldRanges(for code: Unicode.Scalar) -> [Range<Data.Index>] {
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

    func int(in range: Range<Index>) -> Int? {
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

    func double(in range: Range<Index>) -> Double? {
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

    func byte(in range: Range<Index>) -> UInt8? {
        guard !range.isEmpty else { return nil }
        let next = index(after: range.lowerBound)
        guard next == range.upperBound else { return nil }
        return self[range.lowerBound]
    }

    func equalsASCII(_ ascii: StaticString, in range: Range<Index>) -> Bool {
        guard let bytes = ascii.withUTF8Buffer({ buffer -> [UInt8]? in
            Array(buffer)
        }) else {
            return false
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

    func hasPrefixASCII(_ ascii: StaticString) -> Bool {
        guard let bytes = ascii.withUTF8Buffer({ buffer -> [UInt8]? in
            Array(buffer)
        }) else {
            return false
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

    func string(in range: Range<Index>) -> String? {
        String(data: self[range], encoding: .utf8)
    }
}
