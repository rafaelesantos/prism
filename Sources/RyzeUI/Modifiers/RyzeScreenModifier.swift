//
//  RyzeScreenSizeModifier.swift
//  Ryze
//
//  Created by Rafael Escaleira on 01/08/25.
//

import SwiftUI

private struct RyzeScreenSizePreferenceKey: @MainActor PreferenceKey {
    @MainActor static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

private struct RyzeScreenScrollOffsetPreferenceKey: @MainActor PreferenceKey {
    @MainActor static var defaultValue: CGPoint = .zero

    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
        value = nextValue()
    }
}

struct RyzeScreenModifier: RyzeViewModifier {
    @State var size: CGSize = .zero
    @State var origin: CGPoint = .zero
    @State var isLargeScreen: Bool = false

    let minimumWidthScreen: CGFloat

    func body(content: Content) -> some View {
        content
            .environment(\.screenSize, size)
            .environment(\.isLargeScreen, size.width > minimumWidthScreen)
            .environment(\.scrollPosition, origin)
            .background {
                GeometryReader { proxy in
                    Color.clear
                        .preference(
                            key: RyzeScreenSizePreferenceKey.self,
                            value: proxy.size
                        )
                        .preference(
                            key: RyzeScreenScrollOffsetPreferenceKey.self,
                            value: proxy.frame(in: .named("scroll")).origin
                        )
                }
            }
            .onPreferenceChange(RyzeScreenSizePreferenceKey.self) { newSize in
                size = newSize
            }
            .onPreferenceChange(RyzeScreenScrollOffsetPreferenceKey.self) { newOrigin in
                origin = newOrigin
            }
    }

    static func mocked() -> some View {
        RyzeHStack.mocked()
            .ryze(width: .max, height: .max)
            .ryzePadding()
            .ryzeScreenObserve()
    }
}

#Preview {
    RyzeScreenModifier.mocked()
}
