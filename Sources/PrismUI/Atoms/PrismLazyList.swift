//
//  PrismLazyList.swift
//  Prism
//
//  Created by Rafael Escaleira on 06/06/25.
//

import SwiftUI

/// Lazy loading list for the PrismUI Design System.
///
/// `PrismLazyList` is a lazily loaded list:
/// - Uses `LazyVStack` for performance with long lists
/// - Automatic vertical scrolling
/// - Automatic edge padding
/// - Semantic spacing via `PrismSpacing`
/// - Full accessibility support (VoiceOver/TalkBack)
/// - UI testing (XCUITest) via stable testIDs
///
/// ## Basic Usage
/// ```swift
/// PrismLazyList {
///     ForEach(items) { item in
///         PrismBodyText(item.title)
///     }
/// }
/// ```
///
/// ## With testID for Testing
/// ```swift
/// PrismLazyList(testID: "items_list") {
///     ForEach(items) { item in
///         PrismBodyText(item.title)
///     }
/// }
/// ```
///
/// - Note: Ideal for long lists where performance is critical.
public struct PrismLazyList: PrismView {
    @Environment(\.theme) var theme
    let content: any View
    public var accessibility: PrismAccessibilityProperties?

    public init(
        _ accessibility: PrismAccessibilityProperties? = nil,
        @ViewBuilder content: () -> some View
    ) {
        self.accessibility = accessibility
        self.content = content()
    }

    public init(
        testID: String,
        @ViewBuilder content: () -> some View
    ) {
        self.accessibility = PrismAccessibility.custom(label: "", testID: testID)
        self.content = content()
    }

    public var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: theme.spacing.medium) {
                AnyView(content)
            }
            .prismPadding()
        }
        .prism(accessibility)
    }

    public static func mocked() -> some View {
        PrismLazyList {
            PrismText.mocked()
            PrismHStack.mocked()
            PrismText.mocked()
            PrismVStack.mocked()
        }
    }
}

#Preview {
    PrismLazyList.mocked()
}
