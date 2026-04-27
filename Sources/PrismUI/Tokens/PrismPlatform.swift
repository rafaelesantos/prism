//
//  PrismPlatform.swift
//  Prism
//
//  Created by Rafael Escaleira on 09/04/26.
//

import SwiftUI

/// Apple platforms supported by the design system.
public enum PrismPlatform: String, CaseIterable, Sendable {
    /// iPhone and iPad running iOS.
    case iOS
    /// Mac running macOS.
    case macOS
    /// Apple TV running tvOS.
    case tvOS
    /// Apple Watch running watchOS.
    case watchOS
    /// Apple Vision Pro running visionOS.
    case visionOS

    /// The platform detected at compile time for the current build target.
    public static var current: Self {
        #if os(visionOS)
            .visionOS
        #elseif os(tvOS)
            .tvOS
        #elseif os(watchOS)
            .watchOS
        #elseif os(macOS)
            .macOS
        #else
            .iOS
        #endif
    }
}

/// Platform navigation model.
public enum PrismNavigationModel: String, Sendable {
    /// Push-based navigation stack.
    case stack
    /// Tab bar navigation at the root level.
    case tabBar
    /// Side-by-side split view navigation.
    case splitView
}

/// Per-platform content margins.
public struct PrismContentMargins: Sendable {
    /// Leading and trailing content margin in points.
    public let horizontal: CGFloat
    /// Top and bottom content margin in points.
    public let vertical: CGFloat

    /// Creates content margins with the given horizontal and vertical values.
    public init(
        horizontal: CGFloat,
        vertical: CGFloat
    ) {
        self.horizontal = horizontal
        self.vertical = vertical
    }
}

/// Platform context for adaptive layout resolution.
public struct PrismPlatformContext: Sendable {
    /// The target Apple platform.
    public let platform: PrismPlatform
    /// The active layout tier (compact, regular, or expansive).
    public let layoutTier: PrismLayoutTier
    /// The recommended navigation model for this platform and tier.
    public let navigationModel: PrismNavigationModel
    /// Safe-area content margins for the platform.
    public let contentMargins: PrismContentMargins
    /// Maximum readable content width, or `nil` for unconstrained layouts.
    public let maxReadableWidth: CGFloat?
    /// Whether the platform prefers a centered content canvas (e.g., visionOS).
    public let prefersCenteredCanvas: Bool
    /// Whether the platform prefers edge-to-edge content (e.g., watchOS).
    public let prefersEdgeToEdgeContent: Bool
    /// Whether the platform uses focus-driven navigation (e.g., tvOS).
    public let prefersFocusNavigation: Bool
    /// The recommended SwiftUI control size for this context.
    public let controlSize: ControlSize

    /// Creates a platform context with the given layout parameters.
    public init(
        platform: PrismPlatform,
        layoutTier: PrismLayoutTier,
        navigationModel: PrismNavigationModel,
        contentMargins: PrismContentMargins,
        maxReadableWidth: CGFloat?,
        prefersCenteredCanvas: Bool,
        prefersEdgeToEdgeContent: Bool,
        prefersFocusNavigation: Bool,
        controlSize: ControlSize
    ) {
        self.platform = platform
        self.layoutTier = layoutTier
        self.navigationModel = navigationModel
        self.contentMargins = contentMargins
        self.maxReadableWidth = maxReadableWidth
        self.prefersCenteredCanvas = prefersCenteredCanvas
        self.prefersEdgeToEdgeContent = prefersEdgeToEdgeContent
        self.prefersFocusNavigation = prefersFocusNavigation
        self.controlSize = controlSize
    }

    /// The default platform context resolved for the current platform in compact tier.
    public static let `default` = resolve(
        platform: .current,
        layoutTier: .compact
    )

    /// Resolves a platform context with recommended navigation, margins, and control sizes.
    ///
    /// - Parameters:
    ///   - platform: The target Apple platform.
    ///   - layoutTier: The active layout tier.
    /// - Returns: A fully configured ``PrismPlatformContext``.
    public static func resolve(
        platform: PrismPlatform,
        layoutTier: PrismLayoutTier
    ) -> Self {
        switch platform {
        case .iOS:
            Self(
                platform: platform,
                layoutTier: layoutTier,
                navigationModel: layoutTier == .compact ? .tabBar : .splitView,
                contentMargins: PrismContentMargins(
                    horizontal: layoutTier.horizontalPadding,
                    vertical: max(16, layoutTier.verticalPadding)
                ),
                maxReadableWidth: layoutTier == .compact ? nil : 760,
                prefersCenteredCanvas: false,
                prefersEdgeToEdgeContent: false,
                prefersFocusNavigation: false,
                controlSize: layoutTier.controlSize
            )

        case .macOS:
            Self(
                platform: platform,
                layoutTier: layoutTier,
                navigationModel: .splitView,
                contentMargins: PrismContentMargins(
                    horizontal: max(24, layoutTier.horizontalPadding),
                    vertical: 20
                ),
                maxReadableWidth: 820,
                prefersCenteredCanvas: false,
                prefersEdgeToEdgeContent: false,
                prefersFocusNavigation: false,
                controlSize: .large
            )

        case .tvOS:
            Self(
                platform: platform,
                layoutTier: layoutTier,
                navigationModel: .stack,
                contentMargins: PrismContentMargins(
                    horizontal: 80,
                    vertical: 60
                ),
                maxReadableWidth: nil,
                prefersCenteredCanvas: false,
                prefersEdgeToEdgeContent: false,
                prefersFocusNavigation: true,
                controlSize: .extraLarge
            )

        case .watchOS:
            Self(
                platform: platform,
                layoutTier: .compact,
                navigationModel: .stack,
                contentMargins: PrismContentMargins(
                    horizontal: 8,
                    vertical: 8
                ),
                maxReadableWidth: nil,
                prefersCenteredCanvas: false,
                prefersEdgeToEdgeContent: true,
                prefersFocusNavigation: false,
                controlSize: .small
            )

        case .visionOS:
            Self(
                platform: platform,
                layoutTier: layoutTier,
                navigationModel: .splitView,
                contentMargins: PrismContentMargins(
                    horizontal: max(28, layoutTier.horizontalPadding),
                    vertical: max(24, layoutTier.verticalPadding)
                ),
                maxReadableWidth: 900,
                prefersCenteredCanvas: true,
                prefersEdgeToEdgeContent: false,
                prefersFocusNavigation: false,
                controlSize: .large
            )
        }
    }
}
