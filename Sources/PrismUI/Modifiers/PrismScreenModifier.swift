//
//  PrismScreenSizeModifier.swift
//  Prism
//
//  Created by Rafael Escaleira on 01/08/25.
//

import SwiftUI

/// Screen observation modifier for the PrismUI Design System.
///
/// `PrismScreenModifier` monitors screen size and scroll position:
/// - Makes `screenSize` available in the environment
/// - Makes `isLargeScreen` available in the environment (configurable)
/// - Makes `scrollPosition` available in the environment
/// - Uses `PreferenceKey` for efficient propagation
///
/// ## Basic Usage
/// ```swift
/// MyView()
///     .prismScreenObserve(minimumWidthScreen: 430)
/// ```
///
/// ## Accessing from the Environment
/// ```swift
/// struct MyView: View {
///     @Environment(\.screenSize) var screenSize
///     @Environment(\.isLargeScreen) var isLargeScreen
///     @Environment(\.scrollPosition) var scrollPosition
///
///     var body: some View {
///         if isLargeScreen {
///             TabletLayout()
///         } else {
///             PhoneLayout()
///         }
///     }
/// }
/// ```
///
/// ## Internal Preferences
/// - `PrismScreenSizePreferenceKey` - Propagates screen size
/// - `PrismScreenScrollOffsetPreferenceKey` - Propagates scroll offset
///
/// - Note: The default threshold for `isLargeScreen` is 430pt (iPhone 14 Pro Max).
private struct PrismScreenSizePreferenceKey: @MainActor PreferenceKey {
    @MainActor static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

private struct PrismScreenScrollOffsetPreferenceKey: @MainActor PreferenceKey {
    @MainActor static var defaultValue: CGPoint = .zero

    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
        value = nextValue()
    }
}

struct PrismScreenModifier: ViewModifier {
    @Environment(\.theme) private var theme

    @State var size: CGSize = .zero
    @State var origin: CGPoint = .zero

    let minimumWidthScreen: CGFloat

    public func body(content: Content) -> some View {
        let layoutTier = theme.tokens.layoutTier(for: size.width)
        let platform = PrismPlatform.current
        let platformContext = PrismPlatformContext.resolve(
            platform: platform,
            layoutTier: layoutTier
        )
        let adaptiveLargeScreenThreshold = max(
            minimumWidthScreen,
            theme.tokens.breakpoint(for: .tabletCompact)
        )

        content
            .environment(\.screenSize, size)
            .environment(\.isLargeScreen, size.width >= adaptiveLargeScreenThreshold)
            .environment(\.scrollPosition, origin)
            .environment(\.platform, platform)
            .environment(\.platformContext, platformContext)
            .environment(\.layoutTier, layoutTier)
            .background {
                GeometryReader { proxy in
                    Color.clear
                        .preference(
                            key: PrismScreenSizePreferenceKey.self,
                            value: proxy.size
                        )
                        .preference(
                            key: PrismScreenScrollOffsetPreferenceKey.self,
                            value: proxy.frame(in: .named("scroll")).origin
                        )
                }
            }
            .onPreferenceChange(PrismScreenSizePreferenceKey.self) { newSize in
                size = newSize
            }
            .onPreferenceChange(PrismScreenScrollOffsetPreferenceKey.self) { newOrigin in
                origin = newOrigin
            }
    }

    static func mocked() -> some View {
        PrismHStack.mocked()
            .prism(width: .max, height: .max)
            .prismPadding()
            .prismScreenObserve()
    }
}

#Preview {
    PrismScreenModifier.mocked()
}
