//
//  PrismRoutable.swift
//  Prism
//
//  Created by Rafael Escaleira on 03/04/25.
//

/// A protocol that route types must conform to for use with ``PrismRouter``.
///
/// Conforming types must be `Hashable`, `Identifiable`, and `Sendable`.
/// A default `id` implementation is provided that returns `self`.
public protocol PrismRoutable: Hashable, Identifiable, Sendable {}

extension PrismRoutable {
    /// The stable identity of the route, defaulting to the route value itself.
    public var id: Self {
        self
    }
}
