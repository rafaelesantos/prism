//
//  PrismBodyText.swift
//  Prism
//
//  Created by Rafael Escaleira on 03/07/25.
//

import PrismFoundation
import SwiftUI

/// Body text component for the PrismUI Design System.
///
/// `PrismBodyText` is a pre-styled text component for body content:
/// - Body font (system default size and weight)
/// - Automatic primary text color
/// - Full accessibility support (VoiceOver/TalkBack)
/// - UI testing (XCUITest) via stable testIDs
///
/// ## Basic Usage
/// ```swift
/// PrismBodyText("This is the main text content.")
/// ```
///
/// ## With testID for Testing
/// ```swift
/// PrismBodyText(
///     "Product description",
///     testID: "product_description"
/// )
/// ```
///
/// ## With Localized String
/// ```swift
/// PrismBodyText(PrismUIString.prismPreviewDescription)
/// ```
///
/// - Note: This component automatically uses `.body` font and `.text` color from the theme.
/// - Important: For secondary text, use `PrismFootnoteText`.
public struct PrismBodyText: PrismView {
    let content: PrismTextContent?
    public var accessibility: PrismAccessibilityProperties?

    public init(
        _ localized: PrismResourceString?,
        _ accessibility: PrismAccessibilityProperties? = nil
    ) {
        self.content = PrismTextContent(localized?.value)
        self.accessibility = accessibility
    }

    public init(
        _ text: String?,
        _ accessibility: PrismAccessibilityProperties? = nil
    ) {
        self.content = PrismTextContent(text)
        self.accessibility = accessibility
    }

    public init(
        _ text: LocalizedStringKey,
        testID: String
    ) {
        self.content = PrismTextContent(text)
        self.accessibility = PrismAccessibility.text(text, testID: testID)
    }

    public var body: some View {
        PrismText(
            content: content,
            accessibility: accessibility
        )
        .prism(font: .body)
        .prism(color: .text)
    }

    public static func mocked() -> some View {
        PrismBodyText(PrismUIString.prismPreviewDescription)
    }
}

#Preview {
    PrismBodyText.mocked().prismPadding()
}
