import SwiftUI

/// Themed section with header, footer, and Apple-style grouped inset.
public struct PrismSection<Content: View, Header: View, Footer: View>: View {
    @Environment(\.prismTheme) private var theme

    private let content: Content
    private let header: Header
    private let footer: Footer

    public init(
        @ViewBuilder content: () -> Content,
        @ViewBuilder header: () -> Header,
        @ViewBuilder footer: () -> Footer
    ) {
        self.content = content()
        self.header = header()
        self.footer = footer()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: SpacingToken.xs.rawValue) {
            header
                .font(TypographyToken.footnote.font(weight: .medium))
                .foregroundStyle(theme.color(.onBackgroundSecondary))
                .textCase(.uppercase)
                .padding(.horizontal, SpacingToken.lg.rawValue)

            VStack(spacing: 0) {
                content
            }
            .background(theme.color(.surface), in: RadiusToken.lg.shape)

            footer
                .font(TypographyToken.caption.font)
                .foregroundStyle(theme.color(.onBackgroundTertiary))
                .padding(.horizontal, SpacingToken.lg.rawValue)
        }
    }
}

extension PrismSection where Footer == EmptyView {

    public init(
        @ViewBuilder content: () -> Content,
        @ViewBuilder header: () -> Header
    ) {
        self.content = content()
        self.header = header()
        self.footer = EmptyView()
    }
}

extension PrismSection where Header == EmptyView, Footer == EmptyView {

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
        self.header = EmptyView()
        self.footer = EmptyView()
    }
}
