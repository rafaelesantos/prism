//
//  PrismZStack.swift
//  Prism
//
//  Created by Rafael Escaleira on 08/06/25.
//

import SwiftUI

/// Layered container (z-axis) for the PrismUI Design System.
///
/// `PrismZStack` is a wrapper around the native `ZStack` with:
/// - Depth stacking of views (Z axis)
/// - Configurable alignment
/// - Full accessibility support (VoiceOver/TalkBack)
/// - UI testing (XCUITest) via stable testIDs
///
/// ## Basic Usage
/// ```swift
/// PrismZStack {
///     PrismShape(.rectangle)
///         .prism(background: .secondary)
///     PrismText("Overlay")
/// }
/// ```
///
/// ## With testID for Testing
/// ```swift
/// PrismZStack(
///     alignment: .topLeading,
///     testID: "card_overlay"
/// ) {
///     BackgroundImage()
///     OverlayContent()
/// }
/// ```
///
/// ## Available Alignments
/// - `.topLeading`, `.top`, `.topTrailing`
/// - `.leading`, `.center`, `.trailing`
/// - `.bottomLeading`, `.bottom`, `.bottomTrailing`
///
/// - Note: Views are stacked in declaration order (first view at the back).
public struct PrismZStack: PrismView {
    let alignment: Alignment
    let content: any View

    public var accessibility: PrismAccessibilityProperties?

    public init(
        _ accessibility: PrismAccessibilityProperties? = nil,
        alignment: Alignment = .center,
        @ViewBuilder content: () -> some View
    ) {
        self.accessibility = accessibility
        self.alignment = alignment
        self.content = content()
    }

    public init(
        alignment: Alignment = .center,
        testID: String,
        @ViewBuilder content: () -> some View
    ) {
        self.accessibility = PrismAccessibility.custom(label: "", testID: testID)
        self.alignment = alignment
        self.content = content()
    }

    public var body: some View {
        ZStack(alignment: alignment) {
            AnyView(content)
        }
        .prism(accessibility)
    }

    public static func mocked() -> some View {
        PrismZStack {
            PrismSymbol.mocked()
        }
    }
}

#Preview {
    PrismZStack.mocked()
}
