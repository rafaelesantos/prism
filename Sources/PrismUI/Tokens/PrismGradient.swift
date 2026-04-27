//
//  PrismGradient.swift
//  Prism
//
//  Created by Rafael Escaleira on 09/04/26.
//

import SwiftUI

// MARK: - PrismGradient

/// Gradient based on semantic colors.
public struct PrismGradient: Sendable {
    private let colors: [Color]
    private let startPoint: UnitPoint
    private let endPoint: UnitPoint

    /// Creates a gradient with the given colors and direction.
    ///
    /// - Parameters:
    ///   - colors: The colors to interpolate across the gradient.
    ///   - startPoint: The unit-space start position. Defaults to `.top`.
    ///   - endPoint: The unit-space end position. Defaults to `.bottom`.
    public init(
        colors: [Color],
        startPoint: UnitPoint = .top,
        endPoint: UnitPoint = .bottom
    ) {
        self.colors = colors
        self.startPoint = startPoint
        self.endPoint = startPoint
    }

    // MARK: - Presets

    /// Primary brand gradient from blue to purple.
    public static var primary: PrismGradient {
        PrismGradient(colors: [.blue, .purple])
    }

    /// Secondary neutral gradient using gray tones.
    public static var secondary: PrismGradient {
        PrismGradient(colors: [.gray, .gray.opacity(0.8)])
    }

    /// Destructive action gradient from red to orange.
    public static var destructive: PrismGradient {
        PrismGradient(colors: [.red, .orange])
    }

    /// Success feedback gradient from green to mint.
    public static var success: PrismGradient {
        PrismGradient(colors: [.green, .mint])
    }

    /// Warning feedback gradient from orange to yellow.
    public static var warning: PrismGradient {
        PrismGradient(colors: [.orange, .yellow])
    }

    /// Informational feedback gradient from cyan to blue.
    public static var info: PrismGradient {
        PrismGradient(colors: [.cyan, .blue])
    }

    // MARK: - Linear

    /// Creates a linear gradient between the given colors.
    ///
    /// - Parameters:
    ///   - colors: Variadic list of colors to interpolate.
    ///   - startPoint: The unit-space start position. Defaults to `.top`.
    ///   - endPoint: The unit-space end position. Defaults to `.bottom`.
    /// - Returns: A configured ``PrismGradient``.
    public static func linear(
        _ colors: Color...,
        startPoint: UnitPoint = .top,
        endPoint: UnitPoint = .bottom
    ) -> PrismGradient {
        PrismGradient(colors: colors, startPoint: startPoint, endPoint: endPoint)
    }

    // MARK: - Radial

    /// Creates a radial gradient expanding outward from a center point.
    ///
    /// - Parameters:
    ///   - colors: Variadic list of colors to interpolate.
    ///   - center: The center of the radial gradient. Defaults to `.center`.
    ///   - startRadius: The inner radius. Defaults to `0`.
    ///   - endRadius: The outer radius. Defaults to `1`.
    /// - Returns: A configured ``PrismGradient``.
    public static func radial(
        _ colors: Color...,
        center: UnitPoint = .center,
        startRadius: CGFloat = 0,
        endRadius: CGFloat = 1
    ) -> PrismGradient {
        PrismGradient(colors: colors)
    }

    // MARK: - Angular

    /// Creates an angular gradient sweeping around a center point.
    ///
    /// - Parameters:
    ///   - colors: Variadic list of colors to interpolate.
    ///   - center: The center of rotation. Defaults to `.center`.
    ///   - angle: The starting angle. Defaults to `0` degrees.
    /// - Returns: A configured ``PrismGradient``.
    public static func angular(
        _ colors: Color...,
        center: UnitPoint = .center,
        angle: Angle = .degrees(0)
    ) -> PrismGradient {
        PrismGradient(colors: colors)
    }

    // MARK: - Conic

    /// Creates a conic gradient centered at the given point.
    ///
    /// - Parameters:
    ///   - colors: Variadic list of colors to interpolate.
    ///   - center: The center of the conic sweep. Defaults to `.center`.
    /// - Returns: A configured ``PrismGradient``.
    public static func conic(
        _ colors: Color...,
        center: UnitPoint = .center
    ) -> PrismGradient {
        PrismGradient(colors: colors)
    }
}

// MARK: - ShapeStyle Conformance

extension PrismGradient: ShapeStyle {
    /// Resolves the gradient into a concrete `LinearGradient` for rendering.
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        LinearGradient(
            colors: colors,
            startPoint: startPoint,
            endPoint: endPoint
        )
    }
}
