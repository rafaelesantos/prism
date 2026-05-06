import SwiftUI

public struct PrismPreviewCatalog<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: SpacingToken.xl.rawValue) {
                previewBlock("Light Mode") {
                    content
                        .preferredColorScheme(.light)
                }

                previewBlock("Dark Mode") {
                    content
                        .preferredColorScheme(.dark)
                }

                previewBlock("Large Text") {
                    content
                        .dynamicTypeSize(.xxxLarge)
                }

                previewBlock("Accessibility Size") {
                    content
                        .dynamicTypeSize(.accessibility3)
                }

                previewBlock("Disabled State") {
                    content
                        .disabled(true)
                }
            }
            .padding(SpacingToken.lg.rawValue)
        }
    }

    @ViewBuilder
    private func previewBlock<V: View>(_ title: String, @ViewBuilder content: () -> V) -> some View {
        VStack(alignment: .leading, spacing: SpacingToken.xs.rawValue) {
            Text(title)
                .font(TypographyToken.caption.font(weight: .medium))
                .foregroundStyle(.secondary)

            content()
                .padding(SpacingToken.md.rawValue)
                .background(.quaternary, in: RadiusToken.md.shape)
        }
    }
}
