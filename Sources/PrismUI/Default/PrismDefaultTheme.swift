//
//  PrismTheme.swift
//  Prism
//
//  Created by Rafael Escaleira on 19/04/25.
//

import PrismFoundation
import SwiftUI

/// Default implementation of the Prism theme.
public struct PrismTheme: PrismThemeProtocol, Sendable {
    /// The color palette for the theme.
    public var color: PrismColorProtocol
    /// The spacing scale for the theme.
    public var spacing: PrismSpacingProtocol
    /// The border radius scale for the theme.
    public var radius: PrismRadiusProtocol
    /// The component size scale for the theme.
    public var size: PrismSizeProtocol
    /// The locale used for localized resources.
    public var locale: PrismLocale
    /// The default animation curve applied to interactive transitions.
    public var animation: Animation?
    /// The haptic feedback style triggered on interactions.
    public var feedback: SensoryFeedback
    /// An explicit color scheme override, or `nil` to follow the system.
    public var colorScheme: ColorScheme?
    /// The design token collection backing spacing, radius, font, and motion values.
    public var tokens: PrismDesignTokens

    /// Creates a theme with the given configuration values.
    public init(
        color: PrismColorProtocol = PrismDefaultColor(),
        spacing: PrismSpacingProtocol = PrismDefaultSpacing(),
        radius: PrismRadiusProtocol = PrismDefaultRadius(),
        size: PrismSizeProtocol = PrismDefaultSize(),
        locale: PrismLocale = .current,
        animation: Animation? = .spring(duration: 0.35, bounce: 0.25),
        feedback: SensoryFeedback = .impact,
        colorScheme: ColorScheme? = nil,
        tokens: PrismDesignTokens = .default
    ) {
        self.color = color
        self.spacing = spacing
        self.radius = radius
        self.size = size
        self.locale = locale
        self.animation = animation
        self.feedback = feedback
        self.colorScheme = colorScheme
        self.tokens = tokens
    }

    /// The standard light-mode theme with default tokens.
    public static var `default`: PrismTheme {
        PrismTheme()
    }

    /// A dark-mode theme variant using ``PrismDefaultColor/dark``.
    public static var dark: PrismTheme {
        PrismTheme(
            color: PrismDefaultColor.dark,
            colorScheme: .dark
        )
    }

    /// A high-contrast theme variant for improved accessibility.
    public static var highContrast: PrismTheme {
        PrismTheme(
            color: PrismDefaultColor.highContrast,
            animation: .linear(duration: 0.2),
            feedback: .success
        )
    }

    /// A compact theme variant using ``PrismDesignTokens/compact`` tokens.
    public static var compact: PrismTheme {
        PrismTheme(tokens: .compact)
    }

    /// An expanded theme variant using ``PrismDesignTokens/expanded`` tokens.
    public static var expanded: PrismTheme {
        PrismTheme(tokens: .expanded)
    }

    /// Returns a copy of this theme with a different color palette.
    public func with(color: PrismColorProtocol) -> PrismTheme {
        PrismTheme(
            color: color,
            spacing: spacing,
            radius: radius,
            size: size,
            locale: locale,
            animation: animation,
            feedback: feedback,
            colorScheme: colorScheme,
            tokens: tokens
        )
    }

    /// Returns a copy of this theme with a different color scheme override.
    public func with(colorScheme: ColorScheme?) -> PrismTheme {
        PrismTheme(
            color: color,
            spacing: spacing,
            radius: radius,
            size: size,
            locale: locale,
            animation: animation,
            feedback: feedback,
            colorScheme: colorScheme,
            tokens: tokens
        )
    }

    /// Returns a copy of this theme with a different animation curve.
    public func with(animation: Animation?) -> PrismTheme {
        PrismTheme(
            color: color,
            spacing: spacing,
            radius: radius,
            size: size,
            locale: locale,
            animation: animation,
            feedback: feedback,
            colorScheme: colorScheme,
            tokens: tokens
        )
    }

    /// Returns a copy of this theme with a different design token collection.
    public func with(tokens: PrismDesignTokens) -> PrismTheme {
        PrismTheme(
            color: color,
            spacing: spacing,
            radius: radius,
            size: size,
            locale: locale,
            animation: animation,
            feedback: feedback,
            colorScheme: colorScheme,
            tokens: tokens
        )
    }
}

extension PrismThemeProtocol {
    /// Type-erases any ``PrismThemeProtocol`` conformance into a concrete ``PrismTheme``.
    public func eraseToAnyTheme() -> PrismTheme {
        PrismTheme(
            color: color,
            spacing: spacing,
            radius: radius,
            size: size,
            locale: locale,
            animation: animation,
            feedback: feedback,
            colorScheme: colorScheme,
            tokens: tokens
        )
    }
}
