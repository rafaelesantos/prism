//
//  ShapeStyle+Extensions.swift
//  Prism
//
//  Created by Rafael Escaleira on 01/07/25.
//

import SwiftUI

/// Semantic ``PrismColor`` tokens accessible as `ShapeStyle` static members.
///
/// These properties resolve at render time using the current theme's design tokens,
/// enabling theme-aware styling throughout the view hierarchy.
///
/// ```swift
/// PrismText("Hello")
///     .foregroundStyle(.textSecondary)
/// ```
extension ShapeStyle where Self == PrismColor {
    /// The theme's primary accent color.
    public static var primary: PrismColor { .init(keyPath: \.primary) }
    /// The theme's secondary accent color.
    public static var secondary: PrismColor { .init(keyPath: \.secondary) }
    /// The theme's primary background color.
    public static var background: PrismColor { .init(keyPath: \.background) }
    /// The theme's secondary background color, for grouped or inset content.
    public static var backgroundSecondary: PrismColor { .init(keyPath: \.backgroundSecondary) }
    /// The theme's shadow color.
    public static var shadow: PrismColor { .init(keyPath: \.shadow) }
    /// The theme's surface color for cards and elevated elements.
    public static var surface: PrismColor { .init(keyPath: \.surface) }
    /// The theme's primary text color.
    public static var text: PrismColor { .init(keyPath: \.text) }
    /// The theme's secondary text color for captions and subtitles.
    public static var textSecondary: PrismColor { .init(keyPath: \.textSecondary) }
    /// The theme's border/separator color.
    public static var border: PrismColor { .init(keyPath: \.border) }
    /// The theme's error/destructive color.
    public static var error: PrismColor { .init(keyPath: \.error) }
    /// The theme's success/positive color.
    public static var success: PrismColor { .init(keyPath: \.success) }
    /// The theme's warning/caution color.
    public static var warning: PrismColor { .init(keyPath: \.warning) }
    /// The theme's informational color.
    public static var info: PrismColor { .init(keyPath: \.info) }
    /// The theme's disabled/inactive color.
    public static var disabled: PrismColor { .init(keyPath: \.disabled) }
    /// The theme's hover highlight color.
    public static var hover: PrismColor { .init(keyPath: \.hover) }
    /// The theme's pressed/active state color.
    public static var pressed: PrismColor { .init(keyPath: \.pressed) }
    /// A constant white color, independent of theme.
    public static var white: PrismColor { .init(keyPath: \.white) }
    /// A constant black color, independent of theme.
    public static var black: PrismColor { .init(keyPath: \.black) }

    /// Creates a ``PrismColor`` from a hex string (e.g., `"#FF5733"`).
    ///
    /// - Parameter hex: A hex color string. When `nil`, falls back to `.primary`.
    /// - Returns: A ``PrismColor`` wrapping the parsed color.
    public static func hex(_ hex: String?) -> PrismColor {
        guard let hex else { return .primary }
        return .init(rawValue: .init(hex: hex))
    }

    /// Creates a ``PrismColor`` wrapping an existing SwiftUI `Color`.
    ///
    /// - Parameter color: A SwiftUI `Color`. When `nil`, falls back to `.primary`.
    /// - Returns: A ``PrismColor`` wrapping the given color.
    public static func color(_ color: Color?) -> PrismColor {
        guard let color else { return .primary }
        return .init(rawValue: color)
    }
}
