//
//  PrismSecondaryButton.swift
//  Prism
//
//  Created by Rafael Escaleira on 02/07/25.
//

import PrismFoundation
import SwiftUI

/// Secondary button for the PrismUI Design System.
///
/// `PrismSecondaryButton` is the button for secondary actions:
/// - Bordered style (border with semi-transparent background)
/// - Theme primary color (or error for destructive role)
/// - Large size (.large) with capsule border
/// - Interactive regular glass effect
/// - Full accessibility support (VoiceOver/TalkBack)
/// - UI testing (XCUITest) via stable testIDs
///
/// ## Basic Usage
/// ```swift
/// PrismSecondaryButton("Cancel") {
///     // Cancel action
/// }
/// ```
///
/// ## With testID for Testing
/// ```swift
/// PrismSecondaryButton(
///     "Go Back",
///     testID: "back_button"
/// ) {
///     // Navigate to previous screen
/// }
/// ```
///
/// ## With Destructive Role
/// ```swift
/// PrismSecondaryButton(
///     "Discard Changes",
///     role: .destructive
/// ) {
///     // Discard changes
/// }
/// ```
///
/// ## With Localized String
/// ```swift
/// PrismSecondaryButton(.prismPreviewTitle) {
///     // Secondary action
/// }
/// ```
///
/// ## Available Roles
/// - `.none` - Default primary color
/// - `.destructive` - Error color (red)
/// - `.cancel` - Primary color (for cancel actions)
///
/// - Note: The button automatically uses `.bordered` buttonStyle with `.glassEffect(.regular.interactive())`.
/// - Important: Use for secondary actions that are not the main focus of the screen.
public struct PrismSecondaryButton: PrismView {
    let content: PrismTextContent?
    let role: ButtonRole?
    let action: () -> Void

    public var accessibility: PrismAccessibilityProperties?

    public init(
        _ text: String?,
        _ accessibility: PrismAccessibilityProperties? = nil,
        role: ButtonRole? = nil,
        action: @escaping () -> Void
    ) {
        self.content = PrismTextContent(text)
        self.accessibility = accessibility
        self.role = role
        self.action = action
    }

    public init(
        _ localized: PrismResourceString?,
        _ accessibility: PrismAccessibilityProperties? = nil,
        role: ButtonRole? = nil,
        action: @escaping () -> Void
    ) {
        self.content = PrismTextContent(localized?.value)
        self.accessibility = accessibility
        self.role = role
        self.action = action
    }

    public init(
        _ text: LocalizedStringKey,
        testID: String,
        role: ButtonRole? = nil,
        action: @escaping () -> Void
    ) {
        self.content = PrismTextContent(text)
        self.accessibility = PrismAccessibility.button(text, testID: testID)
        self.role = role
        self.action = action
    }

    public var body: some View {
        PrismButton(accessibility, role: role, action: action) {
            PrismText(content: content)
        }
        .buttonStyle(
            PrismButtonChromeStyle(
                variant: .secondary,
                role: role
            )
        )
    }

    public static func mocked() -> some View {
        PrismSecondaryButton(
            .prismPreviewTitle,
            role: .cancel
        ) {

        }
        .prism(font: .body)
    }
}

#Preview {
    PrismSecondaryButton.mocked().prismPadding()
}
