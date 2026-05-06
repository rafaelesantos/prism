import SwiftUI

@MainActor
public struct PrismButtonGroup<Content: View>: View {
    private let alignment: HorizontalAlignment
    private let spacing: SpacingToken
    private let content: Content

    public init(
        alignment: HorizontalAlignment = .center,
        spacing: SpacingToken = .md,
        @ViewBuilder content: () -> Content
    ) {
        self.alignment = alignment
        self.spacing = spacing
        self.content = content()
    }

    public var body: some View {
        HStack(spacing: spacing.rawValue) {
            content
        }
        .frame(maxWidth: .infinity, alignment: Alignment(horizontal: alignment, vertical: .center))
        .accessibilityElement(children: .contain)
    }
}

@MainActor
public struct PrismSegmentedButtons: View {
    @Environment(\.prismTheme) private var theme

    let options: [String]
    @Binding var selection: String

    public init(options: [String], selection: Binding<String>) {
        self.options = options
        self._selection = selection
    }

    public var body: some View {
        HStack(spacing: 0) {
            ForEach(options, id: \.self) { option in
                Button {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                        selection = option
                    }
                } label: {
                    Text(option)
                        .font(TypographyToken.subheadline.font)
                        .foregroundStyle(
                            selection == option
                                ? theme.color(.onBrand)
                                : theme.color(.onBackground)
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, SpacingToken.sm.rawValue)
                        .background(
                            selection == option
                                ? theme.color(.interactive)
                                : Color.clear,
                            in: Capsule()
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(SpacingToken.xxs.rawValue)
        .background(theme.color(.surfaceSecondary), in: Capsule())
        .accessibilityElement(children: .contain)
    }
}
