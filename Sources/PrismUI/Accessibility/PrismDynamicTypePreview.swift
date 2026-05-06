import SwiftUI

public struct PrismDynamicTypePreview<Content: View>: View {
    private let content: Content

    private let sizes: [DynamicTypeSize] = [
        .xSmall,
        .medium,
        .large,
        .xxxLarge,
        .accessibility3,
    ]

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: SpacingToken.xl.rawValue) {
                ForEach(sizes, id: \.self) { size in
                    VStack(alignment: .leading, spacing: SpacingToken.xs.rawValue) {
                        Text(String(describing: size))
                            .font(.caption2)
                            .foregroundStyle(.secondary)

                        content
                            .dynamicTypeSize(size)
                    }
                    .padding(SpacingToken.md.rawValue)
                    .background(.quaternary, in: RadiusToken.md.shape)
                }
            }
            .padding(SpacingToken.lg.rawValue)
        }
    }
}
