//
//  PrismHStack.swift
//  Prism
//
//  Created by Rafael Escaleira on 26/04/25.
//

import SwiftUI

/// Horizontal layout container for the PrismUI Design System.
///
/// `PrismHStack` is a wrapper around the native `HStack` with:
/// - Semantic spacing via `PrismSpacing`
/// - Accessibility support (VoiceOver/TalkBack)
/// - UI testing (XCUITest) via stable testIDs
/// - Integration with the Prism theming system
///
/// ## Basic Usage
/// ```swift
/// PrismHStack {
///     PrismSymbol("star")
///     PrismText("Rating")
/// }
/// ```
///
/// ## With Custom Spacing
/// ```swift
/// PrismHStack(spacing: .small) {
///     PrismAvatar()
///     PrismVStack {
///         PrismText("Name")
///         PrismText("Title")
///     }
/// }
/// ```
///
/// ## With testID for Testing
/// ```swift
/// PrismHStack(
///     alignment: .center,
///     spacing: .medium,
///     testID: "user_info_row"
/// ) {
///     PrismSymbol("person.circle")
///     PrismText("Profile", testID: "profile_label")
/// }
/// ```
///
/// ## Available Alignments
/// - `.top`, `.center`, `.bottom`, `.firstTextBaseline`, `.lastTextBaseline`
///
/// - Note: Spacing uses the theme token system for visual consistency.
public struct PrismHStack: PrismView {
    @Environment(\.theme) private var theme

    let alignment: VerticalAlignment
    let spacing: PrismSpacing?
    let content: any View

    public var accessibility: PrismAccessibilityProperties?

    public init(
        _ accessibility: PrismAccessibilityProperties? = nil,
        alignment: VerticalAlignment = .center,
        spacing: PrismSpacing? = nil,
        @ViewBuilder content: () -> some View
    ) {
        self.accessibility = accessibility
        self.alignment = alignment
        self.spacing = spacing
        self.content = content()
    }

    public init(
        alignment: VerticalAlignment = .center,
        spacing: PrismSpacing? = nil,
        testID: String,
        @ViewBuilder content: () -> some View
    ) {
        self.accessibility = PrismAccessibility.custom(label: "", testID: testID)
        self.alignment = alignment
        self.spacing = spacing
        self.content = content()
    }

    public var body: some View {
        HStack(
            alignment: alignment,
            spacing: spacing?.rawValue(for: theme.spacing)
        ) {
            AnyView(content)
        }
        .prism(accessibility)
    }

    public static func mocked() -> some View {
        PrismHStack(
            alignment: .center,
            spacing: .medium
        ) {
            PrismSymbol.mocked()
                .prismPadding()
            PrismVStack.mocked()
        }
    }
}

#Preview {
    PrismHStack.mocked()
}
