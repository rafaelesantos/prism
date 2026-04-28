import SwiftUI

/// Named spring configurations for consistent motion across the system.
///
/// ```swift
/// withAnimation(PrismSpringConfig.gentle.animation) {
///     isExpanded.toggle()
/// }
/// ```
public struct PrismSpringConfig: Sendable, Hashable {
    public let response: Double
    public let dampingFraction: Double
    public let blendDuration: Double

    public init(response: Double, dampingFraction: Double, blendDuration: Double = 0) {
        self.response = response
        self.dampingFraction = dampingFraction
        self.blendDuration = blendDuration
    }

    public var animation: Animation {
        .spring(response: response, dampingFraction: dampingFraction, blendDuration: blendDuration)
    }
}

extension PrismSpringConfig {

    /// Snappy micro-interaction (buttons, toggles).
    public static let snappy = PrismSpringConfig(response: 0.25, dampingFraction: 0.8)

    /// Gentle content reveal (cards, sheets).
    public static let gentle = PrismSpringConfig(response: 0.5, dampingFraction: 0.75)

    /// Bouncy feedback (success states, celebrations).
    public static let bouncy = PrismSpringConfig(response: 0.4, dampingFraction: 0.5)

    /// Stiff mechanical feel (sliders, progress).
    public static let stiff = PrismSpringConfig(response: 0.2, dampingFraction: 0.9)

    /// Slow, dramatic entrance (hero transitions).
    public static let dramatic = PrismSpringConfig(response: 0.7, dampingFraction: 0.65)

    /// No bounce, fastest settle (instant feedback).
    public static let critical = PrismSpringConfig(response: 0.15, dampingFraction: 1.0)

    /// Rubber-band overshoot (pull-to-refresh, overscroll).
    public static let rubber = PrismSpringConfig(response: 0.35, dampingFraction: 0.4)
}

extension View {

    /// Animates changes using a named spring configuration.
    public func prismSpring(
        _ config: PrismSpringConfig,
        value: some Equatable
    ) -> some View {
        animation(config.animation, value: value)
    }
}
