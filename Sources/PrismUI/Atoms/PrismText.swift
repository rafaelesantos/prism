//
//  PrismText.swift
//  Prism
//
//  Created by Rafael Escaleira on 19/04/25.
//

import PrismFoundation
import SwiftUI

/// Text component for the PrismUI Design System.
///
/// `PrismText` is the fundamental component for displaying text, with support for:
/// - Loading states (automatic skeleton)
/// - Accessibility (VoiceOver/TalkBack)
/// - UI testing (XCUITest) via stable testIDs
/// - Internationalization via `LocalizedStringKey`
///
/// ## Basic Usage
/// ```swift
/// PrismText("Hello World")
/// ```
///
/// ## With testID
/// ```swift
/// PrismText("Welcome", testID: "welcome_text")
/// ```
///
/// ## As Header
/// ```swift
/// PrismText("Title", testID: "main_header", isHeader: true)
/// ```
///
/// ## Loading State
/// ```swift
/// PrismText("Loading...")
///     .prism(loading: true)  // Displays skeleton
/// ```
///
/// - Note: When `isLoading` is active, the text automatically displays a skeleton.
public struct PrismText: PrismView {
    @Environment(\.isLoading) private var isLoading

    let content: PrismTextContent?
    public var accessibility: PrismAccessibilityProperties?

    // MARK: - Initialization

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
        _ accessibility: PrismAccessibilityProperties? = nil,
    ) {
        self.content = PrismTextContent(text)
        self.accessibility = accessibility
    }

    /// Quick initializer with accessibility builder.
    public init(
        _ text: String?,
        accessibility: (PrismAccessibilityConfig) -> PrismAccessibilityConfig
    ) {
        self.content = PrismTextContent(text)
        self.accessibility = accessibility(PrismAccessibilityConfig()).build()
    }

    /// Initializer with static convenience.
    public init(
        _ text: LocalizedStringKey,
        testID: String,
        isHeader: Bool = false
    ) {
        self.content = PrismTextContent(text)
        self.accessibility = PrismAccessibility.text(text, testID: testID, isHeader: isHeader)
    }

    init(
        content: PrismTextContent?,
        accessibility: PrismAccessibilityProperties? = nil
    ) {
        self.content = content
        self.accessibility = accessibility
    }

    // MARK: - Body

    @ViewBuilder
    public var body: some View {
        let view = Group {
            if isLoading {
                if let content {
                    content.view()
                        .prismSkeleton()
                } else {
                    Text(verbatim: .prismPreviewDescription)
                        .prismSkeleton()
                }
            } else if let content {
                content.view()
            }
        }

        if let accessibility {
            view.prism(accessibility: accessibility)
        } else {
            view
        }
    }

    // MARK: - Mock

    public static func mocked() -> some View {
        PrismText(.prismPreviewDescription)
    }
}

// MARK: - Previews

#Preview("Default") {
    PrismText.mocked()
        .prismPadding()
}

#Preview("With Accessibility") {
    PrismText("Hello World", testID: "hello_text")
        .prismPadding()
}

#Preview("As Header") {
    PrismText("Welcome", testID: "welcome_header", isHeader: true)
        .prismPadding()
}
