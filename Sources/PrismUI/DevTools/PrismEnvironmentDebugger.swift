import SwiftUI

public struct PrismEnvironmentSnapshot: Sendable {
    public let colorScheme: ColorScheme
    public let dynamicTypeSize: DynamicTypeSize
    public let layoutDirection: LayoutDirection
    public let accessibilityEnabled: Bool
    public let reduceMotion: Bool
    public let reduceTransparency: Bool

    public init(
        colorScheme: ColorScheme,
        dynamicTypeSize: DynamicTypeSize,
        layoutDirection: LayoutDirection,
        accessibilityEnabled: Bool,
        reduceMotion: Bool,
        reduceTransparency: Bool
    ) {
        self.colorScheme = colorScheme
        self.dynamicTypeSize = dynamicTypeSize
        self.layoutDirection = layoutDirection
        self.accessibilityEnabled = accessibilityEnabled
        self.reduceMotion = reduceMotion
        self.reduceTransparency = reduceTransparency
    }
}

public struct PrismEnvironmentDebugger: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.layoutDirection) private var layoutDirection
    @Environment(\.accessibilityEnabled) private var accessibilityEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    public init() {}

    public var snapshot: PrismEnvironmentSnapshot {
        PrismEnvironmentSnapshot(
            colorScheme: colorScheme,
            dynamicTypeSize: dynamicTypeSize,
            layoutDirection: layoutDirection,
            accessibilityEnabled: accessibilityEnabled,
            reduceMotion: reduceMotion,
            reduceTransparency: reduceTransparency
        )
    }

    public var body: some View {
        List {
            Section("Environment") {
                row(
                    label: "Color Scheme",
                    value: colorScheme == .dark ? "Dark" : "Light",
                    icon: "circle.lefthalf.filled"
                )
                row(
                    label: "Dynamic Type",
                    value: String(describing: dynamicTypeSize),
                    icon: "textformat.size"
                )
                row(
                    label: "Layout Direction",
                    value: layoutDirection == .rightToLeft ? "RTL" : "LTR",
                    icon: "text.alignleft"
                )
            }

            Section("Accessibility") {
                row(
                    label: "VoiceOver",
                    value: accessibilityEnabled ? "On" : "Off",
                    icon: "accessibility"
                )
                row(
                    label: "Reduce Motion",
                    value: reduceMotion ? "On" : "Off",
                    icon: "figure.walk"
                )
                row(
                    label: "Reduce Transparency",
                    value: reduceTransparency ? "On" : "Off",
                    icon: "square.on.square"
                )
            }
        }
        .accessibilityLabel("Environment debugger")
    }

    @ViewBuilder
    private func row(label: String, value: String, icon: String) -> some View {
        HStack {
            Label(label, systemImage: icon)
                .font(TypographyToken.body.font)
            Spacer()
            Text(value)
                .font(TypographyToken.body.font(weight: .medium, design: .monospaced))
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }
}

// MARK: - Floating Badge Modifier

private struct PrismEnvironmentDebugBadge: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        #if DEBUG
            content.overlay(alignment: .bottomTrailing) {
                HStack(spacing: 4) {
                    Image(systemName: colorScheme == .dark ? "moon.fill" : "sun.max.fill")
                        .font(.system(size: 9))
                    Text(String(describing: dynamicTypeSize))
                        .font(.system(size: 8, weight: .medium, design: .monospaced))
                    if reduceMotion {
                        Image(systemName: "figure.walk")
                            .font(.system(size: 9))
                    }
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(.black.opacity(0.7))
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                .padding(8)
                .allowsHitTesting(false)
            }
        #else
            content
        #endif
    }
}

extension View {
    public func prismEnvironmentDebug() -> some View {
        modifier(PrismEnvironmentDebugBadge())
    }
}
