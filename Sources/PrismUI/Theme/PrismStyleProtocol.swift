import SwiftUI

/// Protocol for custom button styling within Prism theming.
@MainActor
public protocol PrismCustomButtonStyle {
    associatedtype Body: View
    @ViewBuilder func makeBody(label: Text, icon: Image?, theme: any PrismTheme, isPressed: Bool) -> Body
}

/// Protocol for custom card styling.
@MainActor
public protocol PrismCustomCardStyle {
    associatedtype Body: View
    @ViewBuilder func makeBody(content: AnyView, theme: any PrismTheme) -> Body
}

/// Built-in elevated card style.
public struct PrismElevatedCardStyle: PrismCustomCardStyle {
    public init() {}

    public func makeBody(content: AnyView, theme: any PrismTheme) -> some View {
        content
            .padding(SpacingToken.md.rawValue)
            .background(theme.color(.surface), in: RadiusToken.lg.shape)
            .prismElevation(.medium)
    }
}

/// Built-in outlined card style.
public struct PrismOutlinedCardStyle: PrismCustomCardStyle {
    public init() {}

    public func makeBody(content: AnyView, theme: any PrismTheme) -> some View {
        content
            .padding(SpacingToken.md.rawValue)
            .background(theme.color(.background), in: RadiusToken.lg.shape)
            .overlay(
                RoundedRectangle(cornerRadius: RadiusToken.lg.rawValue)
                    .stroke(theme.color(.border), lineWidth: 1)
            )
    }
}

/// Built-in flat card style (no elevation or border).
public struct PrismFlatCardStyle: PrismCustomCardStyle {
    public init() {}

    public func makeBody(content: AnyView, theme: any PrismTheme) -> some View {
        content
            .padding(SpacingToken.md.rawValue)
            .background(theme.color(.surfaceSecondary), in: RadiusToken.lg.shape)
    }
}
