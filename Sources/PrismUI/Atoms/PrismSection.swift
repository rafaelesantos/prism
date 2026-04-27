//
//  PrismSection.swift
//  Prism
//
//  Created by Rafael Escaleira on 06/06/25.
//

import PrismFoundation
import SwiftUI

/// List section for the PrismUI Design System.
///
/// `PrismSection` is a wrapper around the native `Section` with:
/// - Optional header and footer
/// - Localized string support via `PrismResourceString`
/// - Automatic uppercase header for list styling
/// - Full accessibility support (VoiceOver/TalkBack)
/// - UI testing (XCUITest) via stable testIDs
///
/// ## Basic Usage
/// ```swift
/// PrismSection {
///     PrismBodyText("Section content")
/// }
/// ```
///
/// ## With Header and Footer
/// ```swift
/// PrismSection(
///     header: PrismUIString.sectionTitle,
///     footer: PrismUIString.sectionDescription
/// ) {
///     PrismBodyText("Content")
/// }
/// ```
///
/// ## With Custom Header
/// ```swift
/// PrismSection {
///     PrismBodyText("Content")
/// } header: {
///     PrismText("Title")
///         .prism(font: .headline)
/// }
/// ```
///
/// ## With testID for Testing
/// ```swift
/// PrismSection(testID: "settings_section") {
///     PrismBodyText("Settings")
/// }
/// ```
///
/// - Note: The automatic header uses `.footnote` font and `.textSecondary` color in uppercase.
public struct PrismSection: PrismView {
    let header: any View
    let content: any View
    let footer: any View
    public var accessibility: PrismAccessibilityProperties?

    public init(
        _ accessibility: PrismAccessibilityProperties? = nil,
        @ViewBuilder header: () -> some View,
        @ViewBuilder content: () -> some View,
        @ViewBuilder footer: () -> some View
    ) {
        self.accessibility = accessibility
        self.header = header()
        self.content = content()
        self.footer = footer()
    }

    public init(@ViewBuilder content: () -> some View) {
        self.content = content()
        self.header = EmptyView()
        self.footer = EmptyView()
    }

    public init(
        @ViewBuilder content: () -> some View,
        @ViewBuilder header: () -> some View
    ) {
        self.content = content()
        self.header = header()
        self.footer = EmptyView()
    }

    public init(
        @ViewBuilder content: () -> some View,
        @ViewBuilder footer: () -> some View
    ) {
        self.content = content()
        self.header = EmptyView()
        self.footer = footer()
    }

    public init(
        header: PrismResourceString? = nil,
        footer: PrismResourceString? = nil,
        @ViewBuilder content: () -> some View
    ) {
        self.content = content()
        self.header =
            header == nil
            ? EmptyView()
            : PrismText(header?.value.uppercased())
                .prism(font: .footnote)
                .prism(color: .textSecondary)

        self.footer =
            footer == nil
            ? EmptyView()
            : PrismText(footer)
                .prism(font: .footnote)
                .prism(color: .textSecondary)
    }

    public init(
        testID: String,
        @ViewBuilder content: () -> some View
    ) {
        self.accessibility = PrismAccessibility.custom(label: "", testID: testID)
        self.content = content()
        self.header = EmptyView()
        self.footer = EmptyView()
    }

    public var body: some View {
        Section {
            AnyView(content)
        } header: {
            AnyView(header)
        } footer: {
            AnyView(footer)
        }
    }

    public static func mocked() -> some View {
        PrismSection(
            header: PrismUIString.prismPreviewTitle,
            footer: PrismUIString.prismPreviewDescription
        ) {
            PrismBodyText.mocked()
            PrismHStack.mocked()
            PrismFootnoteText.mocked()
        }
    }
}

#Preview {
    PrismSection.mocked()
}
