//
//  PrismLabel.swift
//  Prism
//
//  Created by Rafael Escaleira on 04/07/25.
//

import PrismFoundation
import SwiftUI

/// Label with icon and text for the PrismUI Design System.
///
/// `PrismLabel` is a wrapper around the native `Label` with:
/// - Integrated SF Symbols icon
/// - Loading state support (automatic skeleton)
/// - Full accessibility support (VoiceOver/TalkBack)
/// - UI testing (XCUITest) via stable testIDs
///
/// ## Basic Usage
/// ```swift
/// PrismLabel("Settings", symbol: "gear")
/// ```
///
/// ## With testID for Testing
/// ```swift
/// PrismLabel(
///     "Notifications",
///     testID: "notifications_label",
///     symbol: "bell"
/// )
/// ```
///
/// ## With Loading State
/// ```swift
/// @State var isLoading = true
/// PrismLabel("Status", symbol: "checkmark")
///     .prism(loading: isLoading)  // Displays skeleton
/// ```
///
/// ## With Localized String
/// ```swift
/// PrismLabel(PrismUIString.prismPreviewTitle, symbol: "star")
/// ```
///
/// - Note: When `isLoading` is active, the label automatically displays a skeleton.
public struct PrismLabel: PrismView {
    @Environment(\.isLoading) private var isLoading

    let content: PrismTextContent?
    let symbol: String

    public var accessibility: PrismAccessibilityProperties?

    public init(
        _ text: String?,
        _ accessibility: PrismAccessibilityProperties? = nil,
        symbol: String,
    ) {
        self.content = PrismTextContent(text)
        self.accessibility = accessibility
        self.symbol = symbol
    }

    public init(
        _ localized: PrismResourceString?,
        _ accessibility: PrismAccessibilityProperties? = nil,
        symbol: String,
    ) {
        self.content = PrismTextContent(localized?.value)
        self.accessibility = accessibility
        self.symbol = symbol
    }

    public init(
        _ text: LocalizedStringKey,
        testID: String,
        symbol: String,
    ) {
        self.content = PrismTextContent(text)
        self.accessibility = PrismAccessibility.custom(label: text, testID: testID)
        self.symbol = symbol
    }

    private var placeholderText: String {
        .prismPreviewDescription
    }

    public var body: some View {
        if isLoading {
            let loadingView = labelView(content ?? .string(placeholderText))
                .prismSkeleton()

            if let accessibility {
                loadingView.prism(accessibility: accessibility)
            } else {
                loadingView
            }
        } else if let content {
            let label = labelView(content)

            if let accessibility {
                label.prism(accessibility: accessibility)
            } else {
                label
            }
        }
    }

    @ViewBuilder
    private func labelView(_ content: PrismTextContent) -> some View {
        Label {
            content.view()
        } icon: {
            Image(systemName: symbol)
        }
    }

    public static func mocked() -> some View {
        PrismLabel(
            PrismUIString.prismPreviewTitle,
            symbol: "bolt.fill"
        )
    }
}

#Preview {
    PrismLabel.mocked().prismPadding()
}
