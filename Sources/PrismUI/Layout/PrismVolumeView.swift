import SwiftUI

#if os(visionOS)
    public struct PrismVolumeView<Content: View>: View {
        @Environment(\.prismTheme) private var theme

        private let content: Content
        private let depth: CGFloat

        public init(
            depth: CGFloat = 0,
            @ViewBuilder content: () -> Content
        ) {
            self.content = content()
            self.depth = depth
        }

        public var body: some View {
            content
                .offset(z: depth)
                .frame(depth: max(depth, 100))
        }
    }

    public struct PrismOrnamentView<Content: View>: View {
        @Environment(\.prismTheme) private var theme

        private let content: Content

        public init(@ViewBuilder content: () -> Content) {
            self.content = content()
        }

        public var body: some View {
            content
                .padding(SpacingToken.md.rawValue)
                .glassBackgroundEffect()
        }
    }
#endif
