import SwiftUI

@MainActor
public protocol PrismCustomButtonStyle {
    associatedtype Body: View
    @ViewBuilder func makeBody(label: Text, icon: Image?, theme: any PrismTheme, isPressed: Bool) -> Body
}

@MainActor
public protocol PrismCustomCardStyle {
    associatedtype Body: View
    @ViewBuilder func makeBody(content: AnyView, theme: any PrismTheme) -> Body
}

public struct PrismElevatedCardStyle: PrismCustomCardStyle {
    public init() {}

    public func makeBody(content: AnyView, theme: any PrismTheme) -> some View {
        content
            .padding(SpacingToken.md.rawValue)
            .background(theme.color(.surface), in: RadiusToken.lg.shape)
            .prismElevation(.medium)
    }
}

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

public struct PrismFlatCardStyle: PrismCustomCardStyle {
    public init() {}

    public func makeBody(content: AnyView, theme: any PrismTheme) -> some View {
        content
            .padding(SpacingToken.md.rawValue)
            .background(theme.color(.surfaceSecondary), in: RadiusToken.lg.shape)
    }
}
