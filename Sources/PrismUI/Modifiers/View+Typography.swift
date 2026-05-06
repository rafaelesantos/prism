import SwiftUI

extension View {

    public func prismFont(_ token: TypographyToken) -> some View {
        font(token.font)
    }

    public func prismFont(_ token: TypographyToken, weight: Font.Weight) -> some View {
        font(token.font(weight: weight))
    }

    public func prismFont(
        _ token: TypographyToken,
        weight: Font.Weight,
        design: Font.Design
    ) -> some View {
        font(token.font(weight: weight, design: design))
    }

    public func prismFont(
        _ token: TypographyToken,
        weight: Font.Weight,
        width: Font.Width
    ) -> some View {
        font(token.font(weight: weight, width: width))
    }

    public func prismFontWidth(_ width: Font.Width) -> some View {
        fontWidth(width)
    }

    public func prismColor(_ token: ColorToken) -> some View {
        modifier(ThemeColorModifier(token: token))
    }
}

private struct ThemeColorModifier: ViewModifier {
    @Environment(\.prismTheme) private var theme
    let token: ColorToken

    func body(content: Content) -> some View {
        content.foregroundStyle(theme.color(token))
    }
}
