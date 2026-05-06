import SwiftUI

public struct PrismDepthStack<Content: View>: View {
    @Environment(\.prismTheme) private var theme

    private let spacing: CGFloat
    private let content: Content

    public init(
        spacing: CGFloat = SpacingToken.md.rawValue,
        @ViewBuilder content: () -> Content
    ) {
        self.spacing = spacing
        self.content = content()
    }

    public var body: some View {
        ZStack {
            content
        }
    }
}

private struct PrismDepthModifier: ViewModifier {
    let depth: CGFloat

    func body(content: Content) -> some View {
        #if os(visionOS)
            content.offset(z: depth)
        #else
            content
        #endif
    }
}

extension View {

    public func prismDepth(_ depth: CGFloat) -> some View {
        modifier(PrismDepthModifier(depth: depth))
    }
}
