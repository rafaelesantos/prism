//
//  PrismNavigationType.swift
//  Prism
//
//  Created by Rafael Escaleira on 03/04/25.
//

/// Navigation styles supported by ``PrismRouter``.
public enum PrismNavigationStyle: Sendable, Codable {
    /// Pushes the route onto the navigation stack.
    case push
    /// Presents the route as a modal sheet.
    case present
    /// Presents the route as a full-screen cover.
    case full
}
