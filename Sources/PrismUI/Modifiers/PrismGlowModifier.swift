//
//  PrismGlowModifier.swift
//  Prism
//
//  Created by Rafael Escaleira on 25/04/25.
//

import SwiftUI

/// Animated glow effect modifier for the PrismUI Design System.
///
/// `PrismGlowModifier` applies an animated glow with angular gradient:
/// - Continuous angular gradient animation (6s per cycle)
/// - Dynamic colors based on theme or custom color
/// - 20pt blur for a soft effect
/// - Ideal for highlight or celebration states
///
/// ## Basic Usage
/// ```swift
/// PrismText("Highlight")
///     .prismGlow()
/// ```
///
/// ## With Custom Color
/// ```swift
/// PrismSymbol("star.fill")
///     .prismGlow(for: .yellow)
/// ```
///
/// ## Effect
/// The glow uses an animated angular gradient that:
/// - Rotates 360 degrees continuously
/// - Alternates between main color and 60% opacity
/// - Creates a "moving light" effect
///
/// - Note: The modifier uses `TimelineView` for smooth and efficient animation.
public struct PrismGlowModifier: ViewModifier {
    @Environment(\.theme) var theme
    let color: Color?

    var colors: [Color] {
        guard let color else {
            return [
                theme.color.primary,
                theme.color.secondary,
                theme.color.primary,
                theme.color.secondary,
            ]
        }

        return [
            color,
            color.opacity(0.6),
            color,
            color.opacity(0.6),
        ]
    }

    init(color: Color? = nil) {
        self.color = color
    }

    public func body(content: Content) -> some View {
        content
            .background(animatedAngularGradient)
    }

    private var animatedAngularGradient: some View {
        TimelineView(.animation) { ctx in
            let date = ctx.date.timeIntervalSinceReferenceDate
            let period = 6.0
            let progress = date.truncatingRemainder(dividingBy: period) / period
            let angle = progress * 360

            angularGradient(angle: angle)
        }
    }

    private func angularGradient(angle: Double) -> some View {
        AngularGradient(
            colors: colors,
            center: .center,
            startAngle: .degrees(angle),
            endAngle: .degrees(angle + 360)
        )
        .blur(radius: 20)
        .prismPadding()
        .prismPadding(.negative(.medium))
    }

    static func mocked() -> some View {
        PrismHStack.mocked()
            .prismPadding()
            .prismGlow()
            .prismPadding()
    }
}

#Preview {
    PrismGlowModifier.mocked()
}
