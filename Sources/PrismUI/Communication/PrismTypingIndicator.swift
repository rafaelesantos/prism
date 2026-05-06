import SwiftUI

@MainActor
public struct PrismTypingIndicator: View {
    @Environment(\.prismTheme) private var theme

    private let dotSize: CGFloat
    private let color: Color?

    @State private var animating = false

    public init(dotSize: CGFloat = 8, color: Color? = nil) {
        self.dotSize = dotSize
        self.color = color
    }

    public var body: some View {
        HStack(spacing: dotSize * 0.6) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(dotColor)
                    .frame(width: dotSize, height: dotSize)
                    .offset(y: animating ? -dotSize * 0.5 : dotSize * 0.5)
                    .animation(
                        .easeInOut(duration: 0.4)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.15),
                        value: animating
                    )
            }
        }
        .onAppear { animating = true }
        .accessibilityLabel("Someone is typing")
        .accessibilityAddTraits(.updatesFrequently)
    }

    private var dotColor: Color {
        color ?? theme.color(.onSurfaceSecondary)
    }
}

@MainActor
public struct PrismTypingBubble: View {
    @Environment(\.prismTheme) private var theme

    private let sender: String?
    private let dotSize: CGFloat
    private let color: Color?

    public init(sender: String? = nil, dotSize: CGFloat = 8, color: Color? = nil) {
        self.sender = sender
        self.dotSize = dotSize
        self.color = color
    }

    public var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                if let sender {
                    Text(sender)
                        .font(TypographyToken.caption.font(weight: .semibold))
                        .foregroundStyle(theme.color(.brand))
                }

                PrismTypingIndicator(dotSize: dotSize, color: color)
                    .padding(.horizontal, SpacingToken.md.rawValue)
                    .padding(.vertical, SpacingToken.sm.rawValue)
                    .background(
                        theme.color(.surfaceSecondary),
                        in: UnevenRoundedRectangle(
                            topLeadingRadius: RadiusToken.lg.rawValue,
                            bottomLeadingRadius: RadiusToken.sm.rawValue,
                            bottomTrailingRadius: RadiusToken.lg.rawValue,
                            topTrailingRadius: RadiusToken.lg.rawValue
                        )
                    )
            }
            Spacer(minLength: 48)
        }
        .accessibilityElement(children: .combine)
    }
}
