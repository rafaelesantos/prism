//
//  PrismPlaygroundTheme.swift
//  PrismPlayground
//
//  Created by Rafael Escaleira on 11/04/26.
//

import PrismFoundation
import PrismUI
import SwiftUI

/// Design System customizado para o PrismPlayground
struct PrismPlaygroundTheme: PrismThemeProtocol {
    let tokens: PrismDesignTokens
    let locale: PrismLocale = .portugueseBR
    let feedback: SensoryFeedback = .success
    let colorScheme: ColorScheme? = nil

    init() {
        self.tokens = PrismDesignTokens(
            spacing: [
                .none: 0,
                .extraSmall: 4,
                .small: 8,
                .medium: 16,
                .large: 24,
                .extraLarge: 32,
                .ultraLarge: 48,
                .section: 64
            ],
            radius: [
                .none: 0,
                .small: 8,
                .medium: 12,
                .large: 16,
                .extraLarge: 24,
                .circle: .infinity
            ],
            fontSizes: [
                .caption2: 11,
                .caption: 12,
                .footnote: 13,
                .body: 16,
                .title3: 18,
                .title2: 20,
                .title: 24,
                .largeTitle: 32
            ]
        )
    }

    var color: any PrismColorProtocol {
        PrismPlaygroundColors()
    }

    var spacing: any PrismSpacingProtocol {
        PrismPlaygroundSpacing()
    }

    var radius: any PrismRadiusProtocol {
        PrismPlaygroundRadius()
    }

    var size: any PrismSizeProtocol {
        PrismPlaygroundSize()
    }

    var animation: Animation? {
        .smooth(duration: 0.35)
    }
}

// MARK: - Cores do Playground

private struct PrismPlaygroundColors: PrismColorProtocol {
    // MARK: - Brand Colors
    var primary: Color
    var secondary: Color
    var accent: Color

    // MARK: - Background Colors
    var background: Color
    var backgroundSecondary: Color
    var surface: Color

    // MARK: - Text Colors
    var text: Color
    var textSecondary: Color
    var textTertiary: Color
    var textInverse: Color

    // MARK: - Border Colors
    var border: Color
    var borderSubtle: Color
    var borderStrong: Color

    // MARK: - State Colors
    var disabled: Color
    var hover: Color
    var pressed: Color
    var selected: Color

    // MARK: - Feedback Colors
    var error: Color
    var success: Color
    var warning: Color
    var info: Color

    // MARK: - Utility Colors
    var shadow: Color
    var white: Color
    var black: Color

    // MARK: - Initialization
    init() {
        // Brand Colors
        self.primary = Color(red: 0.2, green: 0.4, blue: 0.9)
        self.secondary = Color(red: 0.6, green: 0.3, blue: 0.8)
        self.accent = Color(red: 0.9, green: 0.3, blue: 0.5)

        // Background Colors - usando cores do sistema para suportar dark mode
        self.background = Color(UIColor.systemBackground)
        self.backgroundSecondary = Color(UIColor.secondarySystemBackground)
        self.surface = Color(UIColor.tertiarySystemBackground)

        // Text Colors
        self.text = Color(UIColor.label)
        self.textSecondary = Color(UIColor.secondaryLabel)
        self.textTertiary = Color(UIColor.tertiaryLabel)
        self.textInverse = Color.white

        // Border Colors
        self.border = Color(UIColor.separator)
        self.borderSubtle = Color(UIColor.separator).opacity(0.5)
        self.borderStrong = Color(UIColor.opaqueSeparator)

        // State Colors
        self.disabled = Color(UIColor.systemGray4)
        self.hover = Color(red: 0.2, green: 0.4, blue: 0.9).opacity(0.1)
        self.pressed = Color(red: 0.2, green: 0.4, blue: 0.9).opacity(0.2)
        self.selected = Color(red: 0.2, green: 0.4, blue: 0.9).opacity(0.15)

        // Feedback Colors
        self.error = Color(red: 0.9, green: 0.2, blue: 0.3)
        self.success = Color(red: 0.1, green: 0.7, blue: 0.4)
        self.warning = Color(red: 1.0, green: 0.6, blue: 0.0)
        self.info = Color(red: 0.0, green: 0.5, blue: 0.9)

        // Utility Colors
        self.shadow = Color.black.opacity(0.2)
        self.white = Color.white
        self.black = Color.black
    }
}

// MARK: - Spacing Protocol

private struct PrismPlaygroundSpacing: PrismSpacingProtocol {
    var none: CGFloat { 0 }
    var extraSmall: CGFloat { 4 }
    var small: CGFloat { 8 }
    var medium: CGFloat { 16 }
    var large: CGFloat { 24 }
    var extraLarge: CGFloat { 32 }
    var ultraLarge: CGFloat { 48 }
    var section: CGFloat { 64 }
}

// MARK: - Radius Protocol

private struct PrismPlaygroundRadius: PrismRadiusProtocol {
    var none: CGFloat { 0 }
    var small: CGFloat { 8 }
    var medium: CGFloat { 12 }
    var large: CGFloat { 16 }
    var extraLarge: CGFloat { 24 }
    var circle: CGFloat { .infinity }
}

// MARK: - Size Protocol

private struct PrismPlaygroundSize: PrismSizeProtocol {
    var ultraSmall: CGFloat { 24 }
    var ultraSmall2: CGFloat { 28 }
    var extraSmall: CGFloat { 32 }
    var extraSmall2: CGFloat { 36 }
    var small: CGFloat { 40 }
    var small2: CGFloat { 44 }
    var medium: CGFloat { 48 }
    var medium2: CGFloat { 52 }
    var large: CGFloat { 56 }
    var large2: CGFloat { 64 }
    var extraLarge: CGFloat { 72 }
    var extraLarge2: CGFloat { 80 }
    var ultraLarge: CGFloat { 96 }
    var max: CGFloat { .infinity }
}
