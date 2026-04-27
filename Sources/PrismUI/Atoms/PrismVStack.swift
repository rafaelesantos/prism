//
//  PrismVStack.swift
//  Prism
//
//  Created by Rafael Escaleira on 26/04/25.
//

import SwiftUI

/// Vertical layout container for the PrismUI Design System.
///
/// `PrismVStack` is a wrapper around the native `VStack` with:
/// - Semantic spacing via `PrismSpacing`
/// - Accessibility support (VoiceOver/TalkBack)
/// - UI testing (XCUITest) via stable testIDs
/// - Integration with the Prism theming system
///
/// ## Basic Usage
/// ```swift
/// PrismVStack {
///     PrismText("Title")
///     PrismText("Description")
/// }
/// ```
///
/// ## With Custom Spacing
/// ```swift
/// PrismVStack(spacing: .large) {
///     PrismText("Title")
///     PrismText("Description")
/// }
/// ```
///
/// ## With testID for Testing
/// ```swift
/// PrismVStack(
///     alignment: .leading,
///     spacing: .medium,
///     testID: "login_form"
/// ) {
///     PrismTextField(text: $email, configuration: .email)
///     PrismPrimaryButton("Sign In", testID: "login_button") { }
/// }
/// ```
///
/// ## Available Alignments
/// - `.leading`, `.center`, `.trailing`
///
/// - Note: Spacing uses the theme token system for visual consistency.
public struct PrismVStack: PrismView {
    @Environment(\.theme) private var theme

    let alignment: HorizontalAlignment
    let spacing: PrismSpacing?
    let content: any View

    public var accessibility: PrismAccessibilityProperties?

    public init(
        _ accessibility: PrismAccessibilityProperties? = nil,
        alignment: HorizontalAlignment = .center,
        spacing: PrismSpacing? = nil,
        @ViewBuilder content: () -> some View
    ) {
        self.accessibility = accessibility
        self.alignment = alignment
        self.spacing = spacing
        self.content = content()
    }

    public init(
        alignment: HorizontalAlignment = .center,
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
        VStack(
            alignment: alignment,
            spacing: spacing?.rawValue(for: theme.spacing)
        ) {
            AnyView(content)
        }
        .prism(accessibility)
    }

    public static func mocked() -> some View {
        PrismVStack(alignment: .leading) {
            PrismBodyText.mocked()
            PrismFootnoteText.mocked()
        }
        .prism(width: .max)
    }
}

#Preview {
    PrismVStack.mocked()
}
