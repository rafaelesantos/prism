import SwiftUI

@MainActor
public struct PrismSharedElement<Content: View>: View {
    let id: String
    let namespace: Namespace.ID
    let anchor: UnitPoint
    let isSource: Bool
    let content: Content

    public init(
        id: String,
        namespace: Namespace.ID,
        anchor: UnitPoint = .center,
        isSource: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.id = id
        self.namespace = namespace
        self.anchor = anchor
        self.isSource = isSource
        self.content = content()
    }

    public var body: some View {
        content
            .matchedGeometryEffect(id: id, in: namespace, anchor: anchor, isSource: isSource)
    }
}

private struct PrismMatchedGeometryModifier: ViewModifier {
    let id: String
    let namespace: Namespace.ID
    let anchor: UnitPoint
    let isSource: Bool

    func body(content: Content) -> some View {
        content
            .matchedGeometryEffect(id: id, in: namespace, anchor: anchor, isSource: isSource)
    }
}

extension View {

    public func prismMatchedGeometry(
        id: String,
        in namespace: Namespace.ID,
        anchor: UnitPoint = .center,
        isSource: Bool = true
    ) -> some View {
        modifier(PrismMatchedGeometryModifier(id: id, namespace: namespace, anchor: anchor, isSource: isSource))
    }
}

@MainActor
public struct PrismHeroTransition<Source: View, Destination: View>: View {
    @Namespace private var heroNamespace
    @Binding var isExpanded: Bool

    let heroID: String
    let spring: PrismSpringConfig
    let source: Source
    let destination: Destination

    public init(
        isExpanded: Binding<Bool>,
        heroID: String = "hero",
        spring: PrismSpringConfig = .dramatic,
        @ViewBuilder source: () -> Source,
        @ViewBuilder destination: () -> Destination
    ) {
        self._isExpanded = isExpanded
        self.heroID = heroID
        self.spring = spring
        self.source = source()
        self.destination = destination()
    }

    public var body: some View {
        Group {
            if isExpanded {
                destination
                    .matchedGeometryEffect(id: heroID, in: heroNamespace)
                    .onTapGesture {
                        withAnimation(spring.animation) {
                            isExpanded = false
                        }
                    }
            } else {
                source
                    .matchedGeometryEffect(id: heroID, in: heroNamespace)
                    .onTapGesture {
                        withAnimation(spring.animation) {
                            isExpanded = true
                        }
                    }
            }
        }
    }
}
