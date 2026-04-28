import SwiftUI

/// Screen-level layout template with themed background and safe area handling.
public struct PrismScaffold<Content: View>: View {
    @Environment(\.prismTheme) private var theme

    private let background: ColorToken
    private let content: Content

    public init(
        background: ColorToken = .background,
        @ViewBuilder content: () -> Content
    ) {
        self.background = background
        self.content = content()
    }

    public var body: some View {
        ZStack {
            theme.color(background)
                .ignoresSafeArea()

            content
        }
    }
}
