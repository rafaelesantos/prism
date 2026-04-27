//
//  PrismCarousel.swift
//  Prism
//
//  Created by Rafael Escaleira on 14/02/26.
//

import SwiftUI

/// Horizontal scrolling item carousel for the PrismUI Design System.
///
/// `PrismCarousel` is a horizontal list component with:
/// - Scale and opacity effects on side items
/// - Optional auto-scrolling (configurable via timer)
/// - Selection binding to control the visible item
/// - Semantic spacing via `PrismSpacing`
/// - Full accessibility support (VoiceOver/TalkBack)
/// - UI testing (XCUITest) via stable testIDs
///
/// ## Basic Usage
/// ```swift
/// @State var selected: Int?
/// PrismCarousel(
///     items: ["A", "B", "C"],
///     selection: $selected
/// ) { index in
///     PrismText("Item \(index)")
/// }
/// ```
///
/// ## With Auto Scroll
/// ```swift
/// @State var selected: Int?
/// PrismCarousel(
///     items: items,
///     selection: $selected,
///     isAutoScrolling: true  // Scrolls every 5 seconds
/// ) { index in
///     CardView(item: items[index])
/// }
/// ```
///
/// ## With testID for Testing
/// ```swift
/// PrismCarousel(
///     items: items,
///     testID: "featured_carousel",
///     selection: $selected
/// ) { index in
///     FeaturedCard(item: items[index])
/// }
/// ```
///
/// ## Customization
/// ```swift
/// PrismCarousel(
///     items: items,
///     itemWidth: 200,          // Width of each item
///     spacing: .medium,        // Spacing between items
///     minimumScale: 0.9,       // Minimum scale for side items
///     selection: $selected
/// ) { index in
///     ContentCard(items[index])
/// }
/// ```
///
/// - Note: Auto scroll occurs every 5 seconds using `.bouncy(duration: 1.2)` animation.
/// - Important: The carousel uses `.viewAligned` scroll behavior for precise alignment.
public struct PrismCarousel<Item: Identifiable & Equatable, Content: View>: PrismView {
    @Environment(\.theme) var theme

    let items: [Item]
    let itemWidth: CGFloat
    let spacing: PrismSpacing
    let minimumScale: CGFloat
    let isAutoScrolling: Bool
    let content: (Int) -> Content

    @Binding var selection: Int?
    public var accessibility: PrismAccessibilityProperties?

    public enum MockView: View {
        case empty
        public var body: some View {
            PrismText("Carousel Mock")
        }
    }

    public static func mocked() -> MockView {
        .empty
    }

    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()

    var spacingValue: CGFloat {
        spacing.rawValue(for: theme.spacing)
    }

    public init(
        items: [Item],
        _ accessibility: PrismAccessibilityProperties? = nil,
        itemWidth: CGFloat = 160,
        spacing: PrismSpacing = .small,
        minimumScale: CGFloat = 0.85,
        selection: Binding<Int?>,
        isAutoScrolling: Bool = true,
        @ViewBuilder content: @escaping (Int) -> Content
    ) {
        self.items = items
        self.accessibility = accessibility
        self.itemWidth = itemWidth
        self.spacing = spacing
        self.minimumScale = minimumScale
        self.isAutoScrolling = isAutoScrolling
        self._selection = selection
        self.content = content
    }

    public init(
        items: [Item],
        testID: String,
        itemWidth: CGFloat = 160,
        spacing: PrismSpacing = .small,
        minimumScale: CGFloat = 0.85,
        selection: Binding<Int?>,
        isAutoScrolling: Bool = true,
        @ViewBuilder content: @escaping (Int) -> Content
    ) {
        self.items = items
        self.accessibility = PrismAccessibility.custom(label: "Carousel", testID: testID)
        self.itemWidth = itemWidth
        self.spacing = spacing
        self.minimumScale = minimumScale
        self.isAutoScrolling = isAutoScrolling
        self._selection = selection
        self.content = content
    }

    public var body: some View {
        GeometryReader { proxy in
            let horizontalInset = (proxy.size.width / 2) - (itemWidth / 2.5) + spacingValue
            let minimumScaleValue = minimumScale

            ScrollView(.horizontal) {
                HStack(spacing: spacingValue) {
                    ForEach(Array(items.enumerated()), id: \.element.id) { index, _ in
                        content(index)
                            .frame(width: itemWidth)
                            .containerRelativeFrame(.horizontal)
                            .id(index)
                            .scrollTransition(.interactive, axis: .horizontal) { view, phase in
                                let progress = 1 - abs(phase.value)
                                let scale = minimumScaleValue + progress * (1 - minimumScaleValue)
                                let opacity = 0.5 + (0.5 * (1 - abs(phase.value)))

                                return
                                    view
                                    .scaleEffect(scale)
                                    .opacity(opacity)
                            }
                    }
                }
                .scrollTargetLayout()
            }
            .scrollIndicators(.hidden)
            .contentMargins(.horizontal, horizontalInset)
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $selection)
            .padding(.horizontal, -40)
            .animation(.bouncy(duration: 1.2), value: items)
            .prism(if: isAutoScrolling) { $0.onReceive(timer) { _ in autoScroll() } }
        }
        .prism(accessibility)
    }

    func autoScroll() {
        guard !items.isEmpty else { return }

        withAnimation(.bouncy(duration: 1.2)) {
            selection = ((selection ?? .zero) + 1) % items.count
        }
    }
}
