import SwiftUI

public enum PrismScrollBehavior: Sendable {
    case viewAligned
    case paging
    case automatic
}

// MARK: - Scroll Target

private struct PrismScrollTargetModifier: ViewModifier {
    let behavior: PrismScrollBehavior

    func body(content: Content) -> some View {
        switch behavior {
        case .viewAligned:
            content
                .scrollTargetLayout()
                .scrollTargetBehavior(.viewAligned)
        case .paging:
            content
                .scrollTargetLayout()
                .scrollTargetBehavior(.paging)
        case .automatic:
            content
        }
    }
}

extension View {

    public func prismScrollTarget(_ behavior: PrismScrollBehavior = .viewAligned) -> some View {
        modifier(PrismScrollTargetModifier(behavior: behavior))
    }

    public func prismScrollIndicators(_ visibility: ScrollIndicatorVisibility = .hidden) -> some View {
        self.scrollIndicators(visibility)
    }

    public func prismScrollClipDisabled(_ disabled: Bool = true) -> some View {
        self.scrollClipDisabled(disabled)
    }

    public func prismToolbarBackground(
        _ visibility: Visibility = .hidden,
        for bars: ToolbarPlacement = .automatic
    ) -> some View {
        self.toolbarBackgroundVisibility(visibility, for: bars)
    }
}
