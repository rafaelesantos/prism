//
//  PrismShape.swift
//  Prism
//
//  Created by Rafael Escaleira on 26/04/25.
//

import SwiftUI

/// Custom shape for the PrismUI Design System.
///
/// `PrismShape` is a `Shape` wrapper that provides common geometric shapes:
/// - Perfect circle
/// - Capsule (fully rounded rectangle)
/// - Rectangle with custom corner radius
/// - Compatible with `.clipShape()` and `.background()`
///
/// ## Basic Usage
/// ```swift
/// PrismShape(.circle)
///     .prism(background: .primary)
/// ```
///
/// ## As Clip Shape
/// ```swift
/// PrismImage("photo")
///     .prism(clip: .rounded(radius: 12))
/// ```
///
/// ## Available Shapes
/// - `.circle` - Perfect circle
/// - `.capsule` - Capsule (pill shape)
/// - `.rounded(radius: CGFloat)` - Rectangle with custom corner radius
///
/// - Note: Use with `prism(clip:)` or `prism(background:)` to apply shapes.
public struct PrismShape: Shape {
    var base: @Sendable (CGRect) -> Path

    public init<S: Shape>(shape: S) {
        base = shape.path(in:)
    }

    public func path(in rect: CGRect) -> Path {
        base(rect)
    }

    public static var capsule: PrismShape {
        .init(shape: .capsule)
    }

    public static var circle: PrismShape {
        .init(shape: .circle)
    }

    public static func rounded(radius: CGFloat) -> PrismShape {
        .init(shape: .rect(cornerRadius: radius))
    }
}
