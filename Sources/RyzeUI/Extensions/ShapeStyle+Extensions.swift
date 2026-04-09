//
//  ShapeStyle+Extensions.swift
//  Ryze
//
//  Created by Rafael Escaleira on 01/07/25.
//

import SwiftUI

extension ShapeStyle where Self == RyzeColor {
    public static var primary: RyzeColor { .init(keyPath: \.primary) }
    public static var secondary: RyzeColor { .init(keyPath: \.secondary) }
    public static var background: RyzeColor { .init(keyPath: \.background) }
    public static var backgroundSecondary: RyzeColor { .init(keyPath: \.backgroundSecondary) }
    public static var shadow: RyzeColor { .init(keyPath: \.shadow) }
    public static var surface: RyzeColor { .init(keyPath: \.surface) }
    public static var text: RyzeColor { .init(keyPath: \.text) }
    public static var textSecondary: RyzeColor { .init(keyPath: \.textSecondary) }
    public static var border: RyzeColor { .init(keyPath: \.border) }
    public static var error: RyzeColor { .init(keyPath: \.error) }
    public static var success: RyzeColor { .init(keyPath: \.success) }
    public static var warning: RyzeColor { .init(keyPath: \.warning) }
    public static var info: RyzeColor { .init(keyPath: \.info) }
    public static var disabled: RyzeColor { .init(keyPath: \.disabled) }
    public static var hover: RyzeColor { .init(keyPath: \.hover) }
    public static var pressed: RyzeColor { .init(keyPath: \.pressed) }
    public static var white: RyzeColor { .init(keyPath: \.white) }
    public static var black: RyzeColor { .init(keyPath: \.black) }

    public static func hex(_ hex: String?) -> RyzeColor {
        guard let hex else { return .primary }
        return .init(rawValue: .init(hex: hex))
    }

    public static func color(_ color: Color?) -> RyzeColor {
        guard let color else { return .primary }
        return .init(rawValue: color)
    }
}
