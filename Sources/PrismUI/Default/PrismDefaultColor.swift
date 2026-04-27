//
//  PrismDefaultColor.swift
//  Prism
//
//  Created by Rafael Escaleira on 19/04/25.
//

import SwiftUI

/// Default implementation of theme colors.
public struct PrismDefaultColor: PrismColorProtocol {

    // MARK: - Static Asset Helper

    @usableFromInline
    static func asset(_ name: String) -> Color {
        Color(name, bundle: .module)
    }

    // MARK: - Brand Colors

    /// Primary brand color used for key actions and highlights.
    public var primary: Color
    /// Secondary brand color for supporting elements.
    public var secondary: Color
    /// Accent color for emphasis and call-to-action elements.
    public var accent: Color

    // MARK: - Background Colors

    /// Main background color for the application canvas.
    public var background: Color
    /// Secondary background color for grouped or nested content areas.
    public var backgroundSecondary: Color
    /// Surface color for cards, sheets, and elevated containers.
    public var surface: Color

    // MARK: - Text Colors

    /// Primary text color for headings and body copy.
    public var text: Color
    /// Secondary text color for supporting descriptions.
    public var textSecondary: Color
    /// Tertiary text color for captions, placeholders, and metadata.
    public var textTertiary: Color
    /// Inverse text color for use on filled or dark backgrounds.
    public var textInverse: Color

    // MARK: - Border Colors

    /// Default border color for outlines and separators.
    public var border: Color
    /// Subtle border color for low-emphasis dividers.
    public var borderSubtle: Color
    /// Strong border color for high-emphasis outlines.
    public var borderStrong: Color

    // MARK: - State Colors

    /// Color applied to disabled or non-interactive elements.
    public var disabled: Color
    /// Color applied on pointer hover state.
    public var hover: Color
    /// Color applied on press or tap state.
    public var pressed: Color
    /// Color applied to the currently selected item.
    public var selected: Color

    // MARK: - Feedback Colors

    /// Error feedback color for destructive or invalid states.
    public var error: Color
    /// Success feedback color for confirmations and completed actions.
    public var success: Color
    /// Warning feedback color for cautionary messages.
    public var warning: Color
    /// Informational feedback color for tips and notices.
    public var info: Color

    // MARK: - Utility Colors

    /// Shadow color for elevation and depth effects.
    public var shadow: Color
    /// Constant white color, unaffected by color scheme.
    public var white: Color
    /// Constant black color, unaffected by color scheme.
    public var black: Color

    // MARK: - Initialization

    /// Creates a default color palette, loading brand colors from the asset catalog.
    public init(
        // Brand
        primary: Color = Self.asset("Primary"),
        secondary: Color = Self.asset("Secondary"),
        accent: Color = Self.asset("Accent"),
        // Background
        background: Color = Self.asset("Background"),
        backgroundSecondary: Color = Self.asset("BackgroundSecondary"),
        surface: Color = Self.asset("Surface"),
        // Text
        text: Color = .primary,
        textSecondary: Color = .secondary,
        textTertiary: Color = .gray,
        textInverse: Color = .white,
        // Border
        border: Color = Self.asset("Border"),
        borderSubtle: Color = Self.asset("Border").opacity(0.5),
        borderStrong: Color = Self.asset("Border").opacity(0.8),
        // State
        disabled: Color = Self.asset("Disabled"),
        hover: Color = Self.asset("Hover"),
        pressed: Color = Self.asset("Pressed"),
        selected: Color = Self.asset("Primary").opacity(0.2),
        // Feedback
        error: Color = Self.asset("Error"),
        success: Color = Self.asset("Success"),
        warning: Color = Self.asset("Warning"),
        info: Color = Self.asset("Info"),
        // Utility
        shadow: Color = Self.asset("Shadow"),
        white: Color = .white,
        black: Color = .black
    ) {
        self.primary = primary
        self.secondary = secondary
        self.accent = accent
        self.background = background
        self.backgroundSecondary = backgroundSecondary
        self.surface = surface
        self.text = text
        self.textSecondary = textSecondary
        self.textTertiary = textTertiary
        self.textInverse = textInverse
        self.border = border
        self.borderSubtle = borderSubtle
        self.borderStrong = borderStrong
        self.disabled = disabled
        self.hover = hover
        self.pressed = pressed
        self.selected = selected
        self.error = error
        self.success = success
        self.warning = warning
        self.info = info
        self.shadow = shadow
        self.white = white
        self.black = black
    }

    // MARK: - Dark Theme

    /// Dark color palette variant optimized for dark-mode interfaces.
    public static var dark: PrismDefaultColor {
        PrismDefaultColor(
            primary: Color(red: 0.4, green: 0.6, blue: 1.0),
            secondary: Color(red: 0.5, green: 0.5, blue: 0.6),
            accent: Color(red: 0.5, green: 0.7, blue: 1.0),
            background: Color(red: 0.05, green: 0.05, blue: 0.08),
            backgroundSecondary: Color(red: 0.1, green: 0.1, blue: 0.15),
            surface: Color(red: 0.12, green: 0.12, blue: 0.18),
            text: .white,
            textSecondary: Color.gray.opacity(0.8),
            textTertiary: Color.gray.opacity(0.6),
            textInverse: .black,
            border: Color.gray.opacity(0.3),
            borderSubtle: Color.gray.opacity(0.15),
            borderStrong: Color.gray.opacity(0.5),
            disabled: Color.gray.opacity(0.4),
            hover: Color.white.opacity(0.1),
            pressed: Color.white.opacity(0.15),
            selected: Color.blue.opacity(0.3),
            error: Color(red: 1.0, green: 0.4, blue: 0.4),
            success: Color(red: 0.4, green: 1.0, blue: 0.5),
            warning: Color(red: 1.0, green: 0.7, blue: 0.3),
            info: Color(red: 0.3, green: 0.8, blue: 1.0),
            shadow: .black,
            white: .white,
            black: .black
        )
    }

    // MARK: - High Contrast Theme

    /// High-contrast color palette variant for improved accessibility.
    public static var highContrast: PrismDefaultColor {
        PrismDefaultColor(
            primary: .yellow,
            secondary: .gray,
            accent: .cyan,
            background: .black,
            backgroundSecondary: Color.gray.opacity(0.2),
            surface: Color.gray.opacity(0.3),
            text: .white,
            textSecondary: .white.opacity(0.9),
            textTertiary: .white.opacity(0.7),
            textInverse: .black,
            border: .white,
            borderSubtle: .white.opacity(0.5),
            borderStrong: .white,
            disabled: .gray.opacity(0.5),
            hover: .white.opacity(0.2),
            pressed: .white.opacity(0.3),
            selected: .purple.opacity(0.4),
            error: .red,
            success: .green,
            warning: .yellow,
            info: .cyan,
            shadow: .black,
            white: .white,
            black: .black
        )
    }
}
