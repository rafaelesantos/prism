//
//  PrismPrimaryButton.swift
//  Prism
//
//  Created by Rafael Escaleira on 29/06/25.
//

import PrismFoundation
import SwiftUI

/// Primary button for the PrismUI Design System.
///
/// `PrismPrimaryButton` is the prominent button for primary actions:
/// - Glass prominent style (glass effect with depth)
/// - Theme primary color (or error for destructive role)
/// - Large size (.large) with capsule border
/// - Full accessibility support (VoiceOver/TalkBack)
/// - UI testing (XCUITest) via stable testIDs
///
/// ## Basic Usage
/// ```swift
/// PrismPrimaryButton("Sign In") {
///     // Login action
/// }
/// ```
///
/// ## With testID for Testing
/// ```swift
/// PrismPrimaryButton(
///     "Confirm Purchase",
///     testID: "confirm_purchase_button"
/// ) {
///     // Process purchase
/// }
/// ```
///
/// ## With Destructive Role
/// ```swift
/// PrismPrimaryButton(
///     "Delete Account",
///     role: .destructive
/// ) {
///     // Delete user account
/// }
/// ```
///
/// ## With Localized String
/// ```swift
/// PrismPrimaryButton(.prismPreviewTitle) {
///     // Action
/// }
/// ```
///
/// ## Available Roles
/// - `.none` - Default primary color
/// - `.destructive` - Error color (red)
/// - `.cancel` - Primary color (for cancel actions)
///
/// - Note: The button automatically uses `.glassProminent` buttonStyle and `.capsule` borderShape.
/// - Important: Use for the primary action on screens (CTA - Call to Action).
public struct PrismPrimaryButton: PrismView {
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
                variant: .primary,
                role: role
            )
        )
    }

    public static func mocked() -> some View {
        PrismPrimaryButton(
            .prismPreviewTitle,
            role: .cancel
        ) {
        }
        .prism(font: .body)
    }
}

#Preview {
    PrismPrimaryButton.mocked().prismPadding()
}
