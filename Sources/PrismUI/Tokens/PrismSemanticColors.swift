//
//  PrismSemanticColors.swift
//  Prism
//
//  Created by Rafael Escaleira on 09/04/26.
//

import SwiftUI

// MARK: - PrismSemanticColors

/// Semantic color mapping for SwiftUI.
public struct PrismSemanticColors: Sendable {
    // MARK: - State Colors

    /// Color for active or enabled interactive elements.
    public var active: Color
    /// Color for inactive or disabled interactive elements.
    public var inactive: Color
    /// Color for the currently selected item.
    public var selected: Color
    /// Color for elements with keyboard or assistive-technology focus.
    public var focused: Color

    // MARK: - Feedback Colors

    /// Positive feedback color (e.g., success confirmations).
    public var positive: Color
    /// Negative feedback color (e.g., error states).
    public var negative: Color
    /// Cautionary feedback color (e.g., warnings).
    public var caution: Color
    /// Informational feedback color (e.g., tips and notices).
    public var informational: Color

    // MARK: - Depth Colors

    /// Surface color for elevated elements such as cards and sheets.
    public var elevated: Color
    /// Surface color for recessed or sunken areas.
    public var submerged: Color
    /// Semi-transparent overlay color for modals and popovers.
    public var overlay: Color

    // MARK: - Border Colors

    /// Default border color for standard separators and outlines.
    public var borderDefault: Color
    /// Subtle border color for low-emphasis dividers.
    public var borderSubtle: Color
    /// Strong border color for high-emphasis outlines.
    public var borderStrong: Color

    // MARK: - Text Hierarchy

    /// Primary text color for headings and body copy.
    public var textPrimary: Color
    /// Secondary text color for supporting descriptions.
    public var textSecondary: Color
    /// Tertiary text color for captions and metadata.
    public var textTertiary: Color
    /// Text color for disabled or non-interactive labels.
    public var textDisabled: Color
    /// Inverse text color for use on filled backgrounds.
    public var textInverse: Color
    /// Text color for hyperlinks and tappable inline text.
    public var textLink: Color

    // MARK: - Initialization

    /// Creates a semantic color set with the given color values.
    public init(
        active: Color = .blue,
        inactive: Color = .gray,
        selected: Color = .blue.opacity(0.2),
        focused: Color = .blue.opacity(0.3),
        positive: Color = .green,
        negative: Color = .red,
        caution: Color = .orange,
        informational: Color = .cyan,
        elevated: Color = .white,
        submerged: Color = .black.opacity(0.02),
        overlay: Color = .black.opacity(0.4),
        borderDefault: Color = .gray.opacity(0.3),
        borderSubtle: Color = .gray.opacity(0.1),
        borderStrong: Color = .gray.opacity(0.6),
        textPrimary: Color = .primary,
        textSecondary: Color = .secondary,
        textTertiary: Color = .gray,
        textDisabled: Color = .gray.opacity(0.5),
        textInverse: Color = .white,
        textLink: Color = .blue
    ) {
        self.active = active
        self.inactive = inactive
        self.selected = selected
        self.focused = focused
        self.positive = positive
        self.negative = negative
        self.caution = caution
        self.informational = informational
        self.elevated = elevated
        self.submerged = submerged
        self.overlay = overlay
        self.borderDefault = borderDefault
        self.borderSubtle = borderSubtle
        self.borderStrong = borderStrong
        self.textPrimary = textPrimary
        self.textSecondary = textSecondary
        self.textTertiary = textTertiary
        self.textDisabled = textDisabled
        self.textInverse = textInverse
        self.textLink = textLink
    }

    // MARK: - Dark Mode Variant

    /// Semantic color set optimized for dark mode interfaces.
    public static var dark: PrismSemanticColors {
        PrismSemanticColors(
            active: .blue.opacity(0.8),
            inactive: .gray.opacity(0.5),
            selected: .blue.opacity(0.3),
            focused: .blue.opacity(0.4),
            positive: .green.opacity(0.8),
            negative: .red.opacity(0.8),
            caution: .orange.opacity(0.8),
            informational: .cyan.opacity(0.8),
            elevated: .white.opacity(0.1),
            submerged: .black.opacity(0.3),
            overlay: .black.opacity(0.6),
            borderDefault: .gray.opacity(0.4),
            borderSubtle: .gray.opacity(0.2),
            borderStrong: .gray.opacity(0.7),
            textPrimary: .white,
            textSecondary: .gray.opacity(0.8),
            textTertiary: .gray.opacity(0.6),
            textDisabled: .gray.opacity(0.4),
            textInverse: .black,
            textLink: .blue.opacity(0.8)
        )
    }

    // MARK: - High Contrast Variant

    /// Semantic color set with increased contrast for accessibility.
    public static var highContrast: PrismSemanticColors {
        PrismSemanticColors(
            active: .yellow,
            inactive: .gray,
            selected: .purple.opacity(0.3),
            focused: .yellow.opacity(0.4),
            positive: .green,
            negative: .red,
            caution: .yellow,
            informational: .cyan,
            elevated: .white,
            submerged: .black.opacity(0.1),
            overlay: .black.opacity(0.8),
            borderDefault: .white,
            borderSubtle: .gray.opacity(0.5),
            borderStrong: .white,
            textPrimary: .white,
            textSecondary: .gray,
            textTertiary: .gray.opacity(0.7),
            textDisabled: .gray.opacity(0.3),
            textInverse: .black,
            textLink: .yellow
        )
    }
}

// MARK: - PrismColorProtocol Extension

extension PrismColorProtocol {
    /// Convenience accessor for the dark semantic color set.
    public var semanticDark: PrismSemanticColors {
        .dark
    }

    /// Convenience accessor for the high-contrast semantic color set.
    public var semanticHighContrast: PrismSemanticColors {
        .highContrast
    }
}
