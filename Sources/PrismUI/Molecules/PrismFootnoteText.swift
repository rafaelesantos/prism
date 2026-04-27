//
//  PrismFootnoteText.swift
//  Prism
//
//  Created by Rafael Escaleira on 03/07/25.
//

import PrismFoundation
import SwiftUI

/// Footnote text component for the PrismUI Design System.
///
/// `PrismFootnoteText` is a pre-styled text component for secondary content:
/// - Footnote font (smaller than body)
/// - Automatic secondary text color
/// - Full accessibility support (VoiceOver/TalkBack)
/// - UI testing (XCUITest) via stable testIDs
///
/// ## Basic Usage
/// ```swift
/// PrismFootnoteText("Additional information or secondary description.")
/// ```
///
/// ## With testID for Testing
/// ```swift
/// PrismFootnoteText(
///     "Last updated: today",
///     testID: "last_update_label"
/// )
/// ```
///
/// ## With Localized String
/// ```swift
/// PrismFootnoteText(PrismUIString.prismPreviewDescription)
/// ```
///
/// - Note: This component automatically uses `.footnote` font and `.textSecondary` color from the theme.
/// - Important: Ideal for captions, auxiliary descriptions, and metadata.
public struct PrismFootnoteText: PrismView {
    let content: PrismTextContent?
    public var accessibility: PrismAccessibilityProperties?

    public init(
        _ localized: PrismResourceString?,
        _ accessibility: PrismAccessibilityProperties? = nil,
    ) {
        self.content = PrismTextContent(localized?.value)
        self.accessibility = accessibility
    }

    public init(
        _ text: String?,
        _ accessibility: PrismAccessibilityProperties? = nil,
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
        let textView = PrismText(
            content: content,
            accessibility: nil
        )
        .prism(font: .footnote)
        .prism(color: .textSecondary)

        if let accessibility {
            textView.prism(accessibility: accessibility)
        } else {
            textView
        }
    }

    public static func mocked() -> some View {
        PrismFootnoteText(PrismUIString.prismPreviewDescription)
    }
}

#Preview {
    PrismFootnoteText.mocked().prismPadding()
}
