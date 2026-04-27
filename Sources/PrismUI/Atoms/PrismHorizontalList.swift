//
//  PrismHorizontalList.swift
//  Prism
//
//  Created by Rafael Escaleira on 29/07/25.
//

import SwiftUI

/// Horizontal scrolling list for the PrismUI Design System.
///
/// `PrismHorizontalList` is a list with horizontal scrolling:
/// - Horizontal scroll with `ScrollViewProxy` for programmatic navigation
/// - Hidden scroll indicators
/// - Position binding to control the visible item
/// - Full accessibility support (VoiceOver/TalkBack)
/// - UI testing (XCUITest) via stable testIDs
///
/// ## Basic Usage
/// ```swift
/// PrismHorizontalList { proxy in
///     ForEach(items) { item in
///         PrismBodyText(item.title)
///     }
/// }
/// ```
///
/// ## With Programmatic Scrolling
/// ```swift
/// PrismHorizontalList { proxy in
///     ForEach(items) { item in
///         PrismBodyText(item.title)
///             .id(item.id)
///     }
/// }
/// // Elsewhere: proxy.scrollTo(itemId)
/// ```
///
/// ## With testID for Testing
/// ```swift
/// PrismHorizontalList(testID: "horizontal_list") { proxy in
///     ForEach(items) { item in
///         ItemView(item: item)
///     }
/// }
/// ```
///
/// - Note: Use `ScrollViewProxy` for programmatic scrolling via `scrollTo(_:)`.
public struct PrismHorizontalList: PrismView {
    let content: (ScrollViewProxy) -> any View
    public var accessibility: PrismAccessibilityProperties?

    @State var position: Int?

    public init(
        _ accessibility: PrismAccessibilityProperties? = nil,
        @ViewBuilder content: @escaping (ScrollViewProxy) -> some View
    ) {
        self.accessibility = accessibility
        self.content = content
    }

    public init(
        testID: String,
        @ViewBuilder content: @escaping (ScrollViewProxy) -> some View
    ) {
        self.accessibility = PrismAccessibility.custom(label: "", testID: testID)
        self.content = content
    }

    public var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                AnyView(content(proxy))
            }
            .scrollIndicators(.hidden)
            .scrollPosition(id: $position)
        }
        .prism(accessibility)
    }

    public static func mocked() -> some View {
        PrismHorizontalList { _ in
            PrismHStack.mocked()
            PrismHStack.mocked()
        }
    }
}

#Preview {
    PrismHorizontalList.mocked()
}
