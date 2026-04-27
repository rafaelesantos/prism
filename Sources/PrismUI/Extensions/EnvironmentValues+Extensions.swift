//
//  EnvironmentValues+Extensions.swift
//  Prism
//
//  Created by Rafael Escaleira on 19/04/25.
//

import PrismFoundation
import SwiftUI

/// PrismUI custom environment values for state, screen, theme, and layout propagation.
extension EnvironmentValues {

    // MARK: - State

    /// Whether the view hierarchy is in a loading state, enabling skeleton placeholders.
    @Entry public var isLoading: Bool = false
    /// Whether the view hierarchy is in a disabled state.
    @Entry public var isDisabled: Bool = false

    // MARK: - Screen

    /// The current screen size observed by ``prismScreenObserve(minimumWidthScreen:)``.
    @Entry public var screenSize: CGSize = .zero
    /// The current scroll position within a tracked scroll view.
    @Entry public var scrollPosition: CGPoint = .zero
    /// Whether the current screen width exceeds the large-screen threshold.
    @Entry public var isLargeScreen: Bool = false

    // MARK: - Theme

    /// The active ``PrismTheme`` for the view hierarchy.
    @Entry public var theme: PrismTheme = .default
    /// The active ``PrismDesignTokens`` resolved from the current theme.
    @Entry public var designTokens: PrismDesignTokens = .default

    // MARK: - Layout

    /// The current platform (iOS, macOS, etc.).
    @Entry public var platform: PrismPlatform = .current
    /// Platform-specific layout context (e.g., safe area, idiom).
    @Entry public var platformContext: PrismPlatformContext = .default
    /// The current layout tier (`.compact`, `.regular`, `.expanded`).
    @Entry public var layoutTier: PrismLayoutTier = .compact
    /// Whether the view is pinned to the top edge of its container.
    @Entry public var isPinnedToTop: Bool = false
    /// Whether the view is pinned to the bottom edge of its container.
    @Entry public var isPinnedToBottom: Bool = false
}
