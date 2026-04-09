//
//  RyzeGlowModifier.swift
//  Ryze
//
//  Created by Rafael Escaleira on 25/04/25.
//

import SwiftUI

struct RyzeGlowModifier: RyzeViewModifier {
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

    func body(content: Content) -> some View {
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
        .ryzePadding()
        .ryzePadding(.negative(.medium))
    }

    static func mocked() -> some View {
        RyzeHStack.mocked()
            .ryzePadding()
            .ryzeGlow()
            .ryzePadding()
    }
}

#Preview {
    RyzeGlowModifier.mocked()
}
