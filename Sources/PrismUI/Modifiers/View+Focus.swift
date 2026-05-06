import SwiftUI

public enum PrismFocusStyle: Sendable {
    case ring
    case highlight
    case scale
    case subtle
}

private struct PrismFocusModifier: ViewModifier {
    @Environment(\.prismTheme) private var theme
    @Environment(\.isFocused) private var isFocused

    let style: PrismFocusStyle

    func body(content: Content) -> some View {
        content
            .overlay {
                switch style {
                case .ring:
                    if isFocused {
                        RoundedRectangle(cornerRadius: RadiusToken.md.rawValue)
                            .stroke(theme.color(.interactive), lineWidth: 2.5)
                            .padding(-2)
                    }
                case .highlight:
                    if isFocused {
                        RoundedRectangle(cornerRadius: RadiusToken.md.rawValue)
                            .fill(theme.color(.interactive).opacity(0.12))
                    }
                case .scale, .subtle:
                    EmptyView()
                }
            }
            .scaleEffect(isFocused && style == .scale ? 1.05 : 1.0)
            .opacity(isFocused && style == .subtle ? 0.85 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: isFocused)
    }
}

public struct PrismFocusSection<Content: View>: View {
    @Environment(\.prismTheme) private var theme

    private let title: LocalizedStringKey?
    private let content: Content

    public init(
        _ title: LocalizedStringKey? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: SpacingToken.sm.rawValue) {
            if let title {
                Text(title)
                    .font(TypographyToken.headline.font)
                    .foregroundStyle(theme.color(.onBackground))
            }

            #if os(tvOS)
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: SpacingToken.md.rawValue) {
                        content
                    }
                    .padding(.horizontal, SpacingToken.lg.rawValue)
                }
                .focusSection()
            #else
                content
            #endif
        }
    }
}

extension View {

    public func prismFocusStyle(_ style: PrismFocusStyle = .ring) -> some View {
        modifier(PrismFocusModifier(style: style))
    }

    public func prismFocusable(_ style: PrismFocusStyle = .ring) -> some View {
        self
            .focusable()
            .prismFocusStyle(style)
    }
}
