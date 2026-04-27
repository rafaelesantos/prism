//
//  Array+Extensions.swift
//  Prism
//
//  Created by Rafael Escaleira on 29/08/25.
//

import Foundation

extension Array {
    /// Asynchronously transforms each element of the array using the given closure.
    ///
    /// - Parameter transform: An async throwing closure that converts each element to type `T`.
    /// - Returns: An array of transformed elements, preserving order.
    public func asyncMap<T>(
        _ transform: @Sendable @escaping (Element) async throws -> T
    ) async rethrows -> [T] {
        var results = [T]()
        for item in self {
            try await results.append(transform(item))
        }
        return results
    }

    /// Asynchronously transforms each element and returns only non-nil results.
    ///
    /// - Parameter transform: An async throwing closure that returns an optional transformed value.
    /// - Returns: An array of non-nil transformed elements, preserving order.
    public func asyncCompactMap<T>(
        _ transform: @Sendable @escaping (Element) async throws -> T?
    ) async rethrows -> [T] {
        var results = [T]()
        for item in self {
            if let transformed = try await transform(item) {
                results.append(transformed)
            }
        }
        return results
    }

    /// Asynchronously filters elements using the given predicate.
    ///
    /// - Parameter predicate: An async throwing closure that returns `true` for elements to keep.
    /// - Returns: An array of elements satisfying the predicate, preserving order.
    public func asyncFilter(
        _ predicate: @Sendable @escaping (Element) async throws -> Bool
    ) async rethrows -> [Element] {
        var results = [Element]()
        for item in self {
            if try await predicate(item) {
                results.append(item)
            }
        }
        return results
    }

    /// The second element of the array, or `nil` if the array has fewer than two elements.
    public var second: Element? {
        count > 1 ? self[1] : nil
    }

    /// The second-to-last element of the array, or `nil` if the array has fewer than two elements.
    public var secondToLast: Element? {
        count > 1 ? self[count - 2] : nil
    }

    /// Splits the array into chunks of the specified size.
    ///
    /// - Parameter size: The maximum number of elements per chunk. Must be greater than zero.
    /// - Returns: An array of arrays, each containing at most `size` elements.
    public func chunked(into size: Int) -> [[Element]] {
        guard size > 0 else { return [] }

        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

extension Sequence {
    /// Sorts the sequence by an optional key path, placing `nil` values at the end.
    ///
    /// - Parameters:
    ///   - keyPath: A key path to an optional `Comparable` property on each element.
    ///   - comparator: A comparison closure. Defaults to ascending order (`<`).
    /// - Returns: A sorted array of elements.
    public func sorted<T: Comparable>(
        by keyPath: KeyPath<Element, T?>,
        using comparator: (T, T) -> Bool = (<)
    ) -> [Element] {
        sorted {
            switch ($0[keyPath: keyPath], $1[keyPath: keyPath]) {
            case (let lhs?, let rhs?):
                return comparator(lhs, rhs)
            case (.some, nil):
                return true
            case (nil, .some), (nil, nil):
                return false
            }
        }
    }
}

extension Array {
    /// Safely accesses the element at the given index, returning `nil` if the index is out of bounds.
    public subscript(safe index: Index) -> Element? {
        index >= .zero && index < count ? self[index] : nil
    }
}
