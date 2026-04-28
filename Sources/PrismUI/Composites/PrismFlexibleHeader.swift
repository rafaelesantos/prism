import SwiftUI

/// Stretchy scroll header that expands on overscroll and collapses on scroll.
///
/// Pattern from Apple Landmarks sample — image stretches when pulling down.
///
/// ```swift
/// ScrollView {
///     PrismFlexibleHeader(minHeight: 200) {
///         Image("hero").resizable().scaledToFill()
///     }
///     // rest of content
/// }
/// ```
public struct PrismFlexibleHeader<Content: View>: View {
    private let minHeight: CGFloat
    private let content: Content

    public init(
        minHeight: CGFloat = 250,
        @ViewBuilder content: () -> Content
    ) {
        self.minHeight = minHeight
        self.content = content()
    }

    public var body: some View {
        GeometryReader { geometry in
            let offset = geometry.frame(in: .global).minY
            let height = max(minHeight, minHeight + offset)

            content
                .frame(width: geometry.size.width, height: height)
                .clipped()
                .offset(y: offset > 0 ? -offset : 0)
        }
        .frame(height: minHeight)
    }
}

/// Collapsible header that fades navigation title as user scrolls.
public struct PrismParallaxHeader<Content: View, Overlay: View>: View {
    @Environment(\.prismTheme) private var theme

    private let minHeight: CGFloat
    private let content: Content
    private let overlay: Overlay

    public init(
        minHeight: CGFloat = 300,
        @ViewBuilder content: () -> Content,
        @ViewBuilder overlay: () -> Overlay
    ) {
        self.minHeight = minHeight
        self.content = content()
        self.overlay = overlay()
    }

    public var body: some View {
        GeometryReader { geometry in
            let offset = geometry.frame(in: .global).minY
            let height = max(minHeight, minHeight + offset)
            let progress = min(1, max(0, -offset / (minHeight * 0.6)))

            ZStack(alignment: .bottomLeading) {
                content
                    .frame(width: geometry.size.width, height: height)
                    .clipped()
                    .offset(y: offset > 0 ? -offset : 0)

                overlay
                    .padding(SpacingToken.lg.rawValue)
                    .opacity(1 - progress)
            }
        }
        .frame(height: minHeight)
    }
}

extension PrismParallaxHeader where Overlay == EmptyView {

    public init(
        minHeight: CGFloat = 300,
        @ViewBuilder content: () -> Content
    ) {
        self.minHeight = minHeight
        self.content = content()
        self.overlay = EmptyView()
    }
}
