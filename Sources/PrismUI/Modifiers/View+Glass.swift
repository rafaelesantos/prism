import SwiftUI

extension View {

    public func prismGlass(in shape: some Shape = Capsule()) -> some View {
        modifier(GlassModifier(shape: AnyShape(shape)))
    }

    public func prismGlass(cornerRadius: CGFloat) -> some View {
        modifier(GlassModifier(shape: AnyShape(.rect(cornerRadius: cornerRadius))))
    }

    public func prismGlassID<ID: Hashable & Sendable>(_ id: ID, in namespace: Namespace.ID) -> some View {
        self.glassEffectID(id, in: namespace)
    }

    public func prismBackgroundExtension() -> some View {
        self.backgroundExtensionEffect()
    }
}

public struct PrismGlassContainer<Content: View>: View {
    private let spacing: CGFloat
    private let content: Content

    public init(
        spacing: CGFloat = SpacingToken.sm.rawValue,
        @ViewBuilder content: () -> Content
    ) {
        self.spacing = spacing
        self.content = content()
    }

    public var body: some View {
        GlassEffectContainer(spacing: spacing) {
            content
        }
    }
}

private struct GlassModifier: ViewModifier {
    let shape: AnyShape

    func body(content: Content) -> some View {
        content.glassEffect(.regular, in: shape)
    }
}
