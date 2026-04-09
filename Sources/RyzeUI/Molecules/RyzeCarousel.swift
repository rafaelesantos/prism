//
//  RyzeCarousel.swift
//  Ryze
//
//  Created by Rafael Escaleira on 14/02/26.
//

import SwiftUI

public struct RyzeCarousel<Item: Identifiable & Equatable, Content: View>: View {
    @Environment(\.theme) var theme

    let items: [Item]
    let itemWidth: CGFloat
    let spacing: RyzeSpacing
    let minimumScale: CGFloat
    let isAutoScrolling: Bool
    let content: (Int) -> Content

    @Binding var selection: Int?

    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()

    var spacingValue: CGFloat {
        spacing.rawValue(for: theme.spacing)
    }

    public init(
        items: [Item],
        itemWidth: CGFloat = 160,
        spacing: RyzeSpacing = .small,
        minimumScale: CGFloat = 0.85,
        selection: Binding<Int?>,
        isAutoScrolling: Bool = true,
        @ViewBuilder content: @escaping (Int) -> Content
    ) {
        self.items = items
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
            .ryze(if: isAutoScrolling) { $0.onReceive(timer) { _ in autoScroll() } }
        }
    }

    func autoScroll() {
        guard !items.isEmpty else { return }

        withAnimation(.bouncy(duration: 1.2)) {
            selection = ((selection ?? .zero) + 1) % items.count
        }
    }
}
