//
//  PrismDesignTokens.swift
//  Prism
//
//  Created by Rafael Escaleira on 09/04/26.
//

import SwiftUI

// MARK: - Token Types

/// Design system spacing token.
public enum SpacingToken: CaseIterable, Sendable {
    /// No spacing (0pt).
    case none
    /// Extra-small spacing (4pt default).
    case extraSmall
    /// Small spacing (8pt default).
    case small
    /// Medium spacing (16pt default).
    case medium
    /// Large spacing (24pt default).
    case large
    /// Extra-large spacing (32pt default).
    case extraLarge
    /// Ultra-large spacing (48pt default).
    case ultraLarge
    /// Section-level spacing (64pt default).
    case section
}

/// Design system border radius token.
public enum RadiusToken: CaseIterable, Sendable {
    /// No rounding (sharp corners).
    case none
    /// Small corner radius (4pt default).
    case small
    /// Medium corner radius (8pt default).
    case medium
    /// Large corner radius (16pt default).
    case large
    /// Extra-large corner radius (24pt default).
    case extraLarge
    /// Fully circular radius (infinity).
    case circle
}

/// Design system font sizes.
public enum FontSizeToken: CaseIterable, Sendable {
    /// Smallest caption text (11pt default).
    case caption2
    /// Caption text (12pt default).
    case caption
    /// Footnote text (13pt default).
    case footnote
    /// Body text (16pt default).
    case body
    /// Third-level title (18pt default).
    case title3
    /// Second-level title (20pt default).
    case title2
    /// Primary title (24pt default).
    case title
    /// Large display title (32pt default).
    case largeTitle
}

/// Design system animation durations.
public enum MotionToken: CaseIterable, Sendable {
    /// Near-instantaneous animation (0.05s default).
    case instant
    /// Fast animation (0.15s default).
    case fast
    /// Standard animation (0.3s default).
    case normal
    /// Slow, deliberate animation (0.5s default).
    case slow
}

// MARK: - Design Tokens

/// Collection of design tokens: spacing, radius, fonts, animations, and breakpoints.
public struct PrismDesignTokens: Equatable, Sendable {

    // MARK: - Spacing Scale (8pt grid system)

    /// Spacing scale mapping each ``SpacingToken`` to a point value following the 8pt grid system.
    public let spacing: [SpacingToken: CGFloat]

    // MARK: - Radius Scale

    /// Radius scale mapping each ``RadiusToken`` to a point value.
    public let radius: [RadiusToken: CGFloat]

    // MARK: - Font Sizes (Dynamic Type base)

    /// Font size scale mapping each ``FontSizeToken`` to a base point size for Dynamic Type.
    public let fontSizes: [FontSizeToken: CGFloat]

    // MARK: - Motion Durations

    /// Animation duration scale mapping each ``MotionToken`` to a time interval in seconds.
    public let durations: [MotionToken: TimeInterval]

    // MARK: - Breakpoints

    /// Responsive breakpoint widths mapping each ``Breakpoint`` to a minimum width in points.
    public let breakpoints: [Breakpoint: CGFloat]

    // MARK: - Initialization

    /// Creates a design token collection with the given scales.
    ///
    /// - Parameters:
    ///   - spacing: Spacing scale dictionary. Defaults to ``defaultSpacing``.
    ///   - radius: Radius scale dictionary. Defaults to ``defaultRadius``.
    ///   - fontSizes: Font size scale dictionary. Defaults to ``defaultFontSizes``.
    ///   - durations: Motion duration dictionary. Defaults to ``defaultDurations``.
    ///   - breakpoints: Responsive breakpoint dictionary. Defaults to ``defaultBreakpoints``.
    public init(
        spacing: [SpacingToken: CGFloat] = defaultSpacing,
        radius: [RadiusToken: CGFloat] = defaultRadius,
        fontSizes: [FontSizeToken: CGFloat] = defaultFontSizes,
        durations: [MotionToken: TimeInterval] = defaultDurations,
        breakpoints: [Breakpoint: CGFloat] = defaultBreakpoints
    ) {
        self.spacing = spacing
        self.radius = radius
        self.fontSizes = fontSizes
        self.durations = durations
        self.breakpoints = breakpoints
    }

    // MARK: - Default Values

    /// The standard design token configuration using all default values.
    public static let `default` = PrismDesignTokens()

    /// A compact token variant with tighter spacing and smaller radii for dense layouts.
    public static var compact: PrismDesignTokens {
        PrismDesignTokens(
            spacing: [
                .none: 0,
                .extraSmall: 4,
                .small: 8,
                .medium: 12,
                .large: 16,
                .extraLarge: 20,
                .ultraLarge: 24,
                .section: 32,
            ],
            radius: [
                .none: 0,
                .small: 6,
                .medium: 10,
                .large: 14,
                .extraLarge: 20,
                .circle: .infinity,
            ],
            fontSizes: [
                .caption2: 11,
                .caption: 12,
                .footnote: 13,
                .body: 15,
                .title3: 17,
                .title2: 19,
                .title: 22,
                .largeTitle: 28,
            ]
        )
    }

    /// An expanded token variant with larger spacing, radii, and font sizes for spacious layouts.
    public static var expanded: PrismDesignTokens {
        PrismDesignTokens(
            spacing: [
                .none: 0,
                .extraSmall: 6,
                .small: 12,
                .medium: 18,
                .large: 24,
                .extraLarge: 36,
                .ultraLarge: 54,
                .section: 72,
            ],
            radius: [
                .none: 0,
                .small: 8,
                .medium: 12,
                .large: 18,
                .extraLarge: 26,
                .circle: .infinity,
            ],
            fontSizes: [
                .caption2: 12,
                .caption: 14,
                .footnote: 15,
                .body: 17,
                .title3: 20,
                .title2: 24,
                .title: 28,
                .largeTitle: 36,
            ],
            durations: [
                .instant: 0.1,
                .fast: 0.25,
                .normal: 0.4,
                .slow: 0.6,
            ]
        )
    }

    // MARK: - Default Configurations

    /// Default spacing scale based on an 8pt grid system.
    public static let defaultSpacing: [SpacingToken: CGFloat] = [
        .none: 0,
        .extraSmall: 4,
        .small: 8,
        .medium: 16,
        .large: 24,
        .extraLarge: 32,
        .ultraLarge: 48,
        .section: 64,
    ]

    /// Default border radius scale.
    public static let defaultRadius: [RadiusToken: CGFloat] = [
        .none: 0,
        .small: 4,
        .medium: 8,
        .large: 16,
        .extraLarge: 24,
        .circle: .infinity,
    ]

    /// Default font size scale aligned with Dynamic Type base sizes.
    public static let defaultFontSizes: [FontSizeToken: CGFloat] = [
        .caption2: 11,
        .caption: 12,
        .footnote: 13,
        .body: 16,
        .title3: 18,
        .title2: 20,
        .title: 24,
        .largeTitle: 32,
    ]

    /// Default animation duration scale in seconds.
    public static let defaultDurations: [MotionToken: TimeInterval] = [
        .instant: 0.05,
        .fast: 0.15,
        .normal: 0.3,
        .slow: 0.5,
    ]

    /// Default responsive breakpoint widths in points.
    public static let defaultBreakpoints: [Breakpoint: CGFloat] = [
        .phoneCompact: 375,
        .phoneMax: 430,
        .tabletCompact: 768,
        .tabletMax: 1024,
        .desktop: 1440,
    ]

    // MARK: - Convenience Accessors

    /// Returns the spacing value for the given token, falling back to `0` if not found.
    public func spacing(for token: SpacingToken) -> CGFloat {
        spacing[token] ?? 0
    }

    /// Returns the radius value for the given token, falling back to `0` if not found.
    public func radius(for token: RadiusToken) -> CGFloat {
        radius[token] ?? 0
    }

    /// Returns the font size for the given token, falling back to `16` if not found.
    public func fontSize(for token: FontSizeToken) -> CGFloat {
        fontSizes[token] ?? 16
    }

    /// Returns the animation duration for the given token, falling back to `0.3` if not found.
    public func duration(for token: MotionToken) -> TimeInterval {
        durations[token] ?? 0.3
    }

    /// Returns an `easeInOut` SwiftUI animation configured with the duration of the given token.
    public func animation(for token: MotionToken) -> Animation {
        .easeInOut(duration: duration(for: token))
    }

    /// Returns the minimum width for the given breakpoint, falling back to `0` if not found.
    public func breakpoint(for breakpoint: Breakpoint) -> CGFloat {
        breakpoints[breakpoint] ?? 0
    }

    /// Determines the ``PrismLayoutTier`` for the given viewport width based on configured breakpoints.
    public func layoutTier(for width: CGFloat) -> PrismLayoutTier {
        let tabletCompact = breakpoint(for: .tabletCompact)
        let desktop = breakpoint(for: .desktop)

        return switch width {
        case ..<tabletCompact:
            PrismLayoutTier.compact
        case tabletCompact..<desktop:
            PrismLayoutTier.regular
        default:
            PrismLayoutTier.expansive
        }
    }
}

// MARK: - Breakpoint

/// Responsive layout breakpoints.
public enum Breakpoint: CaseIterable, Sendable {
    /// Small phone viewport (375pt default).
    case phoneCompact
    /// Large phone viewport (430pt default).
    case phoneMax
    /// Compact tablet viewport (768pt default).
    case tabletCompact
    /// Full-size tablet viewport (1024pt default).
    case tabletMax
    /// Desktop viewport (1440pt default).
    case desktop
}
