import SwiftUI

private struct PrismOrnamentModifier<OrnamentContent: View>: ViewModifier {
    let edge: Edge
    let ornamentContent: OrnamentContent

    func body(content: Content) -> some View {
        #if os(visionOS)
            content.ornament(attachmentAnchor: .scene(ornamentAnchor)) {
                ornamentContent
            }
        #else
            content.overlay(alignment: overlayAlignment) {
                ornamentContent
                    .padding(SpacingToken.sm.rawValue)
            }
        #endif
    }

    #if os(visionOS)
        private var ornamentAnchor: UnitPoint {
            switch edge {
            case .top: .top
            case .bottom: .bottom
            case .leading: .leading
            case .trailing: .trailing
            }
        }
    #endif

    private var overlayAlignment: Alignment {
        switch edge {
        case .top: .top
        case .bottom: .bottom
        case .leading: .leading
        case .trailing: .trailing
        }
    }
}

extension View {

    public func prismOrnament<Content: View>(
        edge: Edge = .bottom,
        @ViewBuilder content: () -> Content
    ) -> some View {
        modifier(PrismOrnamentModifier(edge: edge, ornamentContent: content()))
    }
}
